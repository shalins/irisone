//
//  CardMap.swift
//  Iris
//
//  Created by Shalin Shah on 1/13/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation
import Mapbox

enum CardMapType {
  case heatmap
  case route
}

protocol CardMapDelegate: class {
    func calloutViewTapped(mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation)
    func doneLoading(mapView: MGLMapView, didFinishLoading style: MGLStyle)
}

class CardMap: NSObject, MGLMapViewDelegate {
    
    weak var delegate: CardMapDelegate?
    var geoJSONURL: String?
    var mapType: CardMapType?
    
    var destination: CLLocationCoordinate2D?

    func imageForAnnotation(annotation: MGLAnnotation) -> UIImage {
        var image = UIImage()
        if let subtitle = annotation.subtitle {
            switch subtitle! {
            case "moderate":
                image = #imageLiteral(resourceName: "medium_crime")
            case "low":
                image = #imageLiteral(resourceName: "low_crime")
            case "severe":
                image = #imageLiteral(resourceName: "high_crime")
            case "destination":
                image = #imageLiteral(resourceName: "destination")
            case "spot":
                image = #imageLiteral(resourceName: "spot")
            default:
                // for things like bus stops
                image = #imageLiteral(resourceName: "annotation")
            }
        }
        return image
    }
        
    // create a reuse identifier string by concatenating the annotation coordinate, title, subtitle
    func reuseIdentifierForAnnotation(annotation: MGLAnnotation) -> String {
        var reuseIdentifier = "\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)"
        if let title = annotation.title {
            reuseIdentifier += title!
        }
        return reuseIdentifier
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard let castAnnotation = annotation as? IrisAnnnotation else { return nil }
        if (castAnnotation.type == .image) { return nil }
        
        let reuseIdentifier = reuseIdentifierForAnnotation(annotation: annotation)
        print(reuseIdentifier)
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            if (castAnnotation.type == .textbox) {
                annotationView = TextBoxAnnotationView(reuseIdentifier: reuseIdentifier)
                let width = (castAnnotation.richLabel["text"] ?? "none").width(withConstrainedHeight: 20, font: UIFont(name: "NunitoSans-SemiBold", size: 12) ?? UIFont())
                //castAnnotation.richLabel["text"]
                annotationView!.bounds = CGRect(x: 0, y: 0, width: width + 10, height: 30)
                (annotationView as! TextBoxAnnotationView).label.text = castAnnotation.richLabel["text"] ?? "none"
            } else {
                annotationView = WarningAnnotationView(reuseIdentifier: reuseIdentifier)
                annotationView!.bounds = CGRect(x: 0, y: 0, width: 70, height: 48)
                (annotationView as! WarningAnnotationView).smallLabel.text = castAnnotation.richLabel["text"]
            }
        }
         
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        guard let castAnnotation = annotation as? IrisAnnnotation else { return nil }
        if (castAnnotation.type != .image) { return nil }

        let reuseIdentifier = reuseIdentifierForAnnotation(annotation: annotation)
        print(reuseIdentifier)
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier)

        if annotationImage == nil {
            var image = imageForAnnotation(annotation: annotation)

            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: reuseIdentifier)
        }
        return annotationImage
    }

    func convertMetersToMiles(metric: Double) -> Double {
        let miles = metric * 0.000621371192
        return round(100.0 * miles) / 100.0
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        if (self.mapType == .route) { return false }
        return true
    }
    
    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
        delegate?.calloutViewTapped(mapView: mapView, calloutViewFor: annotation)

        return MapCalloutView(representedObject: annotation)
    }
     
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        // Optionally handle taps on the callout.
        print("Tapped the callout for: \(annotation)")
        
        // Hide the callout.
        mapView.deselectAnnotation(annotation, animated: true)
    }
    
    func removeAllAnnotations(mapView: MGLMapView, annotations: [MGLAnnotation]?) {
        guard let annotations = annotations else { return print("Annotations Error") }
        if annotations.count != 0 {
            for annotation in annotations {
                mapView.removeAnnotation(annotation)
            }
        } else {
            return
        }
        
        guard let style = mapView.style else { return }
        if let styleLayer = style.layer(withIdentifier: "polyline-dash") {
            style.removeLayer(styleLayer)
        }
        if let source = style.source(withIdentifier: "polyline") {
            style.removeSource(source)
        }
        if let styleLayer = style.layer(withIdentifier: "heatmap") {
            style.removeLayer(styleLayer)
        }
        if let source = style.source(withIdentifier: "heatmap") {
            style.removeSource(source)
        }
    }
    
    func adjustCamera(mapView: MGLMapView) {
        let bounds = MGLCoordinateBounds(
            sw: CLLocationCoordinate2D(latitude: UserLocation.latitude, longitude: UserLocation.longitude),
            ne: self.destination ?? CLLocationCoordinate2D())
        let insets = UIEdgeInsets(top: 80.0, left: 80.0, bottom: 150.0, right: 80.0)
        mapView.setVisibleCoordinateBounds(bounds, edgePadding: insets, animated: true)
        let camera = mapView.camera(mapView.camera, fitting: bounds, edgePadding: insets)
        mapView.setCamera(camera, withDuration: 1.0, animationTimingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear))
    }
    
    func drawPolyline(mapView: MGLMapView) {
        guard let style = mapView.style else { return }
        guard let jsonURL = geoJSONURL else { return }
        let url = URL(string: jsonURL)
        
        self.adjustCamera(mapView: mapView)
        
        do {
            // Convert the file contents to a shape collection feature object
            let data = try Data(contentsOf: url!)

            guard let shapeFromGeoJSON = try? MGLShape(data: data, encoding: String.Encoding.utf8.rawValue) as? MGLShapeCollectionFeature  else {
                fatalError("Could not generate MGLShape")
            }
            
            if let styleLayer = style.layer(withIdentifier: "polyline-dash") {
                style.removeLayer(styleLayer)
            }
            if let source = style.source(withIdentifier: "polyline") {
                style.removeSource(source)
            }

            let source = MGLShapeSource(identifier: "polyline", shape: shapeFromGeoJSON, options: nil)
            style.addSource(source)
            let dashedLayer = MGLLineStyleLayer(identifier: "polyline-dash", source: source)
            dashedLayer.predicate = NSPredicate(format: "name = 'walk'")
            dashedLayer.lineJoin = NSExpression(forConstantValue: "round")
            dashedLayer.lineCap = NSExpression(forConstantValue: "round")
            dashedLayer.lineColor = NSExpression(forConstantValue: UIColor.white)
            dashedLayer.lineOpacity = NSExpression(forConstantValue: 1.0)
            dashedLayer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [14: 4, 18: 4])
            dashedLayer.lineDashPattern = NSExpression(forConstantValue: [0.5, 1.5])
            style.addLayer(dashedLayer)
            
            for shape in shapeFromGeoJSON.shapes {
                if let polyline = shape as? MGLPolylineFeature {
                    polyline.title = polyline.attributes["name"] as? String
                    
                    if (polyline.title != "walk") {
                        DispatchQueue.main.async {
                            mapView.addAnnotation(polyline)
                        }
                    }
                }
            }
        } catch {
            print("GeoJSON parsing failed")
        }
    }
    
    func drawHeatmap(mapView: MGLMapView, style: MGLStyle) {
        guard let jsonURL = geoJSONURL else { return }
        guard let url = URL(string: jsonURL) else { return }
        
        self.adjustCamera(mapView: mapView)

        if let styleLayer = style.layer(withIdentifier: "heatmap") {
            style.removeLayer(styleLayer)
        }
        if let source = style.source(withIdentifier: "heatmap") {
            style.removeSource(source)
        }
                
        let source = MGLShapeSource(identifier: "heatmap", url: url, options: nil)
        style.addSource(source)

        // Create a heatmap layer.
        let heatmapLayer = MGLHeatmapStyleLayer(identifier: "heatmap", source: source)

        // Adjust the color of the heatmap based on the point density.

        let colorDictionary: [NSNumber: UIColor] = [
            0.0: .clear,
            0.03: UIColor(red: 188.0/255, green: 63.0/255, blue: 188.0/255, alpha: 1.0),
            0.20: UIColor(red: 220.0/255, green: 61.0/255, blue: 152.0/255, alpha: 1.0),
            0.45: UIColor(red: 249.0/255, green: 59.0/255, blue: 118.0/255, alpha: 1.0),
            0.9: UIColor(red: 180/255, green: 40/255, blue: 84/255, alpha: 1.0),
            1.5: UIColor(red: 129/255, green: 27/255, blue: 59/255, alpha: 1.0),
            3: UIColor(red: 88/255, green: 18/255, blue: 40/255, alpha: 1.0)
        ]
        heatmapLayer.heatmapColor = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($heatmapDensity, 'linear', nil, %@)", colorDictionary)

        // Heatmap weight measures how much a single data point impacts the layer's appearance.
        heatmapLayer.heatmapWeight = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:(severity, 'linear', nil, %@)",
        [0: 0,
        6: 1])

        // Heatmap intensity multiplies the heatmap weight based on zoom level.
        heatmapLayer.heatmapIntensity = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
        [0: 1,
        9: 3])

        heatmapLayer.heatmapRadius = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
        [0: 1,
        9: 30])

        // The heatmap layer should be visible up to zoom level 9.
        heatmapLayer.heatmapOpacity = NSExpression(format: "mgl_step:from:stops:($zoomLevel, 0.75, %@)", [1: 0.0, 3: 0.05, 5: 0.1, 9: 0.15, 12:0.2, 15:0.4, 17:0.5, 20:0.3])
        style.addLayer(heatmapLayer)
    }


     
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 1
    }
     
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 8.0
    }
    
     
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        if (annotation.title == "busride" && annotation is MGLPolyline) {
            return UIColor.white
        } else if (annotation.title == "warning" && annotation is MGLPolyline) {
            return UIColor.systemPink
        } else {
            return UIColor.red
        }
    }
         
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1)
    }
    
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        if (self.geoJSONURL == "none") { return }

        DispatchQueue.main.async {
            self.delegate?.doneLoading(mapView: mapView, didFinishLoading: style)
        }
    }
}

class WalkTimeAnnotationView: MGLAnnotationView {
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = 6
        backgroundColor = UIColor.black
        
        bigLabel.frame = CGRect(x: 5, y: self.frame.height/2 - 13, width: 40, height: 26)
        smallLabel.frame = CGRect(x: 45, y: self.frame.height/2 - 20, width: 30, height: 40)
        addSubview(bigLabel)
        addSubview(smallLabel)
    }
    
    var bigLabel: UILabel = {
        let bigLabel = UILabel()
        bigLabel.translatesAutoresizingMaskIntoConstraints = false
        bigLabel.font = UIFont(name: "NunitoSans-SemiBold", size: 26)!
        bigLabel.textColor = .white
        bigLabel.numberOfLines = 1
        bigLabel.textAlignment = .left
        return bigLabel
    }()
    
    var smallLabel: UILabel = {
        let smallLabel = UILabel()
        smallLabel.translatesAutoresizingMaskIntoConstraints = false
        smallLabel.font = UIFont(name: "NunitoSans-SemiBold", size: 12)!
        smallLabel.textColor = .white
        smallLabel.numberOfLines = 2
        smallLabel.textAlignment = .left
        return smallLabel
    }()
}

class TextBoxAnnotationView: MGLAnnotationView {
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = 6
        backgroundColor = UIColor.black
        
        label.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        addSubview(label)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 10
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    var label: UILabel = {
        let smallLabel = UILabel()
        smallLabel.translatesAutoresizingMaskIntoConstraints = false
        smallLabel.font = UIFont(name: "NunitoSans-SemiBold", size: 12)!
        smallLabel.textColor = .white
        smallLabel.numberOfLines = 2
        smallLabel.textAlignment = .center
        smallLabel.layer.shouldRasterize = true
        smallLabel.layer.rasterizationScale = UIScreen.main.scale
        return smallLabel
    }()
}


class WarningAnnotationView: MGLAnnotationView {
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = 6
        backgroundColor = UIColor.systemPink
        
        smallLabel.frame = CGRect(x: 5, y: self.frame.height/2 - 20, width: 70, height: 40)
        addSubview(smallLabel)
    }
    
    var smallLabel: UILabel = {
        let smallLabel = UILabel()
        smallLabel.translatesAutoresizingMaskIntoConstraints = false
        smallLabel.font = UIFont(name: "NunitoSans-SemiBold", size: 12)!
        smallLabel.textColor = .white
        smallLabel.numberOfLines = 2
        smallLabel.textAlignment = .left
        return smallLabel
    }()
}

class IrisAnnnotation: MGLPointAnnotation {
    var type: AnnotationType!
    var richLabel: [String: String] = ["text" : "none", "icon" : "none", "image" : "none", "url" : "none"]
    var richSmallLabelOne: [String: String] = ["text" : "none", "icon" : "none", "image" : "none", "url" : "none"]
    
    func setMetadata(richLabel: [String: String]) {
        self.title = richLabel["text"]
        self.subtitle = richLabel["icon"]
        if (self.subtitle == "low" || self.subtitle == "moderate" || self.subtitle == "severe" || self.subtitle == "destination" || self.subtitle == "spot") {
            self.type = .image
        } else if (self.subtitle == "warning") {
            self.type = .warning
        } else {
            self.type = .textbox
        }
    }
}

enum AnnotationType {
  case image
  case textbox
  case warning
}

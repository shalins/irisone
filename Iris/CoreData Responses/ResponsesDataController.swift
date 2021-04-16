//
//  ResponsesDataController.swift
//  Iris
//
//  Created by Shalin Shah on 1/26/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation
import CoreData
import FirebaseFirestore
import SwiftyJSON

extension DataController {

    func createNewResponse(fromResponse responses: Responses?) throws -> Response? {
        let response = Response(context: self.context)
        response.responseID = responses?.responseID
        response.alerts = responses?.alerts
        response.sentence = responses?.sentence
        response.sentenceFormat = responses?.sentenceFormat
        response.responseURL = responses?.responseURL
        response.responseURLType = responses?.responseURLType

        self.context.insert(response)
        try self.context.save()
        
        return response
    }
    
    func addResponseToCard(card: Card, response: Response) throws {
        card.setValue(response, forKey: "response")
        try self.context.save()
    }
    
    func deleteResponseFromCard(response: Response) throws {
        self.context.delete(response)
        try self.context.save()
    }

    
    func getResponse(fromCard card: Card?) throws -> Response? {
        
        let request = NSFetchRequest<Response>(entityName: "Response")
        request.predicate = NSPredicate(format: "ANY %K =[cd] %@", #keyPath(Response.card.cardID), card?.cardID ?? "")
        
        let response = try self.context.fetch(request)
        
        return response.first
    }
    
    func getResponse(fromCardID cardID: String) throws -> Response? {
        
        let request = NSFetchRequest<Response>(entityName: "Response")
        request.predicate = NSPredicate(format: "ANY %K =[cd] %@", #keyPath(Response.card.cardID), cardID)
        
        let response = try self.context.fetch(request)
        
        return response.first
    }

    func updateResponseSentence(response: Response, sentence: [String]) throws {
        response.setValue(sentence, forKey: "sentence")
        try self.context.save()
    }



    func createNewDetail(fromDetails details: Details?) throws -> Detail? {
        let detail = Detail(context: self.context)
        
        detail.detailID = details?.detailID
        detail.richLabel = details?.richLabel
        detail.richSmallLabelOne = details?.richSmallLabelOne
        detail.richSmallLabelTwo = details?.richSmallLabelTwo
        detail.lat = details?.lat ?? 0.0
        detail.lon = details?.lon ?? 0.0
        detail.order = detail.order ?? 0.0

        self.context.insert(detail)
        try self.context.save()
        
        return detail
    }

    func addDetailToResponse(response: Response, detail: Detail) throws {
        response.addToDetails(detail)
        try self.context.save()
    }
    
    
    func getDetails(fromResponse responseID: String) throws -> [Detail]? {
        
        let request = NSFetchRequest<Detail>(entityName: "Detail")
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        request.predicate = NSPredicate(format: "ANY %K =[cd] %@", #keyPath(Detail.response.responseID), responseID)
        
        let details = try self.context.fetch(request)
        
        return details
    }

    
    func createNewSubdetail(fromSubdetails subdetails: Subdetails?) throws -> Subdetail? {
        let subdetail = Subdetail(context: self.context)
        
        subdetail.timestamp = subdetails?.timestamp ?? 0.0
        subdetail.order = subdetails?.order ?? 0.0
        subdetail.richLabel = subdetails?.richLabel
        subdetail.richSublabel = subdetails?.richSublabel
        subdetail.richDescription = subdetails?.richDescription
        subdetail.richSmallLabelOne = subdetails?.richSmallLabelOne
        subdetail.richSmallLabelTwo = subdetails?.richSmallLabelTwo
        subdetail.richMetric = subdetails?.richMetric
        subdetail.richMetricUnits = subdetails?.richMetricUnits
        subdetail.richMetricTwo = subdetails?.richMetricTwo
        subdetail.richMetricUnitsTwo = subdetails?.richMetricUnitsTwo
        subdetail.subdetailID = subdetails?.subdetailID
        subdetail.selected = false

        self.context.insert(subdetail)
        try self.context.save()
        
        return subdetail
    }
    
    func addSubdetailToDetail(detail: Detail, subdetail: Subdetail) throws {
        detail.addToSubdetails(subdetail)
        try self.context.save()
    }
    
    func updateSubdetailSelected(subdetail: Subdetail, selected: Bool) throws {
        subdetail.setValue(selected, forKey: "selected")
        try self.context.save()
    }
    
    func getSubdetails(fromDetailID detailID: String) throws -> [Subdetail]? {
        let request = NSFetchRequest<Subdetail>(entityName: "Subdetail")
        
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        request.predicate = NSPredicate(format: "ANY %K =[cd] %@", #keyPath(Subdetail.detail.detailID), detailID)
        
        let subdetails = try self.context.fetch(request)
        
        return subdetails
    }
    
    
    
    
    
    
    
    func installDataFromJSON(cardID: String, responseJSON: JSON, newResponse: @escaping (Response?) -> Void) {
        let currentCard = try? DataController.shared.getCard(fromID: cardID)
        
        let response = responseJSON["response"]
        
        let responseObject = Responses(responseIDString: response["response_id"].string, alertsArray: response["alerts"].arrayValue.map {$0.stringValue}, sentenceFormatArray: response["sentence_format"].arrayValue.map {$0.stringValue}, sentenceArray: response["sentence"].arrayValue.map {$0.stringValue}, responseURLString: response["response_url"].string, responseURLTypeString: response["response_url_type"].string)

        let localResponse = try? DataController.shared.createNewResponse(fromResponse: responseObject)
        try? DataController.shared.deleteResponseFromCard(response: currentCard?.response ?? Response(context: DataController.shared.context))
        try? DataController.shared.addResponseToCard(card: currentCard!, response: localResponse!)
        
        let myGroup = DispatchGroup()

        for (_, detailJSON) : (String, JSON) in response["details"] {
           // Do something you want
            myGroup.enter()
            let detailObject = Details(detailIDString: detailJSON["detail_id"].string, richLabelString: detailJSON["label"].dictionaryValue.mapValues { $0.stringValue }, richSmallLabelOneString: detailJSON["small_label_one"].dictionaryValue.mapValues { $0.stringValue }, richSmallLabelTwoString: detailJSON["small_label_two"].dictionaryValue.mapValues { $0.stringValue }, latNum: detailJSON["lat"].double, lonNum: detailJSON["lon"].double, orderNum: detailJSON["order"].double)

            let localDetails = try? DataController.shared.createNewDetail(fromDetails: detailObject)
            try? DataController.shared.addDetailToResponse(response: localResponse!, detail: localDetails!)

            for (_, subdetailJSON) : (String, JSON) in detailJSON["subdetails"] {
               // Do something you want
                myGroup.enter()
                let subdetail = Subdetails(timestampNum: subdetailJSON["timestamp"].double, richLabelArray: subdetailJSON["label"].dictionaryValue.mapValues { $0.stringValue }, richSublabelArray: subdetailJSON["sublabel"].dictionaryValue.mapValues { $0.stringValue }, richDescriptionArray: subdetailJSON["description"].dictionaryValue.mapValues { $0.stringValue }, richSmallLabelOneArray: subdetailJSON["small_label_one"].dictionaryValue.mapValues { $0.stringValue }, richSmallLabelTwoArray: subdetailJSON["small_label_two"].dictionaryValue.mapValues { $0.stringValue }, richMetricArray: subdetailJSON["metric"].dictionaryValue.mapValues { $0.stringValue }, richMetricUnitsArray: subdetailJSON["metric_units"].dictionaryValue.mapValues { $0.stringValue }, richMetricTwoArray: subdetailJSON["metric_two"].dictionaryValue.mapValues { $0.stringValue }, richMetricUnitsTwoArray: subdetailJSON["metric_units_two"].dictionaryValue.mapValues { $0.stringValue }, subdetailIDString: subdetailJSON["subdetail_id"].string, orderNum: subdetailJSON["order"].double)

                let localSubdetails = try? DataController.shared.createNewSubdetail(fromSubdetails: subdetail)
                try? DataController.shared.addSubdetailToDetail(detail: localDetails!, subdetail: localSubdetails!)

                myGroup.leave()
            }
            myGroup.leave()
        }
        
        myGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                print("Installed the Card's Response Data")
                newResponse(localResponse)
            }
        }
    }
}

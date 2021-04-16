//
//  ServiceViewController.swift
//  Iris
//
//  Created by Shalin Shah on 1/7/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit

enum ServiceType {
    case about
    case privacy
    case terms
}

class ServiceViewController: UIViewController {

    @IBOutlet weak var policyText: UITextView! {
        didSet {
            self.policyText.layer.shouldRasterize = true
            self.policyText.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    @IBOutlet weak var policyTitle: UILabel! {
        didSet {
            self.policyText.layer.shouldRasterize = true
            self.policyText.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    var mode: ServiceType!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fillTextView()

        self.view.layer.shouldRasterize = true
        self.view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func fillTextView() {
        if (self.mode == .privacy) {
            self.policyTitle.text = "Privacy Policy"
            self.policyText.text = """
                -- Last Updated: February 4, 2020 --

                Thank you for choosing to be part of our community at Iris (“Company”, “we”, “us”, or “our”). We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about our notice, or our practices with regards to your personal information, please contact us at irissuggestions@gmail.com.

                When you visit our mobile application, and use our services, you trust us with your personal information. We take your privacy very seriously. In this privacy notice, we seek to explain to you in the clearest way possible what information we collect, how we use it and what rights you have in relation to it. We hope you take some time to read through it carefully, as it is important. If there are any terms in this privacy notice that you do not agree with, please discontinue use of our Apps and our services.

                This privacy notice applies to all information collected through our mobile application, ("Apps"), and/or any related services, sales, marketing or events (we refer to them collectively in this privacy notice as the "Services").

                Please read this privacy notice carefully as it will help you make informed decisions about sharing your personal information with us.



                TABLE OF CONTENTS

                1. WHAT INFORMATION DO WE COLLECT?

                2. WILL YOUR INFORMATION BE SHARED WITH ANYONE?

                3. HOW LONG DO WE KEEP YOUR INFORMATION?

                4. HOW DO WE KEEP YOUR INFORMATION SAFE?

                5. DO WE COLLECT INFORMATION FROM MINORS?

                6. WHAT ARE YOUR PRIVACY RIGHTS?

                7. CONTROLS FOR DO-NOT-TRACK FEATURES

                8. DO CALIFORNIA RESIDENTS HAVE SPECIFIC PRIVACY RIGHTS?

                9. DO WE MAKE UPDATES TO THIS POLICY?

                10. HOW CAN YOU CONTACT US ABOUT THIS POLICY?



                1. WHAT INFORMATION DO WE COLLECT?


                Information automatically collected

                In Short:   Some information — such as IP address and/or browser and device characteristics — is collected automatically when you visit our Apps.

                We automatically collect certain information when you visit, use or navigate the Apps. This information does not reveal your specific identity (like your name or contact information) but may include device and usage information, such as your IP address, browser and device characteristics, operating system, language preferences, referring URLs, device name, country, location, information about how and when you use our Apps and other technical information. This information is primarily needed to maintain the security and operation of our Apps, and for our internal analytics and reporting purposes.


                Information collected through our Apps

                In Short:   We may collect information regarding your geo-location, when you use our apps.

                If you use our Apps, we may also collect the following information:
                Geo-Location Information. We may request access or permission to and track location-based information from your mobile device, either continuously or while you are using our mobile application, to provide location-based services. If you wish to change our access or permissions, you may do so in your device's settings.



                2. WILL YOUR INFORMATION BE SHARED WITH ANYONE?

                In Short:  We only share information with your consent, to comply with laws, to provide you with services, to protect your rights, or to fulfill business obligations.

                We may process or share data based on the following legal basis:
                Consent: We may process your data if you have given us specific consent to use your personal information in a specific purpose.

                Legitimate Interests: We may process your data when it is reasonably necessary to achieve our legitimate business interests.

                Performance of a Contract: Where we have entered into a contract with you, we may process your personal information to fulfill the terms of our contract.

                Legal Obligations: We may disclose your information where we are legally required to do so in order to comply with applicable law, governmental requests, a judicial proceeding, court order, or legal process, such as in response to a court order or a subpoena (including in response to public authorities to meet national security or law enforcement requirements).

                Vital Interests: We may disclose your information where we believe it is necessary to investigate, prevent, or take action regarding potential violations of our policies, suspected fraud, situations involving potential threats to the safety of any person and illegal activities, or as evidence in litigation in which we are involved.
                More specifically, we may need to process your data or share your personal information in the following situations:

                Vendors, Consultants and Other Third-Party Service Providers. We may share your data with third party vendors, service providers, contractors or agents who perform services for us or on our behalf and require access to such information to do that work. Examples include: payment processing, data analysis, email delivery, hosting services, customer service and marketing efforts. We may allow selected third parties to use tracking technology on the Apps, which will enable them to collect data about how you interact with the Apps over time. This information may be used to, among other things, analyze and track data, determine the popularity of certain content and better understand online activity. Unless described in this Policy, we do not share, sell, rent or trade any of your information with third parties for their promotional purposes.

                Business Transfers. We may share or transfer your information in connection with, or during negotiations of, any merger, sale of company assets, financing, or acquisition of all or a portion of our business to another company.

                Third-Party Advertisers. We may use third-party advertising companies to serve ads when you visit the Apps. These companies may use information about your visits to our Website(s) and other websites that are contained in web cookies and other tracking technologies in order to provide advertisements about goods and services of interest to you.


                3. HOW LONG DO WE KEEP YOUR INFORMATION?

                In Short:  We keep your information for as long as necessary to fulfill the purposes outlined in this privacy notice unless otherwise required by law.

                We will only keep your personal information for as long as it is necessary for the purposes set out in this privacy notice, unless a longer retention period is required or permitted by law (such as tax, accounting or other legal requirements). No purpose in this policy will require us keeping your personal information for longer than the period of time in which users have an account with us.

                When we have no ongoing legitimate business need to process your personal information, we will either delete or anonymize it, or, if this is not possible (for example, because your personal information has been stored in backup archives), then we will securely store your personal information and isolate it from any further processing until deletion is possible.


                4. HOW DO WE KEEP YOUR INFORMATION SAFE?

                In Short:  We aim to protect your personal information through a system of organizational and technical security measures.

                We have implemented appropriate technical and organizational security measures designed to protect the security of any personal information we process. However, please also remember that we cannot guarantee that the internet itself is 100% secure. Although we will do our best to protect your personal information, transmission of personal information to and from our Apps is at your own risk. You should only access the services within a secure environment.



                5. DO WE COLLECT INFORMATION FROM MINORS?

                In Short:  We do not knowingly collect data from or market to children under 18 years of age.

                We do not knowingly solicit data from or market to children under 18 years of age. By using the Apps, you represent that you are at least 18 or that you are the parent or guardian of such a minor and consent to such minor dependent’s use of the Apps. If we learn that personal information from users less than 18 years of age has been collected, we will deactivate the account and take reasonable measures to promptly delete such data from our records. If you become aware of any data we have collected from children under age 18, please contact us at __________.



                6. WHAT ARE YOUR PRIVACY RIGHTS?

                In Short:  You may review, change, or terminate your account at any time.

                If you are resident in the European Economic Area and you believe we are unlawfully processing your personal information, you also have the right to complain to your local data protection supervisory authority. You can find their contact details here: http://ec.europa.eu/justice/data-protection/bodies/authorities/index_en.htm.

                If you have questions or comments about your privacy rights, you may email us at irissuggestions@gmail.com.


                Account Information
                If you would at any time like to review or change the information in your account or terminate your account, you can:

                    ■  Log into your account settings and update your user account.

                Upon your request to terminate your account, we will deactivate or delete your account and information from our active databases. However, some information may be retained in our files to prevent fraud, troubleshoot problems, assist with any investigations, enforce our Terms of Use and/or comply with legal requirements.

                Opting out of email marketing: You can unsubscribe from our marketing email list at any time by clicking on the unsubscribe link in the emails that we send or by contacting us using the details provided below. You will then be removed from the marketing email list – however, we will still need to send you service-related emails that are necessary for the administration and use of your account. To otherwise opt-out, you may:



                7. CONTROLS FOR DO-NOT-TRACK FEATURES

                Most web browsers and some mobile operating systems and mobile applications include a Do-Not-Track (“DNT”) feature or setting you can activate to signal your privacy preference not to have data about your online browsing activities monitored and collected. No uniform technology standard for recognizing and implementing DNT signals has been finalized. As such, we do not currently respond to DNT browser signals or any other mechanism that automatically communicates your choice not to be tracked online. If a standard for online tracking is adopted that we must follow in the future, we will inform you about that practice in a revised version of this privacy notice.



                8. DO CALIFORNIA RESIDENTS HAVE SPECIFIC PRIVACY RIGHTS?

                In Short:  Yes, if you are a resident of California, you are granted specific rights regarding access to your personal information.

                California Civil Code Section 1798.83, also known as the “Shine The Light” law, permits our users who are California residents to request and obtain from us, once a year and free of charge, information about categories of personal information (if any) we disclosed to third parties for direct marketing purposes and the names and addresses of all third parties with which we shared personal information in the immediately preceding calendar year. If you are a California resident and would like to make such a request, please submit your request in writing to us using the contact information provided below.

                If you are under 18 years of age, reside in California, and have a registered account with the Apps, you have the right to request removal of unwanted data that you publicly post on the Apps. To request removal of such data, please contact us using the contact information provided below, and include the email address associated with your account and a statement that you reside in California. We will make sure the data is not publicly displayed on the Apps, but please be aware that the data may not be completely or comprehensively removed from our systems.



                9. DO WE MAKE UPDATES TO THIS POLICY?

                In Short:  Yes, we will update this policy as necessary to stay compliant with relevant laws.

                We may update this privacy notice from time to time. The updated version will be indicated by an updated “Revised” date and the updated version will be effective as soon as it is accessible. If we make material changes to this privacy notice, we may notify you either by prominently posting a notice of such changes or by directly sending you a notification. We encourage you to review this privacy notice frequently to be informed of how we are protecting your information.



                10. HOW CAN YOU CONTACT US ABOUT THIS POLICY?

                If you have questions or comments about this policy, you may email us at __________ or by post to:

                Iris
                __________
                Berkeley, CA 94704
                United States

                HOW CAN YOU REVIEW, UPDATE, OR DELETE THE DATA WE COLLECT FROM YOU?
                Based on the laws of some countries, you may have the right to request access to the personal information we collect from you, change that information, or delete it in some circumstances. To request to review, update, or delete your personal information, please submit a request form by clicking here. We will respond to your request within 30 days.
                """
        } else if (self.mode == .terms) {
            self.policyTitle.text = "Terms of Service"
            self.policyText.text = """

            -- Last Updated: September 1st, 2020 --
            
            These terms of service ("Terms") apply to your access and use of Iris (the "Service"). Please read them carefully.
            
            -- Accepting these Terms
            If you access or use the Service, it means you agree to be bound by all of the terms below. So, before you use the Service, please read all of the terms. If you don't agree to all of the terms below, please do not use the Service. Also, if a term does not make sense to you, please let us know by e-mailing irissuggestions@gmail.com.
            
            -- Changes to these Terms
            We reserve the right to modify these Terms at any time. For instance, we may need to change these Terms if we come out with a new feature or for some other reason.
            
            Whenever we make changes to these Terms, the changes are effective immediately after we post such revised Terms (indicated by revising the date at the top of these Terms) or upon your acceptance if we provide a mechanism for your immediate acceptance of the revised Terms (such as a click-through confirmation or acceptance button). It is your responsibility to check Iris for changes to these Terms.
            
            If you continue to use the Service after the revised Terms go into effect, then you have accepted the changes to these Terms.
            
            -- Privacy Policy
            For information about how we collect and use information about users of the Service, please check out our privacy policy available from the settings page of Iris.
            
            -- Third-Party Services
            From time to time, we may provide you with links to third party websites or services that we do not own or control. Your use of the Service may also include the use of applications that are developed or owned by a third party. Your use of such third party applications, websites, and services is governed by that party's own terms of service or privacy policies. We encourage you to read the terms and conditions and privacy policy of any third party application, website or service that you visit or use.
            
            -- Creating Accounts
            When you create an account or use another service to log in to the Service, you agree to maintain the security of your password and accept all risks of unauthorized access to any data or other information you provide to the Service.
            
            If you discover or suspect any Service security breaches, please let us know as soon as possible.
            
            -- Your Content & Conduct
            
            Our Service allows you and other users to post, link and otherwise make available content. You are responsible for the content that you make available to the Service, including its legality, reliability, and appropriateness.
            
            When you post, link or otherwise make available content to the Service, you grant us the right and license to use, reproduce, modify, publicly perform, publicly display and distribute your content on or through the Service. We may format your content for display throughout the Service, but we will not edit or revise the substance of your content itself.
            
            Aside from our limited right to your content, you retain all of your rights to the content you post, link and otherwise make available on or through the Service.
            
            
            You can remove the content that you posted by deleting it. Once you delete your content, it will not appear on the Service, but copies of your deleted content may remain in our system or backups for some period of time. We will retain web server access logs for a maximum of 1 hour and then delete them.
            
            You may not post, link and otherwise make available on or through the Service any of the following:
            
            
            - Content that is libelous, defamatory, bigoted, fraudulent or deceptive;
            - Content that is illegal or unlawful, that would otherwise create liability;
            - Content that may infringe or violate any patent, trademark, trade secret, copyright, right of privacy, right of publicity or other intellectual or other right of any party;
            - Mass or repeated promotions, political campaigning or commercial messages directed at users who do not follow you (SPAM);
            - Private information of any third party (e.g., addresses, phone numbers, email addresses, Social Security numbers and credit card numbers); and
            - Viruses, corrupted data or other harmful, disruptive or destructive files or code.
            - Also, you agree that you will not do any of the following in connection with the Service or other users:
            
            -- Use the Service in any manner that could interfere with, disrupt, negatively affect or inhibit other users from fully enjoying the Service or that could damage, disable, overburden or impair the functioning of the Service;
            -- Impersonate or post on behalf of any person or entity or otherwise misrepresent your affiliation with a person or entity;
            -- Collect any personal information about other users, or intimidate, threaten, stalk or otherwise harass other users of the Service;
            -- Create an account or post any content if you are not over 13 years of age years of age; and
            -- Circumvent or attempt to circumvent any filtering, security measures, rate limits or other features designed to protect the Service, users of the Service, or third parties.
            
            We have adopted a policy of terminating, in appropriate circumstances and, at our sole discretion, access to the service for users who are deemed to have violated the above policies.
            
            -- Iris Materials --
            We put a lot of effort into creating the Service including, the logo and all designs, text, graphics, pictures, information and other content (excluding your content). This property is owned by us or our licensors and it is protected by U.S. and international copyright laws. We grant you the right to use it.
            
            However, unless we expressly state otherwise, your rights do not include: (i) publicly performing or publicly displaying the Service; (ii) modifying or otherwise making any derivative uses of the Service or any portion thereof; (iii) using any data mining, robots or similar data gathering or extraction methods; (iv) downloading (other than page caching) of any portion of the Service or any information contained therein; (v) reverse engineering or accessing the Service in order to build a competitive product or service; or (vi) using the Service other than for its intended purposes. If you do any of this stuff, we may terminate your use of the Service.
            
            -- Hyperlinks and Third Party Content --
            You may create a hyperlink to the Service. But, you may not use, frame or utilize framing techniques to enclose any of our trademarks, logos or other proprietary information without our express written consent.
            
            Iris makes no claim or representation regarding, and accepts no responsibility for third party websites accessible by hyperlink from the Service or websites linking to the Service. When you leave the Service, you should be aware that these Terms and our policies no longer govern.
            
            If there is any content on the Service from you and others, we don't review, verify or authenticate it, and it may include inaccuracies or false information. We make no representations, warranties, or guarantees relating to the quality, suitability, truth, accuracy or completeness of any content contained in the Service. You acknowledge sole responsibility for and assume all risk arising from your use of or reliance on any content.
            
            -- Unavoidable Legal Stuff --
            THE SERVICE AND ANY OTHER SERVICE AND CONTENT INCLUDED ON OR OTHERWISE MADE AVAILABLE TO YOU THROUGH THE SERVICE ARE PROVIDED TO YOU ON AN AS IS OR AS AVAILABLE BASIS WITHOUT ANY REPRESENTATIONS OR WARRANTIES OF ANY KIND. WE DISCLAIM ANY AND ALL WARRANTIES AND REPRESENTATIONS (EXPRESS OR IMPLIED, ORAL OR WRITTEN) WITH RESPECT TO THE SERVICE AND CONTENT INCLUDED ON OR OTHERWISE MADE AVAILABLE TO YOU THROUGH THE SERVICE WHETHER ALLEGED TO ARISE BY OPERATION OF LAW, BY REASON OF CUSTOM OR USAGE IN THE TRADE, BY COURSE OF DEALING OR OTHERWISE.
            
            IN NO EVENT WILL IRIS BE LIABLE TO YOU OR ANY THIRD PARTY FOR ANY SPECIAL, INDIRECT, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY KIND ARISING OUT OF OR IN CONNECTION WITH THE SERVICE OR ANY OTHER SERVICE AND/OR CONTENT INCLUDED ON OR OTHERWISE MADE AVAILABLE TO YOU THROUGH THE SERVICE, REGARDLESS OF THE FORM OF ACTION, WHETHER IN CONTRACT, TORT, STRICT LIABILITY OR OTHERWISE, EVEN IF WE HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES OR ARE AWARE OF THE POSSIBILITY OF SUCH DAMAGES. OUR TOTAL LIABILITY FOR ALL CAUSES OF ACTION AND UNDER ALL THEORIES OF LIABILITY WILL BE LIMITED TO THE AMOUNT YOU PAID TO IRIS. THIS SECTION WILL BE GIVEN FULL EFFECT EVEN IF ANY REMEDY SPECIFIED IN THIS AGREEMENT IS DEEMED TO HAVE FAILED OF ITS ESSENTIAL PURPOSE.
            
            You agree to defend, indemnify and hold us harmless from and against any and all costs, damages, liabilities, and expenses (including attorneys' fees, costs, penalties, interest and disbursements) we incur in relation to, arising from, or for the purpose of avoiding, any claim or demand from a third party relating to your use of the Service or the use of the Service by any person using your account, including any claim that your use of the Service violates any applicable law or regulation, or the rights of any third party, and/or your violation of these Terms.
            
            -- Copyright Complaints --
            
            We take intellectual property rights seriously. In accordance with the Digital Millennium Copyright Act ("DMCA") and other applicable law, we have adopted a policy of terminating, in appropriate circumstances and, at our sole discretion, access to the service for users who are deemed to be repeat infringers.
            
            -- Governing Law --
            
            The validity of these Terms and the rights, obligations, and relations of the parties under these Terms will be construed and determined under and in accordance with the laws of the California, without regard to conflicts of law principles.
            
            -- Jurisdiction --
            You expressly agree that exclusive jurisdiction for any dispute with the Service or relating to your use of it, resides in the courts of the California and you further agree and expressly consent to the exercise of personal jurisdiction in the courts of the California located in Berkeley in connection with any such dispute including any claim involving Service. You further agree that you and Service will not commence against the other a class action, class arbitration or other representative action or proceeding.
            
            -- Termination --
            If you breach any of these Terms, we have the right to suspend or disable your access to or use of the Service.
            
            -- Entire Agreement --
            These Terms constitute the entire agreement between you and Iris regarding the use of the Service, superseding any prior agreements between you and Iris relating to your use of the Service.
            
            -- Feedback --
            Please let us know what you think of the Service, these Terms and, in general, Iris. When you provide us with any feedback, comments or suggestions about the Service, these Terms and, in general, Iris, you irrevocably assign to us all of your right, title and interest in and to your feedback, comments and suggestions.
            
            -- Questions & Contact Information --
            Questions or comments about the Service may be directed to us at the email address irissuggestions@gmail.com.
            """
        } else if (self.mode == .about) {
            self.policyTitle.text = "About the Team"
            self.policyText.text = """
            Iris was created by Kanyes Thaker, Sam Gorman, and Shalin Shah. We are a team of undergrads at Berkeley and Stanford who wanted to create something awesome. Thank you for using our product, it means the world to us.
            """
            
        }
    }
}

//
//  NotificationCellTableViewCell.swift
//  WABOOKS_iOS_V2
//
//  Created by MacBook on 5/17/21.
//

import UIKit
import Foundation
import SDWebImage


class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var bgView       : UIView!
    @IBOutlet weak var lblTitle     : UILabel!
    @IBOutlet weak var lblDescr     : UILabel!
    @IBOutlet weak var logoImgView  : UIImageView!
    @IBOutlet weak var pointView    : UIView!
    @IBOutlet weak var imageStatus  : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.lblTitle.getlocalizedFont()
        self.lblDescr.getlocalizedFont()
    }
    
    func formatTitle(boldText:String,normalText:String) -> NSMutableAttributedString?{
        let boldText  = boldText
        let normalText = normalText
        
        let attributedString = normalText.parseHTMLForTextView()
        
        
        let originalFont        =  UIFont(name: "Inter-Bold", size: 15.0)
        let attrs = [NSAttributedString.Key.font : originalFont]
        var boldString : NSMutableAttributedString? = NSMutableAttributedString(string: boldText, attributes:attrs as [NSAttributedString.Key : Any])
        
        
        boldString?.append(attributedString!)
        return boldString
    }
    
    func configCell(item: WABOOKS_MREC_R010.RESPONSE.REC, unReadNoti: Bool) {
        
        let boldTitle = " " + "\(mapDVCD(DV_CD:  item.DV_CD ?? "", SN_NM: item.SND_NM ?? "" , CONT: item.CONT ?? "").0)"
        let normaltitle = "\(mapDVCD(DV_CD:  item.DV_CD ?? "", SN_NM: item.SND_NM ?? "" , CONT: item.CONT ?? "").2)"
        let normaltitles = "\(mapDVCD(DV_CD:  item.DV_CD ?? "", SN_NM: item.SND_NM ?? "" , CONT: item.SND_DATE ?? "").2)"
        
        if item.DV_CD == "1" || item.DV_CD == "5" {
            self.lblTitle.attributedText  =  self.formatTitle(boldText: boldTitle, normalText:"\n\(normaltitle)")
        }else if item.DV_CD == "2" || item.DV_CD == "3" || item.DV_CD == "4" {
            self.lblTitle.attributedText  =  self.formatTitle(boldText: boldTitle, normalText:"\n\(normaltitles)")
            
        }else if item.DV_CD == "7" || item.DV_CD == "8" {
            self.lblTitle.attributedText = self.formatTitle(boldText: (item.SND_NM ?? "") + " ", normalText:"\(normaltitle)")
        }
        else {
            self.lblTitle.attributedText = self.formatTitle(boldText: (item.SND_NM ?? "") + " ", normalText:"  \(normaltitle)")
            
        }
        self.lblTitle.lineBreakMode = .byTruncatingTail
        self.lblTitle.numberOfLines = 2
        self.lblTitle.setLineSpacing(lineSpacing:4)
        
        let Time = calDateformatTime((item.SND_DATE ?? "")+(item.SND_TIME ?? "") )
        self.lblDescr.text       = Time
        let getImageName = getImageName(DV_CD: item.DV_CD ?? "")
        let getImageStatus = getImageStatus(DV_CD: item.DV_CD ?? "")
        
        if getImageName == "" {
            //Use server image
            self.setImage(SND_IMG_URL: item.SND_IMG_URL ?? "",SND_ID: item.SND_ID ?? "")
            self.imageStatus.isHidden = false
            self.imageStatus.image           = UIImage(named: "\(getImageStatus)")
        }else {
            //Use local image
            self.logoImgView.image           = UIImage(named: "\(getImageName)")
            self.imageStatus.isHidden        = true
        }
        
        self.pointView.backgroundColor   = UIColor.white
        
        if unReadNoti { //new
            self.bgView.backgroundColor      = UIColor(resource: .notificationBg)
        } else {
            self.bgView.backgroundColor      = .white
        }
    }
    func setImage(SND_IMG_URL: String,SND_ID : String) {
        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
        let split_url       = SND_IMG_URL.components(separatedBy: "?")
        let img_url         = "\(split_url.first ??  "")?token=\(authorization)&\(split_url.last ?? "")" + "&\(SND_ID)"
        let url             = URL(string: "\(img_url)")
        
        self.logoImgView.sd_setImage(with: url,  completed: { (image, error, SDImageCacheType , url) in
            if error == nil {
                self.logoImgView.clipsToBounds = true
                self.logoImgView.contentMode = .scaleAspectFill
                self.logoImgView.layer.cornerRadius =  min(self.logoImgView.frame.size.width, self.logoImgView.frame.size.height) / 2
                self.logoImgView.image  = image
            } else {
                self.logoImgView.layer.cornerRadius =  min(self.logoImgView.frame.size.width, self.logoImgView.frame.size.height) / 2
                self.logoImgView.image  = UIImage(named: "head_employee_ico") 
            }
        })
    }
    
    func isRead(item: WABOOKS_MREC_R010.RESPONSE.REC) {
        self.logoImgView.image           = UIImage(named: "\(getImageName(DV_CD: item.DV_CD ?? ""))off")
    }
    
    func getImageName(DV_CD: String) -> String {
        switch DV_CD {
        case "1": return "Contact"
        case "2": return "Payroll"
        case "3": return "Deposit"
        case "4": return "Widthrawal"
        case "5": return "Daily Cash Report"
        default: return ""
        }
    }
    
    func getImageStatus(DV_CD: String) -> String {
        switch DV_CD {
        case "6": return "expense _approve_request_ico"
        case "7","8","13","14" : return "approve_request_ico"
        case "9","10": return "Reject"
        case "11": return "simple_approve_ico"
        case "12": return "article_post_ico"
        case "15": return "cmt_ico"
        default: return ""
        }
    }
    
    /// Mapping DV_CD will returns 3 value type, action, localized content
    /// - Parameters:
    ///   - DV_CD  : checking notification type 1: Contact, 3: Deposit, 4: Expense, 5: Report
    ///   - CONT    : content
    /// - Returns  : 1. type of notification, 2. web action, 3. localized content
    func mapDVCD(DV_CD: String, SN_NM: String, CONT: String) -> (String, String, String) {
        switch DV_CD {
        case "1":
            // CONT arrives as "KM|EN"; WeCMS has no Khmer, so always use the EN half.
            let cont        = CONT.components(separatedBy: "|")
            let contactNo   = cont.count == 1 ? "" : cont.last ?? ""
            let titleStr    = "status_of_000".localized
            return ("contact".localized + " ", "mobl_0010_002.act", String(format: titleStr, contactNo)) //거래처
        case "2":
            let date        = formatteDate(dateStr: CONT)
            let titleStr    = "status_of_000".localized
            //return ("급여명세", "", "") //not used
            return ("Payroll", "szon_0004_008.act", String(format: titleStr, date))
        case "3":
            let date        = formatteDate(dateStr: CONT)
            let titleStr    = "status_of_000_3_deposit".localized
            //let titleStr = "there_are_new_deposit_transactions".localized
            return ("deposit".localized + " ", "szon_0004_008.act", String(format: titleStr, date)) //입금
        case "4":
            let date        = formatteDate(dateStr: CONT)
            let titleStr    = "status_of_000_4_withdrawal".localized
            //let titleStr = "there_are_new_withdrawal_transactions".localized
            return ("withdrawal".localized + " ", "szon_0004_009.act", String(format: titleStr, date)) //Expense/Withdrawal/출금
        case "5":
            let date        = formatteDate(dateStr: CONT)//CONT.formatDate(format: toFormatStr, fromFormat: "yyyyMMdd")//CONT
            let titleStr    = "status_of_000".localized
            return ("report".localized + " ", "szon_0004_010.act", String(format: titleStr, date)) //보고서
        case "6":
            let titleStr    = "request_an_expense_approval_000".localized
            
//            [{\"AMT\":\"1.000000\",\"CCY_CD\":\"KHR\"}]
             let formattedCurrency = formatCurrencyFromJSON(jsonString: CONT) ?? ""
            
            return (SN_NM, "", String(format: titleStr, formattedCurrency))
        case "7":
            let titleStr    = "approved_your_expense_approval_request_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "8":
            let titleStr    = "approved_your_expense_approval_request_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "9":
            let titleStr    = "reject_your_expense_approval_request_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "10":
            let titleStr    = "reject_your_expense_approval_request_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "11":
            let titleStr    = "request_an_approval_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "12":
            let titleStr    = "posted_an_article_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "13":
            let titleStr    = "approved_your_approval_request_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "14":
            let titleStr    = "approved_your_approval_request_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "15":
            // Remove "@[" and "]"
            let modifiedString = CONT.replacingOccurrences(of: "\\@\\[|\\]", with: "", options: .regularExpression)
            let lastModifiedString = extractNames(inputString: modifiedString)
            let titleStr    = "commented_on_your_post_000".localized
            let titleString    = "commented on your post with attachment.".localized
            if CONT == "" {
                return (SN_NM, "", String(format: titleString, lastModifiedString))
            }else{
                return (SN_NM, "", String(format: titleStr, lastModifiedString))
            }
//        case "16":
//            let titleStr    = "commented_on_your_post_000".localized
//            // Remove "@[" and "]"
//            let modifiedString = CONT.replacingOccurrences(of: "\\@\\[|\\]", with: "", options: .regularExpression)
//            return (SN_NM, "", String(format: titleStr, modifiedString))
        default : return ("", "", "")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }


    func formatCurrencyFromJSON(jsonString: String) -> String? {
        // Extracting the JSON string from the given input
        guard let jsonSubstringRange = jsonString.range(of: "\\[{.*?}\\]", options: .regularExpression) else {
            #if DEBUG
            print("Invalid JSON format")
            #endif
            return nil
        }

        let jsonSubstring = jsonString[jsonSubstringRange]

        // Convert the substring to a String
        let extractedJSON = String(jsonSubstring)

        // Decoding the JSON data
        if let jsonData = extractedJSON.data(using: .utf8),
           let jsonArray = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: String]],
           let firstItem = jsonArray.first,
           let amountString = firstItem["AMT"],
           let currencyCode = firstItem["CCY_CD"]{
//           let amount = Double(amountString) {
            let str = customFormatCurrency(CCY_CD: currencyCode, amount: amountString)
            print("\(amountString) JAJ \(str)")
            // Formatting the values
            let formattedString = "\(currencyCode) \(str)"
            return formattedString
        } else {
            print("Invalid JSON format")
            return nil
        }
    }
    
    // a @[Hello 2024](06auguset@testing.com) @[Sokny Ran (Yakuza)](soknyran.dev@gmail.com) b @[E-Youvita](vita@gmail.com)
    func extractNames(inputString: String) -> String {
        var modifiedString = inputString

        // Remove occurrences of (email)
        modifiedString = modifiedString.replacingOccurrences(of: "\\([^\\)]+\\)", with: "", options: .regularExpression)

        // Remove occurrences of @[...] and extract names
        let regexPattern = "\\@\\[([^\\]]*)\\]"

        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: [])
            let range = NSRange(location: 0, length: modifiedString.utf16.count)

            var extractedNames = [String]()

            regex.enumerateMatches(in: modifiedString, options: [], range: range) { (match, _, _) in
                if let matchRange = match?.range(at: 1) {
                    if let range = Range(matchRange, in: modifiedString) {
                        extractedNames.append(String(modifiedString[range]))
                    }
                }
            }

            // Replace occurrences of @[...] with extracted names
            for name in extractedNames {
                modifiedString = modifiedString.replacingOccurrences(of: "@[\(name)]", with: name)
            }

            return modifiedString.trimmingCharacters(in: .whitespaces)
        } catch {
            print("Error creating regex: \(error)")
            return modifiedString
        }
    }






    
}

// ME : TWICE :3

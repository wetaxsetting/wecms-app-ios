//
//  ApproverCell.swift
//  WeCMS_iOS
//
//  Created by Kimlang on 31/1/24.
//

import UIKit

class ApproverCell: UICollectionViewCell {

    @IBOutlet weak var statusIcon   : UIImageView!
    @IBOutlet weak var profileIcon  : UIImageView!
    @IBOutlet weak var dateLabel    : UILabel!
    @IBOutlet weak var statusLabel  : UILabel!
    @IBOutlet weak var nameLabel    : UILabel!
    @IBOutlet weak var containtView : UIView!
    @IBOutlet weak var numberListLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileIcon.layer.cornerRadius = profileIcon.frame.height / 2
        profileIcon.layer.masksToBounds = false
        profileIcon.clipsToBounds = true
    }
    
    func configCell(data: ApproverData, index: Int){
        nameLabel.text      = data.title ?? ""
        if data.id == Shared.R002_DATA?.USER_ID {
            nameLabel.text! += " "+"me".localized
        }
        self.numberListLabel.text = String(index)
        statusLabel.text    = setStatus(data: data.status ?? "", index: index)
        dateLabel.text      = "(\(data.date?.formatFullExpenseDateToString ?? ""))"
        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
        let split_url       = data.profile?.components(separatedBy: "?")
        let img_url         = "\(split_url?.first ??  "")?token=\(authorization)&\(split_url?.last ?? "")" + "&\(data.id ?? "")"
        
        let url             = URL(string: "\(img_url)")
        self.profileIcon.sd_setImage(with: url,  completed: { (image, error, SDImageCacheType , url) in
            if error == nil {
                self.profileIcon.image  = image
            } else {
                self.profileIcon.image  = UIImage(named: "head_employee_ico")
            }
        })
        
        statusIcon.image    = UIImage(named:"\(setImageName(data: data.status ?? ""))")
   
        if data.status == "P" || data.status == "W" || data.status == "S" {
            statusLabel.textColor = #colorLiteral(red: 0.4599350691, green: 0.4599351287, blue: 0.4599351287, alpha: 1)
            dateLabel.isHidden    = true
        }else if data.status == "R"{
            statusLabel.textColor = #colorLiteral(red: 0.7683763504, green: 0.0238144286, blue: 0.06762222946, alpha: 1)
            dateLabel.isHidden    = false
        }else if data.status == "A" {
            statusLabel.textColor = #colorLiteral(red: 0.01862202026, green: 0.4014231265, blue: 0.1809398234, alpha: 1)
            dateLabel.isHidden    = false
        }
    }
    
    func setImageName (data: String ) -> String {
        if data == "P"{
            return "Pending"
        }else if data == "A"{
            return "Frame 427323020"
        }else if data == "R"{
            return "Reject"
        } else if data == "W" {
            return "Pending"
        } else if data == "S" {
            return "ico_suspend"
        }
        return ""
    }
    
    func setStatus(data: String, index: Int) -> String {
        switch data  {
        case "P" :
            return "pending_for_approval".localized
        case "R" :
            return "Rejected".localized
        case "A" :
            return "approved".localized
        case "W" :
            if index == 2 {
                return "waiting_first_approver".localized
            } else if index == 3 {
                return "waiting_second_approver".localized
            } else if index == 4 {
                return "waiting_third_approver".localized
            } else {
                return "Waiting"
            }
        case "S" :
            return "unable_to_approve".localized
        default :
            return ""
        }
        
    }
}

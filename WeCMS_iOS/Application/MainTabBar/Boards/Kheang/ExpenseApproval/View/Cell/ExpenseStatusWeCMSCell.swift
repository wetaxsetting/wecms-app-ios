//
//  ExpenseStatusWeCMSCell.swift
//  WeCMS_iOS
//
//  Created by lymanny on 15/1/25.
//

import UIKit

class ExpenseStatusWeCMSCell: UICollectionViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var userImage            : UIImageView!
    @IBOutlet weak var nameLabel            : UILabel!
    @IBOutlet weak var dateLabel            : UILabel!
    @IBOutlet weak var titleLabel           : UILabel!
    @IBOutlet weak var fromDateLabel        : UILabel!
    @IBOutlet weak var payDateLabel         : UILabel!
    @IBOutlet weak var pendingView          : UIView!
    @IBOutlet weak var rejectView           : UIView!
    @IBOutlet weak var completedView        : UIView!
    @IBOutlet weak var progressView         : UIView!
    @IBOutlet weak var pendingLabel         : UILabel!
    @IBOutlet weak var rejectLabel          : UILabel!
    @IBOutlet weak var progressLable        : UILabel!
    
    @IBOutlet weak var completeLabel        : UILabel!
    @IBOutlet weak var stackView            : UIStackView!
    @IBOutlet weak var statusTitle          : UILabel!
    
    //Stackview Outlet
    @IBOutlet weak var statuseImage         : UIImageView!
    
    @IBOutlet weak var requestDateStackView : UIStackView!
    @IBOutlet weak var contentStackView     : UIStackView!
    
    //Constraint Outlet
    @IBOutlet weak var contentStackViewTopConstraint    : NSLayoutConstraint!
    @IBOutlet weak var heightContentStackViewConstraint : NSLayoutConstraint!
    
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.pendingLabel.text   = "pending".localized
        self.rejectLabel.text    = "Rejected".localized
        self.completeLabel.text  = "approved".localized
        self.progressLable.text  = "progress".localized
        self.progressLable.getlocalizedFont()
        self.completeLabel.getlocalizedFont()
        self.rejectLabel.getlocalizedFont()
        self.pendingLabel.getlocalizedFont()
        self.statusTitle.getlocalizedFont()
        self.dateLabel.getlocalizedFont()
        self.fromDateLabel.getlocalizedFont()
        self.payDateLabel.getlocalizedFont()
    }
    
    //MARK: - Function
    func MREC_BLTB_0005_R002(data: MREC_BLTB_0005_R002.RESPONSE, POST_APPR_DV: String) {
        self.stackView.isHidden = true
        self.titleLabel.text = data.POST_TITLE
        self.titleLabel.getlocalizedFont()
        self.nameLabel.text = data.REG_NM
        self.nameLabel.getlocalizedFont()
        self.dateLabel.text = data.REG_DTM?.formatFullExpenseDateToString
        self.fromDateLabel.text = "schedule".localized
        
        if data.PAY_DATE == nil {
            payDateLabel.text = ""
        } else {
            payDateLabel.text = data.PAY_DATE?.formatExpenseDateToString
        }
        
        self.requestDateStackView.isHidden = POST_APPR_DV == "00"
        self.contentStackViewTopConstraint.constant = POST_APPR_DV == "00" ? 10 : 2
        self.contentStackView.isHidden = false
        
        self.pendingView.isHidden = data.APPR_STTS != "P"
        self.rejectView.isHidden = data.APPR_STTS != "R"
        self.completedView.isHidden = data.APPR_STTS != "C"
        
        if POST_APPR_DV == "00" {
            heightContentStackViewConstraint.constant = 28
        }
        
        // Check approved APPR_STTS = "A"
        if data.APPR_STTS == "A" {
            completedView.isHidden = false
            progressView.isHidden = true
            completeLabel.text = "approved".localized
        }
        
        // Check progress  APPR_STTS = "I" || APPR_STTS = 1..<5/4
        if data.APPR_STTS != "P" && data.APPR_STTS != "R" && data.APPR_STTS != "C" && data.APPR_STTS != "A" {
            progressView.isHidden = false
            progressLable.text = "progress".localized
            if data.APPR_STTS != "I" {
                progressLable.text! += " " + (data.APPR_STTS ?? "")
            }
        }
        
        self.userImage.sd_setImage(with: data.REG_IMG_URL?.formatFileURL,  completed: { (image, error, SDImageCacheType , url) in
            if error == nil {
                self.userImage.image  = image
            } else {
                self.userImage.image  = UIImage(named: "head_employee_ico")
            }
        })
    }
    
    func MREC_BLTB_0005_R001(data: MREC_BLTB_0005_R001.RESPONSE, POST_APPR_DV: String) {
        
        self.stackView.isHidden = false
        self.statusTitle.text = data.POST_STTS == "PL" ? "public".localized : "private".localized
        self.statuseImage.image = UIImage(named: data.POST_STTS == "PL" ? "ico_earth" : "ico_lock")
        
        
        self.titleLabel.text = data.POST_TITLE
        self.nameLabel.text = data.REG_NM
        self.dateLabel.text = data.REG_DTM?.formatFullExpenseDateToString
        self.requestDateStackView.isHidden = true
        self.contentStackViewTopConstraint.constant = POST_APPR_DV == "00" ? 10 : 2
        self.contentStackView.isHidden = true
        self.contentStackView.isHidden = true
        self.heightContentStackViewConstraint.constant = 0
        
        self.userImage.sd_setImage(with: data.REG_IMG_URL?.formatFileURL,  completed: { (image, error, SDImageCacheType , url) in
            if error == nil {
                self.userImage.image  = image
            } else {
                self.userImage.image  = UIImage(named: "head_employee_ico")
            }
        })
    }
    
}

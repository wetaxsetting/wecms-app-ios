//
//  FullContentWeCMSCell.swift
//  WeCMS_iOS
//
//  Created by lymanny on 20/1/25.
//

import UIKit

class FullContentWeCMSCell: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var userImage            : UIImageView!
    @IBOutlet weak var nameUserLabel        : UILabel!
    @IBOutlet weak var dateLabel            : UILabel!
    @IBOutlet weak var approvalLabel        : UILabel!
    @IBOutlet weak var titlePostLabel       : UILabel!
    @IBOutlet weak var fromDateLabel        : UILabel!
    @IBOutlet weak var pendingView          : UIView!
    @IBOutlet weak var rejectView           : UIView!
    @IBOutlet weak var approveView          : UIView!
    @IBOutlet weak var partiallyView        : UIView!
    @IBOutlet weak var newView              : UIView!
    @IBOutlet weak var amountLabel          : UILabel!
    @IBOutlet weak var pinButton            : UIButton!
    @IBOutlet weak var payDateLabel         : UILabel!
    @IBOutlet weak var dotPostBtn           : UIButton!
    @IBOutlet weak var amountKHRLabel       : UILabel!
    @IBOutlet weak var statuseImage         : UIImageView!
    
    //StackView Outlet
    @IBOutlet weak var detailStackView      : UIStackView!
    @IBOutlet weak var leftDetailStackView  : UIStackView!
    @IBOutlet weak var rightDetailStackView : UIStackView!
    @IBOutlet weak var detailLeftBottomStackView: UIStackView!
    @IBOutlet weak var requestDateStackView : UIStackView!
    
    //Constraint Outlet
    @IBOutlet weak var widthAmount          : NSLayoutConstraint!
    @IBOutlet weak var pendingLabel         : UILabel!
    @IBOutlet weak var rejectLabel          : UILabel!
    @IBOutlet weak var completedLabel       : UILabel!
    @IBOutlet weak var processLabel         : UILabel!
    @IBOutlet weak var statusLabel          : UILabel!
    
    //MARK: - Properties & Variable
    var isDraft = false {
        didSet {
            if isDraft {
                self.detailLeftBottomStackView.isHidden  = true
                self.rightDetailStackView.isHidden       = true
            } else {
                self.detailLeftBottomStackView.isHidden  = false
                self.rightDetailStackView.isHidden       = false
            }
        }
    }
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpLocalize()
    }
    
    //MARK: - Function
    func setUpLocalize() {
        self.processLabel.getlocalizedFont()
        self.fromDateLabel.getlocalizedFont()
        self.completedLabel.getlocalizedFont()
        self.payDateLabel.getlocalizedFont()
        self.rejectLabel.getlocalizedFont()
        self.pendingLabel.getlocalizedFont()
        self.dateLabel.getlocalizedFont()
        self.titlePostLabel.getlocalizedFont()
        self.nameUserLabel.getlocalizedFont()
        self.approvalLabel.getlocalizedFont()
        self.amountLabel.getlocalizedFont()
        self.amountKHRLabel.getlocalizedFont()
    }
    
    func config(data: WeCMSStruct.BoardDetail_Protocol) {
        
        self.titlePostLabel.text = data.POST_TITLE
        self.nameUserLabel.text = data.REG_NM
        if data.POST_APPR_DV == "00" && data.POST_TYPE_CD == "02" {
            self.detailLeftBottomStackView.isHidden = false
            self.statuseImage.isHidden = true
            self.approvalLabel.text = "simple_approval".localized
        }else if data.POST_APPR_DV == "10" && data.POST_TYPE_CD == "02" {
            self.detailLeftBottomStackView.isHidden = false
            self.statuseImage.isHidden = true
            self.approvalLabel.text = "expense_approval".localized
        }else if data.POST_STTS == "PL" && data.POST_TYPE_CD == "01" {
            self.detailLeftBottomStackView.isHidden = true
            self.widthAmount.constant = 0
            self.statuseImage.isHidden = false
            self.statuseImage.image = UIImage(named: "ico_earth")
            self.statusLabel.text = " "  + "public".localized
        }else if data.POST_STTS == "PV" && data.POST_TYPE_CD == "01" {
            self.detailLeftBottomStackView.isHidden = true
            self.widthAmount.constant = 0
            self.statusLabel.text = " " + "private".localized
            self.statuseImage.isHidden = false
            self.statuseImage.image = UIImage(named: "ico_lock")
        }else {
            self.detailLeftBottomStackView.isHidden = true
            self.statuseImage.isHidden = true
            self.statuseImage.image = UIImage(named: "")
            self.statusLabel.text = ""
        }
        self.requestDateStackView.isHidden = data.POST_APPR_DV == "00"
        self.isDraft = data.POST_TYPE_CD == "01" || data.POST_SEQ_NO == nil
        self.newView.isHidden = data.READ_YN == "Y"
        self.pinButton.isHidden = data.PIN_POST_TYPE == nil
        self.statuseImage.isHidden = data.POST_APPR_DV == "00" || data.POST_APPR_DV == "10"
        
        if let hidhidePin = data.PIN_POST_TYPE {
            if hidhidePin == "LD"{
                self.pinButton.isHidden = true
            }else{
                self.pinButton.isHidden = data.PIN_POST_TYPE == nil
            }
        }
        // if data response "0" is hiden
        if  data.TOT_PAY_USD_AMT == "" || data.TOT_PAY_USD_AMT == "0.000000" {
            self.amountLabel.isHidden = true
        } else if data.TOT_PAY_USD_AMT == nil {
            self.amountLabel.text = ""
            self.amountLabel.isHidden = true
        }else {
            self.amountLabel.isHidden = false
            //            self.amountLabel.text     = "$\(data.TOT_PAY_USD_AMT?.formatStringDouble ?? "")"
            self.amountLabel.text = "$ \(customFormatCurrency(CCY_CD: "USD", amount: data.TOT_PAY_USD_AMT?.formatStringDouble ?? ""))"
        }
        
        if data.TOT_PAY_LOC_AMT     == "" ||  data.TOT_PAY_LOC_AMT     == "0.000000" {
            self.amountKHRLabel.isHidden = true
        } else if data.TOT_PAY_LOC_AMT == nil {
            self.amountKHRLabel.text = ""
            self.amountKHRLabel.isHidden = true
        }else {
            self.amountKHRLabel.isHidden = false
            self.amountKHRLabel.text     = "VND " + "\(data.TOT_PAY_LOC_AMT?.components(separatedBy: ".").first?.vndCurrencyFormatter() ?? "" )"
            
        }
        //approvalLabel.isHidden = data.POST_TYPE_CD == "01"
        statusLabel.isHidden = data.POST_TYPE_CD == "02"
        dateLabel.text = (calDateformatTime(data.REG_DTM ?? "") ?? "") + " • " + "expense_approval".localized
        
        //fromDateLabel.text = data.PAY_REQ_DATE?.formatExpenseDateToString
        fromDateLabel.text      = "schedule".localized
        payDateLabel.text       = data.PAY_DATE?.formatExpenseDateToString
        dotPostBtn.isHidden     = Shared.R002_DATA?.USER_ID != data.REG_ID && data.DEL_YN != "Y"
        pendingView.isHidden    = data.APPR_STTS != "P"
        pendingLabel.text       =  "pending".localized
        rejectView.isHidden     = data.APPR_STTS != "R"
        rejectLabel.text        =   "rejected".localized
        approveView.isHidden    = data.APPR_STTS != "C"
        processLabel.text       = "progress".localized
        partiallyView.isHidden  = true
        completedLabel.text  =   "approved".localized
        
        // Check approved APPR_STTS = "A"
        if data.APPR_STTS == "A" {
            approveView.isHidden = false
            partiallyView.isHidden = true
            completedLabel.text = "approved".localized
        }
        
        // Check progress  APPR_STTS = "I" || APPR_STTS = 1..<5/4
        if data.APPR_STTS != "P" && data.APPR_STTS != "R" && data.APPR_STTS != "C" && data.APPR_STTS != "A" {
            partiallyView.isHidden = false
            processLabel.text = "progress".localized
            if data.APPR_STTS != "I" {
                processLabel.text! += " " + (data.APPR_STTS ?? "")
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
    
}


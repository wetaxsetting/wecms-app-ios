//
//  ApprovalInfoWeCMSCell.swift
//  WABOOKS_iOS_V2
//
//  Created by lymanny on 13/1/25.
//

import UIKit

class ApprovalInfoWeCMSCell: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var approvalImage    : UIImageView!
    @IBOutlet weak var titleLabel       : UILabel!
    @IBOutlet weak var amountStackView  : UIStackView!
    @IBOutlet weak var usdLabel         : UILabel!
    @IBOutlet weak var localLabel       : UILabel!
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.titleLabel.getlocalizedFont()
    }
    
    //MARK: - Function
    func configCell(data: ApprovalContent) {
        self.approvalImage.image    = UIImage(named: data.Image ?? "")
        self.titleLabel.text        = data.Title
        
    }
    
    func configTotalCell(data: ApprovalContent, TOTL_AMTUSD: Double, TOTL_AMTKHR: Double, TOTL_AMTVND: Double) {
        self.approvalImage.image = UIImage(named: data.Image ?? "")
        self.titleLabel.text     = data.Title
        
        if TOTL_AMTVND != 0 || TOTL_AMTUSD != 0 {
            if TOTL_AMTVND != 0 && TOTL_AMTUSD == 0 {
                amountStackView.spacing = 0
                //self.usdLabel.isHidden   = true
                self.localLabel.isHidden = false
                self.localLabel.text    = "VND \(customFormatCurrency(CCY_CD: "VND", amount: "\(TOTL_AMTVND)".components(separatedBy: ".").first ?? ""))"
            }else if TOTL_AMTVND == 0 && TOTL_AMTUSD != 0 {
                amountStackView.spacing = 6
                //self.usdLabel.isHidden   = false
                self.localLabel.isHidden = true
                self.usdLabel.text      = "USD \(customFormatCurrency(CCY_CD: "USD", amount: "\(TOTL_AMTUSD)"))"
            }else {
                amountStackView.spacing = 6
                //self.usdLabel.isHidden   = false
                self.localLabel.isHidden = false
                self.usdLabel.text      = "USD \(customFormatCurrency(CCY_CD: "USD", amount: "\(TOTL_AMTUSD)"))"
                self.localLabel.text    = "VND \(customFormatCurrency(CCY_CD: "VND", amount: "\(TOTL_AMTVND)".components(separatedBy: ".").first ?? ""))"
            }
        }else {
            amountStackView.spacing = 6
            //self.usdLabel.isHidden   = false
            self.localLabel.isHidden = false
            self.usdLabel.text = "USD 0.00"
            self.localLabel.text = "VND 0"
        }
        
    }
    
    func configDraftCell(data: ApprovalContent, TOTL_AMTUSD: Double, TOTL_AMTKHR: Double, TOTL_AMTVND: Double) {
        self.approvalImage.image    = UIImage(named: data.Image ?? "")
        self.titleLabel.text        = data.Title
        if TOTL_AMTVND != 0 || TOTL_AMTUSD != 0 {
        }else {
            self.localLabel.text = "VND 0"
        }
    }
    
    func configEditCell(data: EditArticleData) {
        self.approvalImage.image    = UIImage(named: data.icon ?? "")
        self.titleLabel.text        = data.title
        
        switch data.rowType{
        case .TOTALAMOUNT:
            if data.valueKH != "" || data.Value != "" {
                if data.valueKH != "" && data.Value == "" {
                    amountStackView.spacing = 0
                    //self.usdLabel.isHidden   = true
                    self.localLabel.isHidden = false
                    self.localLabel.text    = "VND " + ("\(data.valueKH?.components(separatedBy: ".").first ?? "")".components(separatedBy: ".").first ?? "").vndCurrencyFormatter()
                }else if data.valueKH == "" && data.Value != "" {
                    amountStackView.spacing = 6
                    self.localLabel.isHidden = true
                    //self.usdLabel.isHidden   = false
                    self.usdLabel.text      = "USD \(customFormatCurrency(CCY_CD: "USD", amount: "\(data.Value ?? "")"))"
                }else {
                    amountStackView.spacing = 6
                    self.localLabel.isHidden = false
                    //self.usdLabel.isHidden   = false
                    self.usdLabel.text      = "USD \(customFormatCurrency(CCY_CD: "USD", amount: "\(data.Value ?? "")"))"
                    self.localLabel.text    = "VND \(customFormatCurrency(CCY_CD: "VND", amount: "\(data.Value?.components(separatedBy: ".").first ?? "")"))"
                }
            }else {
                amountStackView.spacing = 6
                self.localLabel.isHidden = false
                //self.usdLabel.isHidden   = false
                self.usdLabel.text = "USD 0.00"
                self.localLabel.text = "VND 0"
            }
            
            
        default: break
        }
    }
}

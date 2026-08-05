//
//  ApprovalInfoCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Seanghay Huort on 16/1/24.
//

import UIKit

class ApprovalInfoCell: UITableViewCell {

    @IBOutlet weak var valueKHLabel : UILabel!
    @IBOutlet weak var approvalImage: UIImageView!
    @IBOutlet weak var titleLabel   : UILabel!
    @IBOutlet weak var valueLabel   : UILabel!
    
    @IBOutlet weak var amountStackView  : UIStackView!
    @IBOutlet weak var usdView          : UIView!
    @IBOutlet weak var usdLabel         : UILabel!
    @IBOutlet weak var localView        : UIView!
    @IBOutlet weak var localLabel       : UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.titleLabel.getlocalizedFont()
        self.valueLabel.getlocalizedFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(data: ApprovalContent) {
        self.approvalImage.image    = UIImage(named: data.Image ?? "")
        self.titleLabel.text        = data.Title
        self.valueLabel.text        = data.Value
        
    }
    func configTotalCell(data: ApprovalContent, TOTL_AMTUSD: Double, TOTL_AMTKHR: Double, TOTL_AMTVND: Double) {
        self.approvalImage.image    = UIImage(named: data.Image ?? "")
        self.titleLabel.text        = data.Title
        if TOTL_AMTVND != 0 || TOTL_AMTUSD != 0 {
            if TOTL_AMTVND != 0 && TOTL_AMTUSD == 0 {
                self.usdView.isHidden   = true
                self.localView.isHidden = false
                self.localLabel.text    = "VND \(customFormatCurrency(CCY_CD: "VND", amount: "\(TOTL_AMTVND)".components(separatedBy: ".").first ?? ""))"
            }else if TOTL_AMTVND == 0 && TOTL_AMTUSD != 0 {
                self.localView.isHidden = true
                self.usdView.isHidden   = false
                self.usdLabel.text      = "USD \(customFormatCurrency(CCY_CD: "USD", amount: "\(TOTL_AMTUSD)"))"
            }else {
                self.localView.isHidden = false
                self.usdView.isHidden   = false
                self.usdLabel.text      = "USD \(customFormatCurrency(CCY_CD: "USD", amount: "\(TOTL_AMTUSD)"))"
                self.localLabel.text    = "VND \(customFormatCurrency(CCY_CD: "VND", amount: "\(TOTL_AMTVND)".components(separatedBy: ".").first ?? ""))"
            }
        }else {
            self.localView.isHidden = false
            self.usdView.isHidden   = false
            self.usdLabel.text = "USD 0.00"
            self.localLabel.text = "VND 0"
        }
        
        
    }
    func configDraftCell(data: ApprovalContent, TOTL_AMTUSD: Double, TOTL_AMTKHR: Double, TOTL_AMTVND: Double) {
//    func configDraftCell(data: ApprovalContent, TOTL_AMTUSD: Double, TOTL_AMTKHR: Double) {
        self.approvalImage.image    = UIImage(named: data.Image ?? "")
        self.titleLabel.text        = data.Title
        if TOTL_AMTVND != 0 || TOTL_AMTUSD != 0 {
            if TOTL_AMTVND != 0 && TOTL_AMTUSD == 0 {
                self.valueLabel.text = "VND " + ("\(TOTL_AMTVND)".components(separatedBy: ".").first ?? "").vndCurrencyFormatter()
            }else if TOTL_AMTVND == 0 && TOTL_AMTUSD != 0 {
                self.valueLabel.text = "USD " + ("\(TOTL_AMTUSD)".components(separatedBy: ".").first ?? "").formatUSDCurrency()
            }else {
                self.valueLabel.text = "USD " + "\(TOTL_AMTUSD)".formatUSDCurrency() + "\nVND " + ("\(TOTL_AMTVND)".components(separatedBy: ".").first ?? "").vndCurrencyFormatter()
            }
        }else {
            self.valueLabel.text = "USD 0.00"
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
                    self.usdView.isHidden   = true
                    self.localView.isHidden = false
                    self.localLabel.text    = "VND " + ("\(data.valueKH?.components(separatedBy: ".").first ?? "")".components(separatedBy: ".").first ?? "").vndCurrencyFormatter()
                }else if data.valueKH == "" && data.Value != "" {
                    self.localView.isHidden = true
                    self.usdView.isHidden   = false
                    self.usdLabel.text      = "USD \(customFormatCurrency(CCY_CD: "USD", amount: "\(data.Value ?? "")"))"
                }else {
                    self.localView.isHidden = false
                    self.usdView.isHidden   = false
                    self.usdLabel.text      = "USD \(customFormatCurrency(CCY_CD: "USD", amount: "\(data.Value ?? "")"))"
                    self.localLabel.text    = "VND \(customFormatCurrency(CCY_CD: "VND", amount: "\(data.Value?.components(separatedBy: ".").first ?? "")"))"
                }
            }else {
                self.localView.isHidden = false
                self.usdView.isHidden   = false
                self.usdLabel.text = "USD 0.00"
                self.localLabel.text = "VND 0"
            }
            
                
        default:
            self.valueLabel.text        = data.Value
        }
    }
}

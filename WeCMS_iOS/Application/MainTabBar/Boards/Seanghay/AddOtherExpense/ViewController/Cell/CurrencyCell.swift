//
//  CurrencyCell.swift
//  WeCMS_iOS
//
//  Created by SteveChea  on 12/3/24.
//

import UIKit

class CurrencyCell: UITableViewCell {

    @IBOutlet weak var leftImg: UIImageView!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var requireImg: UIImageView!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var lineLeading: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLb.getlocalizedFont()
    }
    
    func configCell(data: AddOtherExpenseModel, CCY_CD: String?, isEditManual: String?){
        let value = data.value
        self.requireImg.image = UIImage(named: value.requireImg ?? "")
        
        switch data.rowType {
        case .CURRENCY:
            self.leftImg.image = UIImage(named: value.leftImg ?? "")
            self.titleLb.text = "currency".localized
            self.requireImg.isHidden = true
            self.txtField.tag = 1
            self.txtField.text = value.key
            self.lineLeading.constant = 0
            self.txtField.isUserInteractionEnabled = false
            
        case .AMOUNT:
            self.leftImg.image = UIImage(named: value.leftImg ?? "")
            self.titleLb.text = "amount".localized
            if isEditManual == "VIEW_DETAIL" || isEditManual == "EDIT_EXPENSE" || isEditManual == "EXPENSE_APPROVAL_VC"{ 
                self.requireImg.isHidden = true
                self.txtField.isUserInteractionEnabled = false
            }else{
                self.requireImg.isHidden = false
                self.txtField.isUserInteractionEnabled = true
            }

            self.txtField.tag = 2
            self.txtField.keyboardType = .decimalPad //isUSD ? .decimalPad : .numberPad
            self.lineLeading.constant = -60
            self.txtField.text     = (value.dec?.isEmpty ?? true) ? "" : customFormatCurrency(CCY_CD: CCY_CD ?? "", amount: value.dec  ?? "")

            if CCY_CD == "KHR"{
                self.txtField.placeholder  = "0"
            }else if CCY_CD == "USD"{
                self.txtField.placeholder  = "0.00"
            }else{
                self.txtField.placeholder  = "0.0"
            }
            
        default: break
        }
    }
}

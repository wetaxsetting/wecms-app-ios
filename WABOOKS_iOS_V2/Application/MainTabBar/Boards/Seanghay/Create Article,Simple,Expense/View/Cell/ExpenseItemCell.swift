//
//  ExpenseItemCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Seanghay Huort on 12/3/24.
//

import UIKit

class ExpenseItemCell: UITableViewCell {

    @IBOutlet weak var nameLabel        : UILabel!
    @IBOutlet weak var amountLabel      : UILabel!
    @IBOutlet weak var purposeButton    : UIButton!
    @IBOutlet weak var purposeDropButton: UIButton!
    @IBOutlet weak var deleteButton     : UIButton!
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var idLabel: UILabel!
    
    
    @IBOutlet weak var dotimage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.getlocalizedFont()
        self.amountLabel.getlocalizedFont()
        self.purposeButton.getlocalizedFont()
        self.idLabel.getlocalizedFont()
        self.purposeDropButton.tintColor = UIColor(hexString: "#0F1FEA")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    //sokchea
    func configCell(data: ApprovalContent) {
        self.nameLabel.text         =  data.TRCO_CMENM
        self.idLabel.text           = ""
        self.dotView.isHidden       = (data.Description ?? "").isEmpty ? false : true
        self.purposeButton.setTitle((data.Description ?? "").isEmpty ? "select_purpose".localized : data.Description, for: .normal)
        self.purposeButton.setTitleColor((data.Description ?? "").isEmpty ? UIColor(hexString: "#0F1FEA") : .label , for: .normal)
        self.amountLabel.text = "\(data.CCY_CD ?? "") \(customFormatCurrency(CCY_CD: data.CCY_CD ?? "", amount: data.Value ?? ""))"
        
    } 
    func configEditCell(data: EditArticleData) {
        self.purposeDropButton.isHidden = true
        self.dotView.isHidden           = true
        self.deleteButton.isHidden      = true
        self.nameLabel.text             = data.title
        self.idLabel.text               = data.DOC_ID
        self.purposeButton.setTitle((data.decription ?? "").isEmpty ? "Select Purpose" : data.decription, for: .normal)
        self.purposeButton.setTitleColor((data.decription ?? "").isEmpty ? UIColor(hexString: "#0F1FEA") : .label , for: .normal)
        self.amountLabel.textColor = (data.DOC_ID ?? "").isEmpty ? .blue : .label
        self.idLabel.isHidden       = (data.DOC_ID ?? "").isEmpty ? true : false
        self.amountLabel.text = "\(data.CCY_CD ?? "") \(customFormatCurrency(CCY_CD: data.CCY_CD ?? "", amount: data.Value ?? ""))"
        
    }
    
    func configPOPCell(data: WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1, isCreate: Bool) {
        self.nameLabel.text         = data.TRCO_CMENM
        self.dotView.isHidden       = (data.USAG_NM ?? "").isEmpty ? false : true
        self.idLabel.text           = isCreate ? "" : data.DOC_ID
        self.deleteButton.isHidden  = !isCreate
        self.dotView.isHidden       = true
        self.purposeDropButton.isHidden = !isCreate
        self.amountLabel.textColor = (data.DOC_ID ?? "").isEmpty ? .blue : .label
        self.idLabel.isHidden       = (data.DOC_ID ?? "").isEmpty ? true : false
        
        self.purposeButton.setTitle((data.USAG_NM ?? "").isEmpty ? "select_purpose".localized : data.USAG_NM, for: .normal)
        self.purposeButton.setTitleColor((data.USAG_NM ?? "").isEmpty ? UIColor(hexString: "#0F1FEA") : .label , for: .normal)
        self.amountLabel.text = "\(data.CCY_CD ?? "") \(customFormatCurrency(CCY_CD: data.CCY_CD ?? "", amount: data.AMT ?? ""))"
        
    }
    
}

//
//  SelectPurposeCell.swift
//  WeCMS_iOS
//
//  Created by SteveChea  on 12/3/24.
//

import UIKit

class PurposeCell: UITableViewCell {

    @IBOutlet weak var leftImg: UIImageView!
    @IBOutlet weak var rightImg: UIImageView!
    @IBOutlet weak var requireImg: UIImageView!
    @IBOutlet weak var titleLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLb.getlocalizedFont()
    }
    
    func configCell(data: AddOtherExpenseModel, isEditManual: String?){
        let value = data.value
        self.leftImg.image = UIImage(named: value.leftImg ?? "")
        self.rightImg.image = UIImage(named: value.rightImg ?? "")
        self.requireImg.image = UIImage(named: value.requireImg ?? "")
        self.titleLb.text = value.title
        if isEditManual == "VIEW_DETAIL" || isEditManual == "EDIT_EXPENSE" || isEditManual == "EXPENSE_APPROVAL_VC"{
            self.requireImg.isHidden =  true
            self.rightImg.isHidden = true
            self.titleLb.textColor = UIColor(hexString: "#000000")
            self.isUserInteractionEnabled = false
        }else{
            self.titleLb.textColor = UIColor(hexString: "#0F1FEA")
            self.requireImg.isHidden = false
            self.rightImg.isHidden = false
            self.isUserInteractionEnabled = true
        }
    }
}

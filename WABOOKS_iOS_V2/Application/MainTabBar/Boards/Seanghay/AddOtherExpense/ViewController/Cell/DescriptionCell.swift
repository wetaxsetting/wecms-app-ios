//
//  DescriptionCell.swift
//  WABOOKS_iOS_V2
//
//  Created by SteveChea  on 12/3/24.
//

import UIKit

class DescriptionCell: UITableViewCell {

    @IBOutlet weak var textView: PlaceholderTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.getlocalizedFont()
    }
    
    func configCell(data: AddOtherExpenseModel,  isEditManual: String?){
        self.textView.placeholderText = data.value.placeholder ?? ""
        self.textView.text = data.value.key ?? ""
        if isEditManual == "VIEW_DETAIL" || isEditManual == "EDIT_EXPENSE" || isEditManual == "EXPENSE_APPROVAL_VC"{
            self.textView.isUserInteractionEnabled = false
        }else{
            self.textView.isUserInteractionEnabled = true
        }
    }
}

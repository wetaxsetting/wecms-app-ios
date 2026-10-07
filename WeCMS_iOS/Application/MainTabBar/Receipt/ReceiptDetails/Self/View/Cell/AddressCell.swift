//
//  AddressCell.swift
//  WeCMS_iOS
//
//  Created by SteveChea  on 27/2/24.
//

import UIKit

class AddressCell: UITableViewCell {

    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var dotImg: UIImageView!
    @IBOutlet weak var txtView: PlaceholderTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLb.getlocalizedFont()
        self.txtView.getlocalizedFont()
    }
    
    func configCell(row: SubmitReceiptModel.reeceipRow.content?) {
        let mappingRow = ReceiptRow(rawValue: row?.code ?? "")
        // Using the same component
        self.titleLb.text            = mappingRow?.description.localized
        self.txtView.placeholderText = "add_address".localized
        
        switch mappingRow {
        case .ADDRESS:
            self.txtView.text        = row?.value
            self.txtView.textColor   = UIColor(hexString: "#757575")
            self.txtView.isEditable  = false
        default: break
            
        }
    }
    
}

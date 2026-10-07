//
//  EmptyCell.swift
//  WeCMS_iOS
//
//  Created by SteveChea  on 2/2/24.
//

import UIKit

class EmptyCell: UITableViewCell {

    @IBOutlet weak var imgView  : UIImageView!
    @IBOutlet weak var titleLb  : UILabel!
    @IBOutlet weak var desLb    : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(cellType: String){
        switch cellType{
        case "B":
            self.titleLb.text   = "you_don't_have_any_e-invoice".localized
            self.desLb.text     = "e-invoice_can_be_added_on_the_WeCMS_web".localized
            self.titleLb.getlocalizedFont()
            self.desLb.getlocalizedFont()
            
        case "R":
            self.titleLb.text   = "you_don't_have_any_receipts.".localized
            self.desLb.text     = "add_receipt_by_manually_below.".localized
            self.titleLb.getlocalizedFont()
            self.desLb.getlocalizedFont()
            
        default: break
        }
    }
    
}

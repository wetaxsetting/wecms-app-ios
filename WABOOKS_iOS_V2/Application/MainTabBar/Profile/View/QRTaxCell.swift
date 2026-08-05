//
//  QRTaxCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Phanna on 22/5/23.
//

import UIKit

class QRTaxCell: UITableViewCell {

//    @IBOutlet weak var qrImage          : UIImageView!
//    @IBOutlet weak var title            : UILabel!
//    @IBOutlet weak var dropDownImage    : UIImageView!
//
//    @IBOutlet weak var bkgView          : UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var emailValue: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var employeeValue: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var containerinfo: UIView!
    
    @IBOutlet weak var taxValue: UILabel!
    @IBOutlet weak var qrLogo: UIImageView!
    @IBOutlet weak var qrImage: UIImageView!
    
    @IBOutlet weak var exspandButton: UIButton!
    
    @IBOutlet weak var imgCollap: UIImageView!
    @IBOutlet weak var employeeLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var qrView: UIView!
    @IBOutlet weak var addressValue: UILabel!
    @IBOutlet weak var nameValue: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        let button = UIButton()
        titleLabel.text = "company_tax_info".localized
        

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
     
        // Configure the view for the selected state
    }

   
}

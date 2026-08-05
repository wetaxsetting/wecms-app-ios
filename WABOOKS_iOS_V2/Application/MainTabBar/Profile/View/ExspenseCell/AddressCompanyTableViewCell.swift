//
//  AddressTableViewCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Chenghav on 3/2/24.
//

import UIKit

class AddressCompanyTableViewCell: UITableViewCell {


    @IBOutlet weak var Address: UILabel!
    @IBOutlet weak var AddressLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

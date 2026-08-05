//
//  TaxIDTableViewCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Chenghav on 3/2/24.
//

import UIKit

class TaxIDTableViewCell: UITableViewCell {

    @IBOutlet weak var Tax: UILabel!
    @IBOutlet weak var TaxLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

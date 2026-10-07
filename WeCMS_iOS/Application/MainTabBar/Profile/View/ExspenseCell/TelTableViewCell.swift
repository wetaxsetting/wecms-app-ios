//
//  TelTableViewCell.swift
//  WeCMS_iOS
//
//  Created by Chenghav on 3/2/24.
//

import UIKit

class TelTableViewCell: UITableViewCell {

    @IBOutlet weak var tel: UILabel!
    @IBOutlet weak var TelLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

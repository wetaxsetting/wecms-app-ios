//
//  EmailTableViewCell.swift
//  WeCMS_iOS
//
//  Created by Chenghav on 3/2/24.
//

import UIKit

class EmailTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var Email: UILabel!
    
    @IBOutlet weak var EmailLab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

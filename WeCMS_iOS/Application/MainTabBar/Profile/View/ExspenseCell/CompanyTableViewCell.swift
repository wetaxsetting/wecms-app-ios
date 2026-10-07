//
//  CompanyTableViewCell.swift
//  WeCMS_iOS
//
//  Created by Chenghav on 3/2/24.
//

import UIKit

class CompanyTableViewCell: UITableViewCell {

    @IBOutlet weak var Company: UILabel!
    @IBOutlet weak var CompanyLabe: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

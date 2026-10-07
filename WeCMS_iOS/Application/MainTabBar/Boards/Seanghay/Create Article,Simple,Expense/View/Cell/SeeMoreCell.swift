//
//  SeeMoreCell.swift
//  WeCMS_iOS
//
//  Created by Seanghay Huort on 14/3/24.
//

import UIKit

class SeeMoreCell: UITableViewCell {

    @IBOutlet weak var titleLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLb.text = "see_more".localized
        self.titleLb.getlocalizedFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

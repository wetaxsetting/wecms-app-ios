//
//  TitleSectionTVC.swift
//  RecipetDetail
//
//  Created by Bong Kokkheang on 28/3/23.
//

import UIKit

class TitleSectionTVC: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(data: String) {
        titleLabel.text = data.localized
    }

}

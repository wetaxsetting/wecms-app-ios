//
//  SearchListItemTVC.swift
//  RecipetDetail
//
//  Created by Bong Kokkheang on 30/3/23.
//

import UIKit

class SearchListItemTVC: UITableViewCell {
    
    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var rightButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func config(data: Client.ContentBody.Item) {
        self.leftLabel.text = data.l_text
        self.rightButton.setTitle(data.r_text?.localized, for: .normal)
    }
}

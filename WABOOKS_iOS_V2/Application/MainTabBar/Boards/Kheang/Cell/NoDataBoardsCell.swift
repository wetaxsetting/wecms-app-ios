//
//  NoDataBoardsCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Hai Sombo on 2/26/24.
//

import UIKit

class NoDataBoardsCell: UITableViewCell {

    @IBOutlet weak var tapLabel     : UILabel!
    @IBOutlet weak var noPostLabel  : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tapLabel.text                   = "Click_+_button_to_create_new_one".localized
        tapLabel.getlocalizedFont()
        noPostLabel.text                = "No_post_yet".localized
        noPostLabel.getlocalizedFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  HeaderCell.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 21/1/24.
//

import UIKit

class HeaderCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var leftLabelConstraint: NSLayoutConstraint!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label.getlocalizedFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(data: Boards) {
        label.textColor = data.isPin ? UIColor(hexString: "CB0D0D") : .black
        button.isHidden = !data.isPin
        label.text = data.title
        leftLabelConstraint.constant = data.isPin ? 8 : -20
        label.getlocalizedFont()
    }

}

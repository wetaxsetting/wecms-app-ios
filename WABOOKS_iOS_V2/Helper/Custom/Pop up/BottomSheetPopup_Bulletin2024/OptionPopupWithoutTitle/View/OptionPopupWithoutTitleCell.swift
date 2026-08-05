//
//  OptionPopupWithoutTitleCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Navy on 16/1/24.
//

import UIKit

class OptionPopupWithoutTitleCell: UITableViewCell {
    
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configCell(data: OptionPopupWithoutTitleModel) {
        self.iconImage.image = UIImage(named: data.icon)
        self.titleLabel.text = data.title
        self.titleLabel.getlocalizedFont()
        self.titleLabel.textColor = data.isRedOption ? UIColor(resource: .bulletinDelete) : .black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

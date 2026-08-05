//
//  SelectOptionWithTitleCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Seanghay Huort on 19/1/24.
//

import UIKit

class SelectOptionWithTitleCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    @IBOutlet weak var backViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backViewBottomConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.checkImage.isHidden = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(data: OptionPopupWithoutTitleModel, saveFilter: String) {
        switch data.title {
        case "last_1_month".localized:
            backView.cornerTopRadius            = 10
            backViewTopConstraint.constant      = 10
            backViewBottomConstraint.constant   = 0
            checkImage.isHidden = saveFilter == "last_1_month".localized ? false : true
        case "last_3_months".localized:
            backViewBottomConstraint.constant   = 0
            backViewTopConstraint.constant      = 0
            backView.cornerRadius               = 0
            checkImage.isHidden = saveFilter == "last_3_months".localized ? false : true
            
        case "last_6_months".localized:
            backViewBottomConstraint.constant   = 10
            backViewTopConstraint.constant      = 0
            backView.cornerBottomRadius         = 10
            checkImage.isHidden = saveFilter == "last_6_months".localized ? false : true
        case "filter_manually".localized:
            backViewBottomConstraint.constant   = 5
            checkImage.isHidden = true
            checkImage.isHidden = saveFilter == "filter_manually".localized ? false : true
        default:
            backViewBottomConstraint.constant   = 5
            checkImage.isHidden = true
        }
        titleLabel.text         = data.title
        titleLabel.textColor    = data.isRedOption ? UIColor(resource: .bulletinDelete) : .black
        
    }

}

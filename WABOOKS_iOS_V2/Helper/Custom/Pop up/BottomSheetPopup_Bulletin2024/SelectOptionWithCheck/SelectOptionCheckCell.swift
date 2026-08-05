//
//  SelectOptionCheckCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Seanghay Huort on 18/1/24.
//

import UIKit

class SelectOptionCheckCell: UITableViewCell {

    @IBOutlet weak var iconImage        : UIImageView!
    @IBOutlet weak var titleLabel       : UILabel!
    @IBOutlet weak var iconCheckImage   : UIImageView!
    @IBOutlet weak var heightHeaderConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var topView: NSLayoutConstraint!
    @IBOutlet weak var optionContainerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headerLabel.getlocalizedFont()
        titleLabel.getlocalizedFont()
        self.titleLabel.textColor       = .black
        self.iconCheckImage.tintColor   = .black
        self.iconCheckImage.isHidden    = true
        self.iconImage.tintColor        = .black
        headerLabel.text                = "approval".localized
        heightHeaderConstraint.constant = 0
        topView.constant                = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configSelected(_ isSelected: Bool) {
        let highlightColor = UIColor.link.withAlphaComponent(0.12)
        let normalColor    = UIColor(named: "MainBulletin") ?? UIColor(white: 0.94, alpha: 1)
        optionContainerView?.backgroundColor = isSelected ? highlightColor : normalColor
        titleLabel.textColor                 = isSelected ? .link : .black
        iconCheckImage.tintColor             = isSelected ? .link : .black
        iconCheckImage.isHidden              = !isSelected
        iconImage.tintColor                  = isSelected ? .link : .black
    }

    func configCell(data: OptionPopupWithoutTitleModel, isNewArticle: Bool) {
        if isNewArticle {
            heightHeaderConstraint.constant = data.title == "simple_approval".localized ? 18.73 : 0
            topView.constant                = data.title == "simple_approval".localized ? 63 : 5
        }
        
        iconImage.image = UIImage(named: data.icon)
        titleLabel.text = data.title
        titleLabel.textColor = data.isRedOption ? UIColor(resource: .bulletinDelete) : .black
        
    }
    
    func configDraftCell(data: OptionPopupWithoutTitleModel, isNewArticle: Bool) {
        if isNewArticle {
            heightHeaderConstraint.constant = data.title == "Edit_Simple_Approval".localized ? 18.73 : 0
            topView.constant                = data.title == "Edit_Simple_Approval".localized ? 63 : 5
        }
        
        iconImage.image = UIImage(named: data.icon)
        titleLabel.text = data.title
        titleLabel.textColor = data.isRedOption ? UIColor(resource: .bulletinDelete) : .black
        
    }

}

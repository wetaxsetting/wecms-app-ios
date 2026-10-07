//
//  ArticleToggleCell.swift
//  WeCMS_iOS
//
//  Created by Seanghay Huort on 23/1/24.
//

import UIKit

class ArticleToggleCell: UITableViewCell {

    @IBOutlet weak var itemImage        : UIImageView!
    @IBOutlet weak var titleLabel       : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var itemSwitch       : UISwitch!
    
    @IBOutlet weak var specificDateButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.titleLabel.getlocalizedFont()
        self.descriptionLabel.getlocalizedFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(data: ApprovalContent) {
        self.itemImage.image        = UIImage(named: data.Image ?? "")
        self.titleLabel.text        = data.Title
        self.descriptionLabel.text  = data.Description
    
    }
    
    func configureMarkCell(data: ApprovalContent, PIN_POST_TYPE: String, PIN_POST_DUE_DT: String = "") {
        self.itemSwitch.isOn                = PIN_POST_TYPE == "" ? false : true
        self.specificDateButton.isHidden    = PIN_POST_TYPE == "" ? true : false
        self.itemImage.image         = UIImage(named: data.Image ?? "")
        self.titleLabel.text         = data.Title
        if PIN_POST_TYPE == "" {
            self.descriptionLabel.text  = "pin_the_post_until_specific_date".localized
            self.specificDateButton.setTitle("", for: .normal)
        }else{
            self.descriptionLabel.text  = PIN_POST_TYPE == "UD" ? "save_per".localized : "until".localized
            self.specificDateButton.setTitle(PIN_POST_TYPE == "UD" ? "permanently".localized : changeFormatDate(PIN_POST_DUE_DT, fromFormat: "yyyyMMdd", toFormat: "dd MMM yyyy"), for: .normal)
        }
    
    }
    //Post to board cell
    func configEditAricle(data: EditArticleData) {
        self.itemImage.image         = UIImage(named: data.icon ?? "")
        self.titleLabel.text         = data.title
        self.descriptionLabel.text   = data.decription
        self.specificDateButton.setTitle(data.Value, for: .normal)
    }
    
    func configMarkEditAricle(data: EditArticleData, PIN_POST_TYPE: String, PIN_POST_DUE_DT: String = "") {
        self.itemSwitch.isOn                = PIN_POST_TYPE == "" ? false : true
        self.specificDateButton.isHidden    = PIN_POST_TYPE == "" ? true : false
        self.itemImage.image         = UIImage(named: data.icon ?? "")
        self.titleLabel.text         = data.title
        if PIN_POST_TYPE == "" {
            self.descriptionLabel.text  = "pin_the_post_until_specific_date".localized
            self.specificDateButton.setTitle("", for: .normal)
        }else{
            self.descriptionLabel.text  = PIN_POST_TYPE == "UD" ? "save_per".localized : "until".localized
            self.specificDateButton.setTitle(PIN_POST_TYPE == "UD" ? "permanently".localized : changeFormatDate(PIN_POST_DUE_DT, fromFormat: "yyyyMMdd", toFormat: "dd MMM yyyy"), for: .normal)
        }
    }

}

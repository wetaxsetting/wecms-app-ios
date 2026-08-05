//
//  ListItemTVC.swift
//  RecipetDetail
//
//  Created by Bong Kokkheang on 28/3/23.
//

import UIKit

class ListItemTVC: UITableViewCell {
    
    @IBOutlet weak var selectImage: UIImageView!
    
    @IBOutlet weak var favouriteButton: UIButton!
    
    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var rightLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var containView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
//        selectImage.image = UIImage(named: selected ? "check-circle" : "uncheck")
//        self.containView.backgroundColor = UIColor(hexString: selected ? "#F5F9FC" : "#FFFFFF")
        
    }
    
    
    func config(data: Client.ContentBody.Item, sectionType: Client.SectionType, searchText: String) {
    
        var range       = NSMakeRange(0, 0)
        var attrsString : NSMutableAttributedString
        let color = UIColor(hexString: "0069B9")
        attrsString =  NSMutableAttributedString(string: data.l_text);
        range = (data.l_text.folding(options: .diacriticInsensitive, locale: .current) as NSString).range(of: searchText.folding(options: .diacriticInsensitive, locale: .current), options: .caseInsensitive)
        attrsString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        selectImage.image                   = UIImage(named: (data.isSelected ?? false) ? "check-circle" : "uncheck")
        self.containView.backgroundColor    = UIColor(hexString: (data.isSelected ?? false) ? "#F5F9FC" : "#FFFFFF")
        self.favouriteButton.isHidden       = (sectionType == .Recently) ? true : false
        self.favouriteButton.isSelected     = (data.isFavourite ?? false)
        self.favouriteButton.setImage(UIImage(named: (data.isFavourite ?? false) ? "fill-star" : "star"), for: .normal)
        self.leftLabel.text                 = data.l_text
        self.rightLabel.text                = data.r_text
        self.leftLabel.textColor            = .black
        self.leftLabel.attributedText       = attrsString
        
//        selectImage.image = UIImage(named: self.isSelected ? "check-circle" : "uncheck")
    }
    
}

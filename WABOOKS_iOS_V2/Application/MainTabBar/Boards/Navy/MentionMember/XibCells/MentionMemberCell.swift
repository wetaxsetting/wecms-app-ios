//
//  MentionMemberCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Navy on 22/1/24.
//

import UIKit

class MentionMemberCell: UITableViewCell {
    
    @IBOutlet weak var topLine      : UIView!
    @IBOutlet weak var profileImage : UIImageView!
    @IBOutlet weak var nameLabel    : UILabel!
    @IBOutlet weak var emailLabel   : UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func configCell(data: MentionMemberUIModel, index: Int) {
        topLine.isHidden    = index != 0
        nameLabel.text      = data.name
        emailLabel.text     = data.email
    
        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
        let split_url       = data.photo.components(separatedBy: "?")
        let img_url         = "\(Shared.c_web_base_url)\(split_url.first ?? "")?token=\(authorization)&\(split_url.last ?? "")"
        let url             = URL(string: "\(img_url)&cmd=getthumb")
        
        self.profileImage.sd_setImage(with: url,  completed: { (image, error, SDImageCacheType , url) in
            if error == nil {
                self.profileImage.image  = image
            } else {
                self.profileImage.image  = UIImage(named: "noimage")
            }
        })
    
    }
}

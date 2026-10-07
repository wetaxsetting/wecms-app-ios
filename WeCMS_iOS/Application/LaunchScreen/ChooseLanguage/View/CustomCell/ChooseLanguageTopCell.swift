//
//  ChooseLanguageTopCell.swift
//  WeCMS_iOS
//
//  Created by Bun on 3/1/23.
//

import UIKit

class ChooseLanguageTopCell: UITableViewCell {

    @IBOutlet weak var btnProductVersion    : UIButton!
    @IBOutlet weak var lblTitle             : UILabel!
    @IBOutlet weak var lblSubTitle          : UILabel!
    @IBOutlet weak var wbImage              : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.lblTitle.getlocalizedFont()
        self.lblSubTitle.getlocalizedFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configCell(strTitle: String, strSubTitle: String, strImage: String) {
        self.lblTitle.text      = strTitle.localized
        self.lblSubTitle.text   = strSubTitle.localized
        self.btnProductVersion.setImage(UIImage(named: strImage), for: .normal)
    }

}

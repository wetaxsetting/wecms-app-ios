//
//  AttactMentsCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Seanghay Huort on 21/1/24.
//

import UIKit

class AttactMentsCell: UITableViewCell {

    @IBOutlet weak var typeFileLabel        : UILabel!
    @IBOutlet weak var attachMentImage      : UIImageView!
    @IBOutlet weak var attachMentLabel      : UILabel!
    @IBOutlet weak var attachMentSizeLabel  : UILabel!
    @IBOutlet weak var deleteButton         : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configFile(data: ApprovalContent) {
        let fileTypes = data.fileName?.components(separatedBy: ".").last ?? ""
        self.attachMentImage.image = UIImage(named: "extension_\(fileTypes)")
        self.attachMentLabel.text       = data.fileName?.removingPercentEncoding
        self.attachMentSizeLabel.text   = (data.fileData ?? "").replace(of: " bytes", with: "").bytesToKilobytes + "KB"
        self.attachMentLabel.getlocalizedFont()
        self.attachMentSizeLabel.getlocalizedFont()
    }
    
    func configFileEditArticle(data: EditArticleData) {
        let fileTypes = data.fileName?.components(separatedBy: ".").last ?? ""
        self.attachMentImage.image = UIImage(named: "extension_\(fileTypes)")
        self.attachMentLabel.text       = data.fileName?.removingPercentEncoding
        self.attachMentSizeLabel.text   = (data.fileData ?? "").replace(of: " bytes", with: "").bytesToKilobytes + "KB"
        self.attachMentLabel.getlocalizedFont()
        self.attachMentSizeLabel.getlocalizedFont()
      
    }
    
}



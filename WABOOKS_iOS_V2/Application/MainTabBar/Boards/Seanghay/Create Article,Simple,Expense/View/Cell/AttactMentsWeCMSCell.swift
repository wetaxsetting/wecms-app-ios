//
//  AttactMentsWeCMSCell.swift
//  WABOOKS_iOS_V2
//
//  Created by lymanny on 20/1/25.
//

import UIKit

class AttactMentsWeCMSCell: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var attachMentImage      : UIImageView!
    @IBOutlet weak var attachMentLabel      : UILabel!
    @IBOutlet weak var attachMentSizeLabel  : UILabel!
    @IBOutlet weak var deleteButton         : UIButton!
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK: - Function
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



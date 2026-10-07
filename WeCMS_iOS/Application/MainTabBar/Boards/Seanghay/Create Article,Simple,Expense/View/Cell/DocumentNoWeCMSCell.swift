//
//  DocumentNoCellWeCMSCell.swift
//  WeCMS_iOS
//
//  Created by lymanny on 13/1/25.
//

import UIKit

class DocumentNoWeCMSCell: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var leftImg : UIImageView!
    @IBOutlet weak var titleLb : UILabel!
    @IBOutlet weak var descLb  : UILabel!
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLb.getlocalizedFont()
    }
    
    //MARK: - Function
    func configCell(data: ApprovalContent) {
        self.leftImg.image    = UIImage(named: data.Image ?? "")
        self.titleLb.text     = data.Title
        self.descLb.text      = data.Value
    }
    
    func configDocNoCell(data: EditArticleData) {
        self.leftImg.image    = UIImage(named: data.icon ?? "")
        self.titleLb.text     = data.title
        self.descLb.text      = data.Value
    }
}

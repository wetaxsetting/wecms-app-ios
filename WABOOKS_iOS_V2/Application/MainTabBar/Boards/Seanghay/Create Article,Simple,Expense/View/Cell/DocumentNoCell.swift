//
//  DocumentNoCell.swift
//  WABOOKS_iOS_V2
//
//  Created by SteveChea  on 25/3/24.
//

import UIKit

class DocumentNoCell: UITableViewCell {

    @IBOutlet weak var leftImg: UIImageView!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var descLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLb.getlocalizedFont()
    }
    
    func configCell(data: ApprovalContent) {
        self.leftImg.image    = UIImage(named: data.Image ?? "")
        self.titleLb.text        = data.Title
        self.descLb.text        = data.Value
    }
    
    func configDocNoCell(data: EditArticleData) {
        self.leftImg.image    = UIImage(named: data.icon ?? "")
        self.titleLb.text     = data.title
        self.descLb.text        = data.Value
    }
}

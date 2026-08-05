//
//  ApprovalSelectInfoWeCMSCell.swift
//  WABOOKS_iOS_V2
//
//  Created by lymanny on 14/1/25.
//

import UIKit

class ApprovalSelectInfoWeCMSCell: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var contentImage : UIImageView!
    @IBOutlet weak var titleLabel   : UILabel!
    @IBOutlet weak var valueLabel   : UILabel!
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.titleLabel.getlocalizedFont()
        self.valueLabel.getlocalizedFont()
    }
    
    //MARK: - Function
    func configCell(data: ApprovalContent, imageSet: [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC6] = []) {
        self.contentImage.image = UIImage(named: data.Image ?? "")
        self.titleLabel.text = data.Title
        self.valueLabel.text = data.Value
        self.valueLabel.textColor = data.Value == "select".localized ? UIColor(hexString: "757575") : UIColor(hexString: "0F1FEA")
    }
    
    func configEditCell(data: EditArticleData, imageSet: [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC6] = []) {
        self.contentImage.image = UIImage(named: data.icon ?? "")
        self.titleLabel.text = data.title
        self.valueLabel.text = data.Value
        self.valueLabel.textColor = data.Value == "select".localized ? UIColor(hexString: "757575") : UIColor(hexString: "0F1FEA")
    }
    
}

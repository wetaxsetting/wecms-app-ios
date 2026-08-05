//
//  ApprovalSelectExpenseCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Seanghay Huort on 25/3/24.
//

import UIKit

class ApprovalSelectExpenseCell: UITableViewCell {

    @IBOutlet weak var imageExpense : UIImageView!
    @IBOutlet weak var expenseLabel : UILabel!
    @IBOutlet weak var valueLabel   : UILabel!
    @IBOutlet weak var forwardImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(data: ApprovalContent) {
        self.forwardImage.isHidden  = false
        self.imageExpense.image     = UIImage(named: data.Image ?? "")
        self.expenseLabel.text      = data.Title
        self.valueLabel.text        = data.Value
        self.valueLabel.textColor   = data.Value == "select".localized ? UIColor(hexString: "757575") : UIColor(hexString: "0F1FEA")
    }
    
    func configEditCell(data: EditArticleData) {
        self.forwardImage.isHidden  = true
        self.imageExpense.image     = UIImage(named: data.icon ?? "")
        self.expenseLabel.text      = "\(data.title ?? "") (\(data.Value ?? ""))"
        self.valueLabel.text        = ""
        self.valueLabel.textColor   = data.Value == "select".localized ? UIColor(hexString: "757575") : UIColor(hexString: "0F1FEA")
    }
    
    func setUpImage() {
        forwardImage.image = UIImage(named: "chevron_right_wecms")
    }
}

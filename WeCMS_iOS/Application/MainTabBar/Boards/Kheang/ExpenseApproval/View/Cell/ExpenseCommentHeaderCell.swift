//
//  ExpenseCommentHeaderCell.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 25/1/24.
//

import UIKit

class ExpenseCommentHeaderCell: UICollectionViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func config(data: any MREC_BLTB_0005_R001_0005_R002_0003_R001_RESPONSE) {
        
        if data.TOT_CMT != "0" && data.TOT_CMT != "1"{
            commentLabel.text = "\(data.TOT_CMT ?? "") " + "comments".localized
            
        }else{
            commentLabel.text = "\(data.TOT_CMT ?? "") " + "comment".localized
        }
        commentLabel.getlocalizedFont()

    }
}

//
//  CommentBoardCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 20/1/24.
//

import UIKit

class CommentBoardCell: UITableViewCell {

    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commentCountLabel.getlocalizedFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(data: WABOOKSStruct.BoardDetail_Protocol) {
        
        nameLabel.isHidden  = data.COMNT_DV_CD == "R" // R: Remark
        nameLabel.text      = data.CMTNT_REG_NM
        
        if data.TOT_CMT != "0" && data.TOT_CMT != "1" {
            commentCountLabel.text = "\(data.TOT_CMT ?? "") " + "comments".localized
        }else {
            commentCountLabel.text = "\(data.TOT_CMT ?? "") " + "comment".localized
        }
        let originalFont =  UIFont(name: "Inter-Medium", size: 14.0)
        let formatedComponent   = self.formatMentionFromAPISyntaxToReadable(originalText: data.COMNT_CONT ?? "")
        let formattedString     = formatedComponent.0
        let mentionedMember     = formatedComponent.1
        self.commentLabel.text  = formattedString
        self.setAttributeLabel(label: commentLabel, textsTobeAttributed: mentionedMember, defaultFont: originalFont, defaultColor: .black, attributedFont:originalFont , atrributedColor: UIColor(resource: .mainTextBulletin))
    }

}

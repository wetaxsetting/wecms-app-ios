//
//  TextViewCommentCell.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 24/2/24.
//

import UIKit

class TextViewCommentCell: UICollectionViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholder: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.textView.text = nil
        self.textView.attributedText = nil
        
        placeholder.getlocalizedFont()
        textView.getlocalizedFont()
    }

    func config(data: CommentViewModel, mentionMembers: [String]) {
        placeholder.text = "Add_a_comment".localized

        let text = data.text ?? ""
        if mentionMembers.count > 0 {
            let originalFont =  UIFont(name: "Inter-Medium", size: 14.0)
            let formatedComponent   = self.formatMentionFromAPISyntaxToReadable(originalText: text)
            let formattedString     = formatedComponent.0
            self.textView.attributedText  = formattedString.parseHTMLForTextView()
            self.setAttributeTextView(textView: textView, textsTobeAttributed: mentionMembers, defaultFont: originalFont, defaultColor: .black, attributedFont:originalFont , atrributedColor: UIColor(resource: .mainTextBulletin))
        } else {
            self.textView.attributedText = text.parseHTMLForTextView()
        }
    }
}

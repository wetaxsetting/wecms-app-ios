//
//  DescriptionExpenseCell.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 25/1/24.
//

import UIKit

class DescriptionExpenseCell: UICollectionViewCell {

    @IBOutlet weak var textView: UITextView!
    
    var POST_CONT : String?
    var mentionMember : [String] = []
    
    override func prepareForReuse() {
        textView.text = nil
        textView.attributedText = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.getlocalizedFont()
        
        
        let formatedComponent   = self.formatMentionFromAPISyntaxToReadable(originalText: POST_CONT ?? "")
        
        mentionMember = formatedComponent.1
        
        setContent()
        
    }
    
    func config02(data: MREC_BLTB_0005_R002.RESPONSE?) {
        setContent()
    }
    
    func config01(data: MREC_BLTB_0005_R001.RESPONSE?) {
        setContent()
    }
    
    func setContent() {
        
        let originalFont =  UIFont(name: "Inter-Medium", size: 14.0)
        
        self.setAttributeTextView(textView: self.textView, textsTobeAttributed: self.mentionMember, defaultFont: originalFont, defaultColor: .black, attributedFont: originalFont, atrributedColor: UIColor(resource: .mainTextBulletin))
        
        self.textView.setHTMLContent(POST_CONT ?? "")
    }
    
    func mediumWithSize(pointSize: CGFloat)-> UIFont {
        
        return UIFont.init(name: "Inter", size: CGFloat(pointSize))!
    
    }

}

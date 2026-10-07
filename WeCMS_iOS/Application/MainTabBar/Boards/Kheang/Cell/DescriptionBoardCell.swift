//
//  DescriptionBoardCell.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 20/1/24.
//

import UIKit

class DescriptionBoardCell: UITableViewCell {

    @IBOutlet weak var textview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textview.getlocalizedFont()
    }

    func config(data: WeCMSStruct.BoardDetail_Protocol) {
        let originalFont =  UIFont(name: "Inter-Medium", size: 14.0)
        let formatedComponent   = self.formatMentionFromAPISyntaxToReadable(originalText: data.POST_CONT ?? "")
        let formattedString     = formatedComponent.0
        let mentionedMember     = formatedComponent.1
        
//        self.textview.attributedText  = data.POST_CONT?.convertHtmlToAttributedWithCSS(font: mediumWithSize(pointSize: 15), csscolor: "black", lineheight: 5, csstextalign: "left", mentionString: formatedComponent.2, username: formatedComponent.1)
//        let htmlString = formattedString.convertStringToHTML
//        if htmlString.contains("<br>") || htmlString.contains("&nbsp;") {
//            self.textview.text      = htmlString.htmlToString
//        }else{
//            self.textview.text      = formattedString
//        }
        
        self.textview.attributedText = data.POST_CONT?.parseHTMLForTextView()
        
        self.setAttributeLabel(label: textview, textsTobeAttributed: mentionedMember, defaultFont: originalFont, defaultColor: .black, attributedFont:originalFont , atrributedColor: UIColor(resource: .mainTextBulletin))
        
    }
    
    func mediumWithSize(pointSize: CGFloat)-> UIFont {
        
        return UIFont.init(name: "Inter", size: CGFloat(pointSize))!
    
    }
    
}

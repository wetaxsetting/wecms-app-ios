//
//  ApprovalFormHeaderCell.swift
//  WeCMS_iOS
//
//  Created by Seanghay Huort on 16/1/24.
//

import UIKit

class ApprovalFormHeaderCell: UITableViewCell {

    @IBOutlet weak var titleTextView        : PlaceholderTextView!
    @IBOutlet weak var descriptionTextView  : PlaceholderTextView!
    @IBOutlet weak var textCountLabel       : UILabel!
    
    @IBOutlet weak var textCountHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textCountBottomConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code]
//        self.titleTextView.placeholder          = "Title"
//        self.descriptionTextView.placeholder    = "Description (max. 200 characters)"
        self.titleTextView.getlocalizedFont()
        self.descriptionTextView.getlocalizedFont()
        self.textCountLabel.getlocalizedFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configArticle(data: ApprovalContent, isArticle: Bool, TITLE: String, DESCRIPTION: String, textCount: Int) {
        
        self.titleTextView.placeholderText         = data.Title?.convertHTMLToString ?? "title".localized
        self.descriptionTextView.placeholderText   = data.Description?.convertHTMLToString ?? "Description".localized
        self.titleTextView.text                    = TITLE
        self.descriptionTextView.text              = DESCRIPTION
        self.textCountLabel.text                   = "\(textCount)/200"
        self.textCountHeightConstraint.constant = isArticle ? 0 : 18.33
    }
    
    func configDraft(data: ApprovalContent, isArticle: Bool) {
        
        self.titleTextView.text         = data.Title?.convertHTMLToString ?? ""
//        self.descriptionTextView.text   = data.Description ?? ""
        self.textCountLabel.text        = "\(data.Description?.count ?? 0)/200"
        self.titleTextView.placeholderText         = data.TitleHolder?.convertHTMLToString ?? "title".localized
        self.descriptionTextView.placeholderText   = data.DescriptionHolder?.convertHTMLToString ?? "Description".localized
        self.textCountHeightConstraint.constant = isArticle ? 0 : 18.33
        // if isFirstLoaded {
        let originalFont =  UIFont(name: "Inter-Medium", size: 15.0)
         let formatedComponent   = self.formatMentionFromAPISyntaxToReadable(originalText: data.Description ?? "")
         let formattedString     = formatedComponent.0
         let mentionedMember     = formatedComponent.1
        self.descriptionTextView.text  = formattedString
         self.setAttributeTextView(textView: self.descriptionTextView, textsTobeAttributed: mentionedMember, defaultFont: originalFont, defaultColor: .black, attributedFont:originalFont , atrributedColor: UIColor(resource: .mainTextBulletin))
        //> Seanghay <\\ SEANGHAY here
//        self.descriptionTextView.attributedText  = formattedString.convertHtmlToAttributedWithCSS(font: mediumWithSize(pointSize: 15), csscolor: "black", lineheight: 5, csstextalign: "left")
         //}
        
    }
    
    //post to Board cell
    func configEditArticle(data: EditArticleData, description : String, isFirstLoaded: Bool, isArticle: Bool, isHideTextCount: String){
        self.titleTextView.text         = data.title?.isNotEmpty ?? true ? data.title?.convertHTMLToString : "title".localized
        self.descriptionTextView.text   = data.decription?.isNotEmpty ?? true ? data.decription?.convertHTMLToString : "Description".localized + " " + "max_200_characters".localized
        titleTextView.textColor         = UIColor(hexString: "#000000")
        descriptionTextView.textColor   = UIColor(hexString: "#000000")
        if isHideTextCount == "01"{
            textCountLabel.isHidden = true
        }else{
            textCountLabel.isHidden = false
        }

        
        
//        if isFirstLoaded {
        let originalFont =  UIFont(name: "Inter-Medium", size: 15.0)
            let formatedComponent   = self.formatMentionFromAPISyntaxToReadable(originalText: description)
            let formattedString     = formatedComponent.0
            let mentionedMember     = formatedComponent.1
            self.descriptionTextView.text  = formattedString
            self.setAttributeTextView(textView: self.descriptionTextView, textsTobeAttributed: mentionedMember, defaultFont: originalFont, defaultColor: .black, attributedFont:originalFont , atrributedColor: UIColor(resource: .mainTextBulletin))
//        }
        
    }
    
    func mediumWithSize(pointSize: CGFloat)-> UIFont {
        
        return UIFont.init(name: "Helvetica Neue", size: CGFloat(pointSize))!
    
    }
}



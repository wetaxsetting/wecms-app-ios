//
//  TextViewCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 11/1/24.
//

import UIKit

class TextViewCell: UICollectionViewCell {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var viewCustom: UIView!
    @IBOutlet weak var customTrailingView: UIView!
    
    var isHighLight: Bool = false {
        didSet {
            textView.backgroundColor = isHighLight ? UIColor(hexString: "#EDF7FF") : .none
            self.viewCustom.isHidden = !isHighLight
            self.customTrailingView.isHidden = !isHighLight
        }
    }
    
    var recData : WABOOKS_MREC_BLTB_0002_R003.RESPONES.REC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.getlocalizedFont()
        self.textView.attributedText = nil
        self.textView.text = nil
        setData()
    }
    
    private func setData() {
        
        let originalFont =  UIFont(name: "Inter-Medium", size: 14.0)
        var statusContent = ""
        var text = ""
        var color = ""
        
        let CONT = (recData?.COMNT_CONT ?? "").isEmpty ? "" : " → " + (recData?.COMNT_CONT ?? "")
        
        if recData?.COMNT_DV_CD == "R" { //remark
            switch recData?.COMNT_TASK_CD {
            case "R001":
                statusContent = "Pinned"
            case "R002":
                statusContent = "rejected_request".localized + CONT
                
                color = "CB0D0D"
                
                text = "rejected_request".localized
            case "R003":
                statusContent = "completed_request".localized + CONT
                
                color = "0069B9"
                text = "completed_request".localized
            case "R004":
                statusContent = "approved_request".localized + CONT
                
                color = "05662E"
                text = "approved_request".localized
            default: break
                
            }
            
            if statusContent.contains("@[") {
                let formatedComponent   = self.formatMentionFromAPISyntaxToReadable(originalText: statusContent)
                let formattedString     = formatedComponent.0
                let mentionedMember     = formatedComponent.1
                textView.text           = formattedString
             
                self.setAttributeTextView(textView: textView, textsTobeAttributed: mentionedMember, defaultFont: originalFont, defaultColor: .black, attributedFont:originalFont , atrributedColor: UIColor(resource: .mainTextBulletin))
            } else {
                
                highLightStatus(COMNT_CONT: statusContent, text: text, color: color, font: originalFont)
            }
            
        } else if recData?.COMNT_DV_CD == "C" { // Comment
            
            let COMNT_CONT = recData?.COMNT_CONT ?? ""
            if COMNT_CONT.contains("@[") {
                let formatedComponent   = self.formatMentionFromAPISyntaxToReadable(originalText: COMNT_CONT)
                let formattedString     = formatedComponent.0
                let mentionedMember     = formatedComponent.1
                self.textView.text      = formattedString
                self.setAttributeTextView(textView: textView, textsTobeAttributed: mentionedMember, defaultFont: originalFont, defaultColor: .black, attributedFont:originalFont , atrributedColor: UIColor(resource: .mainTextBulletin))
                
            } else {
//                textView.text = nil
//                textView.attributedText = nil
//                textView.attributedText = recData?.COMNT_CONT?.parseHTMLForTextView()
                self.textView.setHTMLContent(recData?.COMNT_CONT ?? "")
            }
        }
        
    }
    
    func WABOOKS_MREC_BLTB_0002_R003() {
        
        setData()
    }
    
    func highLightStatus(COMNT_CONT: String, text: String, color: String, font: UIFont?) {
        let matchRange = (COMNT_CONT as NSString).range(of: text)
        let mutableAttributedString = NSMutableAttributedString.init(string: COMNT_CONT)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexString: color), range: matchRange)
        textView.text = nil
        textView.attributedText = mutableAttributedString
        textView.font = font
    }
}



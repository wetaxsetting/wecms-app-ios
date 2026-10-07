//
//  ButtonNotiCell.swift
//  Bizcard4.0
//
//  Created by kimlang on 8/29/23.
//  Copyright © 2023 KOSIGN. All rights reserved.
//

import UIKit

class ButtonNotiCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionDataLabel  : UILabel!
    @IBOutlet weak var lineView             : UIView!
    @IBOutlet weak var widthLineView        : NSLayoutConstraint!
    
    override func awakeFromNib() {
        self.collectionDataLabel.getlocalizedFont()
    }
    
    func configCell(data : CarbonNewNotificationModel ) {
        self.collectionDataLabel.text = data.titleButton
        self.collectionDataLabel.getlocalizedFont()
        
        if data.isSelected ?? false {
         
            self.collectionDataLabel.textColor = .black
            self.lineView.backgroundColor      = .black
        }else {
            self.lineView.backgroundColor      = .clear
            self.collectionDataLabel.textColor  = .gray
            
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.widthLineView.constant = 140
        }else {
            self.widthLineView.constant = (UIScreen.main.bounds.width - 60) / 2
        }
       
        
        self.layer.masksToBounds            = false
       

    }
    
    
}


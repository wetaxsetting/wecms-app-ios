//
//  TitleExpenseCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 25/1/24.
//

import UIKit

class TitleExpenseCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.text = "receipt".localized
  
        titleLabel.getlocalizedFont()
    }
}

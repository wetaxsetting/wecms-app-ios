//
//  EmptyCmtCollectionViewCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Chenghav on 12/2/24.
//

import UIKit

class EmptyCmtCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var subTitleLable: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.text     = "No_responses_yet".localized
        subTitleLable.text  = "Be_the_first_person_to_respond".localized
        titleLabel.getlocalizedFont()
        subTitleLable.getlocalizedFont()
    }

}

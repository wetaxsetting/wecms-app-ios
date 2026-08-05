//
//  RequestorCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 26/2/24.
//

import UIKit

class RequestorCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var requestorLabel: UILabel!
    @IBOutlet weak var requestorNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.requestorLabel.getlocalizedFont()
        self.requestorLabel.text = "requestor".localized
    }

}

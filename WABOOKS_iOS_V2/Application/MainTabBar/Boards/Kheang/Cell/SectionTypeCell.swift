//
//  SectionTypeCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 20/1/24.
//

import UIKit

class SectionTypeCell: UICollectionViewCell {
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var underLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        leftLabel.getlocalizedFont()
        rightLabel.getlocalizedFont()
    }

    func config(data: Boards.Section) {
            
        if data.sectionType != .ALL {
            leftLabel.isHidden = !data.isSelected
        } else {
            leftLabel.isHidden = false
        }
        if let image = data.image {
            img.isHidden = false
            img.image = UIImage(named: image)
        } else {
            img.isHidden = true
        }
        underLineView.isHidden = !data.isSelected
        leftLabel.text = data.name
        rightLabel.text = "+\(data.count ?? "")"
        if let count = Int(data.count ?? "0") {
            rightLabel.isHidden = count <= 0
            if count > 99 {
                rightLabel.text = "+99"
            } else {
                rightLabel.text = "+\(count)"
            }
        }
        leftLabel.textColor = data.isSelected ? .black : UIColor(hexString: "#828282")
        rightLabel.textColor = data.isSelected ? .black : UIColor(hexString: "#828282")
    }
    
}

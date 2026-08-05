//
//  FilterManualCell.swift
//  WABOOKS_iOS_V2
//
//  Created by SteveChea  on 24/1/24.
//

import UIKit

class FilterManualCell: UICollectionViewCell {

    @IBOutlet weak var titleLb  : UILabel!
    @IBOutlet weak var img      : UIImageView!
    @IBOutlet weak var viewBg   : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configCell(data: DateFilter){
        self.titleLb.text = data.Title
        self.img.isHidden = !data.isSelected
        self.titleLb.getlocalizedFont()
        
        if data.isSelected{
            self.titleLb.textColor = UIColor(hexString: "#0F1FEA")
        }else{
            self.titleLb.textColor = UIColor(hexString: "#000000")
        }
    }
}

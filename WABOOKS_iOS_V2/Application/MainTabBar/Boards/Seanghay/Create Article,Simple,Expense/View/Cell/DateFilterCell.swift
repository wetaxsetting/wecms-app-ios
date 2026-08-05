//
//  DateFilterCell.swift
//  WABOOKS_iOS_V2
//
//  Created by SteveChea  on 24/1/24.
//

import UIKit

class DateFilterCell: UICollectionViewCell {

    @IBOutlet weak var titleLb  : UILabel!
    @IBOutlet weak var viewBg   : UIView!
    @IBOutlet weak var img      : UIImageView!
    @IBOutlet weak var desLb    : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configCell(data: DateFilter?){
        self.titleLb.text = data?.Title
        self.desLb.text = data?.Description
        self.titleLb.getlocalizedFont()
        self.desLb.getlocalizedFont()
    }

}

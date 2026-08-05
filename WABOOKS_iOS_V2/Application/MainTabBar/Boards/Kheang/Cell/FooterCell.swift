//
//  FooterCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 5/2/24.
//

import UIKit

class FooterCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var btn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.getlocalizedFont()
    }
    
    func configShowMore() {
        label.text = "show_more".localized
        btn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
    }
    
    func configShowLess() {
        label.text = "show_less".localized
        btn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
    }
}

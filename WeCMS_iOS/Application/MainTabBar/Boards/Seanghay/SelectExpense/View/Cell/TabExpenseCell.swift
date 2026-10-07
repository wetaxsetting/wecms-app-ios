//
//  TabExpenseCell.swift
//  WeCMS_iOS
//
//  Created by Seanghay Huort on 18/1/24.
//

import UIKit

class TabExpenseCell: UICollectionViewCell {
    @IBOutlet weak var ItemLabel        : UILabel!
    @IBOutlet weak var itemCountView    : UIView!
    @IBOutlet weak var lineView         : UIView!
    @IBOutlet weak var itemCountLabel   : UILabel!
    @IBOutlet weak var tapButton        : UIButton!
    
    func configCell(data: SelectExpenses, seleted: Bool, itemCount: Int){
        lineView.isHidden   = seleted
        ItemLabel.text      = data.itemTitle
        ItemLabel.textColor = seleted ?  UIColor(hexString: "828282") : .black
        itemCountLabel.textColor = seleted ?  UIColor(hexString: "828282") : .black
        itemCountLabel.text = "\(itemCount)"
        ItemLabel.getlocalizedFont()
        itemCountLabel.getlocalizedFont()
    }
    
}

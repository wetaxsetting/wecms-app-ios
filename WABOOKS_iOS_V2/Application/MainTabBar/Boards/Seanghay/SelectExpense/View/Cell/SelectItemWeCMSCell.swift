//
//  SelectItemWeCMSCell.swift
//  WABOOKS_iOS_V2
//
//  Created by lymanny on 14/1/25.
//

import UIKit

class SelectItemWeCMSCell: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var backView         : UIView!
    @IBOutlet weak var itemImage        : UIImageView!
    @IBOutlet weak var selectImage      : UIImageView!
    @IBOutlet weak var itemTitleLabel   : UILabel!
    @IBOutlet weak var itemTypeLabel    : UILabel!
    @IBOutlet weak var itemValueLabel   : UILabel!
    @IBOutlet weak var itemIDLabel      : UILabel!
    @IBOutlet weak var itemIDBtn        : UIButton!
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    //MARK: - Function
    func setupView() {
        self.selectImage.isHidden = true
        itemTitleLabel.getlocalizedFont()
        itemTypeLabel.getlocalizedFont()
        itemValueLabel.getlocalizedFont()
        itemIDLabel.getlocalizedFont()
        
    }
    
    func configCell(data: WABOOKSStruct.RECDoc_Protocol, searchText: String) {
        
        selectImage.isHidden        = true
        
        itemTitleLabel.text         = data.TRCO_CMENM
        itemTypeLabel.text          = data.USAG_NM
        itemValueLabel.text = "\(data.TRCO_TRSC_CCY_CD ?? "") \(customFormatCurrency(CCY_CD: data.TRCO_TRSC_CCY_CD ?? "", amount: data.TOTL_AMT ?? ""))"
        
        itemIDLabel.text = data.DISP_DOC_ID ?? ""
        itemTitleLabel.highlightBackground(forText: searchText, withColor: .yellow)
        itemValueLabel.highlightBackground(forText: searchText, withColor: .yellow)
    }
    
    func deSelectCell() {
        self.backView.backgroundColor = .white
        self.selectImage.isHidden     = true
    }
    
}

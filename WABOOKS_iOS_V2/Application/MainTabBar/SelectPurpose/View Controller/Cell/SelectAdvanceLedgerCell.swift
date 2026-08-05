//
//  SelectAdvanceLedgerCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Bun on 18/10/22.
//

import UIKit

class SelectAdvanceLedgerCell: UITableViewCell {

    @IBOutlet weak var lblTitle     : UILabel!
    @IBOutlet weak var lblSubTitle  : UILabel!
    @IBOutlet weak var btnChoose    : UIButton!
    @IBOutlet weak var btnCover     : UIButton!
    @IBOutlet weak var vContainer   : UIView!
    
    // MARK: - Complition -
    var didTapBtnCoverCompletion        : Completion = {}
    var didTouchDownBtnCoverCompletion  : Completion = {}
    var didTapOutsideBtnCoverCompeltion : Completion = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupLocalized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupLocalized() {
        lblTitle.getlocalizedFont()
        lblSubTitle.getlocalizedFont()
    }
    
    func styleSelectedCell(isSelected: Bool) {
        if isSelected {
            self.vContainer.backgroundColor = UIColor(hexString: "F5F9FC")
            self.btnChoose.isSelected       = true
            self.lblTitle.textColor         = UIColor(hexString: "0069B9")
            self.lblTitle.font              = UIFont(name: "Inter-Medium", size: 15) //Init default font
            self.lblTitle.getlocalizedFont()
        }
        else {
            self.vContainer.backgroundColor = UIColor(hexString: "FFFFFF")
            self.btnChoose.isSelected       = false
            self.lblTitle.textColor         = UIColor(hexString: "080829")
            self.lblTitle.font              = UIFont(name: "Inter-Medium", size: 15) //Init default font
            self.lblTitle.getlocalizedFont()
        }
    }
 
    @IBAction func didTapOutSideBtnCover(_ sender: UIButton) {
        didTapOutsideBtnCoverCompeltion()
    }
    
    @IBAction func didTapBtnCover(_ sender: UIButton) {
        self.didTapBtnCoverCompletion()
    }
    
    @IBAction func didTouchDownBtnCover(_ sender: UIButton) {
        self.didTouchDownBtnCoverCompletion()
    } 
}

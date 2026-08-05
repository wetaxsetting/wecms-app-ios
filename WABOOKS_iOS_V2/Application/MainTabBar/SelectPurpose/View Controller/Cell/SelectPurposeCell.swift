//
//  SelectPurposeCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Thea Chum on 13/1/21.
//

import UIKit

class SelectPurposeCell: UITableViewCell {

    // MARK: - IBOutlets -
    @IBOutlet weak var imgViewLogo      : UIImageView!
    @IBOutlet weak var lblTitle         : UILabel!
    @IBOutlet weak var btnChoose        : UIButton!
    @IBOutlet weak var cstWImgViewLogo  : NSLayoutConstraint!
    @IBOutlet weak var vContainer       : UIView!
    @IBOutlet weak var btnCover         : UIButton!
    
    // MARK: - Complition -
    var didTapBtnCoverCompletion        : Completion = {}
    var didTouchDownBtnCoverCompletion  : Completion = {}
    var didTapOutsideBtnCoverCompeltion : Completion = {}
    
    // MARK: - Life Cycle -
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func setupView() {
        cstWImgViewLogo.constant = 0 //logo is hidden
        self.lblTitle.getlocalizedFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func styleSelectedCell(isSelected: Bool) {
        if isSelected {
            self.vContainer.backgroundColor = UIColor(hexString: "F5F9FC")
            self.btnChoose.isSelected       = true
            self.lblTitle.textColor         = UIColor(hexString: "0069B9")
//            self.lblTitle.font              = UIFont(name: "Inter-Medium", size: 15) //Init default font
        }
        else {
            self.vContainer.backgroundColor = UIColor(hexString: "FFFFFF")
            self.btnChoose.isSelected       = false
            self.lblTitle.textColor         = UIColor(hexString: "080829")
//            self.lblTitle.font              = UIFont(name: "Inter-Regular", size: 15) //Init default font
        }
    }
    
    @IBAction func didTapOutSideBtnCover(_ sender: UIButton) {
        didTapOutsideBtnCoverCompeltion()
    }
    
    @IBAction func didTapBtnCover(_ sender: UIButton) {
        self.didTapBtnCoverCompletion()
    }
    
    @IBAction func didTouchDownBtnCover(_ sender: UIButton) {
//        self.didTouchDownBtnCoverCompletion()
    }
    
}

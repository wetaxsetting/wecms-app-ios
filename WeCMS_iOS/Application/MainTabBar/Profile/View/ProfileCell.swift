//
//  ProfileCell.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 12/1/21.
//

import UIKit

enum ProfileCellType : String, CaseIterable {
    case Normal     = "Normal"
    case Detail     = "Detail"
}

class ProfileCell: UITableViewCell {

    @IBOutlet weak var vContainer               : UIView!
    @IBOutlet weak var imgViewLogo              : UIImageView!
    @IBOutlet weak var lblTitle                 : UILabel!
    @IBOutlet weak var lblValue                 : UILabel!
    @IBOutlet weak var imgViewArrow             : UIImageView!
    @IBOutlet weak var cstWidthImgViewArrow     : NSLayoutConstraint!
    @IBOutlet weak var newLab: UILabel!
    @IBOutlet weak var cstTrailingImgViewArrow  : NSLayoutConstraint!
    @IBOutlet weak var lineView                 : UIView!
//    @IBOutlet weak var updateIcon: UIImageView!
    @IBOutlet weak var newUpdateView: UIView!
    // MARK: - Public -
    var type : ProfileCellType = .Normal
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupLocalized()
    }
    
    func configCell(imgStr: String, title: String, value: String, type: ProfileCellType) {
        lblTitle.text   = title
        lblValue.text   = value
        self.type       = type
        
        //ImgView
        imgViewLogo.image = UIImage(named: imgStr)
        
        setupView()
    }
    
    func setHideLineView(isHidden: Bool = true) {
        self.lineView.isHidden = isHidden
    }
    
    private func setupLocalized() {
        self.lblTitle.getlocalizedFont()
        self.lblValue.getlocalizedFont()
    }

    private func setupView() {
        let isTypeDetail = type == .Detail
        
        newUpdateView.backgroundColor    = .clear
        newUpdateView.layer.borderColor  = #colorLiteral(red: 0.8801110387, green: 0.8801110387, blue: 0.8801110387, alpha: 1)
        newUpdateView.layer.borderWidth  = 1
        newUpdateView.layer.cornerRadius = 10
        
        lblValue.textColor               = isTypeDetail ? UIColor(hexString: "0069B9") : UIColor(hexString: "494949")
        lblValue.font                    = isTypeDetail ? UIFont(name: "Inter-Bold", size: 15) : UIFont(name: "Inter-Medium", size: 15)
        cstWidthImgViewArrow.constant    = isTypeDetail ? 24 : 0 //Hide/Show ImgViewArrow
        cstTrailingImgViewArrow.constant = isTypeDetail ? 10 : 20
//        imgViewArrow.image               = isTypeDetail ? UIImage(named: "list_dropdown_ico") : UIImage(named: "list_dropdown_ico")
    }
    
//    private func setupViewDropdown() {
//        let isTypeDetail = type == .Dropdown
//
//        lblValue.textColor               = isTypeDetail ? UIColor(hexString: "0069B9") : UIColor(hexString: "494949")
//        lblValue.font                    = isTypeDetail ? UIFont(name: "Inter-Bold", size: 15) : UIFont(name: "Inter-Medium", size: 15)
//        cstWidthImgViewArrow.constant    = isTypeDetail ? 24 : 0 //Hide/Show ImgViewArrow list_dropdown_ico
//        cstTrailingImgViewArrow.constant = isTypeDetail ? 10 : 20
//
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

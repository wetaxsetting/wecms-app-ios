//
//  ChooseLanguageCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Thea Chum on 11/1/21.
//

import UIKit

class ChooseLanguageCell: UITableViewCell {
    // MARK: - IBOutlets -
    @IBOutlet weak var lblTitle         : UILabel!
    @IBOutlet weak var btnChoose        : UIButton!
    @IBOutlet weak var viewContainer    : UIView!
    @IBOutlet weak var btnCover         : UIButton!
    
    // MARK: - Complition -
    var didTapBtnCoverComplition        : (Int) -> Void = { _ in }
    var didTouchDownChooseBtnComplition : (Int) -> Void = { _ in }
    var didDragExitChooseBtnComplition  : Completion = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.getlocalizedFont()
    }
    
    // MARK: - Public -
    func configCell(title: String, imageStr: String, isSelected: Bool) {
        lblTitle.text           = title
     
        //btn
        btnChoose.setImage(UIImage(named: "\(imageStr)\(isSelected ? "on" : "off")"), for: isSelected ? .selected : .normal)
        btnChoose.setImage(UIImage(named: "\(imageStr)on"), for: .highlighted)
        btnChoose.setImage(UIImage(named: "\(imageStr)on"), for: .selected)
        btnChoose.isSelected            = isSelected
        //View
        viewContainer.backgroundColor   = isSelected ? UIColor(hexString: "EBF7FF") : UIColor(hexString: "FFFFFF") //F5F9FC
        viewContainer.layer.borderColor = isSelected ? UIColor(hexString: "0069B9").cgColor : UIColor(hexString: "DCE6EF").cgColor

        //title
        self.lblTitle.textColor         = isSelected ? UIColor(hexString: "0069B9") : UIColor(hexString: "494949")//F5F9FC
        self.lblTitle.font              = UIFont(name: "Inter-Bold", size: 15)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - IBActions -
    
    @IBAction func didTouchDownBtnCover(_ sender: UIButton) {
        self.didTouchDownChooseBtnComplition(sender.tag)
    }
    
    @IBAction func didDragExitBtnCover(_ sender: UIButton) {
        self.didDragExitChooseBtnComplition()
    }
    
    @IBAction func didTapBtnChoose(_ sender: UIButton) {
        self.didTapBtnCoverComplition(sender.tag)
    }
    
}

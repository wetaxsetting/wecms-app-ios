//
//  SelectItemCell.swift
//  WeCMS_iOS
//
//  Created by Seanghay Huort on 17/1/24.
//

import UIKit

class SelectItemCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var itemImage        : UIImageView!
    @IBOutlet weak var selectImage      : UIImageView!
    @IBOutlet weak var itemTitleLabel   : UILabel!
    @IBOutlet weak var itemTypeLabel    : UILabel!
    @IBOutlet weak var itemValueLabel   : UILabel!
    @IBOutlet weak var itemIDLabel      : UILabel!
    @IBOutlet weak var itemIDBtn        : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectImage.isHidden = true
        itemTitleLabel.getlocalizedFont()
        itemTypeLabel.getlocalizedFont()
        itemValueLabel.getlocalizedFont()
        itemIDLabel.getlocalizedFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - Customize func
    func setupImageForReceipt(imageURL: String) {
        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
        let split_url       = imageURL.components(separatedBy: "?")
        let img_url         = "\(split_url.first ??  "")?token=\(authorization)&\(split_url.last ?? "")" + "&\(imageURL )"
        let url             = URL(string: "\(img_url)")
        self.itemImage.sd_setImage(with: url, completed: { (image, error, SDImageCacheType, url) in
            if error == nil { // Success
//                
//                self.skeletonView.isHidden = true
                
                let size        = image?.size
                var widthPic    : CGFloat = 0
                var heightPic   : CGFloat = 0
                
                widthPic        = (size?.width)!
                heightPic       = (size?.width)!
                 
                // The shortest side
                let sideLength      = min(widthPic, heightPic)
                
                // Determines the x,y coordinate of a centered
                // sideLength by sideLength square
                let xOffset         = ((size?.width)! - sideLength) / 2.0
                let yOffset         = ((size?.height)! - sideLength) / 2.0
                let cropImg         : CGRect    = CGRect(x: xOffset, y: yOffset, width: widthPic, height: heightPic)
                
                let cgImage         : CGImage   = image!.cgImage!.cropping(to: cropImg)!
                let croppedImage    : UIImage   = UIImage(cgImage: cgImage)
                
                /// ImageView
                self.itemImage.contentMode     = .scaleAspectFill
                self.itemImage.clipsToBounds   = true
                self.itemImage.image           = croppedImage
                
            }
            else {
//                self.skeletonView.isHidden = true
                self.itemImage.image        = UIImage(named: "ico_user-1")
                self.itemImage.contentMode  = .scaleAspectFill
            }
        })
    }
    
    func configCell(data: WeCMSStruct.RECDoc_Protocol, searchText: String){
        selectImage.isHidden        = true
        itemTitleLabel.text         = data.TRCO_CMENM
        itemTypeLabel.text          = data.USAG_NM
        self.itemValueLabel.text = "\(data.TRCO_TRSC_CCY_CD ?? "") \(customFormatCurrency(CCY_CD: data.TRCO_TRSC_CCY_CD ?? "", amount: data.TOTL_AMT ?? ""))"
        
//        itemIDBtn.setTitle(data.DOC_ID ?? "", for: .normal)
        itemIDLabel.text = data.DISP_DOC_ID ?? ""
        itemTitleLabel.highlightBackground(forText: searchText, withColor: .yellow)
        itemValueLabel.highlightBackground(forText: searchText, withColor: .yellow)
    }
    
    func configCellApprovers(data: SelectApproversItem, searchText: String){
        
        selectImage.isHidden = true
        setupImageForReceipt(imageURL: data.USER_IMG_URL ?? "")
        itemTitleLabel.text = data.USER_NM
        itemTypeLabel.text  = data.USER_ID
        itemValueLabel.text = ""
//        itemIDBtn.setTitle("", for: .normal)
        itemIDLabel.text = ""
        itemTitleLabel.highlightBackground(forText: searchText, withColor: .yellow)
        itemValueLabel.highlightBackground(forText: searchText, withColor: .yellow)
    }
    
    func configSelectImage(selectCount: Int) { //> Seanghay <\\ check for select approvers number
        switch selectCount {
        case 1:
            self.selectImage.image = UIImage(named: "round_number1")
        case 2:
            self.selectImage.image = UIImage(named: "round_number2")
        case 3:
            self.selectImage.image = UIImage(named: "round_number3")
        case 4:
            self.selectImage.image = UIImage(named: "round_number4")
        default:
            self.selectImage.image = UIImage(named: "round_check")
        }
    }
    
    func deSelectCell() {
        self.backView.backgroundColor   = .white
        self.itemImage.image            = UIImage(named: "radio_btn_off")
    }

}

extension UILabel {
    func highlightBackground(forText text: String, withColor color: UIColor) {
        guard let labelText = self.text else { return }
        
        let attributedString = NSMutableAttributedString(string: labelText)
        let range = (labelText.lowercased() as NSString).range(of: text)
        
        attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: color, range: range)
        
        self.attributedText = attributedString
    }
}

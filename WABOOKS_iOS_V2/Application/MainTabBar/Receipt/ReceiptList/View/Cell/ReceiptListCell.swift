//
//  ReceiptWithImageCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 8/1/21.
//

import UIKit
import SDWebImage
import SkeletonView

class ReceiptListCell: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var labelTitle               : UILabel!
    @IBOutlet weak var labelValue               : UILabel!
    @IBOutlet weak var labelDate                : UILabel!
    @IBOutlet weak var skeletonView             : UIView!
    @IBOutlet weak var imgImageView             : UIImageView!
    @IBOutlet weak var constraintHeightImageView: NSLayoutConstraint!
    @IBOutlet weak var constraintTopImageView   : NSLayoutConstraint!
    @IBOutlet weak var constraintTopMutiIconImageView: NSLayoutConstraint!
    @IBOutlet weak var trallingValueLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var addContentBtn: UIButton!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var conBtn: UIButton!
    @IBOutlet weak var einvoiceLbl: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dateWidthConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var documentView             : UIView!
    @IBOutlet weak var documentHeightConstant   : NSLayoutConstraint!
    @IBOutlet weak var documentTopConstant      : NSLayoutConstraint!
    @IBOutlet weak var documentTitle            : UILabel!
    @IBOutlet weak var documentImage            : UIImageView!
    @IBOutlet weak var documentType             : UILabel!
    
    
    var receiptList : [[WABOOKS_MREC_R006.RESPONSE.REC]]?
    
    let eInvoiceVM  = EInvoiceVM()
    
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupLocalized()
     
        
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 6)
        stackView.isLayoutMarginsRelativeArrangement = true
      
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupLocalized() {
        self.einvoiceLbl.getlocalizedFont()
        self.labelTitle.getlocalizedFont()
        self.labelDate.getlocalizedFont()
        self.labelValue.getlocalizedFont()
    }
    
    //MARK: - Customize func
    func configCell(hasNoImage  : Bool,
                    title       : String,
                    value       : String,
                    currency type: String = "",
                    week        : String,
                    date        : String,
                    img url     : String = "",
                    isMultiImage: Bool,
                    isShowEInvoice: Bool,
                    isEInvoiceConn: Bool,
                    isShow: Bool,
                    isDocument: Bool,
                    documentTitle: String,
                    documentType : String
    ) {
        
        
        let newTitle = hasNoImage ? (title.isEmpty ? "archived_image".localized : title) : title
        
        self.einvoiceLbl.text = isEInvoiceConn ? "linked".localized : "link_e_invoice".localized
        self.labelTitle.text    = newTitle
        self.labelDate.text     = customFormatteDate(date: date, week: week.localized)
        
        trallingValueLabelConstraint.constant = hasNoImage ? -20 : 0
        
        
        self.addContentBtn.isHidden     = (hasNoImage ? true : false)
        self.conBtn.isHidden            = isShowEInvoice
        self.stackView.isHidden         = isShowEInvoice
        self.stackView.backgroundColor  = UIColor(hexString: isEInvoiceConn ? "#ECEFF1" : "#0069B9")
        
        self.einvoiceLbl.textColor      = UIColor(hexString: isEInvoiceConn ? "#666666" : "#ECEFF1")
        self.iconBtn.tintColor          = UIColor(hexString: isEInvoiceConn ? "#666666" : "#ECEFF1")
        
        // Hide show image base on receipt type
        imgImageView.isHidden                   = isDocument
        constraintHeightImageView.constant      = hasNoImage ? 0 : 93
        constraintTopImageView.constant         = hasNoImage ? 0 : 10
        constraintTopMutiIconImageView.constant = hasNoImage ? 0 : (isMultiImage  ? 30 : 0)
        
        documentView.isHidden           = !isDocument
        documentHeightConstant.constant = hasNoImage ? 0 : 93
        documentTopConstant.constant    = hasNoImage ? 0 : 10
        self.documentType.isHidden           = hasNoImage
        self.documentTitle.isHidden          = hasNoImage
        documentImage.isHidden               = hasNoImage
        self.documentType.text               = documentType.uppercased()
        self.documentTitle.text              = documentTitle
        self.documentImage.image             = UIImage(named: "attach_\(documentType)")
        
             
        self.labelValue.text = hasNoImage ? "\(type) \(customFormatCurrency(CCY_CD: type, amount: value))" : value
        
        self.setupImageForReceipt(imageURL: url)
    }
    
    func setupImageForReceipt(imageURL: String) {
        
        //setup skeleton
        self.skeletonView.isHidden          = false
        self.skeletonView.backgroundColor   = .white
        self.skeletonView.isSkeletonable    = true
        self.skeletonView.showAnimatedGradientSkeleton()
         
        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
        let split_url       = imageURL.components(separatedBy: "?")
        let img_url         = "\(split_url.first ?? "")?token=\(authorization)&\(split_url.last ?? "")"
        let url             = URL(string: "\(img_url)&cmd=getthumb") // set &cmd=getthumb **only in receipt list
         
        self.imgImageView.sd_setImage(with: url, completed: { (image, error, SDImageCacheType, url) in
            if error == nil { // Success
                self.skeletonView.isHidden = true
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
                self.imgImageView.contentMode     = .scaleAspectFill
                self.imgImageView.clipsToBounds   = true
                self.imgImageView.image           = croppedImage
                
            }
            else {
                self.skeletonView.isHidden      = true
                self.imgImageView.image         = UIImage(named: "noimage")
                self.imgImageView.contentMode   = .scaleAspectFill
            }
            
        })
    }
}
  
extension ReceiptListCell: EInvoiceDelagate {
    // Here we go:
    func setData(eInvoice: EInvoiceModel?) {
        print("data EInvoice \(eInvoice!)")
    }
    
}

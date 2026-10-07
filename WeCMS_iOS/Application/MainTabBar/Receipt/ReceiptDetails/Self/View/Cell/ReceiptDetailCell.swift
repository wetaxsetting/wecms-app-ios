//
//  ReceiptDetailCell.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 11/1/21.
//

import UIKit
import SDWebImage
import SkeletonView

class ReceiptDetailCell: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var labelTitle   : UILabel!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelValue   : UILabel!
    
    var strCurency : String = ""
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpCell(row: ReceiptDetailsRow.receiptRow.contents) {
        
        let mappingRow = ReceiptRow(rawValue: row.code)
         
        self.labelValue.getlocalizedFont()
        self.labelTitle.getlocalizedFont()
        
        switch mappingRow {
  
        case.WITH_HOLDING_TAX :
            
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "content_cut_black_24dp")
            self.labelValue.text        = row.value
            
        case.TAX_AMOUNT :
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "money_black_24dp")
            self.labelValue.text        = self.strCurency == "USD" ? row.value?.usdCurrency : row.value?.formatKHRCurrency()
        case .PURPOSE:
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "list_purpose_ico")
            self.labelValue.text        = row.value
            
        case .TEL:
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "list_phone_number_ico")

//            if let tel = (row.value?.components(separatedBy: "-").last?.prefix(1)), tel.contains("0") {
//                let tel = "098765445"
//                self.labelValue.text    = String(tel).applyPatternOnNumbers(pattern: "#########", replacmentCharacter: "#")
//            } else{
//                self.labelValue.text    = row.value?.components(separatedBy: "-").last?.applyPatternOnNumbers(pattern: "0########", replacmentCharacter: "#")
//            }
            
            self.labelValue.text        = row.value
            
            
        case .EMAIL:
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "list_email.ico")
            self.labelValue.text        = row.value
            
        case .ADDRESS:
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "list_addr_ico")
            self.labelValue.text        = row.value
        
        case .MERCHANT:
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "list_merchant_ico")
            self.labelValue.text        = row.value
            
        case .DATE:
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "list_debit_date_ico")
            self.labelValue.text        = formatteDate(date: row.value ?? "")
             
        case .ADVANCELEDGER:
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "list_advance_ledger_ico")
            self.labelValue.text        = row.value
            
        case .DEBITDATE:
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "list_debit_date_ico")
            self.labelValue.text        = formatteDate(date: row.value ?? "")
          
        case .USER:
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "list_user_ico")
            self.labelValue.text        = row.value
            
        case .DESCRIPTION:
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "list_descrip_ico")
            self.labelValue.text        = row.value
            
        case .PAYMENT_METHOD:
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "list_wallet_symbol")
            self.labelValue.text        = row.value
            
        case .IMPORT_TRANSACTION:
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "list_import_symbol")
            self.labelValue.text        = row.value
            
        case .BANK:
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "list_account_balance_symbol")
            self.labelValue.text        = row.value
            
        case .PROJECT_SITE:
            self.labelTitle.text        = mappingRow?.description.localized
            self.imageViewIcon.image    = UIImage(named: "project_site_ico")
            self.labelValue.text        = row.value
            
        default: break
        }
    }

}


class HeaderReceiptDetailsCell: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var labelTitle           : UILabel!
    @IBOutlet weak var labelDate            : UILabel!
    @IBOutlet weak var lblReceiptNo         : UILabel!
    @IBOutlet weak var lblMerchant          : UILabel!
    @IBOutlet weak var lblTaxablePersonTaxID: UILabel!
    
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Customize func
    func configCell(title: String, date: String, week: String = "", receipt_no: String = "", merchant: String = "", taxable: String = "", tax_id: String = "") {
        
         
        self.labelDate.text             = formatteDate(date: date, week: week.localized)
        self.labelTitle.text            = title
        self.lblReceiptNo.text          = receipt_no
        self.lblMerchant.text           = merchant
        
        if taxable.isEmpty && tax_id.isEmpty {
            self.lblTaxablePersonTaxID.text = ""
        }
        else {
            self.lblTaxablePersonTaxID.text = "\(taxable) \(tax_id)"
        }
        
        self.lblTaxablePersonTaxID.isHidden = true
         
        self.labelTitle.getlocalizedFont()
        self.labelDate.getlocalizedFont()
        self.lblReceiptNo.getlocalizedFont()
        self.lblMerchant.getlocalizedFont()
        self.lblTaxablePersonTaxID.getlocalizedFont()
    }

}

    
class AttachmentDetailsCell: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var labelAttachment          : UILabel!
    @IBOutlet weak var imageViewImg             : UIImageView!
    @IBOutlet weak var skeletonView             : UIView!
    @IBOutlet weak var constaintHeighImageView  : NSLayoutConstraint!
     
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setLocalized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(img url: String = "", isMultiImage: Bool) {
        DispatchQueue.main.async {
            self.constaintHeighImageView.constant = isMultiImage ? 36 : 0
            self.setupImageForReceipt(imageURL: url)
        }
    }
     
    //MARK: - Customize func
    func setupImageForReceipt(imageURL: String) {
        //setup skeleton
        
        skeletonView.isHidden           = false
        skeletonView.backgroundColor    = .white
        skeletonView.isSkeletonable     = true
        skeletonView.showAnimatedGradientSkeleton()
        
        let url             = URL(string: "\(imageURL)&cmd=getthumb")
        
        self.imageViewImg.sd_setImage(with: url, completed: { (image, error, SDImageCacheType, url) in
            self.skeletonView.isHidden       = true
            self.skeletonView.isSkeletonable = false
            self.skeletonView.stopSkeletonAnimation()
            if error == nil { // Success
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
                self.imageViewImg.contentMode     = .scaleAspectFill
                self.imageViewImg.clipsToBounds   = true
                self.imageViewImg.image           = croppedImage
                self.imageViewImg.isUserInteractionEnabled = true
            }
            else {
                self.skeletonView.isHidden       = true
                
                self.imageViewImg.image         = UIImage(named: "noimage")!
                self.imageViewImg.contentMode   = .scaleAspectFill
                self.imageViewImg.isUserInteractionEnabled = false
            }
        })
    }
    
    private func setLocalized() {
        self.labelAttachment.text = ReceiptRow.ATTACHMEMNT.description.localized
        self.labelAttachment.getlocalizedFont()
    }

}

class MultiAttachmentDetailCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle         : UILabel!
    @IBOutlet weak var collectionView   : UICollectionView!
    
    private var indexOfMajorCell            : Int = 0
    private var indexOfCellBeforeDragging   : Int = 0
    
    let attachments : [String] = ["", "", "", "", ""]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //set left inset to 59
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 54, bottom: 0, right: 0)
        
        
        self.lblTitle.text = "attachment".localized
        self.lblTitle.getlocalizedFont()
    }
    
    private func indexOfCell() -> Int {
        let itemWidth           = self.collectionView.bounds.width
        let proportionalOffset  = self.collectionView.contentOffset.x / itemWidth
        let index               = Int(round(proportionalOffset))
        let safeIndex           = max(0, min(self.attachments.count - 1, index))
        return safeIndex
    }
    
    private func sizeForItem(paddingSize: CGFloat, itemWidth: CGFloat, itemHeight: CGFloat, numberOfItems: CGFloat, heightOfAnyComponent: CGFloat = 0.0) -> CGSize {
        let screenSize      = UIScreen.main.bounds.width
        let ratio           = itemHeight / itemWidth
        let dynamicWidth    = (screenSize - paddingSize) / numberOfItems
        let dynamicHeight   = dynamicWidth * ratio
        let size            = CGSize(width: dynamicWidth, height: dynamicHeight + heightOfAnyComponent)
        return size
    }
    
}

class MultiAttachImageCell: UICollectionViewCell {
    @IBOutlet weak var closeBtn                  : UIButton!
    @IBOutlet weak var skeletonView              : UIView!
    @IBOutlet weak var attachmentImgView         : UIImageView!
    @IBOutlet weak var attachmentImgViewCoverBtn : UIButton!
    @IBOutlet weak var constaintHeightImageView  : NSLayoutConstraint!
    
    /// Completion
    var didTapCloseCompletion   : Completion = {}
    var didTapPreviewImage      : Completion = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        closeBtn.isHidden = true
    }
    
    // MARK: - Actions -
    @IBAction func didTapCloseBtn(_ sender: UIButton) {
        didTapCloseCompletion()
    }
    
    @IBAction func didTapAttachmentBtn(_ sender: UIButton) {
        didTapPreviewImage()
    }
    
    func configCell(img url: String = "", isMultiImage: Bool) {
        DispatchQueue.main.async {
            self.constaintHeightImageView.constant = isMultiImage ? 24 : 0
            self.loadImage(imageURL: url)
        }
    }
    
    func loadImage(imageURL: String) {
        //setup skeleton
        
        skeletonView.isHidden           = false
        skeletonView.backgroundColor    = .white
        skeletonView.isSkeletonable     = true
        skeletonView.showAnimatedGradientSkeleton()
        
        let url             = URL(string: "\(imageURL)&cmd=getthumb")
        
        self.attachmentImgView.sd_setImage(with: url, completed: { (image, error, SDImageCacheType, url) in
            self.skeletonView.isHidden       = true
            self.skeletonView.isSkeletonable = false
            self.skeletonView.stopSkeletonAnimation()
            if error == nil { // Success
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
                self.attachmentImgView.contentMode     = .scaleAspectFill
                self.attachmentImgView.clipsToBounds   = true
                self.attachmentImgView.image           = croppedImage
                self.attachmentImgView.isUserInteractionEnabled = true
            }
            else {
                self.skeletonView.isHidden       = true
                
                self.attachmentImgView.image         = UIImage(named: "noimage")!
                self.attachmentImgView.contentMode   = .scaleAspectFill
                self.attachmentImgView.isUserInteractionEnabled = false
            }
        })
    }
    
    func setupSkeleton() {
        //setup skeleton
        skeletonView.isHidden           = false
        skeletonView.backgroundColor    = .white
        skeletonView.isSkeletonable     = true
        skeletonView.showAnimatedGradientSkeleton()
    }
    
}

class MultiAttachFileCell: UICollectionViewCell {
    
    @IBOutlet weak var fileTitleLabel   : UILabel!
    @IBOutlet weak var fileImage        : UIImageView!
    @IBOutlet weak var fileTypeLabel    : UILabel!
    @IBOutlet weak var openAttachFileButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func didTapOpenAttachFileAction(_ sender: Any) {
        
    }
    
    //For request from api MREC_R006
    func configReceiptDetailCell(data: MREC_R006.RESPONSE.REC.REC1?) {
        let fileName = data?.ORG_FILE_NM?.components(separatedBy: ".")
        let fileInfo = fileName?.last ?? ""

        self.fileTitleLabel.text = data?.ORG_FILE_NM
        self.fileImage.image     = UIImage(named: "attach_\(fileInfo)")
        self.fileTypeLabel.text  = fileInfo.uppercased()
    }
    
    // For request from api MREC_R009
    func configReceiptDetailCellNew (data : MREC_R009.RESPONSE.REC1) {
        
        let fileName = data.ORG_FILE_NM?.components(separatedBy: ".")
        let fileInfo = fileName?.last ?? ""

        self.fileTitleLabel.text = data.ORG_FILE_NM
        self.fileImage.image     = UIImage(named: "attach_\(fileInfo)")
        self.fileTypeLabel.text  = fileInfo.uppercased()
        
    }
}

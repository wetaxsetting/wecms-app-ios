//
//  MultiAttachmentCell.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 7/7/21.
//

import UIKit

import UIKit

class MultiAttachmentCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle         : UILabel!
    @IBOutlet weak var collectionView   : UICollectionView!
    @IBOutlet weak var dotImg           : UIImageView!
    
    private var indexOfMajorCell            : Int = 0
    private var indexOfCellBeforeDragging   : Int = 0
    
    let attachments : [String] = ["", "", "", "", ""]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //set left inset to 59
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 54, bottom: 0, right: 0)
        
        
        self.lblTitle.text = "attachment".localized
        self.lblTitle.getlocalizedFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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











class MultiImageCell : UICollectionViewCell {
    // MARK: - IBOutlets -
    @IBOutlet weak var closeBtn                  : UIButton!
    @IBOutlet weak var skeletonView              : UIView!
    @IBOutlet weak var attachmentImgView         : UIImageView!
    @IBOutlet weak var attachmentImgViewCoverBtn : UIButton!
    @IBOutlet weak var imgView                   : UIImageView!
    
    /// Completion
    var didTapCloseCompletion   : Completion = {}
    var didTapPreviewImage      : Completion = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        closeBtn.isHidden = true
    }
    
    func loadImage(imageURL: String) {
        /// add authorization to image url
     
        self.setupSkeleton()

        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
        let split_url       = imageURL.components(separatedBy: "?")
        let img_url         = "\(split_url.first ?? "")?token=\(authorization)&\(split_url.last ?? "")"
        let url             = URL(string: "\(img_url)&cmd=getthumb")
        
        
        self.attachmentImgView.sd_setImage(with: url, completed: { (image, error, SDImageCacheType, url) in
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
                self.attachmentImgView.contentMode     = .scaleAspectFill
                self.attachmentImgView.clipsToBounds   = true
                self.attachmentImgView.image           = croppedImage
                self.attachmentImgView.isUserInteractionEnabled = true
            }
            else { // fail to load img
                self.skeletonView.isHidden          = true
                self.attachmentImgView.image        = UIImage(named: "noimage")
                self.attachmentImgView.contentMode  = .scaleAspectFill
                self.attachmentImgView.isUserInteractionEnabled = false
            }
        })
    }
    
    // MARK: - Actions -
    @IBAction func didTapCloseBtn(_ sender: UIButton) {
        didTapCloseCompletion()
    }
    
    @IBAction func didTapAttachmentBtn(_ sender: UIButton) {
        didTapPreviewImage()
    }
    
    func setupSkeleton() {
        //setup skeleton
        skeletonView.isHidden           = false
        skeletonView.backgroundColor    = .white
        skeletonView.isSkeletonable     = true
        skeletonView.showAnimatedGradientSkeleton()
    }
    
}


class AddMultiImageCell : UICollectionViewCell {
    @IBOutlet weak var addBtn   : UIButton!
    
    var didTapAddBtnCompletion  : Completion = {}
    
    @IBAction func didTabAddBtn(_ sender: UIButton) {
        didTapAddBtnCompletion()
    }
}

class MultiFileCell : UICollectionViewCell {
    @IBOutlet weak var fileTitleLabel   : UILabel!
    @IBOutlet weak var fileImage        : UIImageView!
    @IBOutlet weak var fileTypeLabel    : UILabel!
    @IBOutlet weak var openAttachFileButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func didTapOpenAttachFileAction(_ sender: Any) {
        
    }
    
    func configReceiptSubmitCell(data: MREC_R006.RESPONSE.REC.REC1?) {
        let fileType = data?.ORG_FILE_NM?.components(separatedBy: ".").last ?? ""
        self.fileTitleLabel.text    = data?.ORG_FILE_NM?.removingPercentEncoding
        self.fileImage.image        = UIImage(named: "attach_\(fileType)")
        self.fileTypeLabel.text     = fileType.uppercased()
    }
    
    func configAddReceiptCell(data: FileModel?) {
        let fileType = data?.fileName.components(separatedBy: ".").last ?? ""
        self.fileTitleLabel.text    = data?.fileName.removingPercentEncoding
        self.fileImage.image        = UIImage(named: "attach_\(fileType)")
        self.fileTypeLabel.text     = fileType.uppercased()
    }

}

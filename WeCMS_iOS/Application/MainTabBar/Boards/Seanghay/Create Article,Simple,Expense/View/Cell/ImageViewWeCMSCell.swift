//
//  ImageViewWeCMSCell.swift
//  WeCMS_iOS
//
//  Created by lymanny on 20/1/25.
//

import UIKit
import SDWebImage
import SkeletonView

class ImageViewWeCMSCell: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var iImage           : UIImageView!
    @IBOutlet weak var valueImage       : UIImageView!
    @IBOutlet weak var imageContainView : UIView!
    @IBOutlet weak var deleteButton     : UIButton!
    
    //MARK: - Properties & Variable
    var isHaveImage = true
    var callback    : (UIImage) -> Void = {_ in }
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        valueImage.image                = UIImage(named: "")
        self.imageContainView.isHidden  = true
    }
    
    //MARK: - Function
    func configImage(data: ApprovalContent ) {
        let size        = data.insertImage?.size
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
        let cropImg         : CGRect    = CGRect(x: xOffset, y: yOffset, width: widthPic, height: heightPic).integral
        
        let sourceCGImage = data.insertImage?.cgImage!
        let croppedCGImage = (sourceCGImage?.cropping(
            to: cropImg
        )!)!
        let croppedImage    : UIImage   = UIImage(cgImage: croppedCGImage)
        
        /// ImageView
        self.valueImage.contentMode     = .scaleAspectFill
        self.valueImage.clipsToBounds   = true
        self.valueImage.image           = croppedImage
        
    }
    
    func setupImageForReceipt2(imageURL: String) {
        
        guard let imageData = Data(base64Encoded: imageURL) else {return}
        let image = UIImage(data: imageData)
        
        let size        = image?.size
        var widthPic    : CGFloat?
        var heightPic   : CGFloat?
        
        widthPic        = (size?.width)
        heightPic       = (size?.width)
        
        // The shortest side
        let sideLength      = min(widthPic ?? 0, heightPic ?? 0)
        
        // Determines the x,y coordinate of a centered
        // sideLength by sideLength square
        let xOffset         = ((size?.width ?? 0) - sideLength) / 2.0
        let yOffset         = ((size?.height ?? 0) - sideLength) / 2.0
        let cropImg         : CGRect    = CGRect(x: xOffset, y: yOffset, width: widthPic ?? 0, height: heightPic ?? 0)
        
        guard let cgImage   = image?.cgImage?.cropping(to: cropImg) else {return}
        let croppedImage    : UIImage   = UIImage(cgImage: cgImage)
        
        /// ImageView
        self.valueImage.contentMode     = .scaleAspectFill
        self.valueImage.clipsToBounds   = true
        self.valueImage.image           = croppedImage
    }
    
    func setupImageForReceipt(imageURL: String) {
        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
        let split_url       = imageURL.components(separatedBy: "?")
        let img_url         = "\(split_url.first ??  "")?token=\(authorization)&\(split_url.last ?? "")" + "&\(imageURL )"
        let url             = URL(string: "\(img_url)")
        self.valueImage.sd_setImage(with: url, completed: { (image, error, SDImageCacheType, url) in
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
                self.valueImage.contentMode     = .scaleAspectFill
                self.valueImage.clipsToBounds   = true
                self.valueImage.image           = croppedImage
                
            }
            else {
                //                self.skeletonView.isHidden = true
                self.valueImage.image        = UIImage(named: "noimage")
                self.valueImage.contentMode  = .scaleAspectFill
            }
        })
    }
    
    //EditArticle
    func configImageEditArticle(data: EditArticleData ) {
        
        let rawDataFromApi = data.insertImage?.contains("\(Shared.c_web_base_url)") ?? false
        if data.insertImage == "" {
            self.valueImage.image        = UIImage(named: "noimage")
            self.valueImage.contentMode  = .scaleAspectFill
        }else{
            if rawDataFromApi {
                setupImageForReceipt(imageURL: data.insertImage ?? "")
            } else {
                setupImageForReceipt2(imageURL: data.insertImage ?? "")
            }
        }
        
    }
    
    //Post To Board
    func configImageDraft(data: ApprovalContent ) {
        
        let rawDataFromApi = data.fileData?.contains("\(Shared.c_web_base_url)") ?? false
        if data.fileData == "" {
            self.valueImage.image        = UIImage(named: "noimage")
            self.valueImage.contentMode  = .scaleAspectFill
        }else{
            if rawDataFromApi {
                setupImageForReceipt(imageURL: data.fileData ?? "")
            } else {
                setupImageForReceipt2(imageURL: data.fileData ?? "")
            }
        }
    }
    
}

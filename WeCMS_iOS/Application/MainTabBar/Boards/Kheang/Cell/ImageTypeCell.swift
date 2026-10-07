//
//  ImageTypeCell.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 11/1/24.
//

import UIKit

class ImageTypeCell: UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var deleteUIView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(deletePressed))
        deleteUIView.addGestureRecognizer(gesture)
    }
    
    @objc func deletePressed() {
        
    }
 
    func config(data: UIImage) {
        img.image = data
    }
    
    func MREC_BLTB_0005_R002(data: MREC_BLTB_0005_R002.RESPONSE) {
        
    }
    
    
    func MREC_BLTB_0002_R003(data: WeCMSStruct.REC_Protocol) {
        self.img.sd_setImage(with: data.FILE_URL?.formatFileURL,  completed: { (image, error, SDImageCacheType , url) in
            if error == nil {
                self.img.image  = image
            } else {
                self.img.image  = UIImage(named: "noimage")
            }
        })
    }
}

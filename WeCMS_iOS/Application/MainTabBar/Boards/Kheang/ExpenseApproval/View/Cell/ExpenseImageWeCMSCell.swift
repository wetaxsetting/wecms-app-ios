//
//  ExpenseImageWeCMSCell.swift
//  WeCMS_iOS
//
//  Created by lymanny on 20/1/25.
//

import UIKit

class ExpenseImageWeCMSCell: UICollectionViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var img            : UIImageView!
    @IBOutlet weak var moreActionView : UIView!
    @IBOutlet weak var dotActionSave  : UIButton!
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - Function
    func config(data: any MREC_BLTB_0005_R002_0005_R001_0002_R003) {
        self.img.sd_setImage(with: data.FILE_URL?.formatFileURL,  completed: { (image, error, SDImageCacheType , url) in
            if error == nil {
                self.img.image  = image
            } else {
                self.img.image  = UIImage(named: "noimage")
            }
        })
    }
    
}

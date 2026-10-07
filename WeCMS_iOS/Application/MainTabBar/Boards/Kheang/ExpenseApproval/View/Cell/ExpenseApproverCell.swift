//
//  ExpenseApproverCell.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 25/1/24.
//

import UIKit

class ExpenseApproverCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel   : UILabel!
    @IBOutlet weak var stackView    : UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.getlocalizedFont()
    }
    
    func config(data: [WeCMSStruct.REC3_Protocol]) {
        titleLabel.text = "approvers".localized
        // get the array of arranged subviews
        let listSubview = stackView.arrangedSubviews.reversed()
        var tmp = data
        tmp = tmp.reversed()
        for (n, c) in listSubview.enumerated() {
            if n < tmp.count {
                let imageView = c as! UIImageView
                let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
                let split_url       = tmp[n].APPRVR_IMG_URL?.components(separatedBy: "?")
                let img_url         = "\(split_url?.first ??  "")?token=\(authorization)&\(split_url?.last ?? "")" + "&\(tmp[n].APPRVR_ID ?? "")"
                
                let url             = URL(string: "\(img_url)")
                imageView.sd_setImage(with: url,  completed: { (image, error, SDImageCacheType , url) in
                    if error == nil {
                        imageView.image  = image
                    } else {
                        imageView.image  = UIImage(named: "head_employee_ico")
                    }
                })
            } else {
                c.alpha = 0
            }
        }
    }
    
}

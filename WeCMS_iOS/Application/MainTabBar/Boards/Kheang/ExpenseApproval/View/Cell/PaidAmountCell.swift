//
//  PaidAmountCell.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 25/1/24.
//

import UIKit

class PaidAmountCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel       : UILabel!
    @IBOutlet weak var dollarAmountLabel: UILabel!
    @IBOutlet weak var img              : UIImageView!
    @IBOutlet weak var khrAmountLabel   : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config(data: MREC_BLTB_0005_R002.RESPONSE) {
        
        titleLabel.text = "Transfer amount"
        
        titleLabel.getlocalizedFont()
        
        if data.PAY_YN   == "Y" {
            img.isHidden = false
        } else {
            img.isHidden = true
        }
        
        let dollarAmount = data.TOT_PAY_USD_AMT
        let localAmount = data.TOT_PAY_LOC_AMT
        
        if  dollarAmount != ""{
//            dollarAmountLabel.text = "USD \(dollarAmount?.formatStringDouble ?? "")"
            dollarAmountLabel.text = "USD \(customFormatCurrency(CCY_CD: "USD", amount: dollarAmount?.formatStringDouble ?? ""))"
            dollarAmountLabel.isHidden = true
        } else {
            dollarAmountLabel.isHidden = true
        }
        
        if  localAmount != "" {
            khrAmountLabel.text = "\("VND ")" + "\((localAmount)?.components(separatedBy: ".").first ?? "")".vndCurrencyFormatter()
           
        } else {
            khrAmountLabel.isHidden = true
        }
    }

}

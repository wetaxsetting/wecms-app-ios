//
//  ElectronicCell.swift
//  warBookScreen
//
//  Created by kimlang on 3/27/23.
//

import UIKit

class EInvoiceCell: UICollectionViewCell {
     
    @IBOutlet weak var viewBoder: UIView!
    @IBOutlet weak var selectImg: UIImageView!
    @IBOutlet weak var balanceLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
 
    func configCell(taxData: EInvoiceModel?, indexPath: Int){
        
        titleLbl.text   = "\(taxData?.title ?? "") \n(\(taxData?.taxID ?? ""))"
        dateLbl.text    = "\(customFormatteDate(date: taxData?.date ?? "")), \(taxData?.docID ?? "")"
        balanceLbl.text = "\(taxData?.balance?.vndCurrency.components(separatedBy: ",").first ?? "")₫"
        selectImg.image = UIImage(named: taxData?.isSelectItem ?? false ? "check-circle" : "uncheck")
        self.contentView.backgroundColor = taxData?.isSelectItem ?? false ? UIColor(hexString: "#F5F9FC") : UIColor(hexString: "#FFFFFF")
        if indexPath == 0 {
            viewBoder.backgroundColor = UIColor(hexString: "#FFFFFF")
        }else{
            viewBoder.backgroundColor = UIColor(hexString: "#ECEFF1")
        }
    }
}

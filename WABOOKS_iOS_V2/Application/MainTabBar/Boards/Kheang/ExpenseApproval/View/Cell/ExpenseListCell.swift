//
//  ExpenseListCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 25/1/24.
//

import UIKit

class ExpenseListCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config(data: WABOOKSStruct.RECDoc_Protocol) {
        if data.TRCO_CMENM == "undefined" {
            companyLabel.text = data.TRCO_CMNM
        } else {
            companyLabel.text = data.TRCO_CMENM
        }
        codeLabel.text = data.DISP_DOC_ID
        descLabel.text = data.USAG_NM
        nameLabel.text  = data.MEMO
        
        var amount = "0"
        if data.CCY_CD == "USD" {
            amount = data.AMT?.formatStringDouble ?? "" // add two zero behind ex: .00
        } else {
            amount = data.AMT ?? "0" // no need to add two zeros for VND currency
        }
        amountLabel.text = "\(data.CCY_CD ?? "") \(customFormatCurrency(CCY_CD: data.CCY_CD ?? "", amount: amount))"
    }
}

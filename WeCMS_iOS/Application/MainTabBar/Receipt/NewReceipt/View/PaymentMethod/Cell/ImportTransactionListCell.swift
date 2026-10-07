//
//  PaymentMethodTitleCell.swift
//  WeCMS_iOS
//
//  Created by Bun on 19/10/22.
//

import UIKit

class ImportTransactionListCell: UITableViewCell {
    
    // No matching transactions found
    @IBOutlet weak var viewNomatching       : UIView!
    @IBOutlet weak var lblNoMatching        : UILabel!
    
    // List Transactions
    @IBOutlet weak var lblBankName          : UILabel!
    @IBOutlet weak var lblBankTransAmount   : UILabel!
    @IBOutlet weak var lblBankTransDate     : UILabel!
    @IBOutlet weak var viewTransaction      : UIView!
    @IBOutlet weak var btnSelecteTransaction: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupLocalized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
 
    }
  
    private func setupLocalized() {
        self.lblNoMatching.getlocalizedFont()
        self.lblNoMatching.text = "no_matching_transaction_found".localized
        
        self.lblBankName.getlocalizedFont()
        self.lblBankTransAmount.getlocalizedFont()
        self.lblBankTransDate.getlocalizedFont()
    }
    
    func configCell(data: MREC_R007.RESPONSE?, index: Int, Currency: String) {
        self.lblBankName.text                   = "\(data?.REC?[index].BANK_NM ?? "") \(data?.REC?[index].ACCT_NO ?? "")"
        self.lblBankTransAmount.text = "\(Currency == "USD" ? "$\(data?.REC?[index].TRSC_AMT.vndCurrency.replace(of: ".", with: "").replace(of: ",", with: ".").vndCurrency ?? "")" : "\( data?.REC?[index].TRSC_AMT.vndCurrency.components(separatedBy: ",").first ?? "")₫")"
        
         
        self.lblBankTransDate.text              = formatteDate(date: data?.REC?[index].TRSC_DT ?? "")
        self.viewNomatching.isHidden            = (data?.REC?[index].TRSC_DT.isEmpty ?? true) ? false : true
        self.viewTransaction.backgroundColor    = UIColor(hexString: (data?.REC?[index].isSelectedTransaction ?? false) ? "#FAFAFA" : "#FFFFFF")
        self.btnSelecteTransaction.isSelected   = data?.REC?[index].isSelectedTransaction ?? false
    }
}

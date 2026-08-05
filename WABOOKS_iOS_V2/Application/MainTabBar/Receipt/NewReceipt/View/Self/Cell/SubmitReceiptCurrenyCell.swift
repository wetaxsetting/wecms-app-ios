//
//  SubmitReceiptCurrenyCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Bun on 4/4/23.
//

import UIKit

class SubmitReceiptCurrenyCell: UITableViewCell {

    @IBOutlet weak var labelTitle               : UILabel!
    @IBOutlet weak var segmentCurrency          : UISegmentedControl!
    @IBOutlet weak var borderViewLeadingCons    : NSLayoutConstraint!
    @IBOutlet weak var btnKHR                   : UIButton!
    @IBOutlet weak var btnUSD                   : UIButton!
     
    var delegate        : getDataDelegate?
    var isAutoMerchant  : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setupLocalized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupLocalized() {
        self.labelTitle.getlocalizedFont()
         
//        self.segmentCurrency.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Inter-Bold", size: 13.0)!, NSAttributedString.Key.foregroundColor: UIColor(hexString: "#494949")], for: .normal)
    }
    
    @IBAction func didTapKHR(_ sender: UIButton) {
        
        
        UIView.animate(withDuration: 0.3) {
            self.borderViewLeadingCons.constant =  2
            self.superview?.layoutIfNeeded()
            self.delegate?.getCurrencyValue(value: "VND", isReset: true)
        }
        
    }
     
    @IBAction func didTapUSD(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.borderViewLeadingCons.constant = 62
            self.superview?.layoutIfNeeded()
            self.delegate?.getCurrencyValue(value: "USD", isReset: true)
        }
        
    }
    
    @IBAction func didTapChangeCurrencyCode(_ sender: UISegmentedControl) {
//
//        switch sender.selectedSegmentIndex {
//        case 0:
//            break
//
//        case 1:
//            self.delegate?.getCurrencyValue(value: "USD", isReset: true)
//            break
//
//        default: break
//        }
    }
    
    func configCell(row: SubmitReceiptModel.reeceipRow.content?) {
        
        
        let mappingRow = ReceiptRow(rawValue: row?.code ?? "")
         
        // Using the same component
        self.labelTitle.text = mappingRow?.description.localized
        self.delegate?.getCurrencyValue(value: (row?.value ?? "KHR"), isReset: false)
        
//        self.segmentCurrency.isUserInteractionEnabled   = !isAutoMerchant
//        self.segmentCurrency.selectedSegmentIndex       = row?.value == "KHR" ? 0 : 1
//        self.segmentCurrency.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Inter-Bold", size: 13.0)!, NSAttributedString.Key.foregroundColor: UIColor(hexString: "#0069B9")], for: .selected)
//        self.delegate?.getCurrencyValue(value: (row?.value ?? "KHR"), isReset: false)
          
    }

}

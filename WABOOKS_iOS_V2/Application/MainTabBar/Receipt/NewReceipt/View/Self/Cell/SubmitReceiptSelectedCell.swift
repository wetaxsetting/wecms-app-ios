//
//  SubmitReceiptSelectedCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Bun on 4/4/23.
//

import UIKit

class SubmitReceiptSelectedCell: UITableViewCell {

    @IBOutlet weak var labelTitle   : UILabel!
    @IBOutlet weak var labelDesc    : UILabel!
    @IBOutlet weak var imgRight     : UIImageView!
    @IBOutlet weak var imgDot       : UIImageView!
    @IBOutlet weak var moreButton   : UIButton!
    
    var isClearVisible  : Bool?
    var completion      : (String, String) -> () = { _, _ in }
    var owner           : UIViewController?
    var clientData      : [Client.ContentBody]?
    var copyClientData  : [Client.ContentBody]?
    var isSearching     : Bool?
    var receiptList     : WABOOKS_MREC_R006.RESPONSE.REC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imgRight.isUserInteractionEnabled = true
        imgRight.addGestureRecognizer(tapGestureRecognizer)
        self.setupLocalized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupLocalized() {
        self.labelTitle.getlocalizedFont()
        self.labelDesc.getlocalizedFont()
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if (isClearVisible ?? false) {
            self.imgRight.image = UIImage(named: "ico_search")
            self.isClearVisible = false
            self.completion("", "") // completion back to SubmitReceiptVC for set the value into VM
        } else {
            if let mother = getVCFromTVC as? SubmitReceiptVC {
                let vc = UIStoryboard.init(name: "ClientSB", bundle: Bundle.main).instantiateViewController(withIdentifier: "ClientVC") as! ClientVC
                vc.clientData   = (self.isSearching ?? false) ? (self.copyClientData ?? []) : (self.clientData ?? [])
                vc.receiptList  = self.receiptList
                
                vc.completionTRSC_CCY_CD = { new_TRSC_CCY_CD in
                    mother.selected_TRCO_TRSC_CCY_CD = new_TRSC_CCY_CD
                }
                
                vc.completion = { data, clientData, isSearching, isManualInput in
                    self.isSearching    = isSearching
                    self.clientData     = clientData
//                    self.textfieldInput.text = data.l_text
//                    self.imgRight.image = UIImage(named: "ico_closed")
//                    //                    guard let row = parentVC.cellValue?.content.firstIndex(where: {$0.code == "TAXID"}) else { return }
//                    //                    let indexPath = IndexPath(item: row, section: 0)
//                    //                    let cell = parentVC.tableView.cellForRow(at: indexPath) as! SubmitReceiptFillCell
//                    //                    cell.textfieldInput.text = data.r_text
                    self.isClearVisible = true
                    self.completion(data.l_text, data.r_text ?? "") // completion back to SubmitReceiptVC for set the value into VM
                }
                self.owner?.pushVC(viewController: vc, animated: true)
            }
        }
    }
    
    func configCell(row: SubmitReceiptModel.reeceipRow.content?, isFromSelected: Bool = false, trco_type: String?) {
        
        let mappingRow = ReceiptRow(rawValue: row?.code ?? "")
        
        // Using the same component
        self.labelTitle.text = mappingRow?.description.localized
         
        switch mappingRow {
        case .DATE, .DEBITDATE:
            self.labelDesc.text     = formatteDate(date: row?.value ?? "")
            self.labelDesc.textColor = UIColor(hexString: "#0069B9")
            self.imgRight.image     = UIImage(named: "ico_blue_right")  //list_arrow_ico
            self.imgDot.isHidden    = false
            
        case .WITH_HOLDING_TAX, .PROJECT_SITE:
            self.labelDesc.text     = (row?.value?.isNotEmpty ?? false) ? row?.value : "select".localized
            self.labelDesc.textColor = UIColor(hexString: "#0069B9")
            self.imgRight.image     = UIImage(named: "ico_blue_right")
            self.imgDot.isHidden    = true
            
        case .PURPOSE:
            self.labelDesc.text     = (row?.value?.isNotEmpty ?? false) ? row?.value : "none".localized
            self.labelDesc.textColor = UIColor(hexString: "#0069B9")
            self.imgRight.image     = UIImage(named: "ico_blue_right")
            self.imgDot.isHidden    = true
            
        case .MERCHANT:
            self.labelDesc.text     = (row?.value?.isEmpty ?? false) ? "contact".localized : row?.value
            self.labelDesc.textColor = UIColor(hexString: (row?.value?.isEmpty ?? false) ? "#A6A6A6" : "#494949")
            self.imgRight.image     = UIImage(named: (row?.value?.isEmpty ?? true) ? "ico_search" : "ico_closed") //UIImage(named: "ico_chevron")  //list_arrow_ico
            self.imgDot.isHidden    = false
            
        case .TYPEOFSUPPLIER:
            self.imgRight.image     = UIImage(named: "ico_blue_right")
            self.imgDot.isHidden    = false
            self.labelDesc.textColor = UIColor(hexString: "#0069B9")
            self.labelDesc.text     = row?.value
            
        case .PAYMENT_METHOD:
            self.labelDesc.text     = (row?.value?.isNotEmpty ?? false) ? row?.value : "none".localized
            self.labelDesc.textColor = UIColor(hexString: "#0069B9")
            self.imgRight.image     = UIImage(named: "ico_blue_right")
            self.imgDot.isHidden    = true
            
        default:
            self.labelDesc.text     = (row?.value?.isNotEmpty ?? false) ? row?.value : "none".localized
            self.labelDesc.textColor = UIColor(hexString: "#0069B9")
            self.imgRight.image     = UIImage(named: "ico_blue_right")
            self.imgDot.isHidden    = false
        }
    }

}

extension Date {

 static func getCurrentDate() -> String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyyMMdd"

        return dateFormatter.string(from: Date())

    }
}

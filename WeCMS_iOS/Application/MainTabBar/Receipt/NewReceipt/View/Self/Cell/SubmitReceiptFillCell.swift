//
//  SubmitReceiptDateCell.swift
//  WeCMS_iOS
//
//  Created by Bun on 4/4/23.
//

import UIKit

class SubmitReceiptFillCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle       : UILabel!
    @IBOutlet weak var textfieldInput   : UITextField!
    @IBOutlet weak var imgRight         : UIImageView!
    @IBOutlet weak var imgDot           : UIImageView!
    
    var owner           : UIViewController?
    var receiptList     : MREC_R006.RESPONSE.REC?
    
    var CCY_CD          = ""
    var isClearVisible  = false
    var completion      : (String, String) -> () = { _, _ in }
    var clientData      : [Client.ContentBody]?
    var copyClientData  : [Client.ContentBody]?
    var isSearching     = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setupLocalized()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imgRight.isUserInteractionEnabled = true
        imgRight.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if isClearVisible {
            self.textfieldInput.text = nil
            self.imgRight.image = UIImage(named: "ico_search")
            self.isClearVisible = false
            self.completion("", "") // completion back to SubmitReceiptVC for set the value into VM
        } else {
            if let mother = getVCFromTVC as? SubmitReceiptVC {
                let vc = UIStoryboard.init(name: "ClientSB", bundle: Bundle.main).instantiateViewController(withIdentifier: "ClientVC") as! ClientVC
                vc.clientData       = self.clientData ?? []
                vc.copyClientData   = self.copyClientData ?? []
                vc.receiptList      = self.receiptList
                
                vc.completionTRSC_CCY_CD = { new_TRSC_CCY_CD in
                    mother.selected_TRCO_TRSC_CCY_CD = new_TRSC_CCY_CD
                }
                
                vc.completion = { data, clientData, isSearching, _ in
                    self.isSearching    = isSearching
                    self.clientData     = clientData
                    
                    self.textfieldInput.text = data.l_text
                    self.imgRight.image = UIImage(named: "ico_closed")
                    //                    guard let row = parentVC.cellValue?.content.firstIndex(where: {$0.code == "TAXID"}) else { return }
                    //                    let indexPath = IndexPath(item: row, section: 0)
                    //                    let cell = parentVC.tableView.cellForRow(at: indexPath) as! SubmitReceiptFillCell
                    //                    cell.textfieldInput.text = data.r_text
                    self.isClearVisible = true
                    self.completion(data.l_text, data.r_text ?? "") // completion back to SubmitReceiptVC for set the value into VM
                }
                self.owner?.pushVC(viewController: vc, animated: true)
            }
        }
    }
    
    private func setupLocalized() {
        self.labelTitle.getlocalizedFont()
        self.textfieldInput.getlocalizedFont()
    }
    
    func configCell(row: SubmitReceiptModel.reeceipRow.content?, isManual: Bool = false) {
        
        let mappingRow = ReceiptRow(rawValue: row?.code ?? "")
        
        // Using the same component
        self.labelTitle.text            = mappingRow?.description.localized
        self.textfieldInput.placeholder = mappingRow?.description.localized
        
        switch mappingRow {
        case .TAXID:
            self.imgDot.isHidden            = true
            
            self.imgRight.isHidden          = true
            self.imgRight.image             = UIImage(named: "ico_chevron")
            
            self.textfieldInput.tag         = 1014
            self.textfieldInput.text        = row?.value
            self.textfieldInput.textColor   = UIColor(hexString: "#494949")
            self.textfieldInput.isUserInteractionEnabled = isManual
            
        case .AMOUNT:
            self.imgDot.isHidden                = false
            self.imgRight.isHidden              = true
            self.imgRight.image                 = UIImage(named: "ico_chevron")
            
            self.textfieldInput.keyboardType    = .decimalPad
            self.textfieldInput.tag             = 1010
            self.textfieldInput.textColor       = UIColor(hexString: "#494949")

//            
            var amount = ""
            
            if row?.value == "" || row?.value == nil {
                amount = ""
            } else {
                amount = customFormatCurrency(CCY_CD: self.CCY_CD, amount: row?.value  ?? "")
                
            }
            self.textfieldInput.text = amount
            self.textfieldInput.placeholder   =  "0" //(row?.value?.isEmpty ?? false) ? "0" : row?.value ?? ""
            self.textfieldInput.isUserInteractionEnabled = true
            
        case .AMOUNTKHR:
            self.imgDot.isHidden            = false
            self.imgRight.isHidden          = true
            self.imgRight.image             = UIImage(named: "ico_chevron")
            
            self.textfieldInput.tag         = 1018
            self.textfieldInput.textColor   = UIColor(hexString: "#A6A6A6")
            self.textfieldInput.text        = (row?.value ?? "").isEmpty ? "0" : row?.value?.components(separatedBy: ",").first
            self.textfieldInput.isUserInteractionEnabled = false
            
        case .TAX_AMOUNT:
            self.imgDot.isHidden                = true
            self.imgRight.isHidden              = true
            self.imgRight.image                 = UIImage(named: "ico_chevron")
            
            self.textfieldInput.keyboardType    = .decimalPad
            self.textfieldInput.textColor       = UIColor(hexString: "#A6A6A6")
            self.textfieldInput.isUserInteractionEnabled = false
            
            if (row?.value == "") {
                self.textfieldInput.text = self.CCY_CD == "KHR" ? "0" : "0.00"
            }
            else {
                self.textfieldInput.text = (row?.value?.toKHRCurrency().replace(of: ",", with: ".") ?? "0")
            }
            
        case .RATE:
            self.imgDot.isHidden                = false
            self.imgRight.isHidden              = true
            self.imgRight.image                 = UIImage(named: "ico_chevron")
            
            self.textfieldInput.tag             = 1017
            self.textfieldInput.keyboardType    = .decimalPad
            self.textfieldInput.textColor       = UIColor(hexString: "#494949")
            self.textfieldInput.text            = (row?.value ?? "").isEmpty ? "" : (customFormatCurrency(CCY_CD: "USD", amount: row?.value ?? "")).components(separatedBy: ",").first
            self.textfieldInput.isUserInteractionEnabled = true
        
        case .EMAIL:
            self.textfieldInput.tag             = 1016
            self.imgRight.isHidden          = true
            self.imgDot.isHidden            = false
            self.textfieldInput.text        = row?.value
            self.textfieldInput.textColor   = UIColor(hexString: "#494949")
            self.textfieldInput.isUserInteractionEnabled = isManual
            
//        case .MERCHANT:
//            self.imgDot.isHidden            = false
//            self.imgRight.isHidden          = false
//            self.imgRight.image             = UIImage(named: (row?.value?.isEmpty ?? true) ? "ico_search" : "ico_closed")
//
//            self.textfieldInput.text        = row?.value
//            self.textfieldInput.textColor   = UIColor(hexString: "#494949")
//            self.textfieldInput.isUserInteractionEnabled = false
                         
        default:
            self.imgDot.isHidden            = false
            self.imgRight.isHidden          = false
            self.imgRight.image             = UIImage(named: "ico_chevron")
            
            self.textfieldInput.text        = row?.value
            self.textfieldInput.textColor   = UIColor(hexString: "#A6A6A6")
            self.textfieldInput.isUserInteractionEnabled = false
            
        }
    }
}

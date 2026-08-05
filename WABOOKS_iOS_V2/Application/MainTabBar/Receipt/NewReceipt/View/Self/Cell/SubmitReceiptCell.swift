//
//  CurrencyNewReceiptCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 11/1/21.
//

import UIKit
import SDWebImage
import SkeletonView
 
class SubmitReceiptCell: UITableViewCell, UITextFieldDelegate {
      
    //MARK: - @IBOutlet
    @IBOutlet weak var imageViewLeadingIcon         : UIImageView!
    @IBOutlet weak var labelTitle                   : UILabel!
    @IBOutlet weak var viewofCurrency               : UIView!
    @IBOutlet weak var textFieldEnterValue          : UITextField!
    @IBOutlet weak var labelSelectedValue           : UILabel!
    @IBOutlet weak var imageViewChevronRight        : UIImageView!
    @IBOutlet weak var imgViewDot                   : UIImageView!
    @IBOutlet weak var lblAdd                       : UILabel!
    
    @IBOutlet weak var lblDescription               : UILabel!
    @IBOutlet weak var constraintTopLblDescription  : NSLayoutConstraint!
    @IBOutlet weak var arrowImageWidthConstaint     : NSLayoutConstraint!
    @IBOutlet weak var lblTaxable                   : UILabel!
    @IBOutlet weak var listMerchantIcon             : UIImageView!
    
    
    // Update 1st Jane 2021
    @IBOutlet weak var viewNormal                   : UIView!
    @IBOutlet weak var viewMerchant                 : UIView!
    @IBOutlet weak var merchantTitle                : UILabel!
    @IBOutlet weak var btnDropDown                  : UIButton!
    @IBOutlet weak var tfMerchant                   : UITextField!
    @IBOutlet weak var btnTrickDropDown             : UIButton!
    @IBOutlet weak var lblSelectMerchant            : UILabel!
    @IBOutlet weak var imgViewChevronRightMerchant  : UIImageView!
    @IBOutlet weak var lblMerchatValue              : UILabel!
    @IBOutlet weak var btnSelectContact             : UIButton!
    @IBOutlet weak var imageViewDotMerchant         : UIImageView!
    
    // View Tel
    @IBOutlet weak var viewTel                      : UIView!
    @IBOutlet weak var lblTel                       : UILabel!
    @IBOutlet weak var lblCodeCountry               : UILabel!
    @IBOutlet weak var btnDropDownCodeCountry       : UIButton!
    @IBOutlet weak var tfPhoneNumber                : UITextField!
    
    @IBOutlet weak var imgErrorReceiptNo            : UIImageView!
    @IBOutlet weak var segementCurrency             : UISegmentedControl!
    @IBOutlet weak var constraintWidthErrorReceiptNo: NSLayoutConstraint! // 24
    @IBOutlet weak var constraintWidthErrorReceiptNoLeading: NSLayoutConstraint!
    
        
    //MARK: - Variable
    var delegate                                    : getDataDelegate? 
    var isKHR                                       : Bool = true
    var isAutoMerchant                              : Bool = false
    var isErrorReceiptNo                            : Bool = true
    var strAmount   = ""
    var strMerchant = ""
    var CCY_CD      = ""
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setLocaized()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)  
    }
    
    //MARK: - @IBAction
    @IBAction func didTapChangeCurrencyCode(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.delegate?.getCurrencyValue(value: "VND", isReset: true)
            break
        case 1:
            self.delegate?.getCurrencyValue(value: "USD", isReset: true)
            break
        default: break
             
        }
    }
    
     
    //MARK: - Private func
    func addressDescriptions(isHidden: Bool, value: String = "") {
        self.lblDescription.isHidden                = isHidden
        self.constraintTopLblDescription.constant   = isHidden ? 0 : 18
        self.lblDescription.text                    = value
    }
    
    func hiddenErrorReceiptNo() {
        self.imgErrorReceiptNo.isHidden                     = true
        self.constraintWidthErrorReceiptNo.constant         = 0
        self.constraintWidthErrorReceiptNoLeading.constant  = 0
    }
    
    func typeOfMerchant(isAuto: Bool, key: String = "", value: String = "") {
        self.tfMerchant.isHidden                    = key.isEmpty
        self.lblSelectMerchant.isHidden             = !key.isEmpty
        self.imgViewChevronRightMerchant.isHidden   = !key.isEmpty
        self.lblSelectMerchant.textColor            = UIColor(hexString: "#0069B9")
        self.merchantTitle.text                     = "merchant".localized
        self.lblMerchatValue.text                   = key
        self.lblSelectMerchant.text                 = (value.isEmpty && key.isEmpty) ? "select".localized : value
        
        self.btnSelectContact.isHidden              = !isAutoMerchant
        
        if key.isEmpty && !isAuto {
            self.tfMerchant.placeholder             = "enter_name".localized
        }
        else {
            self.tfMerchant.text                    = value
        }  
    }
    
    func typeOfBank(isAuto: Bool, key: String = "", value: String = "") {
        self.tfMerchant.isHidden                    = false
        self.lblSelectMerchant.isHidden             = true
        self.imgViewChevronRightMerchant.isHidden   = true
        self.lblSelectMerchant.textColor            = UIColor(hexString: "#0069B9")
        self.merchantTitle.text                     = key.isEmpty ? "bank".localized : key.localized
        self.lblMerchatValue.text                   = ""
        self.lblSelectMerchant.text                 = (value.isEmpty && key.isEmpty) ? "select".localized : value
        
        self.btnSelectContact.isHidden              = true
        
        if key.isEmpty && !isAuto {
            self.tfMerchant.placeholder             = "enter_cheque_no".localized
        }
        else {
            self.tfMerchant.text                    = value
        }
    }
    
    func selectWithArrow(isHidden: Bool = false) {
        self.lblAdd.isHidden                    = isHidden
        self.labelSelectedValue.isHidden        = isHidden
        self.imageViewChevronRight.isHidden     = isHidden
        self.labelSelectedValue.textColor       = isHidden ? .clear : UIColor(hexString: "#0069B9")
        self.labelSelectedValue.text            = ""
        self.lblAdd.text                        = "add".localized
    }
    
    func typeOfSupplier(isHidden: Bool = false, _ text: String = "taxable_person".localized) {

        // Taxable Person >
        self.labelSelectedValue.isHidden        = isHidden
        self.imageViewChevronRight.isHidden     = isHidden
        self.labelSelectedValue.textColor       = isHidden ? .clear : UIColor(hexString: "#0069B9")
        self.labelSelectedValue.text            = text

        // TextField
        self.lblTaxable.isHidden                 = !isHidden
        self.lblTaxable.text                     = text 
    }
  
    private func setLocaized() {
        self.labelTitle.getlocalizedFont()
        self.textFieldEnterValue.getlocalizedFont()
        self.labelSelectedValue.getlocalizedFont()
        self.lblDescription.getlocalizedFont()
        self.merchantTitle.getlocalizedFont()
        self.tfMerchant.getlocalizedFont()
        self.lblSelectMerchant.getlocalizedFont()
        self.lblCodeCountry.getlocalizedFont()
        self.btnDropDownCodeCountry.getlocalizedFont()
        self.lblTel.getlocalizedFont()
        self.tfPhoneNumber.getlocalizedFont()
        self.lblMerchatValue.getlocalizedFont()
        self.lblTaxable.getlocalizedFont()
        
        let font  = UIFont(name: "Inter-Bold", size: 13)
        self.segementCurrency.setTitleTextAttributes([NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor : UIColor(named: "TfColor")!], for: .normal)
    }
    
    func setUpCell(row: SubmitReceiptModel.reeceipRow.content) {
        
        
        let mappingRow = ReceiptRow(rawValue: row.code)
       
        // Hidden Important dot for un-require fields
        self.imgViewDot.isHidden = (mappingRow == .CURRENCY || mappingRow == .PURPOSE || mappingRow == .USER || mappingRow == .WITH_HOLDING_TAX || mappingRow == .TAX_AMOUNT || mappingRow == .PAYMENT_METHOD || mappingRow == .IMPORT_TRANSACTION)
        
        self.imageViewChevronRight.isHidden = (mappingRow == .BANK)
        
        switch mappingRow {
        
//        case .RECEIPTNO:
//            self.labelTitle.text                    = mappingRow?.description.localized
//            self.imageViewLeadingIcon.image         = UIImage(named: "list_receipt_ico")
//            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
//            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
//            self.viewofCurrency.isHidden            = true
//            self.textFieldEnterValue.isHidden       = false
//            self.labelSelectedValue.isHidden        = true
//            self.imageViewChevronRight.isHidden     = true
//            self.viewNormal.isHidden                = false
//            self.viewMerchant.isHidden              = true
//            self.viewTel.isHidden                   = true
//            self.lblAdd.isHidden                    = true
//            self.imgErrorReceiptNo.isHidden                     = isErrorReceiptNo
//            self.constraintWidthErrorReceiptNo.constant         = isErrorReceiptNo ? 0 : 24
//            self.constraintWidthErrorReceiptNoLeading.constant  = isErrorReceiptNo ? 0 : 7
//            self.addressDescriptions(isHidden: true)
//            self.textFieldEnterValue.tag            = 1013
//
//            self.textFieldEnterValue.isUserInteractionEnabled = row.key == "N" // disable user   update
//
//            if row.key == "N" {
//                self.lblTaxable.isHidden                = true
//                self.textFieldEnterValue.placeholder    = "inv_number".localized
//                self.textFieldEnterValue.text           = (row.value ?? "").isEmpty ? "" : row.value
//            }
//            else {
//                self.textFieldEnterValue.isHidden = true
//                self.lblTaxable.isHidden          = false
//                self.lblTaxable.textColor = UIColor(hexString: "#A6A6A6")
//                self.lblTaxable.text = (row.value ?? "").isEmpty ? "" : row.value
//            }
             
        case .DATE:
            self.labelTitle.text                    = mappingRow?.description.localized
            self.imageViewLeadingIcon.image         = UIImage(named: "list_date_ico")
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.viewofCurrency.isHidden            = true
            self.textFieldEnterValue.isHidden       = true
            self.labelSelectedValue.isHidden        = false
            self.imageViewChevronRight.isHidden     = false
            self.labelSelectedValue.textColor       = UIColor(hexString: "#0069B9")
            self.viewNormal.isHidden                = false
            self.viewMerchant.isHidden              = true
            self.viewTel.isHidden                   = true
            self.lblTaxable.isHidden                = true
            self.imgErrorReceiptNo.isHidden         = true
            self.lblAdd.isHidden                    = true
            self.addressDescriptions(isHidden: true)
            self.contentView.isUserInteractionEnabled = true
            self.hiddenErrorReceiptNo()
            if (row.value?.isEmpty ?? false) {
                self.labelSelectedValue.text = "dd MMM yyyy"
            }
            else {
                self.labelSelectedValue.text = formatteDate(date: row.value ?? "")
            }
              
        case .MERCHANT:
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.labelSelectedValue.isHidden        = true
            self.imageViewChevronRight.isHidden     = true
            self.viewNormal.isHidden                = true
            self.viewMerchant.isHidden              = false
            self.viewTel.isHidden                   = true
            self.lblTaxable.isHidden                = true
            self.lblAdd.isHidden                    = true
            self.addressDescriptions(isHidden: true)
            self.hiddenErrorReceiptNo()
            
            self.tfMerchant.tag                     = 1011
            self.btnTrickDropDown.tag               = 1080
            self.imgErrorReceiptNo.isHidden         = true
            self.tfMerchant.placeholder = "enter_name".localized
            self.btnTrickDropDown.isUserInteractionEnabled  = true
            self.contentView.isUserInteractionEnabled       = true
            
            // Manual: User can Input
            // Auto  : User can Select
            self.typeOfMerchant(isAuto: (row.key?.isEmpty ?? false), key: row.key ?? "", value: row.value ?? "")
         
//        case .TYPEOFSUPPLIER:
//            self.labelTitle.text                    = mappingRow?.description.localized
//            self.imageViewLeadingIcon.image         = UIImage(named: "list_type_of_supplier_ico")
//            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
//            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
//            self.viewofCurrency.isHidden            = true
//            self.textFieldEnterValue.isHidden       = true
//            self.labelSelectedValue.isHidden        = false
//            self.imageViewChevronRight.isHidden     = false
//            self.labelSelectedValue.textColor       = UIColor(hexString: "#0069B9")
//            self.viewNormal.isHidden                = false
//            self.viewMerchant.isHidden              = true
//            self.viewTel.isHidden                   = true
//            self.lblTaxable.isHidden                = true
//            self.lblAdd.isHidden                    = true
//            self.addressDescriptions(isHidden: true)
//            self.hiddenErrorReceiptNo()
//            self.imgErrorReceiptNo.isHidden         = true
//            self.contentView.isUserInteractionEnabled = !isAutoMerchant
//
//            self.typeOfSupplier(isHidden: (row.key ?? "").isEmpty, row.value ?? "")
             
        case .TAXID:
            self.labelTitle.text                    = mappingRow?.description.localized 
            self.imageViewLeadingIcon.image         = UIImage(named: "list_tax_id_ico")
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.viewofCurrency.isHidden            = true
            self.textFieldEnterValue.isHidden       = false
            self.labelSelectedValue.isHidden        = true
            self.imageViewChevronRight.isHidden     = true
            self.viewNormal.isHidden                = false
            self.viewMerchant.isHidden              = true
            self.viewTel.isHidden                   = true
            self.lblTaxable.isHidden                = true
            self.imgErrorReceiptNo.isHidden         = true
            self.lblAdd.isHidden                    = true
            self.addressDescriptions(isHidden: true)
            self.hiddenErrorReceiptNo() 
            self.textFieldEnterValue.isUserInteractionEnabled = !isAutoMerchant
            
            self.textFieldEnterValue.tag            = 1014
            
            self.textFieldEnterValue.placeholder    = row.key
            self.textFieldEnterValue.text           = row.value ?? ""
              
        case .CURRENCY:
            // Title
            self.labelTitle.text                    = mappingRow?.description.localized
           
            // Leading Icon
            self.imageViewLeadingIcon.image         = UIImage(named: "list_currency_ico")
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            
            // Currency View
            self.viewofCurrency.isHidden            = false
            
            // TextField
            self.textFieldEnterValue.isHidden       = true
            
            // Select Label and chevron right imageview
            self.labelSelectedValue.isHidden        = true
            self.imageViewChevronRight.isHidden     = true
            self.imgErrorReceiptNo.isHidden         = true
            self.viewNormal.isHidden                = false
            self.viewMerchant.isHidden              = true
            self.viewTel.isHidden                   = true
            self.lblTaxable.isHidden                = true
            self.lblAdd.isHidden                    = true
            self.textFieldEnterValue.placeholder    = row.value
            self.addressDescriptions(isHidden: true)
            self.hiddenErrorReceiptNo()
            self.segementCurrency.isUserInteractionEnabled = !isAutoMerchant
            self.segementCurrency.selectedSegmentIndex = (row.value == "KHR" || row.value == "VND") ? 0 : 1
            self.segementCurrency.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "#0069B9")], for: .selected)
            self.segementCurrency.setTitle("VND", forSegmentAt: 0)
            self.delegate?.getCurrencyValue(value: (row.value ?? "KHR"), isReset: false)
            
        case .AMOUNT:
            self.labelTitle.text                    = mappingRow?.description.localized 
            self.imageViewLeadingIcon.image         = UIImage(named: "list_amount_ico")
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.viewofCurrency.isHidden            = true
            self.textFieldEnterValue.isHidden       = false
            self.labelSelectedValue.isHidden        = true
            self.imageViewChevronRight.isHidden     = true
            
            self.imgErrorReceiptNo.isHidden         = true
            self.viewNormal.isHidden                = false
            self.viewMerchant.isHidden              = true
            self.viewTel.isHidden                   = true
            self.lblTaxable.isHidden                = true
            self.lblAdd.isHidden                    = true
            self.addressDescriptions(isHidden: true)
            self.hiddenErrorReceiptNo()
            
            self.textFieldEnterValue.tag            = 1010
            self.textFieldEnterValue.placeholder    = (self.CCY_CD == "KHR" || self.CCY_CD == "VND") ? "0" : "0,00"
            self.textFieldEnterValue.text           = (row.value?.isEmpty ?? true) ? "" : customFormatCurrency(CCY_CD: self.CCY_CD, amount: row.value?.replace(of: ".", with: "").replace(of: ",", with: ".")  ?? "")
            self.textFieldEnterValue.isUserInteractionEnabled = true
//            if (row.value == "0") {
//                self.textFieldEnterValue.placeholder = self.isKHR ? "0" : "0.00"
//                self.textFieldEnterValue.text = ""
//            }
//            else {
//                if (row.value?.isEmpty ?? false) {
//                    self.textFieldEnterValue.placeholder = self.isKHR ? "0" : "0.00"
//                }
//                self.textFieldEnterValue.text = (row.value?.isEmpty ?? false) ? "" : row.value ?? ""
//            }
            
        case .PURPOSE:
            self.labelTitle.text                    = mappingRow?.description.localized 
            self.imageViewLeadingIcon.image         = UIImage(named: "list_purpose_ico")
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.viewofCurrency.isHidden            = true
            self.textFieldEnterValue.isHidden       = true
            self.labelSelectedValue.isHidden        = false
            self.imageViewChevronRight.isHidden     = false
            self.labelSelectedValue.textColor       = UIColor(hexString: "#0069B9")
            self.viewNormal.isHidden                = false
            self.viewMerchant.isHidden              = true
            self.viewTel.isHidden                   = true
            self.lblTaxable.isHidden                = true
            self.imgErrorReceiptNo.isHidden         = true
            self.lblAdd.isHidden                    = true
            self.addressDescriptions(isHidden: true)
            self.hiddenErrorReceiptNo()
            self.labelSelectedValue.text             = ""
            if (row.value?.isEmpty ?? false) {
                self.labelSelectedValue.text = "select".localized
            }
            else { 
                self.labelSelectedValue.text = row.value
            }
            
        case .PAYMENT_METHOD:
            self.labelTitle.text                    = mappingRow?.description.localized
            self.imageViewLeadingIcon.image         = UIImage(named: "list_wallet_symbol")
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.viewofCurrency.isHidden            = true
            self.textFieldEnterValue.isHidden       = true
            self.labelSelectedValue.isHidden        = false
            self.imageViewChevronRight.isHidden     = false
            self.imgErrorReceiptNo.isHidden         = true
            self.labelSelectedValue.textColor       = UIColor(hexString: "#0069B9")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.viewNormal.isHidden                = false
            self.viewMerchant.isHidden              = true
            self.viewTel.isHidden                   = true
            self.lblTaxable.isHidden                = true
            self.lblAdd.isHidden                    = true
            self.addressDescriptions(isHidden: true)
//            self.hiddenErrorReceiptNo()
            self.labelSelectedValue.text            = ""
            if (row.value?.isEmpty ?? false) {
                self.labelSelectedValue.text = "select".localized
            }
            else {
                self.labelSelectedValue.text = row.value
            }
            
        case .BANK:
            self.textFieldEnterValue.isHidden       = false
            self.labelSelectedValue.isHidden        = true
            self.viewNormal.isHidden                = true
            self.viewMerchant.isHidden              = false
            self.viewTel.isHidden                   = true
            self.lblTaxable.isHidden                = true
            self.imageViewDotMerchant.isHidden      = false
            self.imgErrorReceiptNo.isHidden         = true
            self.lblAdd.isHidden                    = true
            self.labelSelectedValue.textColor       = UIColor(hexString: "#0069B9")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.listMerchantIcon.image             = UIImage(named: "list_account_balance_symbol")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.addressDescriptions(isHidden: true)
//            self.hiddenErrorReceiptNo()
            
            self.tfMerchant.tag                     = 1019
            self.btnTrickDropDown.tag               = 1090
            
            self.tfMerchant.placeholder = "enter_cheque_no".localized
            self.btnTrickDropDown.isUserInteractionEnabled  = true
            self.contentView.isUserInteractionEnabled       = true
            
            // Manual: User can Input
            // Auto  : User can Select
            self.typeOfBank(isAuto: (row.key?.isEmpty ?? false), key: row.key ?? "", value: row.value ?? "")
            
        case .IMPORT_TRANSACTION:
            self.labelTitle.text                    = mappingRow?.description.localized
            self.imageViewLeadingIcon.image         = UIImage(named: "list_import_symbol")
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.viewofCurrency.isHidden            = true
            self.textFieldEnterValue.isHidden       = true
            self.labelSelectedValue.isHidden        = false
            self.imageViewChevronRight.isHidden     = false
            self.imageViewDotMerchant.isHidden      = false
            self.imageViewChevronRight.image        = UIImage(named: (row.key == "true") ? "list_arrow_ico" : "list_arrow_ico_gray")
            self.labelSelectedValue.textColor       = UIColor(hexString: (row.key == "true") ? "#0069B9" : "#A6A6A6")
            self.viewNormal.isHidden                = false
            self.imgViewDot.isHidden                = false
            self.viewMerchant.isHidden              = true
            self.viewTel.isHidden                   = true
            self.lblTaxable.isHidden                = true
            self.imgErrorReceiptNo.isHidden         = true
            self.lblAdd.isHidden                    = true
            self.addressDescriptions(isHidden: true)
            self.hiddenErrorReceiptNo()
            if (row.value?.isEmpty ?? true) {
                self.labelSelectedValue.text = "import".localized
            }
            else {
                self.labelSelectedValue.text = row.value
            }
       
        case .ADVANCELEDGER:
            self.labelTitle.text                    = mappingRow?.description.localized 
            self.imageViewLeadingIcon.image         = UIImage(named: "list_advance_ledger_ico")
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.viewofCurrency.isHidden            = true
            self.textFieldEnterValue.isHidden       = true
            self.labelSelectedValue.isHidden        = false
            self.imageViewChevronRight.isHidden     = false
            self.labelSelectedValue.textColor       = UIColor(hexString: "#0069B9")
            self.viewNormal.isHidden                = false
            self.viewMerchant.isHidden              = true
            self.viewTel.isHidden                   = true
            self.lblDescription.isHidden            = true
            self.lblTaxable.isHidden                = true
            self.lblAdd.isHidden                    = true
            self.constraintTopLblDescription.constant = 0
            self.addressDescriptions(isHidden: true)
            self.hiddenErrorReceiptNo()
            self.imgErrorReceiptNo.isHidden         = true
            if (row.value?.isEmpty ?? false) {
                self.labelSelectedValue.text = "select".localized
            }
            else {
                self.labelSelectedValue.text = row.value
            }
            
        case .DEBITDATE:
            self.labelTitle.text                    = mappingRow?.description.localized 
            self.imageViewLeadingIcon.image         = UIImage(named: "list_debit_date_ico")
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.viewofCurrency.isHidden            = true
            self.textFieldEnterValue.isHidden       = true
            self.labelSelectedValue.isHidden        = false
            self.imageViewChevronRight.isHidden     = false
            self.labelSelectedValue.textColor       = UIColor(hexString: "#0069B9")
            self.viewNormal.isHidden                = false
            self.viewMerchant.isHidden              = true
            self.viewTel.isHidden                   = true
            self.lblTaxable.isHidden                = true
            self.lblAdd.isHidden                    = true
            self.addressDescriptions(isHidden: true)
            self.hiddenErrorReceiptNo()
            self.contentView.isUserInteractionEnabled = true
            self.imgErrorReceiptNo.isHidden         = true
            
            if (row.value?.isEmpty ?? false) {
                self.labelSelectedValue.text = "dd MMM yyyy"
            }
            else {
                self.labelSelectedValue.text = formatteDate(date: row.value ?? "")
            }
            
        case .TEL:
            self.labelTitle.text                    = mappingRow?.description.localized
            self.imageViewLeadingIcon.image         = UIImage(named: "list_purpose_ico")
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.viewofCurrency.isHidden            = true
            self.textFieldEnterValue.isHidden       = true
            self.labelSelectedValue.isHidden        = false
            self.imageViewChevronRight.isHidden     = false
            self.labelSelectedValue.textColor       = UIColor(hexString: "#0069B9")
            self.viewNormal.isHidden                = true
            self.viewMerchant.isHidden              = true
            self.viewTel.isHidden                   = false
            self.lblTaxable.isHidden                = true
            self.lblAdd.isHidden                    = true
            self.addressDescriptions(isHidden: true)
            self.hiddenErrorReceiptNo()

            self.tfPhoneNumber.isUserInteractionEnabled          = true
            self.btnDropDownCodeCountry.isUserInteractionEnabled = true

            self.tfPhoneNumber.tag              = 1015
            self.btnDropDownCodeCountry.tag     = 1081

            self.imgErrorReceiptNo.isHidden         = true
            self.lblTel.text                    = "tel".localized
            self.lblCodeCountry.text            = row.key
            self.tfPhoneNumber.text             = row.value
            self.tfPhoneNumber.placeholder      = "phone_number".localized
            
//        case .EMAIL:
//            self.labelTitle.text                    = mappingRow?.description.localized
//            self.imageViewLeadingIcon.image         = UIImage(named: "list_email.ico")
//            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
//            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
//            self.viewofCurrency.isHidden            = true
//            self.textFieldEnterValue.isHidden       = false
//            self.labelSelectedValue.isHidden        = true
//            self.imageViewChevronRight.isHidden     = true
//            self.viewNormal.isHidden                = false
//            self.viewMerchant.isHidden              = true
//            self.viewTel.isHidden                   = true
//            self.lblTaxable.isHidden                = true
//            self.lblAdd.isHidden                    = true
//            self.addressDescriptions(isHidden: true)
//            self.hiddenErrorReceiptNo()
//
//            self.imgErrorReceiptNo.isHidden         = true
//            self.textFieldEnterValue.isUserInteractionEnabled = !isAutoMerchant
//
//            self.textFieldEnterValue.tag            = 1016
//
//            self.textFieldEnterValue.placeholder    = "enter_email".localized
//            self.textFieldEnterValue.text           = row.value ?? ""
              
//        case .ADDRESS:
//            self.labelTitle.text                    = mappingRow?.description.localized
//            self.imageViewLeadingIcon.image         = UIImage(named: "list_addr_ico")
//            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
//            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
//            self.imageViewChevronRight.isHidden     = false
//            self.viewofCurrency.isHidden            = true
//            self.textFieldEnterValue.isHidden       = true
//            self.viewNormal.isHidden                = false
//            self.viewMerchant.isHidden              = true
//            self.viewTel.isHidden                   = true
//            self.lblTaxable.isHidden                = true
//            self.imgErrorReceiptNo.isHidden         = true
//            self.hiddenErrorReceiptNo()
//
//            self.contentView.isUserInteractionEnabled = !isAutoMerchant
//
//            self.selectWithArrow(isHidden: (row.key?.isEmpty ?? false))
//            self.addressDescriptions(isHidden: (row.value?.isEmpty ?? false), value: row.value ?? "")
               
//        case .USER:
//            self.labelTitle.text                    = mappingRow?.description.localized
//            self.imageViewLeadingIcon.image         = UIImage(named: "list_user_ico")
//            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
//            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
//            self.viewofCurrency.isHidden            = true
//            self.textFieldEnterValue.isHidden       = false
//            self.labelSelectedValue.isHidden        = true
//            self.imageViewChevronRight.isHidden     = true
//            self.viewNormal.isHidden                = false
//            self.viewMerchant.isHidden              = true
//            self.viewTel.isHidden                   = true
//            self.lblTaxable.isHidden                = true
//            self.imgErrorReceiptNo.isHidden         = true
//            self.lblAdd.isHidden                    = true
//            self.addressDescriptions(isHidden: true)
//            self.hiddenErrorReceiptNo()
//            self.textFieldEnterValue.tag            = 1012
//            self.textFieldEnterValue.isUserInteractionEnabled = true
//
//            self.textFieldEnterValue.placeholder    = "enter_name".localized
//            if (row.value?.isEmpty ?? false) {
//                self.textFieldEnterValue.text = Shared.R002_DATA?.USER_NM
//            }
//            else {
//                self.textFieldEnterValue.text = row.value ?? ""
//            }
            
        case .RATE:
            self.labelTitle.text                    = mappingRow?.description.localized
            self.imageViewLeadingIcon.image         = UIImage(named: "list_rates_ico")
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.viewofCurrency.isHidden            = true
            self.textFieldEnterValue.isHidden       = false
            self.labelSelectedValue.isHidden        = true
            self.imageViewChevronRight.isHidden     = true
            self.viewNormal.isHidden                = false
            self.viewMerchant.isHidden              = true
            self.viewTel.isHidden                   = true
            self.lblTaxable.isHidden                = true
            self.imgErrorReceiptNo.isHidden         = true
            self.lblAdd.isHidden                    = true
            self.addressDescriptions(isHidden: true)
            self.hiddenErrorReceiptNo()
           
            self.textFieldEnterValue.isUserInteractionEnabled = true
            
            self.textFieldEnterValue.tag            = 1017
            self.textFieldEnterValue.placeholder    = "enter_rate".localized
            self.textFieldEnterValue.text           = (row.value ?? "").isEmpty ? "" : (customFormatCurrency(CCY_CD: "USD", amount: row.value ?? "")).components(separatedBy: ",").first
             
        case.AMOUNTKHR:
            self.labelTitle.text                    = mappingRow?.description.localized
            self.imageViewLeadingIcon.image         = UIImage(named: "list_amount_ico")
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.viewofCurrency.isHidden            = true
            self.textFieldEnterValue.isHidden       = false
            self.labelSelectedValue.isHidden        = true
            self.imageViewChevronRight.isHidden     = true
            self.viewNormal.isHidden                = false
            self.viewMerchant.isHidden              = true
            self.viewTel.isHidden                   = true
            self.lblTaxable.isHidden                = false
            self.textFieldEnterValue.isHidden       = true
            self.imgErrorReceiptNo.isHidden         = true
            self.lblAdd.isHidden                    = true
            self.addressDescriptions(isHidden: true)
            self.hiddenErrorReceiptNo()
            
            self.textFieldEnterValue.tag            = 1018
            self.lblTaxable.textColor = UIColor(hexString: "#A6A6A6")
             
            self.lblTaxable.text = (row.value ?? "").isEmpty ? "0" : row.value?.components(separatedBy: ",").first
            
        case.WITH_HOLDING_TAX :
            self.labelTitle.text                    = mappingRow?.description.localized
            self.imageViewLeadingIcon.image         = UIImage(named: "content_cut_black_24dp")
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.viewofCurrency.isHidden            = true
            self.textFieldEnterValue.isHidden       = true
            self.labelSelectedValue.isHidden        = false
            self.imageViewChevronRight.isHidden     = false
            self.labelSelectedValue.textColor       = UIColor(hexString: "#0069B9")
            self.viewNormal.isHidden                = false
            self.viewMerchant.isHidden              = true
            self.viewTel.isHidden                   = true
            self.lblTaxable.isHidden                = true
            self.imgErrorReceiptNo.isHidden         = true
            self.lblAdd.isHidden                    = true
            self.addressDescriptions(isHidden: true)
            self.hiddenErrorReceiptNo()
            
            let value = row.value ?? ""
            let withHoldingValue = String(value.dropLast(3))
            
            if (row.value?.isEmpty ?? true) {
                self.labelSelectedValue.text = "select".localized
            }
            else {
                self.labelSelectedValue.text = withHoldingValue + value.getLast3Characters()
            }
            
        case.TAX_AMOUNT :
            
            self.labelTitle.text                    = mappingRow?.description.localized
            self.imageViewLeadingIcon.image         = UIImage(named: "money_black_24dp")
            self.listMerchantIcon.image             = UIImage(named: "list_merchant_ico")
            self.imageViewChevronRight.image        = UIImage(named: "list_arrow_ico")
            self.viewofCurrency.isHidden            = true
            self.textFieldEnterValue.isHidden       = true
            self.labelSelectedValue.isHidden        = true
            self.imageViewChevronRight.isHidden     = true
            self.viewNormal.isHidden                = false
            self.viewMerchant.isHidden              = true
            self.viewTel.isHidden                   = true
            self.lblTaxable.isHidden                = false
            self.lblAdd.isHidden                    = true
            self.addressDescriptions(isHidden: true)
            self.hiddenErrorReceiptNo()
            self.imgErrorReceiptNo.isHidden         = true
            self.lblTaxable.textColor = UIColor(hexString: "#A6A6A6")
            
            if (row.value == "") {
                self.lblTaxable.text = self.isKHR ? "0" : "0.00"
            }
            else {
                self.lblTaxable.text = (row.value?.toKHRCurrency().replace(of: ",", with: ".") ?? "0")
            }
            
        default: break 
        }
    }
    
}
 

//MARK: - Description Cell
class DescriptionNewReceiptCell: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var labelDescription     : UILabel!
    @IBOutlet weak var textViewDescription  : PlaceholderTextView!
    @IBOutlet weak var imgViewDot           : UIImageView!
    
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
         
        self.setLocalized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setLocalized() {
        self.labelDescription.text                  = "description".localized
        self.textViewDescription.placeholderText    = "please_enter_descr".localized
        self.labelDescription.getlocalizedFont()
        self.textViewDescription.getlocalizedFont()
    }
     
}

//MARK: - Attachment Cell
class AttachmentNewReceiptCell: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var labelAttachment      : UILabel!
      
    @IBOutlet weak var ViewAddImage         : UIView!
    @IBOutlet weak var labelTapToAddImage   : UILabel!
    @IBOutlet weak var buttonTapAddImage    : UIButton!
     
    @IBOutlet weak var viewDisplayImage     : UIView!
    @IBOutlet weak var buttonRemoveImage    : UIButton!
    @IBOutlet weak var imageViewDisplayImage: UIImageView!
    @IBOutlet weak var skeletonView         : UIView!
    
 
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setLocalized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Customize func
    func setupImageForReceipt(imageURL: String) {
        
        //setup skeleton
        skeletonView.isHidden           = false
        skeletonView.backgroundColor    = .white
        skeletonView.isSkeletonable     = true
        skeletonView.showAnimatedGradientSkeleton()
         
//        Shared.imgCache.object(forKey: NSString(string: self.receiptList?.SAVE_FILE_NM ?? "")
        let url = URL(string: imageURL)
//        self.imageViewDisplayImage.sd_imageIndicator = SDWebImageActivityIndicator.gray //use skeleton and hide indicator
        self.imageViewDisplayImage.sd_setImage(with: url, completed: { (image, error, SDImageCacheType, url) in
            if error == nil { // Success
                
                self.skeletonView.isHidden = true
                
                let size        = image?.size
                var widthPic    : CGFloat = 0
                var heightPic   : CGFloat = 0
                
                widthPic        = (size?.width)!
                heightPic       = (size?.width)!
                 
                // The shortest side
                let sideLength      = min(widthPic, heightPic)
                
                // Determines the x,y coordinate of a centered
                // sideLength by sideLength square
                let xOffset         = ((size?.width)! - sideLength) / 2.0
                let yOffset         = ((size?.height)! - sideLength) / 2.0
                let cropImg         : CGRect    = CGRect(x: xOffset, y: yOffset, width: widthPic, height: heightPic)
                
                let cgImage         : CGImage   = image!.cgImage!.cropping(to: cropImg)!
                let croppedImage    : UIImage   = UIImage(cgImage: cgImage)
                
                /// ImageView
                self.imageViewDisplayImage.contentMode     = .scaleAspectFill
                self.imageViewDisplayImage.clipsToBounds   = true
                self.imageViewDisplayImage.image           = croppedImage
                
            }
            else {
                self.skeletonView.isHidden = true
                self.imageViewDisplayImage.image        = UIImage(named: "noimage")
                self.imageViewDisplayImage.contentMode  = .scaleAspectFill
            }
        })
    }
    
    private func setLocalized() {
        self.labelAttachment.text       = "attachment".localized
        self.labelTapToAddImage.text    = "tap_to_add_image".localized
        self.labelAttachment.getlocalizedFont()
        self.labelTapToAddImage.getlocalizedFont()
    }
    
    // Hide or show view with tap to add image and display image
    func isShowingAttachment(isHiddenDisplayImage: Bool, isHiddenAddImage: Bool, value: String, img: UIImage?) {
        
        if value.isEmpty {
            self.viewDisplayImage.isHidden  = isHiddenDisplayImage
            self.ViewAddImage.isHidden      = isHiddenAddImage
            if let img = img {
                self.viewDisplayImage.isHidden  = isHiddenAddImage
                self.ViewAddImage.isHidden      = isHiddenDisplayImage
                self.imageViewDisplayImage.image = img
                self.skeletonView.isHidden = true
            }
            
        }
        else {
            self.viewDisplayImage.isHidden  = isHiddenAddImage
            self.ViewAddImage.isHidden      = isHiddenDisplayImage
            setupImageForReceipt(imageURL: value)
        }
    }
      
}

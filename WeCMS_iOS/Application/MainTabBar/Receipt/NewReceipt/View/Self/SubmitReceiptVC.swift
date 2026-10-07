//
//  NewReceiptVC.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 11/1/21.
//

import UIKit
import Photos
import SkeletonView
import SDWebImage
import QuickLook
import PhotosUI
 
class SubmitReceiptVC: UIViewController, ContextMenuDemo  {
 
    //MARK: -  @IBOutlet
    @IBOutlet weak var labelTitle                   : UILabel!
    @IBOutlet weak var tableView                    : UITableView!
    @IBOutlet weak var submitBtn                    : UIButton!
    @IBOutlet weak var btnDeleteReceipt             : UIButton!
    
    // Date Picker
    @IBOutlet weak var buttonDoneDatePicker         : UIButton!
    @IBOutlet weak var constraintTopDatePickerView  : NSLayoutConstraint!
    @IBOutlet weak var pickerViewDate               : UIDatePicker!
    
    // View Picker
    @IBOutlet weak var pickerViewDoneBtn            : UIButton!
    @IBOutlet weak var constraintButtomPickerView   : NSLayoutConstraint!
    @IBOutlet weak var pickerView                   : UIPickerView!
    
    //MARK: - Variable
    // assign cell value
    var cellValue                       : SubmitReceiptModel.reeceipRow?
                        
    var receiptList                     : MREC_R006.RESPONSE.REC?
    var responseImage                   : MREC_C002.RESPONSE?
    var importTransactionData           : MREC_R007.RESPONSE.REC?
   
                
    // VM
    var receiptDetailVM                 = ReceiptDetailsVM()
    var editReceiptVM                   = SubmitReceiptVM()
    var maintabVM                       = MainTabBarVM()
    var settingVM                       = SettingVM()
    var paymentMethodVM                 = PaymentMethodVM()
    let importTransactionVM             = ImportTransactionVM()
    let bankVM                          = BankVM()
    var expenseVM                       = ExpenseVM()
       
    // delete from cell
    var delegate                        : getDataDelegate?
    
    var delegateAddress                 : addressDelegate?
       
    // max image : for choosing from gallery
    private var maxImages               : Int = 100
    var localImages             : [UIImage] = [] //image choosen from Gallary
    // For Zoom animation
    var receiptImage                    : UIImageView?
    
    // Selected Purpose
    var isShowPlanned_money             = true
       
    var selectPurposeIndex              : Int = -1 // -1 : isnot selected yet
    var selectDebitDateIndex            : Int = 0
    private var selectPaymentMethodIndex = 0
    
    // Get String Selected Cell
    var trco_key_defined_merchant       : String = ""
    
    // check with Auto merchant and currency is closed
    var isUSDCurrency                   : Bool = false
       
    // Picker View
    var isShowMerchantPicker            : Bool      = false
    var isShowBankPicker                : Bool      = false
    private(set) var merchantModule     : [String]  = ["manual_input", "select_from_contacts"]
        
    var address                         : [String] = []
        
    var isFromEditing                   : String = "Y"
    var copyClientData                  : [Client.ContentBody]?
    var clientData                      : [Client.ContentBody]?
    var r030REC1                        : MREC_R030.REC1?
    var r030REC2                        : MREC_R030.REC2?
    var rate                            = SubmitReceiptModel.reeceipRow.content(code: "RT")
      
    // max image : for choosing from gallery
    private var selectedImages          : UIImage? //image choosen from Gallary
    private var currentIndexPathImage   : IndexPath?
    var selectedContactIndexPath        : IndexPath?
     
    private var imgREC                  : [MREC_R006.RESPONSE.REC.REC1] = []
    private var fileREC                 : [MREC_R006.RESPONSE.REC.REC1] = []
    private var localDeleteREC1         : [MREC_R006.RESPONSE.REC.REC1] = []
     
    private let dateFormatter           = DateFormatter()
    private var documentManager         : DocumentsManager!
    var isSelectedExpense               = false
    var isClearVisible                  = false
    var isSearching                     = false
    var isJPG                           = true
    var localDocument                   = [FileModel]()
    
    var searchManualInputText           = ""
    var isSwitchButtonEnable            = true
    
    var valueTRCO_RPRS_TLPH             = "+000"
    var isFromSelectExpense             = false
    var dataClient                      : Client.ContentBody.Item?
    var isManualInput                   = false
    var merchant_value                  = ""
    var selected_TRCO_TRSC_CCY_CD       = ""
    
    var previewItems                    : [PreviewItem] = []
    let previewController               = QLPreviewController()
    let previewGenerator                = QLThumbnailGenerator()
    let thumbnailSize                   = CGSize(width: 60, height: 90)
    let imagePicker                     = ImagePicker()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.previewController.dataSource = self
        self.previewController.delegate   = self
        imagePicker.delegate = self
        self.pickerViewDate.calendar = Calendar(identifier: .gregorian)

        self.fetchBankList() // Fetch List Bank
        self.fetchingExchangeRate() // Exchange rate for USD currency
        self.checkProjectSite()
        
        if receiptList?.TRCO_NICK_NM != "" && receiptList?.TRCO_NICK_NM != nil{
            self.isClearVisible = true
        }else{
            self.isClearVisible = false
        }
        self.setUpVC() // some supported ui
        self.checkNotify() // NotificationCenter
        self.tableView.register(UINib(nibName: "AddressCell", bundle: nil), forCellReuseIdentifier: "AddressCell")
    }
    
    //hide navigationBar on SubmitReceiptVC
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = UIColor(hexString: "#666666")
        self.setNavigationBarStyle(isHidden: true, animated: animated, title: nil)
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setNavigationBarStyle(isHidden: false, animated: animated, title: nil)
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case NotifyKey.gotoPhotoPreviewVC.rawValue :
            let vc = segue.destination as! PhotoPreviewsVC
            vc.delegate = self
            vc.currentIndexImage  = currentIndexPathImage?.row
            vc.currentIndexImage = currentIndexPathImage?.section == 2 ? self.imgREC.count + (currentIndexPathImage?.row ?? 0): (currentIndexPathImage?.row ?? 0)
            var imgRec : [Any]   = []
            
//            let fileURLRec = self.imgREC.compactMap { $0.FILE_URL }
            let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
            for imgUrl in imgREC {
                let split_url       = imgUrl.FILE_URL?.components(separatedBy: "?")
                let img_url         = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")"
                imgRec.append(img_url) //file url
            }
            
//            imgRec.append(contentsOf: fileURLRec ) //file url
            imgRec.append(contentsOf: localImages) //img

            vc.imageUrlArray     = [["RCPT_IMG_URL" : imgRec]] as Array<AnyObject>
            
            if let receiptImage = receiptImage {
                vc.cc_setZoomTransition(originalView: receiptImage) // Zoom trasition for receipt image
            }
            
        default: break
        }
    }
    
    //MARK: - @IBAction
    @IBAction func didTapDismissAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
     
    @IBAction func didTapDoneDatePickerAction(_ sender: UIButton) {
        self.hideDatePicker()
    }
    
    @IBAction func didTapDonePickerViewAction(_ sender: UIButton) {
        let int = pickerView.selectedRow(inComponent: 0)
        self.pickerView(self.pickerView, didSelectRow: int, inComponent: 0)
        
        if self.isShowBankPicker {
            let bankName = (self.bankVM.sortedBankList?[int].BANK_NM?.split(separator: "|").first ?? "").replacingOccurrences(of: " ", with: "")
            self.setValue(newValue: getValue(from:.BANK), newKey: String(bankName), code: .BANK, other: getmoreValue(from: .BANK))
        }
        self.checkingSubmitButton()
        self.hidePickerView()
    }
    
    @IBAction func didTapSubmitBtn(_ sender: UIButton) {
        self.checkingSubmitButton()
        self.receiptList?.PROV_STTS == "PP" ? self.createReceipt() : self.updateReceipt()
    }
    
    @IBAction func didTapDeleteReceiptBtn(_ sender: UIButton) {
        customAlert(type        : .YES_OR_NO_ALERT,
                    image       : "badge_warning",
                    title       : "delete".localized,
                    message     : "are_you_sure_you_want_to_delete_the_receipt".localized,
                    redTitle    : "delete".localized,
                    greyTitle   : "cancel".localized) { (isDelete) in
            if isDelete {
                self.deleteReceipt(REG_DT: self.receiptList?.REG_DT ?? "", SEQ_NO: self.receiptList?.SEQ_NO ?? "")
            }
        }
    }
     
    @IBAction func didTapValueChangeDatePicker(_  : UIDatePicker) {
   
        // to check date picker
        let currentDate = Shared.share.getCurrentDate(date: Date()).serverDate
  
        self.pickerViewDate.locale  = Locale(identifier: Shared.language.rawValue)
        let pickerDate              = self.pickerViewDate.date
        let pickerDateString        = Shared.share.getCurrentDate(date: pickerDate).dateString
        let dateStr                 = "\(pickerDateString)"
        let dateformatte            = dateStr.formattedDateFromString(dateString: dateStr, withFormat: "yyyyMMdd") ?? ""
        
        if Shared.share.getCurrentDate(date: pickerDate).serverDate <= currentDate { // Checking: not allowed user to select future date
            self.setValue(newValue: dateformatte, code: pickerViewDate.tag == 3000 ? .DATE : .DEBITDATE)
        }
        else {
            let use_dt = self.pickerViewDate.tag == 3000 ? self.receiptList?.USE_DT ?? "" : self.receiptList?.TRSC_DT2 ?? currentDate
            self.setValue(newValue: use_dt, newKey: currentDate, code: self.pickerViewDate.tag == 3000 ? .DATE : .DEBITDATE)
            self.pickerViewDate.date = dateFormatter.date(from: currentDate) ?? Date()
        }
        self.tableView.reloadRows(at: [IndexPath(row: self.pickerViewDate.tag == 3000 ? 1 : selectDebitDateIndex, section: 0)], with: .none)
    }
    
    @IBAction func editingChangedTxt(_ sender: UITextField) {
        // for amount
        switch sender.tag {
        
        // Amount
        case 1010:
             
            if (getValue(from: .CURRENCY) == CurrencyType.USD.rawValue) || (isUSDCurrency || self.receiptList?.TRCO_TRSC_CCY_CD == "USD") {
                if let text = sender.text {
                    if  text == "" ||  text == "." ||  text == "," {
                        self.checkingSubmitButton()
                    }
                    else {
                        let lastStr = "" + text.suffix(1) // convert to string
                        if text.contains(",") {
                            let strDevide = text.components(separatedBy: ",")
                            if let valueBeforeDot = Double(strDevide[0].replacingOccurrences(of: ".", with: "")) {
                                
                                sender.text = (String(valueBeforeDot).components(separatedBy: ".").first?.vndCurrencyFormatter() ?? "") + "," + ((strDevide[1].prefix(2)).replacingOccurrences(of: ",", with: ""))
                                self.checkingSubmitButton()
                            }
                        }
                        else if lastStr.contains(".") { // version upper 14.4
                            sender.text = text.dropLast() + ","
                            self.checkingSubmitButton()
                        }
                        else {
                            if let value = sender.text?.replacingOccurrences(of: ".", with: "") {
                                sender.text = (String(value).components(separatedBy: ".").first?.vndCurrencyFormatter() ?? "")
                                self.checkingSubmitButton()
                            }
                        }
                    }
                    if let textStr = sender.text {
                        self.setValue(newValue: textStr, code: .AMOUNT)
                        //Update Tax_Amount Value
                        self.updateTaxAmount(amount: textStr)
                    }
                }
                
                
                self.calculatedAmount()
                self.checkingSubmitButton()
                self.importTransactionValidation()
            }
            else {
                if let text = sender.text?.vndCurrencyFormatter() {
                    sender.text = text
                    self.setValue(newValue: text, code: .AMOUNT)
                    
                    if let content = cellValue?.content {
                        //if have AMT_KHR
                        //set value to AMOUNTKHR when input amount
                        let isAmtKHRExist       = content.contains(where: { $0.code == ReceiptRow.AMOUNTKHR.rawValue })
                        if isAmtKHRExist {
                            self.calculatedAmount()
                        }
                    }
                     
                    if let content = cellValue?.content {
                        // check in have TAX_AMOUNT in display data on tableview
                        let isTaxAmountExist      = content.contains(where: { $0.code == ReceiptRow.TAX_AMOUNT.rawValue })
                        if isTaxAmountExist {
                            //Update Tax_Amount Value
                            self.updateTaxAmount(amount: text)
                        }
                    }
                    
                    self.checkingSubmitButton()
                    self.importTransactionValidation()
                }
            }
              
         // Phone Number
        case 1015:
            if let text = sender.text {
                var newString = String()
                
                if  text.prefix(1) == "0" && text.count > 2 {
                    newString = String(text.dropFirst())
                }
                else {
                    newString = text
                }

                sender.text = newString //Old Format -> applyPatternOnNumbers(pattern: "##-###-####", replacmentCharacter: "#")
                self.setValue(newValue: newString, newKey: getKey(from: .TEL), code: .TEL)
                self.checkingSubmitButton()
            }
            
        // Email
        case 1016:
            self.setValue(newValue: sender.text ?? "", code: .EMAIL)
            self.checkingSubmitButton()
        
        // Rate
        case 1017:
            if let text = sender.text?.vndCurrencyFormatter() {
                sender.text = text
                self.setValue(newValue: text, code: .RATE)
                self.calculatedAmount()
                self.checkingSubmitButton()
            }
        
            // Amount(KHR)
            
            // FIXME: - OnHolding
//        case 1018:
//            if let text = sender.text?.khrCurrencyFormatter() {
//                sender.text = text
//                self.setValue(newValue: text, code: .AMOUNTKHR)
//                self.checkingSubmitButton()            }
            
        default: break
        }
    }
    
    //MARK: - Private func
    func getSupplierName(supplier_code: String) -> String {
        var supplier = "1"
        switch supplier_code {
        case "1": supplier = "taxable_person".localized
        case "2": supplier = "non_taxable_person".localized
        case "3": supplier = "oversea_company".localized
        default: break
        }
        return supplier
    }
    
    /// Show Delete Popup, if pressed yes call D001 API
    /// - Parameters:
    ///   - completion: let caller handle latter
    func showPopupDeleteImage(completion: @escaping Completion) {
        customAlert(type        : .YES_OR_NO_ALERT,
                    image       : "badge_warning",
                    title       : "delete".localized,
                    message     : "are_you_sure_want_to_delete_the_attached_image".localized,
                    redTitle    : "delete".localized,
                    greyTitle   : "cancel".localized) { (isDelete) in
            if isDelete {
                completion()
            }
        }
    }
    
    func getDocumentsDirectory() -> URL { // returns your application folder
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func fetchBankList() {
        let body = MREC_R008.REQUEST(LANG_CODE: Shared.language.rawValue, BANK_NM: "", IS_SCRAPPING: "", USE_SHORT_NAME: "Y")
        self.bankVM.fetchBankList(body: body, completion: { result in
            switch result {
            case .success(_):
                print("")
                
            case .failure(let error):
                self.alertError(message: error.localizedDescription)
            }
        })
    }
  
    private func checkNotify() {
        MyNotify.listen(self, selector: #selector(SuccessTakePhotoFromSubmitReceiptVC(_:)), name: .SuccessTakePhotoFromSubmitReceiptVC)
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func showDatePicker() {
        self.dismissKeyboard()
        self.hidePickerView()
          
        if self.pickerViewDate.tag == 3000 {
            let strDate                 = self.getValue(from: .DATE)
            let dateStrings             = self.dateFormatter.date(from: strDate) ?? Date()
            self.pickerViewDate.date    = dateStrings
        }
        else {
            let strDebitDate            = self.getValue(from: .DEBITDATE)
            let debitDateStrings        = self.dateFormatter.date(from: strDebitDate) ?? Date()
            self.pickerViewDate.date    = debitDateStrings
        }
         
        UIView.animate(withDuration: 0.3) {
            self.constraintTopDatePickerView.constant = -240
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideDatePicker() {
        UIView.animate(withDuration: 0.3) {
            self.constraintTopDatePickerView.constant = 0
            self.view.layoutIfNeeded()
        }
        self.pickerViewDate.datePickerMode           = .date
        if #available(iOS 13.4, *) {
            self.pickerViewDate.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        self.pickerViewDate.maximumDate              = Date() // Limit Date
        if self.pickerViewDate.tag == 3000 {
            let dateStrings = self.pickerViewDate.date
            let strDate     = dateStrings.toString(format: "yyyyMMdd")
            self.setValue(newValue: strDate, code: .DATE)
            let row = self.getIdx(cell_code: .DATE)
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        }
    }
    
    private func showPickerView() {
        self.dismissKeyboard()
        self.hideDatePicker()
        
        UIView.animate(withDuration: 0.3) {
            self.constraintButtomPickerView.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func hidePickerView() {
        UIView.animate(withDuration: 0.3) {
            self.constraintButtomPickerView.constant = -240
            self.view.layoutIfNeeded()
        }
    }
    
    private func setUpVC() {
        
        // Acceptable File extension: .pdf, .ppt, .xls, .doc
        self.fileREC = (receiptList?.REC1 ?? []).filter({ obj1 in
            let fileExtension = obj1.ORG_FILE_NM?.components(separatedBy: ".").last?.lowercased() ?? ""
            
            return fileExtension.contains("pdf") || fileExtension.contains("ppt") || fileExtension.contains("xls") || fileExtension.contains("doc")
            
        })
        
        self.imgREC = (receiptList?.REC1 ?? []).filter({ obj1 in
            let fileExtension = obj1.ORG_FILE_NM?.components(separatedBy: ".").last?.lowercased() ?? ""
            
            return !fileExtension.contains("pdf") && !fileExtension.contains("ppt") && !fileExtension.contains("xls") && !fileExtension.contains("doc")
            
        })
        tableView.tableFooterView = UIView()
        tableView.contentInset    = UIEdgeInsets.init(top: 0, left: 0, bottom: 91, right: 0)
        
        self.setLocalized()
        self.btnDeleteReceipt.isHidden =  self.receiptList?.PROV_STTS == "PP" ? false : true // Hidden delete button if editing receipt
        
        self.dateFormatter.timeZone      = TimeZone.current
        self.dateFormatter.locale        = Locale.current
        self.dateFormatter.dateFormat    = "yyyyMMdd"
    }
    
    private func setLocalized() {
        // Checking title and create button of receipt
        self.labelTitle.text        =  self.receiptList?.PROV_STTS == "PP" ? "save_a_receipt".localized : "edit_a_receipt".localized
        self.isShowPlanned_money    = self.receiptList?.PROV_STTS == "PP"
        self.submitBtn.setTitle("save".localized, for: .normal)
        self.buttonDoneDatePicker.setTitle("done".localized, for: .normal)
        self.pickerViewDoneBtn.setTitle("done".localized, for: .normal)
        
        self.labelTitle.getlocalizedFont()
        self.submitBtn.getlocalizedFont()
        self.buttonDoneDatePicker.getlocalizedFont()
        self.pickerViewDoneBtn.getlocalizedFont()
    }
    
    private func checkHiddenErrorReceiptNo() {
        let row = self.getIdx(cell_code: .RECEIPTNO)
        if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? SubmitReceiptCell {
            cell.imgErrorReceiptNo.isHidden                     = true
            cell.lblTaxable.isHidden                            = true
            cell.isErrorReceiptNo                               = true
            cell.constraintWidthErrorReceiptNo.constant         = 0
            cell.constraintWidthErrorReceiptNoLeading.constant  = 0
            
        }
    }
     
    private func displayCells() {
        
        // ****************** NOTE : Server will always response related to currency in ##.## formatte ******************
        
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
         
        // set value to  PickerView get date from existing data
        self.pickerViewDate.locale = Locale(identifier: Shared.language.rawValue)
        self.pickerViewDate.date   = self.pickerViewDate.date.getDateFromString(dateString: self.receiptList?.USE_DT ?? "" )
         
        let amountFormatte  = receiptList?.TOTL_AMT == "0" ? "" : (receiptList?.TOTL_AMT?.replace(of: ".", with: ",") ?? "")
        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
        let split_url       = self.receiptList?.REC1?.first?.FILE_URL?.components(separatedBy: "?")
        var currency_code : String = CurrencyType.VND.rawValue
        
        if let cur_cd = self.receiptList?.TRCO_TRSC_CCY_CD {
            currency_code = cur_cd
        }
         
        self.isUSDCurrency = currency_code == "USD"
      
        //  let merchant_value = self.isFromEditing == "Y" ? self.receiptList?.TRCO_NICK_NM : ""  => Old condition code
        var merchant_value = ""
        if self.isFromEditing == "Y"{
            if self.receiptList?.TRCO_NICK_NM == "" || self.receiptList?.TRCO_NICK_NM == nil{
                merchant_value = self.receiptList?.TRCO_CMENM ?? ""
            }else{
                merchant_value = self.receiptList?.TRCO_NICK_NM ?? ""
            }
        }else{
            merchant_value = ""
        }
         
        let type_of_supplier = mappingTypeOfSupplier(value: self.receiptList?.TRCO_TYPE ?? "1")
        let tax_id     = self.receiptList?.TRCO_TYPE == "3" ? (self.receiptList?.GST_NO ?? "") : (self.receiptList?.TRCO_TAX_ID ?? "")
        let tax_id_key = TypeOfSupplier(rawValue: self.receiptList?.TRCO_TYPE ?? "1")?.description.localized
        var trco_key : String = ""
        
        if self.isFromEditing == "N" {
            trco_key = " (\("manual".localized))"
        }else{
            trco_key = !(self.receiptList?.TRCO_KEY ?? "").isEmpty ? self.receiptList?.TRCO_KEY ?? "" : " (\("manual".localized))"
        }
 
        let taxCalMoney = self.calculateTaxAmount(amount: receiptList?.TOTL_AMT ?? "0", rate: receiptList?.TAX_RATE ?? "")
        let formatTaxtAmt = currency_code == "USD" ? formatCurrency(type: receiptList?.TRCO_TRSC_CCY_CD ?? "", amount: taxCalMoney) : taxCalMoney
        var paymentMethodValue = ""
        
        if self.isFromEditing == "Y" && self.receiptList?.ADV_PAYM_NM != "" && self.receiptList?.ADV_PAYM_NM != nil {
            paymentMethodValue = self.receiptList?.ADV_PAYM_NM ?? ""
            
        }else{
            if self.receiptList?.PAY_WAY_CD == "Q" {    // PAY_WAY_CD == "Q" for Payment Method = Cheque
                paymentMethodValue = self.paymentMethodVM.paymentData[self.selectPaymentMethodIndex].title.isNotEmpty ? "cheque".localized : self.paymentMethodVM.paymentData[self.selectPaymentMethodIndex].title
                self.selectPaymentMethodIndex = 2
            }
            else if self.receiptList?.PAY_WAY_CD == "A" {  // PAY_WAY_CD == "A" for Payment Method = Transfer
                paymentMethodValue = self.paymentMethodVM.paymentData[self.selectPaymentMethodIndex].title.isNotEmpty ? "transfer".localized : self.paymentMethodVM.paymentData[self.selectPaymentMethodIndex].title
                self.selectPaymentMethodIndex = 3
            }
            else if self.receiptList?.PAY_WAY_CD == "C" {   // PAY_WAY_CD == "C" for Payment Method = Cash
                paymentMethodValue = self.paymentMethodVM.paymentData[self.selectPaymentMethodIndex].title.isNotEmpty ? "cash".localized : self.paymentMethodVM.paymentData[self.selectPaymentMethodIndex].title
                self.selectPaymentMethodIndex = 1
            }
            else if self.receiptList?.PAY_WAY_CD == "P" {  // PAY_WAY_CD == "P" for Payment Method = Advance
                paymentMethodValue = self.paymentMethodVM.paymentData[self.selectPaymentMethodIndex].title.isNotEmpty ? "advance".localized : self.paymentMethodVM.paymentData[self.selectPaymentMethodIndex].title
                self.selectPaymentMethodIndex = 4
            }
        }
        
        // Get payment method index to insert row Import Transaction below Payment Method
//        var payWayAmount    = ""
//            payWayAmount = "\(self.receiptList?.TRCO_TRSC_CCY_CD == "USD" ? "$\((self.receiptList?.PAY_WAY_AMT ?? "").usdCurrency)" : "R\((self.receiptList?.PAY_WAY_AMT ?? "").components(separatedBy: ".").first?.formatKHRCurrency() ?? "")")"
//        }else{
//            payWayAmount = "\(self.receiptList?.TRCO_TRSC_CCY_CD == "USD" ? "$\((self.receiptList?.PAY_WAY_AMT ?? "").usdCurrency)" : "\((self.receiptList?.PAY_WAY_AMT ?? "").components(separatedBy: ".").first?.vndCurrencyFormatter() ?? "")₫")"
//        }
        
//        let message         = "OOO_OOO_match".localized
//        let importValue     = self.isFromEditing == "Y" ? (self.receiptList?.PAY_WAY_CD == "A" ? String(format: message, "\(formatteDate(date: self.receiptList?.TRSC_DT2 ?? ""))", "\(payWayAmount)") : "") : ""
        
        // Debit Date row
//        let debitDateValue  = self.isFromEditing == "Y" ? ((self.receiptList?.TRSC_DT2?.isEmpty ?? true) ? self.dateFormatter.string(from: Date()) : self.receiptList?.TRSC_DT2) : self.dateFormatter.string(from: Date())
        
        // BANK row
//        let bankValue       = self.isFromEditing == "Y" ? (self.receiptList?.PAY_WAY_CD == "Q" ? self.receiptList?.CHEQ_NUM : "") : ""
//        let bankName        = self.isFromEditing == "Y" ? (self.receiptList?.PAY_WAY_CD == "Q" ? self.receiptList?.BANK_NM?.replacingOccurrences(of: " ", with: "") : "") : ""
//        let bankOther       = self.isFromEditing == "Y" ? (self.receiptList?.PAY_WAY_CD == "Q" ? self.receiptList?.BANK_CD : "") : ""
        
//        let advancedValue   = self.isFromEditing == "Y" ? (self.receiptList?.PAY_WAY_CD == "P" ? self.receiptList?.ADV_PAYM_NM           : "")   : ""
//        let advancedKey     = self.isFromEditing == "Y" ? (self.receiptList?.PAY_WAY_CD == "P" ? self.receiptList?.ADV_PAYM_SEQ          : "")   : ""
//        let advancedOther   = self.isFromEditing == "Y" ? (self.receiptList?.PAY_WAY_CD == "P" ? self.getmoreValue(from: .ADVANCELEDGER) : "")   : ""
        
        var dateValue       = self.receiptList?.USE_DT ?? ""
        // if date from api is empty, set current date
        if dateValue == "" {
            dateValue = Date.getCurrentDate()
        }
        
        let paymentMethodKey    = self.paymentMethodVM.paymentData[self.selectPaymentMethodIndex].subTitle
        let paymentMethodOther  = self.receiptList?.PAY_WAY_CD ?? ""
        let purposeValue    = self.receiptList?.USAG_NM
        let purposeKey      = self.receiptList?.BUSA_USAG_CD
        
//        let userValue       = self.receiptList?.PROV_STTS == "PP" ? (Shared.R002_DATA?.USER_NM ?? "") : (self.receiptList?.USER_NM ?? "")
        
//        let importTransOther = self.receiptList?.PAY_WAY_AMT ?? ""
        
        let descValue       = self.receiptList?.CONT
        let img_url         = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")"
        let attachKey       = self.receiptList?.SEQ_NO
        
        cellValue = SubmitReceiptModel.reeceipRow(content: [
            SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.DATE.rawValue,           value: dateValue),
            SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.MERCHANT.rawValue,       value: merchant_value, key: trco_key),
            SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.TAXID.rawValue,          value: tax_id,              key: tax_id_key),
            SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.AMOUNT.rawValue,         value: amountFormatte),
            SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.PURPOSE.rawValue,        value: purposeValue,        key: purposeKey),
//            SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.IMPORT_TRANSACTION.rawValue, value: importValue,     key: "true",            other: importTransOther),
//            SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.BANK.rawValue,           value: bankValue,           key: bankName,          other: bankOther),
//            SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.ADVANCELEDGER.rawValue,  value: advancedValue,       key: advancedKey,       other: advancedOther),
//            SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.DEBITDATE.rawValue,      value: debitDateValue),
            SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.DESCRIPTION.rawValue,    value: descValue),
//            SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.PROJECT_SITE.rawValue,   value: PRJT_NM, key: PRJT_NO),
            SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.PAYMENT_METHOD.rawValue, value: paymentMethodValue,  key: paymentMethodKey,  other: paymentMethodOther),
            SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.ATTACHMEMNT.rawValue,    value: img_url, key: attachKey)
        ])
        
                let withHoldingValue    = self.receiptList?.WHT_NM
        let withHoldingKey      = self.receiptList?.WHT_CD
        
         
//            cellValue = SubmitReceiptModel.reeceipRow(
//                content: [
            /* SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.RECEIPTNO.rawValue,        value: self.receiptList?.HAND_DOC_ID ?? "", key: isFromEditing),*/
                    
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.DATE.rawValue,             value: self.receiptList?.USE_DT ?? ""),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.MERCHANT.rawValue,         value: merchant_value,                      key: trco_key),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.TYPEOFSUPPLIER.rawValue,   value: type_of_supplier,                    key: trco_key),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.TAXID.rawValue,            value: tax_id,                              key: tax_id_key),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.CURRENCY.rawValue,         value: currency_code),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.AMOUNT.rawValue,           value: amountFormatte),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.WITH_HOLDING_TAX.rawValue, value: self.receiptList?.WHT_NM,            key: self.receiptList?.WHT_CD),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.TAX_AMOUNT.rawValue,       value: formatTaxtAmt),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.PURPOSE.rawValue,          value: self.receiptList?.USAG_NM,           key: self.receiptList?.BUSA_USAG_CD),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.PAYMENT_METHOD.rawValue,   value: paymentMethodValue, key: self.paymentMethodVM.paymentData[self.selectPaymentMethodIndex].subTitle, other: self.receiptList?.PAY_WAY_CD ?? ""),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.IMPORT_TRANSACTION.rawValue, value: importValue,                       key: "true", other: self.receiptList?.PAY_WAY_AMT ?? ""),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.BANK.rawValue,             value: bankValue,                           key: bankName, other: bankOther),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.ADVANCELEDGER.rawValue,    value: advancedValue,                       key: advancedKey, other: advancedOther),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.DEBITDATE.rawValue,        value: debitDateValue),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.USER.rawValue,             value: self.receiptList?.PROV_STTS == "PP" ? (Shared.R002_DATA?.USER_NM ?? "") : (self.receiptList?.USER_NM ?? "")),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.DESCRIPTION.rawValue,      value: self.receiptList?.CONT),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.ATTACHMEMNT.rawValue,      value: img_url,                             key: self.receiptList?.SEQ_NO)
//                ])
//        }
//        else {
//            cellValue = SubmitReceiptModel.reeceipRow(
//                content: [
            /* SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.RECEIPTNO.rawValue,        value: self.receiptList?.HAND_DOC_ID ?? "", key: isFromEditing),*/
                    
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.DATE.rawValue,             value: self.receiptList?.USE_DT ?? ""),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.MERCHANT.rawValue,         value: merchant_value,                      key: trco_key),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.CURRENCY.rawValue,         value: currency_code),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.AMOUNT.rawValue,           value: amountFormatte),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.PURPOSE.rawValue,          value: self.receiptList?.USAG_NM,           key: self.receiptList?.BUSA_USAG_CD),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.PAYMENT_METHOD.rawValue,   value: paymentMethodValue, key: self.paymentMethodVM.paymentData[self.selectPaymentMethodIndex].subTitle, other: self.receiptList?.PAY_WAY_CD ?? ""),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.IMPORT_TRANSACTION.rawValue, value: importValue,                       key: "true", other: self.receiptList?.PAY_WAY_AMT ?? ""),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.BANK.rawValue,             value: bankValue,                           key: bankName, other: bankOther),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.ADVANCELEDGER.rawValue,    value: advancedValue,                       key: advancedKey, other: advancedOther),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.DEBITDATE.rawValue,        value: debitDateValue),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.USER.rawValue,             value: self.receiptList?.PROV_STTS == "PP" ? (Shared.R002_DATA?.USER_NM ?? "") : (self.receiptList?.USER_NM ?? "")),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.DESCRIPTION.rawValue,      value: self.receiptList?.CONT),
//                          SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.ATTACHMEMNT.rawValue,      value: img_url,                             key: self.receiptList?.SEQ_NO)
//                ])
//        }
         
        /**
         Check display cell based on Input Item from Settings
         - "Y" : Open ( false ),
         - "N" : Close ( true )
         */
        if !(self.settingVM.settingsResponse?.INPUT_FIELD_SET_YN ?? false) {
            cellValue?.content.removeAll(where: { $0.code != ReceiptRow.AMOUNT.rawValue
                                               && $0.code != ReceiptRow.MERCHANT.rawValue
                                               && $0.code != ReceiptRow.TAXID.rawValue
                                               && $0.code != ReceiptRow.DESCRIPTION.rawValue
                                               && $0.code != ReceiptRow.ATTACHMEMNT.rawValue
                                               && $0.code != ReceiptRow.WITH_HOLDING_TAX.rawValue
                                               && $0.code != ReceiptRow.TAX_AMOUNT.rawValue
                                               && $0.code != ReceiptRow.PAYMENT_METHOD.rawValue
                                               && $0.code != ReceiptRow.IMPORT_TRANSACTION.rawValue
                                               && $0.code != ReceiptRow.BANK.rawValue
                                               && $0.code != ReceiptRow.ADVANCELEDGER.rawValue
                                               && $0.code != ReceiptRow.DEBITDATE.rawValue
                                               && $0.code != ReceiptRow.DATE.rawValue
                                               && $0.code != ReceiptRow.CURRENCY.rawValue
                                               && $0.code != ReceiptRow.PURPOSE.rawValue
                                               && $0.code != ReceiptRow.PROJECT_SITE.rawValue
                                              /* $0.code != ReceiptRow.RECEIPTNO.rawValue
                                               && $0.code != ReceiptRow.TYPEOFSUPPLIER.rawValue
                                               && $0.code != ReceiptRow.USER.rawValue*/
            })
        }
       
        // check tax type to display row in table
        self.supplier(type: TypeOfSupplier(rawValue: self.receiptList?.TRCO_TYPE ?? "1") ?? .TaxablePerson)

        if self.receiptList?.TRCO_TRSC_CCY_CD == CurrencyType.USD.rawValue {
            self.displayRate()
        }
  
        self.isFromEditing == "Y" ? () : self.fetchingReceiptNo() // Receipt No. value
        self.checkingSubmitButton()
    }
    
    func calculateTaxAmount(amount : String,rate : String) -> String {
        let amountIn = Double(amount) ?? 0.0
        let taxRate = Double(rate) ?? 0.0
        let taxCalMoney = Double(( amountIn * (taxRate / 100.0)))
        //quick solution to show *.00
        return String(format: "%.2f", taxCalMoney)
    }
    func formattingNumber(_ num: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator       = ","
        numberFormatter.groupingSize            = 3
        numberFormatter.usesGroupingSeparator   = true
        numberFormatter.decimalSeparator        = "."
        numberFormatter.numberStyle             = .decimal
        return numberFormatter.string(from: num as NSNumber)!
    }
     
    private func removeWhereKey(key: ReceiptRow) {
        cellValue?.content.removeAll(where: { $0.code == key.rawValue })
    }
     
    // to set value,key into array
    private func setValue(newValue: String = "", newKey: String = "", code: ReceiptRow, other : String = "") {
        for (index, value) in (cellValue?.content ?? []).enumerated() {
            if value.code == code.rawValue {
                cellValue?.content[index].value = newValue
                cellValue?.content[index].key   = newKey
                cellValue?.content[index].other = other
            }
        }
    }
     
    // retrieve value base on code
    private func getValue(from code: ReceiptRow) -> String {
        var val: String = ""
        for (_, value) in (cellValue?.content ?? []).enumerated() {
            if value.code == code.rawValue {
                val = (value.value ?? "")
            }
        }
        
        return val
    }
    
    // retrieve key base on code
    private func getKey(from code: ReceiptRow) -> String {
        var val: String = ""
        for value in cellValue?.content ?? [] {
            if value.code == code.rawValue {
                val = (value.key ?? "")
            }
        }
        
        return val
    }
    
    // retrieve value base on code
    private func getmoreValue(from code: ReceiptRow) -> String {
        var val: String = ""
        for (_, value) in (cellValue?.content ?? []).enumerated() {
            if value.code == code.rawValue {
                val = (value.other ?? "")
            }
        }
        
        return val
    }
    private func disableSubmitButton(isDisable: Bool) {
        self.submitBtn.backgroundColor  = UIColor(hexString: isDisable ? "#FAFAFA" : "#0069B9")
        self.submitBtn.isEnabled        = isDisable ? false : true
        self.submitBtn.setTitleColor(UIColor(hexString: isDisable ? "#A6A6A6" : "#FFFFFF"), for: .normal)
    }
    
    private func importTransactionValidation() {
        let isTrueOrFalse = self.getValue(from: .MERCHANT).isNotEmpty && self.getValue(from: .AMOUNT).isNotEmpty
        self.setValue(newValue: self.getValue(from: .IMPORT_TRANSACTION), newKey: "\(isTrueOrFalse)", code: .IMPORT_TRANSACTION, other: self.getmoreValue(from: .IMPORT_TRANSACTION))
        if cellValue?.content.contains(where: { $0.code == ReceiptRow.IMPORT_TRANSACTION.rawValue }) ?? false {
            let row = self.getIdx(cell_code: .IMPORT_TRANSACTION)
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        }
    }
    
    func checkingSubmitButton() {
        if let content = cellValue?.content {
            let boolDate        = content.contains(where: { $0.code == ReceiptRow.DATE.rawValue }) ? getValue(from: .DATE).isEmpty : false
            let boolMerchant    = content.contains(where: { $0.code == ReceiptRow.MERCHANT.rawValue }) ? getValue(from: .MERCHANT).isEmpty : false
            //            let boolTel         = content.contains(where: { $0.code == ReceiptRow.TEL.rawValue }) ? (getValue(from: .TEL).replace(of: "-", with: "").count < 8) : false
            let boolEmail       = content.contains(where: { $0.code == ReceiptRow.EMAIL.rawValue }) ? getValue(from: .EMAIL).isEmpty : false
            let boolAddress     = content.contains(where: { $0.code == ReceiptRow.ADDRESS.rawValue }) ? getValue(from: .ADDRESS).isEmpty : false
            let tel     = content.contains(where: { $0.code == ReceiptRow.TEL.rawValue }) ? getValue(from: .TEL).isEmpty : false
            let boolImg         = self.imgREC.isEmpty && self.localImages.isEmpty && self.localDocument.isEmpty && self.fileREC.isEmpty
            let boolRate        = content.contains(where: { $0.code == ReceiptRow.RATE.rawValue }) ? (getValue(from: .RATE).isEmpty || getValue(from: .RATE) == "0") : false
            let boolAmtKHR      = content.contains(where: { $0.code == ReceiptRow.AMOUNTKHR.rawValue }) ? (getValue(from: .AMOUNTKHR).isEmpty || getValue(from: .AMOUNTKHR) == "0") : false
            let boolTypeOfSupplier = false
            let boolTax         = false
            let boolAmount      = ((getValue(from: .AMOUNT) == "0") || getValue(from: .AMOUNT).isEmpty)
            
            // 29-2-2024 Payment method not require
            var boolPayWayAMT   = (self.getValue(from: .PAYMENT_METHOD).isEmpty || self.getValue(from: .PAYMENT_METHOD) == nil) ? false : false
            let amountKHR       = self.getValue(from: .AMOUNT).components(separatedBy: ".").first?.replacingOccurrences(of: ",", with: "") ?? ""
            let amountUSD       = self.getValue(from: .AMOUNT).replace(of: ".", with: "").replace(of: ",", with: ".").vndCurrency
            let amountVND       = self.getValue(from: .AMOUNT).vndCurrencyFormatter()
            
            if self.receiptList?.PAY_WAY_CD == "A" {
                if self.isFromEditing == "Y" {
                    let importMoreValue = self.getmoreValue(from: .IMPORT_TRANSACTION).components(separatedBy: ".").first ?? ""
                    
                    // Format currency (PAY_WAY_AMT)
                    let PAY_WAY_AMT = self.getValue(from: .CURRENCY) == "USD" ? amountUSD : amountVND
                    
                    boolPayWayAMT   = PAY_WAY_AMT == (self.getValue(from: .CURRENCY) == "USD" ? self.getmoreValue(from: .IMPORT_TRANSACTION).vndCurrency : self.getmoreValue(from: .IMPORT_TRANSACTION).vndCurrency.components(separatedBy: ",").first) ? false : true
                    
                }
                else {
                    // Format currency (PAY_WAY_AMT)
                    let PAY_WAY_AMT = self.importTransactionData?.CCY_CD == "USD" ? (self.importTransactionData?.TRSC_AMT.vndCurrency.replace(of: ".", with: "").replace(of: ",", with: ".").vndCurrency ?? "") : (self.importTransactionData?.TRSC_AMT.components(separatedBy: ".").first ?? "").vndCurrencyFormatter()
                    // Check PAY_WAY_AMT match with Import transaction value or not
                    boolPayWayAMT   = PAY_WAY_AMT == (self.importTransactionData?.CCY_CD == "USD" ? amountUSD : (self.importTransactionData?.CCY_CD == "KHR" ? amountKHR : amountVND)) ? false : true
                    
                }
            }
            
            // Old flow
            disableSubmitButton(isDisable: (boolDate || boolMerchant || boolTax || boolAmount || boolRate  || boolAmtKHR  /*|| boolAdvance || boolTransfer || boolImport || boolTypeOfSupplier || getValue(from: .RECEIPTNO).isEmpty */ || boolPayWayAMT || boolImg))
            
        }
    }
    
    // Incase Delete Rate and AmounKHR while currecy is KHR, and Add Rate and AmountKHR while currency is USD
    private func checkSelectedCurrency(isKHR: Bool) {
        if isKHR {
            removeExchangeRate()
        } else {
            self.displayRate()
        }
        self.tableView.reloadData()
    }
    
    // get idx for insert email, tel, address if Type of Supplier is Non-Taxable Person or Oversea Company
    private func validatedWithSettingIndex() -> Int {
        var index : Int = -1
        if let content = cellValue?.content {
            for (idx, value) in content.enumerated() {
                if value.code == ReceiptRow.USER.rawValue {
                    index = idx
                }
                else if value.code == ReceiptRow.DESCRIPTION.rawValue && !(content.contains(where: { $0.code == ReceiptRow.USER.rawValue })) {
                    index = idx
                }
            }
        }
        return index
    }
    
    private func validatedWithAdvanceLedger() -> Int {
        var index : Int = -1
        if let content = cellValue?.content {
            for (idx, value) in content.enumerated() {
                if value.code == ReceiptRow.PURPOSE.rawValue {
                    index = idx
                }
                else if value.code == ReceiptRow.DESCRIPTION.rawValue && !(content.contains(where: { $0.code == ReceiptRow.USER.rawValue }) || content.contains(where: { $0.code == ReceiptRow.PURPOSE.rawValue })) {
                    index = idx
                }
            }
        }
        return index
    }
    
    private func supplier(type: TypeOfSupplier) {
        var index = 0
      
        switch type {
        case .TaxablePerson:
            if let content = cellValue?.content {
                if  (content.contains(where: { $0.code == ReceiptRow.TEL.rawValue })) {
                    removeWhereKey(key: .TEL)
                }
                if  (content.contains(where: { $0.code == ReceiptRow.EMAIL.rawValue })) {
                    removeWhereKey(key: .EMAIL)
                }
                if (content.contains(where: { $0.code == ReceiptRow.ADDRESS.rawValue })) {
                    removeWhereKey(key: .ADDRESS)
                }
            }
            
        case .NonTaxablePerson:
            
            if let content = cellValue?.content {
                if !(content.contains(where: { $0.code == ReceiptRow.TEL.rawValue })) {
                    let TRCO_RPRS_TLPH = receiptList?.TRCO_RPRS_TLPH  ?? ""
                    // To check if key empty or less than 5 digit
                    let isNil             = TRCO_RPRS_TLPH == "" || TRCO_RPRS_TLPH.count < 5
                    var headerCodePrefix  = isNil ? "" : TRCO_RPRS_TLPH.prefix(5)
                    
                    if !(headerCodePrefix.isEmpty) {
                        headerCodePrefix.removeFirst()
                        
                        for char in headerCodePrefix {
                            if char == "0" {
                                headerCodePrefix.removeFirst()
                            } else {
                                break
                            }
                        }
                    }
                    
                    let headerCode        = isNil ? "" : "+\(headerCodePrefix)"
                    let phoneNumber       = isNil ? "" : TRCO_RPRS_TLPH[5...]
                    
                    let phone = SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.TEL.rawValue, value: phoneNumber, key: headerCode)
                    index     = self.validatedWithSettingIndex()
                    
                }
                
                if (content.contains(where: { $0.code == ReceiptRow.EMAIL.rawValue})) {
                    // Add Email into cell
                    removeWhereKey(key: .EMAIL)
                }
                
                if (content.contains(where: { $0.code == ReceiptRow.ADDRESS.rawValue })) {
                    // Add Address into cell
                    removeWhereKey(key: .ADDRESS)
                }
            }
            
        case .OverseaCompany:
            if let content = cellValue?.content {
                if !(content.contains(where: { $0.code == ReceiptRow.TEL.rawValue })) {
                    let TRCO_RPRS_TLPH    = receiptList?.TRCO_RPRS_TLPH ?? ""
                    // To check if key empty or less than 5 digit
                    let isNil             = TRCO_RPRS_TLPH == "" || TRCO_RPRS_TLPH.count < 5
                    var headerCodePrefix  = isNil ? "" : TRCO_RPRS_TLPH.prefix(5)
                    
                    if !(headerCodePrefix.isEmpty) {
                        headerCodePrefix.removeFirst()
                        
                        for char in headerCodePrefix{
                            if char == "0" {
                                headerCodePrefix.removeFirst()
                            } else {
                                break
                            }
                        }
                    }
                    
                    let headerCode        = isNil ? "" : "+\(headerCodePrefix)"
                    let phoneNumber       = isNil ? "" : TRCO_RPRS_TLPH[5...]
                     
                    let phone = SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.TEL.rawValue, value: phoneNumber, key: headerCode)
                    index     = self.validatedWithSettingIndex()
                    
                }
                if !(content.contains(where: { $0.code == ReceiptRow.EMAIL.rawValue })) {
                    var mail : String = ""
                    if self.receiptList?.TRCO_TYPE == "3" {
                        mail = self.receiptList?.EML ?? ""
                    }
                    else {
                        mail = ""
                    }
                    
                    // Add Email into cell
                    let email   = SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.EMAIL.rawValue, value: mail)
                    index       = self.validatedWithSettingIndex()
                  
                }
                if !(content.contains(where: { $0.code == ReceiptRow.ADDRESS.rawValue })) {
                    
                    var address : String = ""
                    if self.receiptList?.TRCO_TYPE == "3" {
                        let add_arr     = [self.receiptList?.TRCO_BSUN_POST_ADRS ?? "", self.receiptList?.TRCO_BSUN_DTL_ADRS ?? "", self.receiptList?.TRCO_BSUN_CITY ?? "", self.receiptList?.TRCO_BSUN_ST ?? ""]
                        self.address    = add_arr
                        
                         address = add_arr.filter({ !$0.isEmpty }).joined(separator: ", ")
                    }
                    else {
                        address = ""
                    }
                    
                    let key = self.getKey(from: .MERCHANT)
                    // Add Address into cell
                    let add = SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.ADDRESS.rawValue, value: address, key: key)
                    index = self.validatedWithSettingIndex()
                  
                }
            }
        }
        self.tableView.reloadData()
        self.checkingSubmitButton()
    }
    
    private func typeOfSupplierChoices(_ selectValue: String?) {
        self.hidePickerView()
        self.hideDatePicker()
        
        //check row selected value
        var selectRowAt = -1
        let data = ["taxable_person".localized,
                    "non_taxable_person".localized,
                    "oversea_company".localized]
        for (i, data) in data.enumerated() {
            if data == selectValue {
                selectRowAt = i
            }
        }
        customOption(type           : .MultipleChoice,
                     title          : "type_of_supplier".localized,
                     message        : "pls_select_type_of_supllier".localized,
                     data           : data,
                     selectRowAt    : selectRowAt
        ) { (index) in
                        switch index {
                        case 0 :
                            self.setValue(newValue: "taxable_person".localized, newKey: self.getKey(from: .MERCHANT), code: .TYPEOFSUPPLIER)
                            self.setValue(newValue: self.getValue(from: .TAXID), newKey: "enter_tax_id".localized, code: .TAXID)
                            self.supplier(type: .TaxablePerson)
            
                        case 1 :
                            self.setValue(newValue: "non_taxable_person".localized, newKey: self.getKey(from: .MERCHANT), code: .TYPEOFSUPPLIER)
                            self.setValue(newValue: self.getValue(from: .TAXID), newKey: "enter_national_id".localized, code: .TAXID)
                            self.supplier(type: .NonTaxablePerson)
            
                        case 2 :
                            self.setValue(newValue: "oversea_company".localized, newKey: self.getKey(from: .MERCHANT), code: .TYPEOFSUPPLIER)
                            self.setValue(newValue: self.getValue(from: .TAXID), newKey: "enter_foreigner".localized, code: .TAXID)
                            self.supplier(type: .OverseaCompany)
            
                        default : break
                        }
                        self.setValue(newValue: "", newKey: "+855", code: .TEL)
                        self.setValue(newValue: "", code: .EMAIL)
                        self.address = []
                        self.setValue(newValue: "", newKey: self.getKey(from: .MERCHANT), code: .ADDRESS)
                        self.tableView.reloadData()
        }
    }
     
    private func validateMerchat() {
        let row = self.getIdx(cell_code: .MERCHANT)
        if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? SubmitReceiptCell {

            if getKey(from: .MERCHANT) == "select_from_contacts".localized {
                setValue(newValue: "", newKey: "", code: .MERCHANT)
                cell.typeOfMerchant(isAuto: getKey(from: .MERCHANT).isEmpty, key: getKey(from: .MERCHANT), value: getValue(from: .MERCHANT))
            }else{
                // Merchant
                let newKey = " (\("manual".localized))"
                setValue(newValue: "", newKey: newKey, code: .MERCHANT)
                cell.typeOfMerchant(isAuto: getKey(from: .MERCHANT).isEmpty, key: getKey(from: .MERCHANT), value: getValue(from: .MERCHANT))
            }
        }
        // disable input by default if auto merchant
        self.validateDisableUserInput()
    }
    
    private func validateDisableUserInput() {
        
//        self.supplier(type: .TaxablePerson)
        self.checkTypeOfSupplierAndTaxIfAutoMerchant()
        self.setValue(newValue: "taxable_person".localized, newKey: getKey(from: .MERCHANT), code: .TYPEOFSUPPLIER)
        self.setValue(newValue: getKey(from: .MERCHANT).isEmpty ? "tax_id".localized : "", newKey: "enter_tax_id".localized, code: .TAXID)
//        self.setValue(newValue: CurrencyType.KHR.rawValue, code: .CURRENCY)
//        self.isUSDCurrency = false
        self.checkAmountInput()
        self.setValue(newValue: "", code: .AMOUNT) // clear amount value
        self.view.layoutIfNeeded()
        self.tableView.reloadData()
    }
   
//    private func validateAddressIfAutoMerchant() {
//        self.hideDatePicker()
//        self.hidePickerView()
//
//        let row = self.getIdx(cell_code: .ADDRESS)
//        if getKey(from: .MERCHANT).isEmpty {
//            if let _ = tableView.cellForRow(at: IndexPath(row: row , section: 0)) as? SubmitReceiptCell {
//                if getValue(from: .MERCHANT).isEmpty {
//                    setValue(newValue: "", code: .ADDRESS)
//                }
//                else {
//                    setValue(newValue: self.getValue(from: .ADDRESS), code: .ADDRESS)
//                }
//            }
//        }
//        else {
//            // Go to Select address
//            let vc = self.VC(sbName: "AddressSB", identifier: "AddressVC") as! AddressVC
//            vc.delegate   = self
//            vc.oldAddress = address
//            self.presetVC(vc: vc)
//        }
//
//        self.checkingSubmitButton()
//    }
    
    private func getIdx(cell_code: ReceiptRow) -> Int {
        var idx: Int = -1
        if let content = cellValue?.content {
            for (index, value) in content.enumerated() {
                if value.code == cell_code.rawValue {
                    idx = index
                    break
                }
            }
        }
        return idx
    }

    private func checkTypeOfSupplierAndTaxIfAutoMerchant() {
        let type_of_supplier : TypeOfSupplier = .TaxablePerson
        let row = self.getIdx(cell_code: .TYPEOFSUPPLIER)
     
        if let _ = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? SubmitReceiptCell {
            if getKey(from: .MERCHANT).isEmpty {
                if getValue(from: .MERCHANT).isEmpty {
                    // set Taxable Person value by default and disable user select
                    self.setValue(newValue: "taxable_person".localized, newKey: getKey(from: .MERCHANT), code: .TYPEOFSUPPLIER)
                    self.setValue(newValue: "tax_id".localized, newKey: type_of_supplier.description.localized, code: .TAXID)
                } else {
                    self.setValue(newValue: self.getValue(from: .TYPEOFSUPPLIER), newKey: getKey(from: .MERCHANT), code: .TYPEOFSUPPLIER)
                    let new_tax_key = mappingRawTypeOfSupplier(getValue(from: .TYPEOFSUPPLIER))
                    self.setValue(newValue: getValue(from: .TAXID), newKey: new_tax_key, code: .TAXID)
                }
            } else {
                self.setValue(newValue: "taxable_person".localized, newKey: getKey(from: .MERCHANT), code: .TYPEOFSUPPLIER)
            }
        }
    }
    
    private func mappingTypeOfSupplier(value: String = "1") -> String {
        var val : String = ""
        switch value {
        case "1"    : val = "taxable_person".localized
        case "2"    : val = "non_taxable_person".localized
        case "3"    : val = "oversea_company".localized
        default: break
        }
        
        return val
    }
    
    private func mappingRawTypeOfSupplier(_ value: String = "taxable_person".localized) -> String {
        var val : String = ""
        switch value {
        case "taxable_person".localized     : val = "1"
        case "non_taxable_person".localized : val = "2"
        case "oversea_company".localized    : val = "3"
        default: break
        }
        
        return val
    }
    
    private func removeExchangeRate() {
        let rate_idx = self.getIdx(cell_code: .RATE)
        if let cell = self.tableView.cellForRow(at: IndexPath(row: rate_idx, section: 0)) as? SubmitReceiptFillCell {
            UIView.animate(withDuration: 0.3) {
                cell.alpha = 0
                self.removeWhereKey(key: .RATE)
            }
        }
         
        let amt_khr_idx = self.getIdx(cell_code: .AMOUNTKHR)
        if let cell = self.tableView.cellForRow(at: IndexPath(row: amt_khr_idx, section: 0)) as? SubmitReceiptFillCell {
            UIView.animate(withDuration: 0.3) {
                cell.alpha = 0
                self.removeWhereKey(key: .AMOUNTKHR)
            }
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.tableView.reloadData()
        })
    }
    
    private func calculatedAmount() {
        if (getValue(from: .CURRENCY) == CurrencyType.USD.rawValue) || (self.settingVM.settingsResponse?.TRCO_TRSC_CCY_CD_YN ?? false) {
            // Old Login (Cambodia)
//            let rate_amt = getValue(from: .RATE)
//            let amt      = getValue(from: .AMOUNT).replace(of: ",", with: "")
            
//            let rate_amt = getValue(from: .RATE).replace(of: ".", with: "")
            
//            let amt_khr  = (Double(rate_amt) ?? 0) * (Double(amt) ?? 0)
//            let amt_khr_ft = (String(amt_khr).components(separatedBy: ".").first ?? "").replace(of: ",", with: "")
//            let amt_ft   = amt_khr_ft.khrCurrencyFormatter()
//            self.setValue(newValue: String(amt_khr), code: .AMOUNTKHR)
             
            // New Login (WABOOKS Cambodia and Vietnam)
            let rate_amt    = getValue(from: .RATE).replace(of: ".", with: "").components(separatedBy: ",").first ?? ""
            let amt         = (getValue(from: .AMOUNT).contains(",") ? String(getValue(from: .AMOUNT).replace(of: ".", with: "").replace(of: ",", with: ".").toDouble) : getValue(from: .AMOUNT).replace(of: ".", with: "").replace(of: ",", with: "."))
            let amt_khr     = (Double(rate_amt) ?? 0) * (Double(amt) ?? 0)
            let amt_khr_ft  = (String(amt_khr).components(separatedBy: ".").first ?? "").replace(of: ",", with: ".")
            let amt_ft      = String(amt_khr).vndCurrency

            self.setValue(newValue: amt_ft, code: .AMOUNTKHR)
            
            if cellValue?.content.contains(where: { $0.code == ReceiptRow.AMOUNTKHR.rawValue }) ?? false {
                let row = self.getIdx(cell_code: .AMOUNTKHR)
                self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
            }
        }
    }
    
    private func updateTaxAmount( amount : String) {
        let fomatCurrency = getValue(from: .CURRENCY)
        var rate          = getmoreValue(from: .WITH_HOLDING_TAX)
        if rate == "" {
            rate = receiptList?.TAX_RATE ?? "0"
        }
        let taxCalMoney     = self.calculateTaxAmount(amount: amount.replace(of: ",", with: ""),rate: rate)
        let formatTaxtAmt   = fomatCurrency == "USD" ? formatCurrency(type: fomatCurrency, amount: taxCalMoney) : taxCalMoney
         
        self.setValue(newValue: formatTaxtAmt, code: .TAX_AMOUNT)
        DispatchQueue.main.async {
            if let content = self.cellValue?.content {
                // check in have TAX_AMOUNT in display data on tableview
                let isTaxAmountExist      = content.contains(where: { $0.code == ReceiptRow.TAX_AMOUNT.rawValue })
                if isTaxAmountExist {
                    let row = self.getIdx(cell_code: .TAX_AMOUNT)
                    self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                }
            }
        }
    }

    // For insert Rate and Amount (KHR) if currency code is USD
    private func displayRate() {
        if !(cellValue?.content.contains(where: { $0.code == ReceiptRow.RATE.rawValue || $0.code == ReceiptRow.AMOUNTKHR.rawValue }) ?? false) {
            let amt_khr = SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.AMOUNTKHR.rawValue)
            
            let row         = self.getIdx(cell_code: .AMOUNT)
            let amt_khr_row = row + 2
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.cellValue?.content.insert(self.rate, at: row)
                self.cellValue?.content.insert(amt_khr, at: amt_khr_row)
 
                self.tableView.reloadData()
//                self.isFromEditing == "Y" ? self.calculatedAmount() : ()
                self.calculatedAmount()
                self.checkingSubmitButton()
            }
        }
    }
    
    // Fetching API
    private func updateReceipt() {
        
        let amount   = getValue(from: .AMOUNT).replace(of: ".", with: "").replace(of: ",", with: ".")
        let rate_amt = getValue(from: .RATE).replace(of: ".", with: "")
        let date     = getValue(from: .DATE).isNotEmpty ? getValue(from: .DATE) : getValue(from: .DATE).format(format: "yyyyMMdd")
        
        // tax id
//        let isOversea   = self.getValue(from: .TYPEOFSUPPLIER) == "oversea_company".localized
        let tax_id      = self.getValue(from: .TAXID)
        let gst_no      = self.getValue(from: .TAXID)
        
        let trco_type  = mappingRawTypeOfSupplier(getValue(from: .TYPEOFSUPPLIER))
        
        // old format
//        let tel        = getValue(from: .TEL).replace(of: "-", with: "")
//        let tel_ft     = "\(getKey(from: .TEL).replace(of: "+", with: ""))-\(tel)"
//        let telephone  = tel.isEmpty ? "" : tel_ft
        
        let headerCode   = self.getKey(from: .TEL).replace(of: "+", with: "")
        let headerPhone  = self.getKey(from: .TEL).count >= 5 ? "+\(headerCode)" : self.getKey(from: .TEL).count >= 4 ? "+0\(headerCode)" : self.getKey(from: .TEL).count >= 3 ? "+00\(headerCode)" : "+000\(headerCode)"
        
        let phoneNumber  = getValue(from: .TEL) == "" ? self.valueTRCO_RPRS_TLPH : getValue(from: .TEL)
        let telephone    = !phoneNumber.contains("+") ? "\(headerPhone)\(phoneNumber)" : phoneNumber
        
        // update with local images
        var REC_IN : [MREC_C004.REQUEST.REC2] = []
        
        for img in self.localImages {
            if let base64 = convertToBase64(img) {
                let formatter           = DateFormatter()
                formatter.dateFormat    = "yyyMMddHHmm"
                
                REC_IN.append(MREC_C004.REQUEST.REC2(FILE_NM: "\(formatter.string(from: Date())).jpg", FILE_DATA: base64))
            }
        }
        if localDocument.count > 0 {
            for item in self.localDocument {
                let base64 = item.fileData.base64EncodedString()
                REC_IN.append(MREC_C004.REQUEST.REC2(FILE_NM: "\(item.fileName)", FILE_DATA: base64))
            }
        }
          
        
        // Delete image and upload new image (** new image saved in local)
        var REC1 : [MREC_C004.REQUEST.REC1] = []
         
        if (self.localDeleteREC1.isEmpty) { // when not delete image from server
            REC1 = []
        }
        else { // when users tap delete image from server one or many
            for localDeleteImg in self.localDeleteREC1 {
                REC1.append(MREC_C004.REQUEST.REC1(FILE_ID: localDeleteImg.FILE_ID))
            }
        }
         
        let TRCO_KEY = getKey(from: .MERCHANT).isEmpty ? trco_key_defined_merchant : getKey(from: .MERCHANT) //"99999999999999999999"
        
        
        // old flow
        // var receiptCurrencyCode = self.receiptList?.TRCO_TRSC_CCY_CD
        //
        // if !getValue(from: .CURRENCY).isEmpty {
        //     receiptCurrencyCode = getValue(from: .CURRENCY)
        // }
        // let TRCO_TRSC_CCY_CD = (self.settingVM.settingsResponse?.TRCO_TRSC_CCY_CD_YN ?? false) ? receiptCurrencyCode : (self.isUSDCurrency ? "USD" : "KHR") //heremen
        
    
        // new flow : https://flow.team/l/bP29o
        var TRCO_TRSC_CCY_CD = ""
        if self.isManualInput {
            TRCO_TRSC_CCY_CD = "VND"
        } else {
            if receiptList?.TRCO_TRSC_CCY_CD == self.selected_TRCO_TRSC_CCY_CD && receiptList?.TRCO_TRSC_CCY_CD != "" {
                TRCO_TRSC_CCY_CD = self.receiptList?.TRCO_TRSC_CCY_CD ?? ""
            } else {
                if self.selected_TRCO_TRSC_CCY_CD != "" {
                    TRCO_TRSC_CCY_CD = self.selected_TRCO_TRSC_CCY_CD
                } else {
                    TRCO_TRSC_CCY_CD = "VND"
                }
            }
        }
        
         
        self.receiptDetailVM.updateOrDelete(  body                : MREC_C004.REQUEST(
                                              CORR_TYPE           : "U",
                                              DOC_ID              : (self.receiptList?.DOC_ID ?? ""),
                                              TRCO_CMNM           : getValue(from: .MERCHANT),
                                              USE_DT              : date,
                                              TRCO_TRSC_CCY_CD    : TRCO_TRSC_CCY_CD,
                                              TOTL_AMT            : amount,
                                              BUSA_USAG_CD        : getKey(from: .PURPOSE),
                                              CONT                : getValue(from: .DESCRIPTION),
                                              USER_NM             : Shared.R002_DATA?.USER_NM ?? "",
                                              REG_DT              : (self.receiptList?.REG_DT ?? ""),
//                                              REG_TYPE            : self.receiptList.RE,  //=== here
                                              SEQ_NO              : (self.receiptList?.SEQ_NO ?? ""),
                                              FILE_URL            : getValue(from: .ATTACHMEMNT),
                                              ADV_PAYM_TRNS_SEQ   : (self.receiptList?.ADV_PAYM_TRNS_SEQ ?? ""),
                                              ADV_PAYM_SEQ        : getmoreValue(from: .PAYMENT_METHOD) == "P" ? getKey(from: .ADVANCELEDGER) : "",
                                              HAND_DOC_ID         : self.receiptList?.HAND_DOC_ID ?? "",
                                              TRCO_TYPE           : trco_type,
                                              TRCO_TAX_ID         : tax_id,
                                              APLY_EXCH_RATE      : rate_amt,
                                              TRCO_RPRS_TLPH      : telephone,
                                              GST_NO              : gst_no,
                                              EML                 : getValue(from: .EMAIL),
                                              TRCO_BSUN_POST_ADRS : self.receiptList?.TRCO_BSUN_POST_ADRS ?? "",
                                              TRCO_BSUN_DTL_ADRS  : self.receiptList?.TRCO_BSUN_DTL_ADRS ?? "",
                                              TRCO_BSUN_ST        : self.receiptList?.TRCO_BSUN_ST ?? "",
                                              TRCO_BSUN_CITY      : self.receiptList?.TRCO_BSUN_CITY ?? "",
                                              TRCO_KEY            : TRCO_KEY,
                                              WHT_CD              : getKey(from: .WITH_HOLDING_TAX),
                                              PAY_WAY_CD          : getmoreValue(from: .PAYMENT_METHOD),
                                              PAY_WAY_AMT         : amount, // self.importTransactionData?.TRSC_AMT ?? amount
                                              BANK_CD             : self.importTransactionData?.BANK_CD ?? (self.getmoreValue(from: .BANK).isEmpty ? (self.receiptList?.BANK_CD ?? "") : self.getmoreValue(from: .BANK)),
                                              ACCT_NO             : self.importTransactionData?.ACCT_NO ?? (self.receiptList?.ACCT_NO ?? ""),
                                              REF_NO              : self.importTransactionData?.ACCT_SEQ_NO ?? (getValue(from: .BANK).isEmpty ? (self.receiptList?.REF_NO ?? "") : getValue(from: .BANK)),
                                              // ==> when we not change new date we choose current date ==> (self.receiptList?.REG_DT)
                                              TRSC_DT2            : self.importTransactionData?.TRSC_DT ?? (self.getValue(from: .DEBITDATE).isEmpty ? (self.receiptList?.REG_DT ?? "")/*(self.receiptList?.TRSC_DT2 ?? "")*/ : self.getValue(from: .DEBITDATE)), /*self.importTransactionData?.TRSC_DT ?? (self.getValue(from: .DEBITDATE).isEmpty ? (self.receiptList?.TRSC_DT2 ?? "") : self.getValue(from: .DEBITDATE))*/
                                              EINV_CON_DOC_ID     : (self.receiptList?.EINV_CON_DOC_ID ?? ""),
                                              PRJT_NO             : getKey(from: .PROJECT_SITE),
                                              REC1                : REC1,
                                              REC2                : REC_IN)) { (result) in
 
            
            switch result {
            case .success(_):
                self.view.window?.rootViewController?.dismiss(animated: true, completion: {
                    MyNotify.send(name: .reloadAfterUpdateOrDeleteOrSubmit, object: ["CORR_TYPE": "U"] as AnyObject)
                })
            case .failure(let error):
                self.alertError(message: error.localizedDescription)
            }
        }
    }
    
    private func createReceipt() {
        let formatteAmt         = (self.isUSDCurrency ? getValue(from: .AMOUNT).replace(of: ".", with: "").replace(of: ",", with: ".") : getValue(from: .AMOUNT).replace(of: ".", with: "")) // server donot accept currency with ,
        let rate_amt            = getValue(from: .RATE).replace(of: ".", with: "").replace(of: ",", with: ".")
        let formatteDate        = getValue(from: .DATE).isEmpty ? getValue(from: .DATE).format(format: "yyyyMMdd") : getValue(from: .DATE)
        
        let trco_type  = mappingRawTypeOfSupplier(getValue(from: .TYPEOFSUPPLIER))
        
        // tax id
//        let isOversea   = self.getValue(from: .TYPEOFSUPPLIER) == "oversea_company".localized
        let tax_id      = self.getValue(from: .TAXID)
        let gst_no      = self.getValue(from: .TAXID)
         
        let headerCode   = self.getKey(from: .TEL).replace(of: "+", with: "")
        let headerPhone  = self.getKey(from: .TEL).count >= 5 ? "+\(headerCode)" : self.getKey(from: .TEL).count >= 4 ? "+0\(headerCode)" : self.getKey(from: .TEL).count >= 3 ? "+00\(headerCode)" : "+000\(headerCode)"
        
        let phoneNumber  = getValue(from: .TEL) == "" ? self.valueTRCO_RPRS_TLPH : getValue(from: .TEL)
        let telephone    = !phoneNumber.contains("+") ? "\(headerPhone)\(phoneNumber)" : phoneNumber
        
        let TRCO_KEY = getKey(from: .MERCHANT).isEmpty ? trco_key_defined_merchant : getKey(from: .MERCHANT) //"99999999999999999999"
         
        let REG_DT = self.receiptList?.REG_DT ?? ""
        let SEQ_NO = self.receiptList?.SEQ_NO ?? ""
        
        // Image
        var REC_IN : [MREC_C003.REQUEST.REC] = []
        
        // File from Server
        if fileREC.count > 0 {
            
            for item in self.fileREC {
                
                let formatter           = DateFormatter()
                formatter.dateFormat    = "yyyMMddHHmm"
                REC_IN.append(MREC_C003.REQUEST.REC(FILE_NM: item.ORG_FILE_NM ?? "", FILE_DATA: item.FILE_URL ?? ""))
            }
            
            if localDocument.count > 0 {
                for item in self.localDocument {
                    let base64 = item.fileData.base64EncodedString()
                    REC_IN.append(MREC_C003.REQUEST.REC(FILE_NM: "\(item.fileName)", FILE_DATA: base64))
                }
            }
        }
        else { // File from user
            if localDocument.count > 0 {
                for item in self.localDocument {
                    let base64 = item.fileData.base64EncodedString()
                    REC_IN.append(MREC_C003.REQUEST.REC(FILE_NM: "\(item.fileName)", FILE_DATA: base64))
                }
            }
        }
        
        // Image from Server
        if imgREC.count > 0 {
            for item in self.imgREC {
                let formatter           = DateFormatter()
                formatter.dateFormat    = "yyyMMddHHmm"
                REC_IN.append(MREC_C003.REQUEST.REC(FILE_NM: "\(formatter.string(from: Date())).jpg", FILE_DATA: item.FILE_URL ?? ""))
            }
            if localImages.count > 0 {
                for img in self.localImages {
                    if let base64 = convertToBase64(img) {
                        let formatter           = DateFormatter()
                        formatter.dateFormat    = "yyyMMddHHmm"
                        
                        REC_IN.append(MREC_C003.REQUEST.REC(FILE_NM: "\(formatter.string(from: Date())).jpg", FILE_DATA: base64))
                    }
                }
            }
        }else { // Image from user
            if localImages.count > 0 {
                for img in self.localImages {
                    if let base64 = convertToBase64(img) {
                        let formatter           = DateFormatter()
                        formatter.dateFormat    = "yyyMMddHHmm"
                        
                        REC_IN.append(MREC_C003.REQUEST.REC(FILE_NM: "\(formatter.string(from: Date())).jpg", FILE_DATA: base64))
                    }
                }
            }
        }
        // Delete image and upload new image (** new image saved in local)
        var REC2 : [MREC_C003.REQUEST.REC2] = []
        if (self.localDeleteREC1.isEmpty) { // when not delete image from server
            REC2 = []
        }
        else { // when users tap delete image from server one or many
            for localDeleteImg in self.localDeleteREC1 {
                REC2.append(MREC_C003.REQUEST.REC2(REG_DT: self.receiptList?.REG_DT ?? "", SEQ_NO: self.receiptList?.SEQ_NO ?? "", FILE_ID: localDeleteImg.FILE_ID ?? ""))
            }
        }
      
        var TRCO_TRSC_CCY_CD = ""
        // TRCO_TRSC_CCY_CD = self.receiptList?.TRCO_TRSC_CCY_CD ?? "VND"
        
        if self.isManualInput {
            TRCO_TRSC_CCY_CD = "VND"
        } else {
            if receiptList?.TRCO_TRSC_CCY_CD == self.selected_TRCO_TRSC_CCY_CD && receiptList?.TRCO_TRSC_CCY_CD != "" {
                TRCO_TRSC_CCY_CD = self.receiptList?.TRCO_TRSC_CCY_CD ?? ""
            } else {
                if self.selected_TRCO_TRSC_CCY_CD != "" {
                    TRCO_TRSC_CCY_CD = self.selected_TRCO_TRSC_CCY_CD
                } else {
                    TRCO_TRSC_CCY_CD = "VND"
                }
            }
        }
        
        let HAND_DOC_ID = self.isFromEditing == "Y" ? (self.editReceiptVM.reponseR050?.DOC_ID ?? "") : (self.editReceiptVM.reponseR050?.DOC_ID ?? "")
        let pay_way_cd   = getmoreValue(from: .PAYMENT_METHOD)
        
        self.editReceiptVM.createReceipt(body                : MREC_C003.REQUEST(
                                         TRCO_CMNM           : getValue(from: .MERCHANT),
                                         USE_DT              : formatteDate,
                                         TRCO_TRSC_CCY_CD    : TRCO_TRSC_CCY_CD,
                                         TOTL_AMT            : formatteAmt,
                                         BUSA_USAG_CD        : getKey(from: .PURPOSE),
                                         ADV_PAYM_SEQ        : getmoreValue(from: .PAYMENT_METHOD) == "P" ? getKey(from: .PAYMENT_METHOD) : "",
                                         CONT                : getValue(from: .DESCRIPTION),
                                         USER_NM             : Shared.R002_DATA?.USER_NM ?? "",
                                         REG_TYPE            : self.isFromSelectExpense ? "M" : "D",
                                         REG_DT              : REG_DT,
                                         SEQ_NO              : SEQ_NO,
                                         HAND_DOC_ID         : HAND_DOC_ID,
                                         TRCO_TYPE           : trco_type,
                                         TRCO_TAX_ID         : tax_id,
                                         APLY_EXCH_RATE      : rate_amt,
                                         TRCO_RPRS_TLPH      : telephone,
                                         GST_NO              : gst_no,
                                         EML                 : getValue(from: .EMAIL), //Shared.R002_DATA?.EML ?? ""
                                         TRCO_BSUN_POST_ADRS : address.isEmpty ? "" : address[0],
                                         TRCO_BSUN_DTL_ADRS  : address.isEmpty ? "" : address[1],
                                         TRCO_BSUN_ST        : address.isEmpty ? "" : address[2],
                                         TRCO_BSUN_CITY      : address.isEmpty ? "" : address[3],
                                         TRCO_KEY            : TRCO_KEY,
                                         WHT_CD              : getKey(from: .WITH_HOLDING_TAX),
                                         PAY_WAY_CD          : pay_way_cd == "" ? nil : pay_way_cd,
                                         PAY_WAY_AMT         : formatteAmt,  // self.importTransactionData?.TRSC_AMT ?? formatteAmt
                                         BANK_CD             : self.importTransactionData?.BANK_CD ?? getmoreValue(from: .BANK),
                                         ACCT_NO             : self.importTransactionData?.ACCT_NO ?? "",
                                         REF_NO              : self.importTransactionData?.ACCT_SEQ_NO ?? getValue(from: .BANK),
                                         TRSC_DT2            : formatteDate,//self.importTransactionData?.TRSC_DT ?? self.getValue(from: .DEBITDATE), //formatteDebitDate
                                         EINV_CON_DOC_ID     : self.receiptList?.EINV_CON_DOC_ID ?? "",
                                         PRJT_NO             : getKey(from: .PROJECT_SITE),
                                         REC                 : REC_IN,
                                         REC2                : REC2)) { (error) in
            if error != nil {
                self.alertError(message: error?.localizedDescription ?? "Error")
                return
            }
                                             
            if self.isFromSelectExpense{
                MyNotify.send(name: .gotoSelectExpense, object: ["MANUAL_EXPENSE": "CREATE"] as AnyObject)
                self.dismiss(animated: true, completion: nil)
               
            }else{
                self.view.window?.rootViewController?.dismiss(animated: true, completion: {
                    MyNotify.send(name: .reloadAfterUpdateOrDeleteOrSubmit, object: ["CORR_TYPE": "S"] as AnyObject)
                })
            }
        }
    }
    
    private func deleteReceipt(REG_DT: String, SEQ_NO: String, _ completion: @escaping () -> () = {}) {
        
        self.editReceiptVM.deleteImage(body     : MREC_D001.REQUEST(
                                       REG_DT   : REG_DT,
                                       SEQ_NO   : SEQ_NO)) { (error) in
            if error != nil {
                self.alertError(message: error?.localizedDescription ?? "Error")
                return
            } else {
                // Success: go to receipt list
                self.view.window?.rootViewController?.dismiss(animated: true, completion: {
                    MyNotify.send(name: .reloadAfterUpdateOrDeleteOrSubmit, object: ["CORR_TYPE": "D"] as AnyObject)
                })
            }
        }
    }
    
    private func checkProjectSite() {
        self.editReceiptVM.checkProjectSite(body: MREC_R012.REQUEST(ENV_SET_INF: "00005")) { (error) in
            if error != nil {
                self.alertError(message: error?.localizedDescription ?? "Error")
                return
            }else{
                print("")
            }
        }
    }
  
    private func uploadImage(body: MREC_C002.REQUEST) {
        self.maintabVM.uploadImage(body : body) { (error) in
            if error != nil {
                self.alertError(message: error?.localizedDescription ?? "Error")
                return
            }

            self.responseImage = self.maintabVM.reponseImage
            let FILE_URL = self.responseImage?.FILE_URL ?? ""
            let SEQ_NO   = "\(self.responseImage?.SEQ_NO ?? 0)"
            self.setValue(newValue: FILE_URL, newKey: SEQ_NO, code: .ATTACHMEMNT)
  
            self.checkingSubmitButton()
  
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func fetchingSetting() {
        self.settingVM.fetchInputSettings { (result) in
            switch result {
            case .success(_):
                self.displayCells()
                self.tableView.reloadData()
            case .failure(let error):
                self.alertError(message: error.localizedDescription)
            }
        }
    }
    
    private func fetchingExchangeRate() {
        let REF_CCY_CD = CurrencyType.VND.rawValue
        self.editReceiptVM.fetchingExchangedRate(body: MREC_R040.REQUEST(INQ_DT: "", REF_CCY_CD: REF_CCY_CD, CCY_CD: CurrencyType.USD.rawValue)) { error in
            if error != nil {
                self.alertError(message: error?.localizedDescription ?? "Error")
            }
            
//            let rate = (self.receiptList?.APLY_EXCH_RATE ?? "").components(separatedBy: ".").first ?? ""
//            let exchange_rate = (rate.prefix(1) == "0") ? "" : rate.formatKHRCurrency()
//            let res_rate = (self.editReceiptVM.reponseR040?.BASIC_AMT?.components(separatedBy: ".").first ?? "").formatKHRCurrency()
//            let rateformatting = (self.isFromEditing == "Y") ? (exchange_rate) :  res_rate
//            self.rate = SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.RATE.rawValue, value: rateformatting, key: self.editReceiptVM.reponseR040?.UNIT_AMT)
            
            // Insert Rate Row
            let rate            = (self.receiptList?.APLY_EXCH_RATE?.components(separatedBy: ".").first ?? "")
            let exchange_rate   = ((rate.prefix(1) == "0") ? "" : rate)
            let res_rate        = (self.editReceiptVM.reponseR040?.BASIC_AMT?.components(separatedBy: ".").first ?? "")
            let rateformatting  = (self.isFromEditing == "Y") ? (exchange_rate) : res_rate
            self.rate           = SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.RATE.rawValue, value: rateformatting, key: self.editReceiptVM.reponseR040?.UNIT_AMT)
            self.fetchingSetting() // Fetching settiing and display cell
        }
    }
    
    private func fetchingReceiptNo() {
         
        let row = self.getIdx(cell_code: .RECEIPTNO)
        self.editReceiptVM.fetchingReceiptNo { error in
            if error != nil {
                // Showed error image when fetching R050 (Receipt no value) failed
                if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? SubmitReceiptCell {
                    cell.imgErrorReceiptNo.isHidden                     = false
                    cell.isErrorReceiptNo                               = false
                    cell.constraintWidthErrorReceiptNo.constant         = 24
                    cell.constraintWidthErrorReceiptNoLeading.constant  = 7
                }
            }
            else {
                // sucess: display Receipt No in text field
//                self.setValue(newValue: self.editReceiptVM.reponseR050?.DOC_ID ?? "", newKey: self.getKey(from: .RECEIPTNO), code: .RECEIPTNO)
//                self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)

                // Hidden error image when fetching R050 (Receipt no value) failed
//                if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? SubmitReceiptCell {
//                    cell.imgErrorReceiptNo.isHidden                     = true
//                    cell.isErrorReceiptNo                               = true
//                    cell.constraintWidthErrorReceiptNo.constant         = 0
//                    cell.constraintWidthErrorReceiptNoLeading.constant  = 0
//
//                }
            }
        }
    }
    
    func showPermissionAlert() {
        self.alertYesNo(
            title   : #""WeCMS" Would Like to Access the Camera"#,
            message : "메모 등록시 사진첨부를 위해서 카메라 접근을 승인해야 합니다.",
            nobtn   : "Don't Allow",
            yesbtn  : "ok".localized,
            completion: { (ok) in
                if ok {
                    self.gotoAppSettings()
                }
            })
    }
    
    func fetchExpenseList() {
        let vc          = self.VC(sbName: "ExpenseSB", identifier: "ExpenseVC") as! ExpenseVC
        vc.delegates    = self
        self.expenseVM.ADV_PAYM_SEQ = self.expenseVM.ADV_PAYM_SEQ ?? self.receiptList?.ADV_PAYM_SEQ
        vc.expenseVM.pay_way_cd = self.expenseVM.pay_way_cd ?? self.receiptList?.PAY_WAY_CD
        self.navigationController?.pushViewController(vc , animated: true)
    }
    
    func pushFile(_ destination: URL) {
        let finalURL = destination.absoluteString
        
        DispatchQueue.main.async {
            if let url = URL(string: finalURL) {
                if #available(iOS 10, *){
                    UIApplication.shared.open(url)
                }else{
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    func openAttachFile() {
        self.documentManager = DocumentsManager(self)
        self.documentManager.openDocument()
        self.documentManager.completionError = { error in
            self.alert(message: error.localizedDescription)
        }
        self.documentManager.completionFilesModel = { files in
            self.localDocument.insert(contentsOf: files, at: 0)
            self.tableView.reloadData()
            self.checkingSubmitButton()
        }
    }
    
    //TODO: -Upload image form camera
    func uploadImageAfterCaptureSucess(normalizeImage : UIImage?) {
        var REC_IN : [MREC_C002.REQUEST.REC] = []
        
        if let base64 = convertToBase64(normalizeImage ?? UIImage()) {
            let formatter           = DateFormatter()
            formatter.dateFormat    = "yyyMMddHHmmssA"
            REC_IN.append(MREC_C002.REQUEST.REC(FILE_NM: "\(formatter.string(from: Date())).jpg", FILE_DATA: base64))
            
            // Upload Image after taking a photo
            self.uploadImage(body: MREC_C002.REQUEST(REC_IN: REC_IN))
        }
    }
     
    //MARK: - @objc
    @objc func didTapPreviewImage(sender: UIButton) {
        performSegue(withIdentifier: NotifyKey.gotoPhotoPreviewVC.rawValue, sender: nil)
    }
    
    @objc func didTapOpenGallery(sender: UIButton) {
        sender.animateButtonUp()
        customOption(type       : .MultipleChoice,
                     image      : "",
                     title      : "register_invoice".localized,
                     message    : "take_a_photo_or_choose_from_gallery".localized,
                     data       : ["take_a_photo".localized, "choose_from_gallery".localized, "attachment_file".localized],
                     selectRowAt: -1,
                     imgStrRec  : ["camera_ico", "gallery_ico", "tap_attachment"]) { [unowned self](index) in
            switch index {
            case 0:
                self.view.endEditing(true)
                self.checkCameraPermission()

            case 1  : 
                if #available(iOS 14.0, *) {
                    self.openGallery()
                } else {
                    // Fallback on earlier versions
                }
                
            case 2  : self.openAttachFile()
            default : break
            }
        }
    }
    
    @objc func SuccessTakePhotoFromSubmitReceiptVC(_ notification:NSNotification) {
        if let img = notification.object as? UIImage {
            self.localImages.append(img)
            self.tableView.reloadData()
            self.checkingSubmitButton()
        }
    }
    
    @objc func didTapDeleteImage(sender: UIButton) {
        customAlert(type        : .YES_OR_NO_ALERT,
                    image       : "badge_warning",
                    title       : "delete".localized,
                    message     : "are_you_sure_want_to_delete_the_attached_image".localized,
                    redTitle    : "delete".localized,
                    greyTitle   : "cancel".localized) { (isDelete) in
            if isDelete {
             
                //  If Edit receipt : delete image donot use api ** new flow
                if self.isFromEditing == "Y" { // if edit receipt
                    self.setValue(newValue: "", newKey: self.receiptList?.SEQ_NO ?? "", code: .ATTACHMEMNT)
                    
                    self.localImages = []
                    
                    // Clear cache
                    SDImageCache.shared.clearMemory()
                    SDImageCache.shared.clearDisk()
                    self.tableView.reloadData()
                } else {
                    /**
                     Note: No longer use D001 on image
                     */
                    
                    // if submit receipt, delete exist img with api
                    // if delete exist img with api, and upload new img => store local and remove on local
                    self.localImages = []
                    self.tableView.reloadData()
                }
                self.checkingSubmitButton()
            }
        }
    }
    
    @objc func didTapButtonKHR(_ sender: UIButton) {
        self.setValue(newValue: "KHR", code: .CURRENCY)
        self.removeExchangeRate()
    }

    @objc func didTapButtonUSD(_ sender: UIButton) {
        self.setValue(newValue: "USD", code: .CURRENCY)
        self.displayRate()
    }
    
    
   func didSetKHR() {
        self.setValue(newValue: "KHR", code: .CURRENCY)
        self.removeExchangeRate()
    }

    func didSetUSD() {
        self.setValue(newValue: "USD", code: .CURRENCY)
        self.displayRate()
    }
    
    @objc func checkAmountInput() {
        
        self.hidePickerView()
        self.hideDatePicker()
        

        self.setValue(newValue: self.getValue(from: .AMOUNT),       code: .AMOUNT)
        self.setValue(newValue: self.getValue(from: .TAX_AMOUNT),   code: .TAX_AMOUNT)
        self.checkingSubmitButton()
         
        // Fetching Exchange rate if currency is USD
        (self.getValue(from: .CURRENCY) == CurrencyType.USD.rawValue) || (isUSDCurrency) ? self.displayRate() : self.removeExchangeRate()
         
        let row = getIdx(cell_code: .AMOUNT)
        if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? SubmitReceiptFillCell {
            if cell.textfieldInput.tag == 1010 {
                DispatchQueue.main.async {
                    cell.CCY_CD = self.getValue(from: .CURRENCY) == CurrencyType.KHR.rawValue ? "KHR" : "USD"
                    self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                    
                }
            }
        }
    
        if let content = cellValue?.content {
            // check in have TAX_AMOUNT in display data on tableview
            let isTaxAmountExist      = content.contains(where: { $0.code == ReceiptRow.TAX_AMOUNT.rawValue })
            if isTaxAmountExist {
                let tax_amount_row = getIdx(cell_code: .TAX_AMOUNT)
                self.tableView.reloadRows(at: [IndexPath(row: tax_amount_row, section: 0)], with: .none)
            }
        }
    }
    
    @objc func didTapShowPickerView(sender: UIButton) {
        self.isShowMerchantPicker = sender.tag == 1080
        
        if !isShowMerchantPicker { // scroll to specific dial_code
            let point           = sender.convert(CGPoint.zero, to: self.tableView)
            let indexPath       = self.tableView.indexPathForRow(at: point)!

//            for (index, value) in (Shared.New_MG?.country_dial_codes_as_frist_order ?? []).enumerated() {
//                if value.dial_code == cellValue?.content[indexPath.row].key {
//                    self.pickerView.selectRow(index, inComponent: 0, animated: true)
//                }
//            }
            
            for (index, value) in Shared.countryData.enumerated() {
                if value.dial_code == cellValue?.content[indexPath.row].key {
                    self.pickerView.selectRow(index, inComponent: 0, animated: true)
                }
            }
        }
    
        // clear value in cell
        if sender.tag == 1080 {  // Row DATE
            self.isShowMerchantPicker   = true
            self.isShowBankPicker       = false
            self.isShowMerchantPicker ? self.setValue(newValue: "", newKey: getKey(from: .MERCHANT), code: .MERCHANT) : ()
        }
        else if sender.tag == 1090 { // Row Debit Date
            self.isShowMerchantPicker   = false
            self.isShowBankPicker       = true
            self.isShowMerchantPicker ? self.setValue(newValue: "", newKey: getKey(from: .BANK), code: .BANK) : ()
        }
        else {
            self.isShowMerchantPicker   = false
            self.isShowBankPicker       = false
        }
        
        self.pickerView.reloadAllComponents()
        self.showPickerView()
        
        // Auto select picker view
        let indexRow = self.bankVM.sortedBankList?.firstIndex(where: { $0.BANK_CD == self.getmoreValue(from: .BANK) }) ?? 0
        self.pickerView.selectRow(indexRow, inComponent: 0, animated: true)
    }
    
    @objc func didTapSelectContact() {
        self.hidePickerView()
        let vc = self.VC(sbName: "ContactListSB", identifier: "ContactListVC") as! ContactListVC
        vc.r030REC1          = self.r030REC1
        vc.r030REC2          = self.r030REC2
        vc.delegate          = self
        vc.selectedIndexPath = self.selectedContactIndexPath
        vc.contactSelected   = self.getValue(from: .MERCHANT)
        vc.TRCO_CMNM         = self.getValue(from: .MERCHANT)
        vc.TRSC_CCY_CD       = self.receiptList?.TRCO_TRSC_CCY_CD
        vc.TRCO_KEY          = self.receiptList?.TRCO_KEY
        self.presetVC(vc: vc)
    }
}

extension SubmitReceiptVC: ImagePickerSelectDelegate{
  
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage) {
        self.localImages.insert(image, at: 0)
        self.tableView.reloadData()
        self.checkingSubmitButton()
        imagePicker.dismiss()
    }
       
    func cancelButtonDidClick(on imagePicker: ImagePicker) {
        imagePicker.dismiss()
    }
    
    private func checkCameraPermission() {
        self.checkAllowCameraPermission(completion: { (allow) in
            if allow {
                self.openCameraVC()
            } else {
                self.showPermissionAlert()
            }
        })
    }
    
    func openCameraVC(){
        self.imagePicker.showImagePicker(from: self, sourceType: .camera, allowsEditing: false)
    }
}

@available(iOS 14.0, *)
extension SubmitReceiptVC: PHPickerViewControllerDelegate{
   
    func openGallery() {
        maxImages = 5 - localImages.count - self.imgREC.count - fileREC.count - localDocument.count //5 max image

        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = maxImages // set to a number for a specific limit
        configuration.filter = .images   // Only select images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        var selectedImages: [UIImage] = []
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter() // Start a task
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let uiImage = image as? UIImage {
                        selectedImages.append(uiImage)
                    }
                    dispatchGroup.leave() // End the task
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.localImages.insert(contentsOf: selectedImages, at: 0)
            self.tableView.reloadData()
            self.checkingSubmitButton()
            self.imagePicker.dismiss()
        }
    }
}

//extension SubmitReceiptVC : QLPreviewControllerDataSource {
//    
//    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
//        return fileREC.count
//    }
//    
//    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
//        let rows    = self.fileREC[index]
//        
////        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
////        let file_name   = rows.ORG_FILE_NM ?? ""
////        
////        let split_url   = rows.FILE_URL?.components(separatedBy: "?")
////        let file_url    = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")" + "&\(file_name)"
//     return 1
//        
//    }
//    
//    
//}
//MARK: - UITableView
extension SubmitReceiptVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (cellValue?.content.count ?? 0)
    }
     
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let code        = cellValue?.content[indexPath.row].code
        let mappingCode = ReceiptRow(rawValue: code ?? "")
         
        switch mappingCode {
        case .ADVANCELEDGER:
            return self.receiptList?.PAY_WAY_CD != "P" ? 0 : UITableView.automaticDimension

        case .BANK:
            return self.receiptList?.PAY_WAY_CD != "Q" ? 0 : UITableView.automaticDimension

        case .DEBITDATE:
            return (self.receiptList?.PAY_WAY_CD == "A" || self.receiptList?.PAY_WAY_CD == "" || self.receiptList?.PAY_WAY_CD == nil) ? 0 : UITableView.automaticDimension

        case .IMPORT_TRANSACTION:
            return self.receiptList?.PAY_WAY_CD != "A" ? 0 : UITableView.automaticDimension
            
        case .DATE:
            return (!(self.settingVM.settingsResponse?.INPUT_FIELD_SET_YN ?? false) || !(self.settingVM.settingsResponse?.TRSC_DT_YN ?? false)) ? 0 : UITableView.automaticDimension
            
        case .CURRENCY:
            return (!(self.settingVM.settingsResponse?.INPUT_FIELD_SET_YN ?? false) || !(self.settingVM.settingsResponse?.TRCO_TRSC_CCY_CD_YN ?? false)) ? 0 : UITableView.automaticDimension
            
        case .PURPOSE:
            return (!(self.settingVM.settingsResponse?.INPUT_FIELD_SET_YN ?? false) || !(self.settingVM.settingsResponse?.USAG_CD_YN ?? false)) ? 0 : UITableView.automaticDimension
            
        case .USER:
            return (!(self.settingVM.settingsResponse?.INPUT_FIELD_SET_YN ?? false) || !(self.settingVM.settingsResponse?.USER_NM_YN ?? false)) ? 0 : UITableView.automaticDimension
            
        case .PROJECT_SITE:
            //Seanghay > vietnam dont have INPUT_FIELD_SET_YN <
            return self.editReceiptVM.responseR012?.ENV_SET_CONT == "N" ? 0 : UITableView.automaticDimension
            
            
        case .ADDRESS:
            return 86
        
        case .TEL:
            return 63
             
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? MultiAttachmentCell {
            cell.collectionView.delegate   = self
            cell.collectionView.dataSource = self
            DispatchQueue.main.async {
                cell.collectionView.reloadData()
            }
        }
    }
    
    private func gotoPurposeVC(_ indexPath: IndexPath){
        let vc                      = self.VC(sbName: "PurposeSB", identifier: "PurposeVC" ) as! PurposeVC
        let purposeCode = self.getKey(from: .PURPOSE)
        vc.delegate                 = self
        vc.selectUserListKey        = purposeCode.isEmpty ? "" : purposeCode
        vc.isShowPlanned_money      = self.isShowPlanned_money
        vc.isShowOnlyPlanned_money  = false
        self.selectPurposeIndex     = indexPath.row  // get row of select purpose to insert advance ledger
        vc.headerTitle              = "purpose_account".localized
        self.presetVC(vc:vc)
    }
    
    private func handleTapPurpose(_ indexPath: IndexPath){
        self.hideDatePicker()
        self.hidePickerView()
        
        gotoPurposeVC(indexPath)
    }
    
    private func handleTapPaymentMethod(){
        self.hideDatePicker()
        self.hidePickerView()
        self.fetchExpenseList()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = cellValue?.content[indexPath.row]
        let mappingRow = ReceiptRow(rawValue: data?.code ?? "")
        
        switch mappingRow {
        case .DESCRIPTION:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionNewReceiptCell", for: indexPath) as! DescriptionNewReceiptCell
            cell.textViewDescription.delegate   = self
            cell.textViewDescription.text       = data?.value
            return cell
            
        case .ATTACHMEMNT:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MultiAttachmentCell") as! MultiAttachmentCell
            return cell
            
        case .DATE, .PAYMENT_METHOD, .PURPOSE, .WITH_HOLDING_TAX, .DEBITDATE, .MERCHANT, .TYPEOFSUPPLIER, .PROJECT_SITE:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitReceiptSelectedCell") as! SubmitReceiptSelectedCell
            self.merchant_value = self.isFromEditing == "Y" ? self.receiptList?.TRCO_NICK_NM ?? "" : ""
            cell.owner          = self
            cell.isClearVisible = self.isClearVisible
            cell.clientData     = self.clientData
            cell.copyClientData = self.copyClientData ?? []
            cell.receiptList    = self.receiptList
            cell.configCell(row: data, isFromSelected: isFromSelectExpense, trco_type: dataClient?.TRCO_TYPE)
            cell.completion = { contactsValue, taxIdValue in
                if mappingRow == .MERCHANT {
                }
                self.isClearVisible = contactsValue.isEmpty ? false : true
               
                if contactsValue.isEmpty {
                    self.receiptList?.TRCO_TRSC_CCY_CD?.removeAll()
                    self.isSwitchButtonEnable = true
                }else {
                    self.isSwitchButtonEnable = false
                }
                
                self.setValue(newValue: contactsValue, code: .MERCHANT)
                self.setValue(newValue: taxIdValue, code: .TAXID)
                self.clientData = []
                
                // remove selected when we clear
                self.receiptList?.TRCO_KEY?.removeAll()
                
                // Reload row by cell_code
                self.tableView.reloadData()
                self.checkingSubmitButton()
            }
            
            cell.moreButton.didTap {
                switch mappingRow{
                case .PURPOSE:
                    self.handleTapPurpose(indexPath)
                    
                case .PAYMENT_METHOD:
                    self.handleTapPaymentMethod()
                    
                case .PROJECT_SITE:
                    self.hideDatePicker()
                    self.hidePickerView()
                    
                    let vc                      = self.VC(sbName: "SelectPurposeSB", identifier: "SelectPurposeVC" ) as! SelectPurposeVC
                    vc.delegate                 = self
                    vc.selectUserListKey        = self.getKey(from: .PURPOSE)
                    vc.isShowPlanned_money      = false
                    vc.isShowOnlyPlanned_money  = false
                    self.selectPurposeIndex     = indexPath.row  // get row of select purpose to insert advance ledger
                    vc.headerTitle              = "select_a_purpose".localized
                    self.presetVC(vc:vc)
                    
                case .MERCHANT:
                    if self.isClearVisible  {
                        cell.imgRight.image = UIImage(named: "ico_search")
                        cell.isClearVisible = false
                        self.setValue(newValue: self.getSupplierName(supplier_code: "1"), code: .TYPEOFSUPPLIER)
                        self.supplier(type: .TaxablePerson)
                        cell.completion("", "")
                        
                    } else {
                        let vc = UIStoryboard.init(name: "ClientSB", bundle: Bundle.main).instantiateViewController(withIdentifier: "ClientVC") as! ClientVC
                        vc.clientData       = self.clientData ?? []
                        vc.copyClientData   = self.clientData ?? []
                        if self.isManualInput{
                            vc.receiptList?.TRCO_KEY?.removeAll()
                        }else{
                            vc.receiptList = self.receiptList
                        }

                        vc.searchManualInputText = self.searchManualInputText
                        
                        vc.completionTRSC_CCY_CD = { new_TRSC_CCY_CD in
                            self.selected_TRCO_TRSC_CCY_CD = new_TRSC_CCY_CD
                        }
                        
                        vc.completion   = { data, clientData, isSearching, isManualInput in
                            
                            self.isManualInput = isManualInput
                            
                            if isManualInput {
                                // Set value manualinput to SubmitReceipt VC
                                self.searchManualInputText = data.l_text
                                self.clientData = []
                                self.isSwitchButtonEnable = true
                            }else{
                                self.searchManualInputText = ""
                                self.isSwitchButtonEnable = false
                            }
                            self.isSearching    = isSearching
                            self.clientData     = clientData
                            self.isClearVisible = data.l_text.isEmpty ? false : true
                            self.setValue(newValue: data.l_text, newKey: data.TRCO_KEY, code: .MERCHANT)
                            self.setValue(newValue: data.r_text ?? "", code: .TAXID)
                            
                                self.tableView.reloadData()
                                self.checkingSubmitButton()
                        }
                        self.pushVC(viewController: vc, animated: true)
                    }
                    
                case .WITH_HOLDING_TAX:
                    self.hideDatePicker()
                    self.hidePickerView()
     
                    let vc                      = self.VC(sbName: "SelectPurposeSB", identifier: "SelectPurposeVC" ) as! SelectPurposeVC
                    vc.delegate                 = self
                    vc.selectUserListKey        = self.getKey(from: .WITH_HOLDING_TAX)
                    vc.isShowPlanned_money      = false
                    vc.isShowOnlyPlanned_money  = false
                    self.selectPurposeIndex     = indexPath.row  // get row of select purpose to insert advance ledger
                    vc.headerTitle              = "select_a_withholding_tax".localized
                    vc.popUpType                = .WITH_HOLDING_TAX
                    self.presetVC(vc:vc)
                     
                default:
                    // In case beside PURPOSE, PAYMENT_METHOD, MERCHANT -> Please add new case
                    break
                }
            }
            return cell
           
        case .CURRENCY:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitReceiptCurrenyCell") as! SubmitReceiptCurrenyCell
            cell.delegate       = self // delegate currency
            cell.isAutoMerchant = self.getKey(from: .MERCHANT).isEmpty
            cell.configCell(row: data)
            cell.isUserInteractionEnabled = isSwitchButtonEnable
            
            if self.receiptList?.TRCO_TRSC_CCY_CD == "KHR" ||  self.receiptList?.TRCO_TRSC_CCY_CD == "USD" {
                cell.isUserInteractionEnabled = false

            }
            if cell.isUserInteractionEnabled == false {
                cell.borderViewLeadingCons.constant = data?.value == "KHR" ? 2 : 62
                cell.btnKHR.setTitleColor(data?.value == "KHR" ? UIColor(hexString: "#7fb3dc") : UIColor(hexString: "#c6c6c6"), for: .normal)
                cell.btnUSD.setTitleColor(data?.value == "USD" ? UIColor(hexString: "#7fb3dc") : UIColor(hexString: "#c6c6c6"), for: .normal)
                
            }else {

                cell.borderViewLeadingCons.constant = data?.value == "KHR" ? 2 : 62
                cell.btnKHR.setTitleColor(data?.value == "KHR" ? UIColor(hexString: "#0694ff") : UIColor(hexString: "#6f6f6f"), for: .normal)
                cell.btnUSD.setTitleColor(data?.value == "USD" ? UIColor(hexString: "#0694ff") : UIColor(hexString: "#6f6f6f"), for: .normal)

            }
            cell.btnKHR.addTarget(self, action: #selector(didTapButtonKHR(_:)), for: .touchUpInside)
            cell.btnUSD.addTarget(self, action: #selector(didTapButtonUSD(_:)), for: .touchUpInside)
//            cell.segmentCurrency.addTarget(self, action: #selector(checkAmountInput), for: .valueChanged)
            return cell
            
        case .TEL:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitReceiptCell", for: indexPath) as! SubmitReceiptCell
            cell.delegate                       = self // delegate currency
            cell.tfPhoneNumber.delegate         = self // delegate phone number
            cell.textFieldEnterValue.delegate   = self // delegate textFields
            cell.tfMerchant.delegate            = self
            
            cell.CCY_CD                         = self.getValue(from: .CURRENCY).isNotEmpty ? self.getValue(from: .CURRENCY) : (self.isUSDCurrency ? "USD" : "VND")
            cell.isKHR                          = self.getValue(from: .CURRENCY).isEmpty ? true : (self.getValue(from: .CURRENCY) == CurrencyType.KHR.rawValue)
            cell.isAutoMerchant                 = self.getKey(from: .MERCHANT).isEmpty
            cell.setUpCell(row: (data ?? SubmitReceiptModel.reeceipRow.content(code: "")))
            
            cell.segementCurrency.addTarget(self, action: #selector(checkAmountInput), for: .valueChanged)
            cell.btnTrickDropDown.addTarget(self, action: #selector(didTapShowPickerView), for: .touchUpInside)
            cell.btnDropDownCodeCountry.addTarget(self, action: #selector(didTapShowPickerView), for: .touchUpInside)
            cell.btnSelectContact.addTarget(self, action: #selector(didTapSelectContact), for: .touchUpInside)
            return cell
            
        case .EMAIL:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitReceiptFillCell") as! SubmitReceiptFillCell
            cell.configCell(row: data, isManual: self.isManualInput)
            return cell
            
        case .ADDRESS:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell") as! AddressCell
            cell.txtView.delegate = self
            cell.configCell(row: data)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitReceiptFillCell") as! SubmitReceiptFillCell
            cell.owner                      = self
            cell.textfieldInput.delegate    = self // delegate textfield
            cell.isClearVisible             = self.getValue(from: .MERCHANT).isNotEmpty ? true : false
            cell.CCY_CD                     = self.getValue(from: .CURRENCY).isNotEmpty ? self.getValue(from: .CURRENCY) : (self.isUSDCurrency ? "USD" : "VND")
            cell.receiptList                = self.receiptList
            cell.configCell(row: data, isManual: self.isManualInput)
            
            cell.completion = { merchantValue, taxIdValue in
                self.setValue(newValue: merchantValue, code: .MERCHANT)
                self.setValue(newValue: taxIdValue, code: .TAXID)
                
                self.tableView.reloadRows(at: [IndexPath(row: self.getIdx(cell_code: .MERCHANT), section: 0), IndexPath(row: self.getIdx(cell_code: .TAXID), section: 0)], with: .none)
                self.checkingSubmitButton()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let code        = cellValue?.content[indexPath.row].code
        let mappingCode = ReceiptRow(rawValue: code ?? "")
         
        DispatchQueue.main.async {
            switch mappingCode {
//            case .RECEIPTNO:
//               self.checkKeyboardUp(type: .RECEIPTNO)
                
            case .DATE:
                self.pickerViewDate.tag = 3000
                self.showDatePicker()
                
            case .DEBITDATE:
                self.pickerViewDate.tag   = 4000
                self.selectDebitDateIndex = indexPath.row
                self.showDatePicker()
                
            case .PROJECT_SITE:
                self.hideDatePicker()
                self.hidePickerView()
                
                let vc                      = self.VC(sbName: "SelectPurposeSB", identifier: "SelectPurposeVC" ) as! SelectPurposeVC
                vc.popUpType                = .PROJECT_SITE
                vc.delegate                 = self
                vc.selectUserListKey        = self.getKey(from: .PROJECT_SITE)
                vc.isShowPlanned_money      = false
                vc.isShowOnlyPlanned_money  = false
                self.selectPurposeIndex     = indexPath.row  // get row of select purpose to insert advance ledger
                vc.headerTitle              = "Project/Site"
                self.presetVC(vc:vc)
                
            case .PURPOSE:
                self.handleTapPurpose(indexPath)
                 
            case .PAYMENT_METHOD:
                self.handleTapPaymentMethod()
                 
            case .IMPORT_TRANSACTION:
                self.hideDatePicker()
                self.hidePickerView()
                
                if self.getValue(from: .MERCHANT).isNotEmpty && self.getValue(from: .AMOUNT).isNotEmpty {
                    
                    let date        = Date()
                    let currentDate = self.dateFormatter.string(from: date)
                    let last7Days   = self.dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -7, to: date) ?? date)
                    let CCY_CD      = (self.cellValue?.content.contains(where: { $0.code == ReceiptRow.CURRENCY.rawValue }) ?? false) ? self.getValue(from: .CURRENCY) : (self.isUSDCurrency ? "USD" : "VND")
                    let strAmount               = self.getValue(from: .AMOUNT)
                    
                    var TRSC_AMT = ""
                    
                    TRSC_AMT = CCY_CD == "USD" ? String(strAmount.replace(of: ".", with: "").replace(of: ",", with: ".").toDouble) : strAmount.replace(of: ".", with: "")
                    
                    
                    let strAmountUSD            = String((self.importTransactionVM.importTransactionData?.REC?.first?.TRSC_AMT.components(separatedBy: ".").first ?? "").toDouble)
                    let importAmountUSD         = strAmountUSD
                    let importAmountKhrAndVnd   = self.importTransactionVM.importTransactionData?.REC?.first?.TRSC_AMT.components(separatedBy: ".").first ?? ""
                    
                    let importTransactionAmount = CCY_CD == "USD" ? importAmountUSD : importAmountKhrAndVnd
                    
                    // Check transaction has value or not
                    if importTransactionAmount != TRSC_AMT {
                        let body = MREC_R007.REQUEST(TRSC_AMT: TRSC_AMT, CCY_CD: CCY_CD, FROM_DT: last7Days, TO_DT: currentDate)
                        
                        // Fetching Import Transaction
                        self.importTransactionVM.fetchTransactionList(body: body) { result in
                            switch result {
                            case .success(let data):
                                
                                let vc = self.PopupVC(storyboard: "ImportTransactionSB", identifier: "ImportTransactionVC") as! ImportTransactionVC
                                vc.TRSC_AMT                                     = TRSC_AMT
                                vc.CCY_CD                                       = CCY_CD
                                vc.heightOfTable                                = CGFloat(((data.REC?.count ?? 0) > 1 ? (2 * 62) : 62)) // 62 is default cell's height
                                vc.importTransactionVM.importTransactionData    = data
                                
                                // Callback when user is Click Match button
                                vc.completion = { result, indexPath in
                                    self.importTransactionData                      = result?.REC?[indexPath]
                                    self.importTransactionVM.importTransactionData  = result
                                    let CCY_CD          = self.importTransactionVM.importTransactionData?.REC?[indexPath].CCY_CD
                                    let amountKhrAndVND = result?.REC?[indexPath].TRSC_AMT.components(separatedBy: ".").first ?? ""
                                    let payWayAmount    = "\(CCY_CD == "USD" ? "\(result?.REC?[indexPath].TRSC_AMT.vndCurrency.replace(of: ".", with: "").replace(of: ",", with: ".").vndCurrency ?? "")" : "\(amountKhrAndVND)")"
                                    let message         = "OOO_OOO_match".localized
                                    var transactionAmount = ""
                                    
                                    transactionAmount = String(format: message, "\(formatteDate(date: result?.REC?[indexPath].TRSC_DT ?? ""))", "\(CCY_CD == "USD" ? "$\(payWayAmount)" : "\(payWayAmount.vndCurrencyFormatter())₫")")
                                    
                                     
                                    self.setValue(newValue: transactionAmount, newKey: "true", code: .IMPORT_TRANSACTION, other: result?.REC?[indexPath].TRSC_AMT ?? "")
                                    let index               = self.getIdx(cell_code: .IMPORT_TRANSACTION)
                                    self.checkingSubmitButton()
                                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                                }
                                
                                vc.modalPresentationStyle                       = .overFullScreen
                                vc.modalTransitionStyle                         = .crossDissolve
                                vc.providesPresentationContextTransitionStyle   = true
                                vc.definesPresentationContext                   = true
                                self.present(vc, animated: true)
                                
                            case .failure(_):
                                // Event fetching API is failed -> still present VC
                                let vc = self.PopupVC(storyboard: "ImportTransactionSB", identifier: "ImportTransactionVC") as! ImportTransactionVC
                                vc.TRSC_AMT                                     = self.getValue(from: .AMOUNT)
                                vc.CCY_CD                                       = CCY_CD
                                vc.heightOfTable                                = 62 // 62 is default cell's height
                                vc.importTransactionVM.importTransactionData    = nil
                                
                                // Callback when user is Click Match button
                                vc.completion = { result, indexPath in
                                    self.importTransactionData                      = result?.REC?[indexPath]
                                    self.importTransactionVM.importTransactionData  = result
                                    let CCY_CD              = self.importTransactionVM.importTransactionData?.REC?[indexPath].CCY_CD
                                    let payWayAmount        = "\(CCY_CD == "USD" ? "$\(result?.REC?[indexPath].TRSC_AMT.usdCurrency ?? "")" : "R\(result?.REC?[indexPath].TRSC_AMT.formatKHRCurrency() ?? "")")"
                                    let message             = "OOO_OOO_match".localized
                                    let transactionAmount   = String(format: message, "\(formatteDate(date: result?.REC?[indexPath].TRSC_DT ?? ""))", "\(payWayAmount)")
                                     
                                    self.setValue(newValue: transactionAmount, newKey: "true", code: .IMPORT_TRANSACTION, other: result?.REC?[indexPath].TRSC_AMT ?? "")
                                    let index               = self.getIdx(cell_code: .IMPORT_TRANSACTION)
                                    self.checkingSubmitButton()
                                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                                }
                                
                                vc.modalPresentationStyle                       = .overFullScreen
                                vc.modalTransitionStyle                         = .crossDissolve
                                vc.providesPresentationContextTransitionStyle   = true
                                vc.definesPresentationContext                   = true
                                self.present(vc, animated: true)
                            }
                        }
                    }
                    else {
                        let vc = self.PopupVC(storyboard: "ImportTransactionSB", identifier: "ImportTransactionVC") as! ImportTransactionVC
                        vc.heightOfTable            = CGFloat(((self.importTransactionVM.importTransactionData?.REC?.count ?? 0) > 1 ? (2 * 62) : 62)) // 62 is default cell's height
                        vc.TRSC_AMT                 = TRSC_AMT
                        vc.CCY_CD                   = CCY_CD
                        vc.importTransactionVM      = self.importTransactionVM
                        
                        vc.completion = { result, indexPath in
                            self.importTransactionData                      = result?.REC?[indexPath]
                            self.importTransactionVM.importTransactionData  = result
                            let CCY_CD              = self.importTransactionVM.importTransactionData?.REC?[indexPath].CCY_CD
                            let amountKhrAndVND     = result?.REC?[indexPath].TRSC_AMT.components(separatedBy: ".").first ?? ""
                            let payWayAmount        = "\(CCY_CD == "USD" ? "\(result?.REC?[indexPath].TRSC_AMT.vndCurrency.replace(of: ".", with: "").replace(of: ",", with: ".").vndCurrency ?? "")" : "\(amountKhrAndVND)")"
                            let message             = "OOO_OOO_match".localized
                            var transactionAmount = ""
                            
                            transactionAmount = String(format: message, "\(formatteDate(date: result?.REC?[indexPath].TRSC_DT ?? ""))", "\(CCY_CD == "USD" ? "$\(payWayAmount)" : "\(payWayAmount.vndCurrencyFormatter())")₫")
                            
                             
                            self.setValue(newValue: transactionAmount, newKey: "true", code: .IMPORT_TRANSACTION, other: result?.REC?[indexPath].TRSC_AMT ?? "")
                            let index               = self.getIdx(cell_code: .IMPORT_TRANSACTION)
                            self.checkingSubmitButton()
                            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                        
                        self.present(vc, animated: true)
                    }
                }
                 
            case .ADVANCELEDGER:
                self.hideDatePicker()
                self.hidePickerView()
                
                let vc                      = self.VC(sbName: "SelectPurposeSB", identifier: "SelectPurposeVC" ) as! SelectPurposeVC
                vc.delegate                 = self
                vc.selectUserListKey        = self.getKey(from: .ADVANCELEDGER)
                vc.isAdvanceLedger          = true
                vc.isShowPlanned_money      = true
                vc.isShowOnlyPlanned_money  = true
                vc.headerTitle              = "select_a_advance_ledger".localized
                self.presetVC(vc:vc)
                
//            case .ADDRESS:
//                self.validateAddressIfAutoMerchant()
                 
            case .TYPEOFSUPPLIER:
                 //can select if merchant isnot auto
                //New Flow
                if self.isManualInput || self.isClearVisible == false{
                    self.typeOfSupplierChoices(self.getValue(from: .TYPEOFSUPPLIER))
                }
            
                //Old Flow
//                if self.isManualInput {
//                    if !self.getKey(from: .MERCHANT).isEmpty {
//                        self.typeOfSupplierChoices(self.getValue(from: .TYPEOFSUPPLIER))
//                    }
//                    else {
//                        self.checkTypeOfSupplierAndTaxIfAutoMerchant()
//                    }
//                }
                
//            case .TAXID:
//                self.checkKeyboardUp(type: .TAXID)
                
//            case .AMOUNT:
//                self.checkKeyboardUp(type: .AMOUNT)
                
//            case .RATE:
//                self.checkKeyboardUp(type: .RATE)
                
//            case .EMAIL:
//                self.checkKeyboardUp(type: .EMAIL)
                
//            case .USER:
//                self.checkKeyboardUp(type: .USER)

            case .MERCHANT:
                let vc = UIStoryboard.init(name: "ClientSB", bundle: Bundle.main).instantiateViewController(withIdentifier: "ClientVC") as! ClientVC
                vc.clientData       = self.clientData ?? []
                vc.copyClientData   = self.clientData ?? []
                print("Before: ", self.selected_TRCO_TRSC_CCY_CD)
                if self.isManualInput{
                    vc.receiptList?.TRCO_KEY?.removeAll()
                }else{
                    vc.receiptList = self.receiptList
                }

                vc.searchManualInputText = self.searchManualInputText
                
                vc.completionTRSC_CCY_CD = { new_TRSC_CCY_CD in
                    self.selected_TRCO_TRSC_CCY_CD = new_TRSC_CCY_CD
                }
                
                vc.completion   = { data, clientData, isSearching, isManualInput in
                    print("After: ", self.selected_TRCO_TRSC_CCY_CD)
                    self.isManualInput = isManualInput
                    if isManualInput {
                        // Set value manualinput to SubmitReceipt VC
                        self.searchManualInputText = data.l_text
                        self.clientData = []
                        self.isSwitchButtonEnable = true
                    }else{
                        self.searchManualInputText = ""
                        self.isSwitchButtonEnable = false
                    }
                    self.searchManualInputText = ""
                    //Old Flow
                    self.isSearching    = isSearching
                    self.clientData     = clientData
                    self.isClearVisible = data.l_text.isEmpty ? false : true
                    self.setValue(newValue: data.l_text, newKey: data.TRCO_KEY, code: .MERCHANT)
                    self.setValue(newValue: data.r_text ?? "", code: .TAXID)
                    
                    // Reload row by cell_code
                    self.receiptList?.TRCO_TRSC_CCY_CD = data.TRSC_CCY_CD
                    self.tableView.reloadRows(at: [IndexPath(row: self.getIdx(cell_code: .MERCHANT), section: 0), IndexPath(row: self.getIdx(cell_code: .TAXID), section: 0)], with: .none)
                    self.checkingSubmitButton()
                    
                }
                self.pushVC(viewController: vc, animated: true)
                
            case .WITH_HOLDING_TAX :
                self.hideDatePicker()
                self.hidePickerView()
 
                let vc                      = self.VC(sbName: "SelectPurposeSB", identifier: "SelectPurposeVC" ) as! SelectPurposeVC
                vc.delegate                 = self
                vc.selectUserListKey        = self.getKey(from: .WITH_HOLDING_TAX)
                vc.isShowPlanned_money      = false
                vc.isShowOnlyPlanned_money  = false
                self.selectPurposeIndex     = indexPath.row  // get row of select purpose to insert advance ledger
                vc.headerTitle              = "select_a_withholding_tax".localized
                vc.popUpType                = .WITH_HOLDING_TAX
                self.presetVC(vc:vc)
                
            default: break
            }
        }
    }
    
    // hide DatePicker and PickerView when user scroll
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            self.hideDatePicker()
            self.hidePickerView()
        }
    }
}
 
//MARK: - UIPickerViewDelegate
extension SubmitReceiptVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
      
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.isShowMerchantPicker ? merchantModule.count : self.isShowBankPicker ? self.bankVM.sortedBankList?.count ?? 0 : Shared.countryData.count
    }
      
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let bankName = self.bankVM.sortedBankList?[row].BANK_NM?.split(separator: "|").first ?? ""
        return self.isShowMerchantPicker ? merchantModule[row].localized : self.isShowBankPicker ? String(bankName) : "\(Shared.countryData[row].dial_code)  \(Shared.countryData[row].name)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let updatedCountryCode  = "\(Shared.countryData[row].dial_code)"
        let bankCode            = self.bankVM.sortedBankList?[row].BANK_CD ?? ""
        let bankName            = (self.bankVM.sortedBankList?[row].BANK_NM?.split(separator: "|").first ?? "").replacingOccurrences(of: " ", with: "")
         
        setValue(newValue   : self.isShowMerchantPicker ? getValue(from: .MERCHANT): self.isShowBankPicker ? (getValue(from: .BANK)): getValue(from: .TEL),
                 newKey     : self.isShowMerchantPicker ? merchantModule[row].localized     : self.isShowBankPicker ? String(bankName)          : updatedCountryCode.localized,
                 code       : self.isShowMerchantPicker ? .MERCHANT : self.isShowBankPicker ? .BANK : .TEL,
                 other      : bankCode)
        
        if !self.isShowMerchantPicker && !self.isShowBankPicker {
            setValue(newValue: getValue(from: .TEL), newKey: updatedCountryCode , code: .TEL)
        }
        
        DispatchQueue.main.async {
            let rowMerchat  = self.getIdx(cell_code: .MERCHANT)
            let rowTel      = self.getIdx(cell_code: .TEL)
            let rowBank     = self.getIdx(cell_code: .BANK)
            self.tableView.reloadRows(at: [IndexPath(row: self.isShowMerchantPicker ? rowMerchat : self.isShowBankPicker ? rowBank : rowTel, section: 0)], with: .none)
            self.isShowMerchantPicker ? self.validateMerchat() : ()
            self.checkingSubmitButton()
        }
    }
}

//MARK: - UITextFieldDelegate
extension SubmitReceiptVC: UITextFieldDelegate {
     
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.hidePickerView()
        self.hideDatePicker()
        
        switch textField.tag {
        
        // Amount, Tel, Rate
        case 1010, 1015, 1017:
            textField.keyboardType = UIKeyboardType.decimalPad
            
        // Merchant, Tax ID
        case 1011, 1014:
            textField.keyboardType = UIKeyboardType.default
            
        // Email
        case 1016:
            textField.keyboardType = UIKeyboardType.emailAddress
            
        default : break
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let tempText = textField.text, let textRange = Range(range, in: tempText) {
            let updatedText = tempText.replacingCharacters(in: textRange, with: string)
            let newLength = tempText.count + string.count - range.length
            
            switch textField.tag {
                // Amount
            case 1010:
                
//                    self.setValue(newValue: updatedText.replace(of: ",", with: "").trim, newKey: getKey(from: .AMOUNT), code: .AMOUNT)
//
//                } else {
//                    self.setValue(newValue: updatedText.replace(of: ".", with: "").trim, newKey: getKey(from: .AMOUNT), code: .AMOUNT)
//                }
                
//                    self.setValue(newValue: updatedText.replace(of: ",", with: "").trim, newKey: getKey(from: .AMOUNT), code: .AMOUNT)
//                }
//                else {
//                        let newText = updatedText.dropLast()
//                        self.setValue(newValue: newText.trimmingCharacters(in: .whitespaces), newKey: getKey(from: .AMOUNT), code: .AMOUNT)
//                    }
//                    else {
//                        if (updatedText.contains(",") && (updatedText.components(separatedBy: ",").last?.count ?? 0) > 2) {
//                            let newText = updatedText.dropLast()
//                            self.setValue(newValue: newText.trimmingCharacters(in: .whitespaces), newKey: getKey(from: .AMOUNT), code: .AMOUNT)
//                        }
//                        else {
////                            let newText = (string == "." && !updatedText.contains(",")) ? updatedText.dropLast() + "," : updatedText.trim
//                            let newText = (string == ".") ? updatedText.dropLast() + "," : updatedText.trim
//                            self.setValue(newValue: newText, newKey: getKey(from: .AMOUNT), code: .AMOUNT)
//                        }
//                    }
//                }
                
                self.importTransactionValidation()
                self.checkingSubmitButton()
                return newLength <= 15
                
                // Merchant
            case 1011:
                self.checkingSubmitButton()
                self.importTransactionValidation()
                return true
                
                // Username
            case 1012:
                //                self.setValue(newValue: updatedText.trim, code: .USER)
                return true
                
                // Receipt No.
//            case 1013:
//                self.setValue(newValue: updatedText.trim, newKey: getKey(from: .RECEIPTNO), code: .RECEIPTNO)
//                self.checkingSubmitButton()
//                return true
                
                // Tax ID
            case 1014:
                self.setValue(newValue: updatedText.trim, newKey: self.getKey(from: .TAXID), code: .TAXID)
                self.checkingSubmitButton()
                return true
                
                // Phone Number
            case 1015:
                return newLength <= 10
                
                // Bank
            case 1019:
                self.setValue(newValue: updatedText.trim, newKey: self.getKey(from: .BANK), code: .BANK, other: self.getmoreValue(from: .BANK))
                self.checkingSubmitButton()
                return newLength <= 20
            
            case 1016:
                self.setValue(newValue: textField.text ?? "", code: .EMAIL)
                self.checkingSubmitButton()
                
                // Rate
            case 1017:
                return true
                
            default: break
            }
        }
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        // Merchant
        case 1011:
            self.setValue(newValue: (textField.text?.trim ?? ""), newKey: getKey(from: .MERCHANT), code: .MERCHANT)
            self.checkingSubmitButton()
            
        // Username
        case 1012:
            self.setValue(newValue: (textField.text?.trim ?? ""), code: .USER)
        
        // TEL
        case 1015:
            self.setValue(newValue: textField.text ?? "", newKey: getKey(from: .TEL), code: .TEL)
        
            // Email
        case 1016:
            self.setValue(newValue: textField.text ?? "", code: .EMAIL)
            self.checkingSubmitButton()
            
        default: break
        }
        return true
    }
     
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - getContactListDelegate
extension SubmitReceiptVC: getContactListDelegate {
    
    func getREC030_REC1(data: MREC_R030.REC1, selectIndexPath: IndexPath?) {
        r030REC2 = nil
        r030REC1 = data
        
        // Address
        let new_add     = [data.TRCO_BSUN_POST_ADRS ?? "", data.TRCO_BSUN_DTL_ADRS ?? "", data.TRCO_BSUN_CITY ?? "", data.TRCO_BSUN_ST ?? ""]
        _  = new_add.filter({ !$0.isEmpty }).joined(separator: ", ")
        
        let TRCO_RPRS_TLPH = data.TRCO_RPRS_TLPH ?? ""
        // To check if key empty or less than 5 digit
        let isNil             = TRCO_RPRS_TLPH == "" || TRCO_RPRS_TLPH.count < 5
        var headerCodePrefix  = isNil ? "" : TRCO_RPRS_TLPH.prefix(5)
        
        if !(headerCodePrefix.isEmpty) {
            headerCodePrefix.removeFirst()
            
            for char in headerCodePrefix {
                if char == "0" {
                    headerCodePrefix.removeFirst()
                } else {
                    break
                }
            }
        }
         
        // Tax Id
        let tx_id = data.TRCO_TYPE == "3" ? (data.GST_NO ?? "") : (data.TRCO_TAX_ID ?? "")
        
        let merchant = data.TRCO_CMENM ?? ""
        self.setValue(newValue: merchant, newKey: getKey(from: .MERCHANT), code: .MERCHANT)
        self.receiptList?.TRCO_KEY  = data.TRCO_KEY
        
        // Define cell (** incase has tel, email, address)
//        self.supplier(type: TypeOfSupplier(rawValue: data.TRCO_TYPE ?? "1") ?? .TaxablePerson)
        self.isUSDCurrency = (data.TRSC_CCY_CD ?? "") == "USD"
        setValue(newValue: data.TRSC_CCY_CD ?? "", code: .CURRENCY)
        self.checkAmountInput()
//        self.setValue(newValue: data.EML ?? "", code: .EMAIL)
//        self.setValue(newValue: phoneNumber, newKey: headerCode, code: .TEL)
//        let type_of_supplier = mappingTypeOfSupplier(value: data.TRCO_TYPE ?? "1")
//        self.setValue(newValue: type_of_supplier, newKey: getKey(from: .MERCHANT), code: .TYPEOFSUPPLIER)
//        self.setValue(newValue: address_ft, newKey: getKey(from: .MERCHANT), code: .ADDRESS)
        self.setValue(newValue: tx_id, newKey: TypeOfSupplier(rawValue: data.TRCO_TYPE ?? "1")?.description.localized ?? "", code: .TAXID)
        self.address    = new_add
        self.trco_key_defined_merchant = data.TRCO_KEY ?? ""
        self.tableView.reloadData()
    }
    
    func getREC030_REC2(data: MREC_R030.REC2, selectIndexPath: IndexPath?) {
        r030REC1 = nil
        r030REC2 = data
        selectedContactIndexPath = selectIndexPath
        
        // Address
        let new_add     = [data.TRCO_BSUN_POST_ADRS ?? "", data.TRCO_BSUN_DTL_ADRS ?? "", data.TRCO_BSUN_CITY ?? "", data.TRCO_BSUN_ST ?? ""]
        _  = new_add.filter({ !$0.isEmpty }).joined(separator: ", ")
        
        let TRCO_RPRS_TLPH = data.TRCO_RPRS_TLPH ?? ""
        // To check if key empty or less than 5 digit
        let isNil             = TRCO_RPRS_TLPH == "" || TRCO_RPRS_TLPH.count < 5
        var headerCodePrefix  = isNil ? "" : (TRCO_RPRS_TLPH.prefix(5))
        
        if !(headerCodePrefix.isEmpty) {
            headerCodePrefix.removeFirst()
            
            for char in headerCodePrefix{
                if char == "0" {
                    headerCodePrefix.removeFirst()
                } else {
                    break
                }
            }
        }
        
        // Tax Id
        let tx_id = data.TRCO_TYPE == "3" ? (data.GST_NO ?? "") : (data.TRCO_TAX_ID ?? "")
        
        let merchant = data.TRCO_CMENM ?? ""
        self.setValue(newValue: merchant, newKey: getKey(from: .MERCHANT), code: .MERCHANT)
        self.receiptList?.TRCO_KEY  = data.TRCO_KEY
        
        if self.cellValue?.content.contains(where: {$0.code != ReceiptRow.CURRENCY.rawValue}) ?? false {
            self.importTransactionVM.importTransactionData?.REC?.removeAll()
            self.setValue(newValue: "", newKey: "true", code: .IMPORT_TRANSACTION, other: self.getmoreValue(from: .IMPORT_TRANSACTION))
            let importIndex = self.getIdx(cell_code: .IMPORT_TRANSACTION)
            self.tableView.reloadRows(at: [IndexPath(row: importIndex, section: 0)], with: .none)
        }
        
        // Define cell (** incase has tel, email, address)
//        self.supplier(type: TypeOfSupplier(rawValue: data.TRCO_TYPE ?? "1") ?? .TaxablePerson)
        self.isUSDCurrency = (data.TRSC_CCY_CD ?? "") == "USD"
        setValue(newValue: data.TRSC_CCY_CD ?? "", code: .CURRENCY)
        self.checkAmountInput()
//        self.setValue(newValue: data.EML ?? "", code: .EMAIL)
//        self.setValue(newValue: phoneNumber, newKey: headerCode, code: .TEL)
//        let type_of_supplier = mappingTypeOfSupplier(value: data.TRCO_TYPE ?? "1")
//        self.setValue(newValue: type_of_supplier, newKey: getKey(from: .MERCHANT), code: .TYPEOFSUPPLIER)
//        self.setValue(newValue: address_ft, newKey: getKey(from: .MERCHANT), code: .ADDRESS)
        self.setValue(newValue: tx_id, newKey: TypeOfSupplier(rawValue: data.TRCO_TYPE ?? "1")?.description.localized ?? "", code: .TAXID)
        self.address    = new_add
        self.trco_key_defined_merchant = data.TRCO_KEY ?? ""
        self.tableView.reloadData()
    }
}

//MARK: - getDataDelegate
extension SubmitReceiptVC: getDataDelegate {
    func getCurrencyValue(value: String, isReset: Bool) {
        setValue(newValue: value, code: .CURRENCY)
        self.isUSDCurrency = value == "USD"
        self.importTransactionVM.importTransactionData?.REC?.removeAll()
        
        // Clear IMPORT_TRANSACTION only while user switching Currency
        if (cellValue?.content.contains(where: { $0.code == ReceiptRow.IMPORT_TRANSACTION.rawValue }) ?? false) {
            let isNewKey : Bool = self.getValue(from: .AMOUNT).isNotEmpty
            self.setValue(newValue: isReset ? "" : self.getValue(from: .IMPORT_TRANSACTION) , newKey: "\(isNewKey)", code: .IMPORT_TRANSACTION, other: self.getmoreValue(from: .IMPORT_TRANSACTION))
            let importIndex = self.getIdx(cell_code: .IMPORT_TRANSACTION)
            self.tableView.reloadRows(at: [IndexPath(row: importIndex, section: 0)], with: .none)
        }
        self.checkingSubmitButton()
    }
}

//MARK: - addressDelegate
extension SubmitReceiptVC: addressDelegate {
    func getAddess(data: [String]) {
//        self.address        = data
//        let address_ft      = address.filter({ !$0.isEmpty }).joined(separator: ", ")
//        self.setValue(newValue: address_ft, newKey: getKey(from: .MERCHANT), code: .ADDRESS)
        
        self.tableView.reloadData()
        self.checkingSubmitButton()
    }
}

//MARK: - UITextViewDelegate
extension SubmitReceiptVC: UITextViewDelegate {
    
    // Digit limit 50 characters
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 200
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.setValue(newValue: textView.text, code: .DESCRIPTION)
        self.checkingSubmitButton()
    }
}

//MARK: - UICollectionView Delegate and DataSource
extension SubmitReceiptVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /// Hold down to preview image
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        guard let cell = collectionView.cellForItem(at: indexPath) as? MultiImageCell else {
            return nil
        }
        
        let img = cell.attachmentImgView.image
        // We have to create an NSString since the identifier must conform to NSCopying
        let identifier = NSString(string: "\(indexPath.row)")

        // Create our configuration with an indentifier
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
            return PhotoPreviewViewController(image: img ?? UIImage(named: "noimage")!)
        }, actionProvider: { suggestedActions in
            return self.makeDefaultDemoMenu()
        })
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0 : //show add attachment cell when total attachments smaller than Max Image (Shared.MAX_IMAGES = 5)
            return (imgREC.count ) + self.localImages.count + (fileREC.count ) + self.localDocument.count < Shared.MAX_IMAGES ? 1 : 0 //1: Show, 0: Hide
        
        case 1:
            return self.imgREC.count
            
        case 2:
            return self.localImages.count
            
        case 3:
            return self.fileREC.count
            
        case 4:
            return self.localDocument.count
        
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (self.imgREC.count == 0) ? 0 : 7) // 7 spacing
        } else {
            if (imgREC.count ) + self.localImages.count + (fileREC.count ) + self.localDocument.count + 1  >= Shared.MAX_IMAGES {
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            } else {
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 7) // 7 spacing
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 3 - 24 , height: 94) //show only 3 cells, 24 spacing btw cell (7*3)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let section = indexPath.section
        
        switch section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddMultiImageCell", for: indexPath) as! AddMultiImageCell
            
            // Open Gallery
            cell.addBtn.addTarget(self, action: #selector(didTapOpenGallery(sender:)), for: .touchUpInside)
            return cell
            
        case 1:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiImageCell", for: indexPath) as! MultiImageCell
            
            let imageURL = self.imgREC[indexPath.row].FILE_URL ?? ""
            
            cell.loadImage(imageURL: imageURL)
            
            /// preview img by clicking
            cell.attachmentImgView.didTap {
                // assign Image View for zoom animation
                self.receiptImage   = cell.attachmentImgView
                self.selectedImages = cell.attachmentImgView.image // img for long press to preview
                
                self.currentIndexPathImage = indexPath
                self.performSegue(withIdentifier: NotifyKey.gotoPhotoPreviewVC.rawValue, sender: nil)
            }
            // delete
            cell.didTapCloseCompletion = {
                 
                //  If Edit receipt : delete image donot use api ** new flow
                if self.isFromEditing == "Y" { // if edit receipt
                    self.showPopupDeleteImage {
                        self.setValue(newValue: "", newKey: self.receiptList?.SEQ_NO ?? "", code: .ATTACHMEMNT)
                          
                        self.localDeleteREC1.append(self.imgREC[indexPath.row])
                        self.imgREC.remove(at: indexPath.row) // locally remove image, without calling API
                         
                        // Clear cache
                        SDImageCache.shared.clearMemory()
                        SDImageCache.shared.clearDisk()
                         
                        self.tableView.reloadData()
                        self.checkingSubmitButton()
                    }
                } else {
                    // if submit receipt, delete exist img with api
                    // if delete exist img with api, and upload new img => store local and remove on local

                    self.showPopupDeleteImage {
                        
                        self.localDeleteREC1.append(self.imgREC[indexPath.row])
                        self.imgREC.remove(at: indexPath.row) // locally remove image
                       
                        // Clear cache
                        SDImageCache.shared.clearMemory()
                        SDImageCache.shared.clearDisk()
                             
                        self.tableView.reloadData()
                        self.checkingSubmitButton()
                    }
                }
            }
            return cell
            
        case 2:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiImageCell", for: indexPath) as! MultiImageCell
            
            let image = localImages[indexPath.row]
            cell.attachmentImgView.image = localImages[indexPath.row]
            
            
            let size        = image.size
            var widthPic    : CGFloat = 0
            var heightPic   : CGFloat = 0
            
            widthPic        = size.width
            heightPic       = size.width
             
            // The shortest side
            let sideLength      = min(widthPic, heightPic)
            
            // Determines the x,y coordinate of a centered
            // sideLength by sideLength square
            let xOffset         = ((size.width) - sideLength) / 2.0
            let yOffset         = ((size.height) - sideLength) / 2.0
            let cropImg         : CGRect    = CGRect(x: xOffset, y: yOffset, width: widthPic, height: heightPic)
            
            let cgImage         : CGImage   = image.cgImage!.cropping(to: cropImg)!
            let croppedImage    : UIImage   = UIImage(cgImage: cgImage)
            
            /// ImageView
            cell.attachmentImgView.contentMode     = .scaleAspectFill
            cell.attachmentImgView.clipsToBounds   = true
            cell.attachmentImgView.image           = croppedImage
            
            /// preview img by clicking
            cell.attachmentImgView.didTap {
                
                self.receiptImage   = cell.attachmentImgView // assign Image View for zoom animation
                self.selectedImages = cell.attachmentImgView.image // img for long pressed to preview
                
                self.currentIndexPathImage = indexPath
                self.performSegue(withIdentifier: NotifyKey.gotoPhotoPreviewVC.rawValue, sender: nil)
            }
            
            // delete btn
            cell.didTapCloseCompletion = {
                
                self.customAlert(type   : .YES_OR_NO_ALERT,
                            image       : "badge_warning",
                            title       : "delete".localized,
                            message     : "are_you_sure_want_to_delete_the_attached_image".localized,
                            redTitle    : "delete".localized,
                            greyTitle   : "cancel".localized) { (isDelete) in
                    if isDelete {
                        self.localImages.remove(at: indexPath.row) // remove from arr
                        self.tableView.reloadData()
                        self.checkingSubmitButton()
                    }
                }
            }
            return cell
            
        case 3:
            
            let rows    = self.fileREC[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiFileCell", for: indexPath) as! MultiFileCell
            
            let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
            let file_name   = rows.ORG_FILE_NM ?? ""
            
            let split_url   = rows.FILE_URL?.components(separatedBy: "?")
            let file_url    = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")" + "&\(file_name)"
            
            cell.configReceiptSubmitCell(data: rows)
            cell.openAttachFileButton.didTap {
                
//                let linked_file = "\(rows.FILE_URL ?? "")&\(rows.ORG_FILE_NM ?? "")"

                DataAccess.shared.downloadTask(withURL: file_url, shouldShowLoading: true) { (data, error) in
                    
                    if error == nil {
                        let path = self.getDocumentsDirectory()
                        let fileUrl = path.appendingPathComponent(rows.ORG_FILE_NM ?? "")
                        
                        do {
                            try data?.write(to: fileUrl)
                            self.quickLook(url: fileUrl) // Preview file

                            // save extention
//                            DispatchQueue.main.async {
//                                let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
//                                if let popoverPresentationController = activityViewController.popoverPresentationController {
//                                    popoverPresentationController.sourceView = self.view
//                                    popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//                                    popoverPresentationController.permittedArrowDirections = []
//                                }
//                                self.present(activityViewController, animated: true, completion: nil)
//                            }
                            
                        } catch {
                            print(error)
                        }
                    }else {
                        self.customAlert(message: error?.localizedDescription ?? "")
                    }
                }
            }
            cell.deleteButton.didTap {
                //  If Edit receipt : delete image donot use api ** new flow
                if self.isFromEditing == "Y" { // if edit receipt
                    self.showPopupDeleteImage {
                        self.setValue(newValue: "", newKey: self.receiptList?.SEQ_NO ?? "", code: .ATTACHMEMNT)
                        
                        self.localDeleteREC1.append(rows)
                        self.fileREC.remove(at: indexPath.row) // locally remove image, without calling API
                        
                        // Clear cache
                        SDImageCache.shared.clearMemory()
                        SDImageCache.shared.clearDisk()
                        
                        self.tableView.reloadData()
                        self.checkingSubmitButton()
                    }
                }
                else {
                    // if submit receipt, delete exist img with api
                    // if delete exist img with api, and upload new img => store local and remove on local
                    
                    self.showPopupDeleteImage {
                        
                        self.localDeleteREC1.append(rows)
                        self.fileREC.remove(at: indexPath.row) // locally remove image
                        
                        // Clear cache
                        SDImageCache.shared.clearMemory()
                        SDImageCache.shared.clearDisk()
                             
                        self.tableView.reloadData()
                        self.checkingSubmitButton()
                    }
                }
            }
            return cell
               
        case 4:
            
            let rows    = localDocument[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiFileCell", for: indexPath) as! MultiFileCell
            
            let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
            let file_name   = rows.fileName
            
            let split_url   = rows.filePath.components(separatedBy: "?")
            let file_url    = "\(split_url.first ?? "")?token=\(authorization)&\(split_url.last ?? "")" + "&\(file_name)"
            
            cell.configAddReceiptCell(data: rows)
            cell.openAttachFileButton.didTap {
                
//                let linked_file = "\(rows.filePath)&\(rows.fileName)"
                
                DataAccess.shared.downloadTask(withURL: file_url, shouldShowLoading: true) { (data, error) in
                    if error == nil {
                        let path = self.getDocumentsDirectory()
                        let fileUrl = path.appendingPathComponent(rows.fileName)
                        do {
                            try data?.write(to: fileUrl)
                            self.quickLook(url: fileUrl)  //Preview file
                            
                            //                          self.  self.previewVC.currentPreviewItemIndex = indexPath.row
//                            self.navigationController?.pushViewController(self.previewVC, animated: true)
//                            DispatchQueue.main.async {
//                                let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
//                                if let popoverPresentationController = activityViewController.popoverPresentationController {
//                                    popoverPresentationController.sourceView = self.view
//                                    popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//                                    popoverPresentationController.permittedArrowDirections = []
//                                }
//                                self.present(activityViewController, animated: true, completion: nil)
//                            }
                            
                        } catch {
                            print(error)
                        }
                        
                    }else {
                        self.customAlert(message: error?.localizedDescription ?? "")
                    }
                }
            }
            cell.deleteButton.didTap {
                //  If Edit receipt : delete image donot use api ** new flow
                if self.isFromEditing == "Y" { // if edit receipt
                    self.showPopupDeleteImage {
                        self.setValue(newValue: "", newKey: self.receiptList?.SEQ_NO ?? "", code: .ATTACHMEMNT)
                        self.localDeleteREC1.append((self.receiptList?.REC1?[indexPath.row])!)
                        self.localDocument.remove(at: indexPath.row) // locally remove image, without calling API
                        
                        // Clear cache
                        SDImageCache.shared.clearMemory()
                        SDImageCache.shared.clearDisk()
                        
                        self.tableView.reloadData()
                        self.checkingSubmitButton()
                    }
                } else {
                    // if submit receipt, delete exist img with api
                    // if delete exist img with api, and upload new img => store local and remove on local
                    
                    self.showPopupDeleteImage {
                        
                        self.localDeleteREC1.append((self.receiptList?.REC1?[indexPath.row])!)
                        self.localDocument.remove(at: indexPath.row) // locally remove image
                        
                        // Clear cache
                        SDImageCache.shared.clearMemory()
                        SDImageCache.shared.clearDisk()
                        
                        self.tableView.reloadData()
                        self.checkingSubmitButton()
                    }
                }
            }
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}

//MARK: - SelectPurposeDelegate
extension SubmitReceiptVC : SelectPurposeDelegate {
    
    // Project/Site
    func sendProjectREC(rec: LIST_POP_UP_RESPONSE.PROJECT_SITE_LIST) {
        setValue(newValue: rec.PRJT_NM, newKey: rec.PRJT_NO, code: .PROJECT_SITE)
        self.tableView.reloadData()
    }
    
    // PURPOSE
    func sendRECItem(rec: LIST_POP_UP_RESPONSE.REC , type: POPUP_TYPE) {
        switch type {
        case .WITH_HOLDING_TAX :
            setValue(newValue: rec.USAG_NM, newKey: rec.USE_USAG_CD, code: .WITH_HOLDING_TAX,other : rec.USAGE_RATE)
            //Update Tax_Amount Value
            let totalAmount = getValue(from: .AMOUNT).replace(of: ",", with: "")
            let fomatCurrency = getValue(from: .CURRENCY)
            let taxCalMoney = self.calculateTaxAmount(amount: totalAmount,rate: rec.USAGE_RATE)
            let formatTaxtAmt = fomatCurrency == "USD" ? formatCurrency(type: fomatCurrency, amount: taxCalMoney) : taxCalMoney
            setValue(newValue: formatTaxtAmt,code: .TAX_AMOUNT)
            
        case .PURPOSE :
            setValue(newValue: rec.USAG_NM, newKey: rec.USE_USAG_CD, code: .PURPOSE)
            
        case .PROJECT_SITE:
            setValue(newValue: rec.USAG_NM, newKey: rec.USE_USAG_CD, code: .PROJECT_SITE)
            
        }
        self.tableView.reloadData()
    }
    
    // Advance Legder
    func sendREC2Item(rec2: LIST_POP_UP_RESPONSE.REC2) {
        let rec         = SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.ADVANCELEDGER.rawValue, value: rec2.ADV_PAYM_NM, key: rec2.ADV_PAYM_SEQ)
        let debit_date  = SubmitReceiptModel.reeceipRow.content(code: ReceiptRow.DEBITDATE.rawValue, value: formatteDate(date: self.receiptList?.USE_DT ?? ""))
        
        if (cellValue?.content.contains(where: { $0.code == rec.code }) ?? false) {
            // if advance legder already insert, here is to set new value to existing advance legder
            setValue(newValue: rec2.ADV_PAYM_NM, newKey: rec2.ADV_PAYM_SEQ, code: .ADVANCELEDGER)
        } else {
            self.isShowPlanned_money = false
         
            // insert value and validate on indexpath when user makes change in setting
            cellValue?.content.insert(rec,  at: selectPurposeIndex)
            cellValue?.content.insert(debit_date, at: selectPurposeIndex + 2) // insert after select advance ledger is done
        }
        self.checkingSubmitButton()
        self.tableView.reloadData()
    }
    
    // PURPOSE
    func sendUserListItem(userList: LIST_POP_UP_RESPONSE.USE_LIST) {
        setValue(newValue: userList.USAG_NM, newKey: userList.USE_USAG_CD, code: .PURPOSE)
        self.tableView.reloadData()
    }
}

extension SubmitReceiptVC: IndexImageDelete {
    func getIndexImage(index: [Int], typeOfImage: [Bool]) {
        
        let row = getIdx(cell_code: .ATTACHMEMNT)
        guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? MultiAttachmentCell else{
           return
        }
        
        for (idx,i) in index.enumerated() {
//          typeOfImage[idx] = true => type url, = false => type UIImage
            if typeOfImage[idx] {
                self.localDeleteREC1.append(self.imgREC[i])
                self.imgREC.remove(at: i) // locally remove image

                DispatchQueue.main.async {
                    cell.collectionView.reloadData()
                }
            }else {
                let index = i - self.imgREC.count // index of local image of section
                self.localImages.remove(at: index) // remove from arr
                
                DispatchQueue.main.async {
                    cell.collectionView.reloadData()
                }
            }
        }
        // Clear cache
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        self.checkingSubmitButton()
    }
}

extension SubmitReceiptVC: SendDelagate {
    func setData(expense: [Expense]?, index: Int) {
        
        self.isSelectedExpense = true
        self.expenseVM.cells = expense ?? []
        self.expenseVM.pay_way_cd = expense?[index].pay_way_cd ?? ""
        self.setValue(newValue: expense?[index].title ?? "", newKey:  expense?[index].code ?? "", code: .PAYMENT_METHOD, other: expense?[index].pay_way_cd ?? "")
        self.tableView.reloadRows(at: [IndexPath(row: self.getIdx(cell_code: .PAYMENT_METHOD), section: 0)], with: .none)
        self.checkingSubmitButton()

        // Save Payment code
        self.expenseVM.pay_way_cd = expense?[index].pay_way_cd
    }
}

// TODO: - Get Image from SelectedImageDelegate
//extension SubmitReceiptVC : SelectedImageDelegate {
//    func didFinishSelectionImage(imageData: UIImage) {
//        self.localImages.insert(imageData, at: 0)
//        self.tableView.reloadData()
//        self.checkingSubmitButton()
//    }
//}


extension SubmitReceiptVC : QLPreviewControllerDelegate, QLPreviewControllerDataSource  {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        previewItems.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        previewItems[index]
    }
    
    func quickLook(url: URL) {
        self.clearPreviewItems()
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.presentAlertController(with: error?.localizedDescription ?? "Failed to download the file!")
                }
                return
            }
            
            // Extract file extension from URL
            let fileExtension = url.pathExtension
            guard self.isValidFileExtension(fileExtension) else {
                DispatchQueue.main.async {
                    self.presentAlertController(with: "The data downloaded is not a valid file")
                }
                return
            }
            do {
                let suggestedFilename = response?.suggestedFilename ?? "quicklook"
                let fileExtension = url.pathExtension.isEmpty ? "pdf" : url.pathExtension  // Default to DOC if no extension
                let previewURL = FileManager.default.temporaryDirectory.appendingPathComponent(suggestedFilename)
                try data.write(to: previewURL, options: .atomic)
                let previewItem = PreviewItem(url: previewURL)
                self.previewItems.append(previewItem)

                DispatchQueue.main.async {
                    self.previewController.reloadData() // Ensure the data is reloaded
                    self.present(self.previewController , animated: true )
                }

            } catch {
                DispatchQueue.main.async {
                    self.presentAlertController(with: "Failed to save the file")
                }
                return
            }
        }.resume()
    }
    
    // MARK: - QLPreviewControllerDelegate

    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.clearPreviewItems()
        }
    }
    
    // clear file image index of row in array
    private func clearPreviewItems() {
        for item in previewItems {
            if let previewItemURL = item.previewItemURL {
                do {
                    try FileManager.default.removeItem(at: previewItemURL)
                    print("Temporary file deleted: \(previewItemURL)")
                } catch {
                    print("Failed to delete temporary file: \(error)")
                }
            }
        }
        previewItems.removeAll()
    }
    
    func presentAlertController(with message: String) {
        // present your alert controller from the main thread
        DispatchQueue.main.async {
            //                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

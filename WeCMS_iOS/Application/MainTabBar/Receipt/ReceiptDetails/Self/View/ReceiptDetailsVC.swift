//
//  ReceiptDetailsVC.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 11/1/21.
//

import UIKit
import Photos
import SkeletonView
import SDWebImage
import PDFKit
import QuickLook

enum AttachFileType {
    case PDF
    case DOCS
    case JPG
    case PPT
    case XLS
}

class ReceiptDetailsVC: UIViewController, ContextMenuDemo {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var labelReceiptTitle    : UILabel!
    @IBOutlet weak var buttonDeleteReceipt  : UIButton!
    @IBOutlet weak var buttonEditReceipt    : UIButton!
    @IBOutlet weak var tableView            : UITableView!
    @IBOutlet weak var cstHideEditBtn       : NSLayoutConstraint!
    @IBOutlet weak var viewlineBtwEditAndDeleteBtn: UIView!
    
    
    //MARK: - Variable
    var receiptList     : MREC_R006.RESPONSE.REC?
    var numberOfRows    : ReceiptDetailsRow.receiptRow?
    var receiptDetailVM = ReceiptDetailsVM()
    // new receiptDetail Response
    var receiptApproval : MREC_R009.RESPONSE?
    var isRequestApproval   : Bool = false
    var doc_id              : String = ""
    var usag_nm             : String = ""
    var settingVM       = SettingVM()
    var editReceiptVM   = SubmitReceiptVM()
    
    
    let previewController = QLPreviewController()
    let previewGenerator = QLThumbnailGenerator()
    let thumbnailSize = CGSize(width: 60, height: 90)
    let scale = UIScreen.main.scale
    
    var previewItems: [PreviewItem] = []
    
    // max image : for choosing from gallery
    private var selectedImages          : UIImage? //image choosen from Gallary
    private var imgREC                  : [MREC_R006.RESPONSE.REC.REC1] = []
    private var fileREC                 : [MREC_R006.RESPONSE.REC.REC1] = []
    private var imgREC009               : [MREC_R009.RESPONSE.REC1]     = []
    private var fileREC009              : [MREC_R009.RESPONSE.REC1]     = []
    private var localImages             : [UIImage] = [] //image choosen from Gallary
    private var currentIndexPathImage   : IndexPath?
    var isFromEditing                   : String = "Y"
    var attachFileType : AttachFileType?
    var isJPG   = true
    var receiptImage    : UIImageView?
    var strCurreny      : String = ""
    var pdfUrl          : URL?
    var pdfView         = PDFView()
    var isFromSelectExpense = false
    var isFromExpenseApproval = false
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        previewController.dataSource = self
        previewController.delegate = self
        
        //cannot edit if CEO purpose
        if let _ = receiptList?.ADV_PAYM_TRNS_SEQ {
            //            buttonEditReceipt.isHidden  = true
            //            cstHideEditBtn.constant     = -38 //-38 hide , 5 not hide
            //            viewlineBtwEditAndDeleteBtn.isHidden = true
            //            buttonEditReceipt.isEnabled                 = false
            //            buttonDeleteReceipt.isEnabled               = false
            //            viewlineBtwEditAndDeleteBtn.backgroundColor = UIColor(hexString: "#FFFFFF").withAlphaComponent(0.2)
        }
        self.checkProjectSite()
        if self.isRequestApproval {
            // New Flow => For data request from api MREC_R009
            self.buttonEditReceipt.isHidden             = true
            self.buttonDeleteReceipt.isHidden           = true
            self.viewlineBtwEditAndDeleteBtn.isHidden   = true
            self.requestApproval(doc_id)
            self.fetchingSetting()
            self.strCurreny = self.receiptApproval?.TRCO_TRSC_CCY_CD ?? ""
            
        }else  {
            // Old Flow => For data request from api MREC_R006
            self.buttonEditReceipt.isHidden             = false
            self.buttonDeleteReceipt.isHidden           = false
            self.viewlineBtwEditAndDeleteBtn.isHidden   = false
            self.fetchingSetting()
            self.setupTable()
            self.strCurreny = receiptList?.TRCO_TRSC_CCY_CD ?? ""
        }
        self.setLocalized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(self.isRequestApproval ? true : false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // Set status bar style into light content (white color)
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case NotifyKey.gotoPhotoPreviewVC.rawValue :
            let vc = segue.destination as! PhotoPreviewsVC
            vc.currentIndexImage = 0
            vc.imageUrlArray    = [["RCPT_IMG_URL" : getValue(from: .ATTACHMEMNT)]] as Array<AnyObject>
            vc.cc_setZoomTransition(originalView: receiptImage!) // Zoom trasition for receipt image
            vc.isBtnDeleteDisable = true
        default: break
            
        }
    }
    
    //MARK: - @IBAction
    @IBAction func didTapDismissAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapDeleteReceiptButtonAction(_ sender: UIButton) {
        
        buttonAnimation(btn: sender) {
            self.customAlert(type       : .YES_OR_NO_ALERT,
                             image      : "badge_warning",
                             title      : "delete".localized,
                             message    : "are_you_sure_you_want_to_delete_the_receipt".localized,
                             redTitle   : "delete".localized,
                             greyTitle  : "cancel".localized) { (isOk) in
                
                if isOk {
                    self.updateOrDeleteReceipt(CORR_TYPE: "D") // D: Delete Receipt
                }
            }
        }
    }
    
    @IBAction func didTapEditReceiptButtonAction(_ sender: UIButton) {
        buttonAnimation(btn: sender) {
            let vc = UIStoryboard(name: "SubmitReceiptSB", bundle: nil).instantiateViewController(withIdentifier: "SubmitReceiptVC") as! SubmitReceiptVC
            vc.isFromEditing    = "Y"
            vc.isManualInput = false
            vc.receiptList = self.receiptList
            vc.selected_TRCO_TRSC_CCY_CD = self.receiptList?.TRCO_TRSC_CCY_CD ?? "USD"
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated:true, completion:nil)
        }
    }
    
    // For request from api MREC_R009
    private func requestApproval(_ doc_id: String) {
        receiptDetailVM.fetchReceiptDetail(body: MREC_R009.REQUEST(DOC_ID: doc_id)) {  (result) in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.receiptApproval = data
                    self.setupRowApproval()
                    self.setupTable()
                    self.tableView.reloadData()
                }
            case .failure(let error):
                self.alertMessage(title: "notice".localized, msg: error.localizedDescription)
            }
        }
    }
    
    //Seanghay > check project site < 22:07:2024
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
    
    func getDocumentsDirectory() -> URL { // returns your application folder
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // For data response from api MREC_R009
    private func setupRowApproval() {
        
        
        var username: String = ""
        if let USER_NM = self.receiptApproval?.USER_NM {
            username = USER_NM.isEmpty ? (Shared.R002_DATA?.USER_NM ?? "") : USER_NM
        }
        else {
            username = Shared.R002_DATA?.USER_NM ?? ""
        }
        
        
        var amount = ""
        let rawAmount = self.receiptApproval?.TOTL_AMT ?? ""
        if (self.receiptApproval?.TRCO_TRSC_CCY_CD ?? "") == "VND" {
            amount = rawAmount.components(separatedBy: ".").first ?? "0"
        } else {
            amount = rawAmount
        }
        
        let currency    = "\(self.receiptApproval?.TRCO_TRSC_CCY_CD ?? "") \(customFormatCurrency(CCY_CD: self.receiptApproval?.TRCO_TRSC_CCY_CD ?? "", amount: amount))"
        
        var img_url = ""
        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
        let imageURL        = self.receiptApproval?.REC1.first?.FILE_URL ?? ""
        let split_url       = imageURL.components(separatedBy: "?")
        img_url             = "\(split_url.first ?? "")?token=\(authorization)&\(split_url.last ?? "")"
        
        let taxAmount = calculateTaxAmount(amount: self.receiptApproval?.TOTL_AMT ?? "0", rate: self.receiptApproval?.TAX_RATE ?? "")
        //        let formatTaxtAmt = formatCurrency(type: receiptList?.TRCO_TRSC_CCY_CD ?? "", amount: taxAmount)
        numberOfRows = ReceiptDetailsRow.receiptRow(content: [
            ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.HEADER.rawValue,             value: currency),
            ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.WITH_HOLDING_TAX.rawValue,   value: (self.receiptApproval?.WHT_NM ?? "")),
            ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.TAX_AMOUNT.rawValue,         value: taxAmount),
            ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PURPOSE.rawValue,            value: self.isFromExpenseApproval ? self.usag_nm : self.receiptApproval?.USAG_NM ?? ""),
            ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.USER.rawValue,               value: username) ,
            ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.DESCRIPTION.rawValue,        value: self.receiptApproval?.CONT),
            ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.ATTACHMEMNT.rawValue,        value: img_url)
        ])
        
        for (_,content) in (numberOfRows?.content ?? []).enumerated() {
            if (content.value == "" || content.value?.isEmpty ?? true || content.value == "0" || content.value == "0.00") {
                numberOfRows?.content.removeAll(where: {$0.code == content.code})
            }
        }
        
        // TRCO_TYPE
        self.supplier(type: TypeOfSupplier(rawValue: self.receiptApproval?.TRCO_TYPE ?? "1") ?? .TaxablePerson)
            
        var purposeIndex = 1
        
        if numberOfRows?.content.contains(where: { $0.code == ReceiptRow.TAX_AMOUNT.rawValue }) ?? false {
            purposeIndex = self.getIdx(cell_code: .TAX_AMOUNT) + 1
        }
        
        if numberOfRows?.content.contains(where: { $0.code == ReceiptRow.PURPOSE.rawValue }) ?? false {
            purposeIndex = self.getIdx(cell_code: .PURPOSE) + 1
        }
        
        //        let purposeIndex    = (numberOfRows?.content.contains(where: { $0.code == ReceiptRow.PURPOSE.rawValue }) ?? false) ? self.getIdx(cell_code: .PURPOSE) + 1 : 1
        
        let chequeMessage   = "OOO_cheque_number_is_OOO".localized
        let message         = "paid_with_OOO".localized
        
        if let PRJT_NM = self.receiptList?.PRJT_NM {
            let project_site    = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PROJECT_SITE.rawValue, value: PRJT_NM)
            numberOfRows?.content.insert(project_site, at: purposeIndex)
        }
        
        // Q For Paid with Cheque
        if self.receiptApproval?.PAY_WAY_CD == "Q" {
            let paymentMethod   = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PAYMENT_METHOD.rawValue, value:  String(format: message, "cheque".localized))
            let bankValue       = String(format: chequeMessage, "\(self.receiptApproval?.BANK_NM ?? "")", "\(self.receiptApproval?.CHEQ_NUM ?? "")")
            let bank            = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.BANK.rawValue, value: bankValue)
            let debit_date      = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.DEBITDATE.rawValue, value: self.receiptApproval?.TRSC_DT2)
            numberOfRows?.content.insert(debit_date, at: purposeIndex)
            numberOfRows?.content.insert(bank, at: purposeIndex)
            numberOfRows?.content.insert(paymentMethod, at: purposeIndex)
        }
        
        // A For Paid with Bank Account
        if self.receiptApproval?.PAY_WAY_CD == "A" {
            let paymentMethod       = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PAYMENT_METHOD.rawValue, value: String(format: message, "bank_transfer".localized))
            var amountUSD           = ""
            var payWayAmount        = ""
            
            let amountVND   = (self.receiptApproval?.PAY_WAY_AMT ?? "").vndCurrency.components(separatedBy: ",").first ?? ""
            amountUSD       = (self.receiptApproval?.PAY_WAY_AMT ?? "").vndCurrency
            payWayAmount    = "\(self.receiptApproval?.TRCO_TRSC_CCY_CD == "USD" ? "$\(amountUSD)" : "\(amountVND)₫")"
            
            
//            let payWayAmount        = "\(self.receiptList?.TRCO_TRSC_CCY_CD == "USD" ? "$\(amountUSD)" : (self.receiptList?.TRCO_TRSC_CCY_CD == "KHR" ? "R\(amountKHR)" : "\(amountVND)₫"))"
            let message             = "OOO_OOO_match".localized
            let importTransValue    = String(format: message, "\(formatteDate(date: self.receiptApproval?.TRSC_DT2 ?? ""))", "\(payWayAmount)")
            
//            let importTransValue    = "\(formatteDate(date: self.receiptList?.TRSC_DT2 ?? "")) \(self.receiptList?.RCPT_TYPE ?? "")\(usdOrKhr) \("match".localized)"
            let importTransaction   = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.IMPORT_TRANSACTION.rawValue, value: importTransValue)
            numberOfRows?.content.insert(importTransaction, at: purposeIndex)
            numberOfRows?.content.insert(paymentMethod, at: purposeIndex)
        }
        
        // C For Paid with Cash
        if self.receiptApproval?.PAY_WAY_CD == "C" {
            let paymentMethod   = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PAYMENT_METHOD.rawValue, value: String(format: message, "cash".localized))
            let debit_date      = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.DEBITDATE.rawValue, value: self.receiptApproval?.TRSC_DT2)
            numberOfRows?.content.insert(debit_date, at: purposeIndex)
            numberOfRows?.content.insert(paymentMethod, at: purposeIndex)
        }
        // P For Paid with Advanced Ledger
        if self.receiptApproval?.PAY_WAY_CD == "P" {
            let paymentMethod   = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PAYMENT_METHOD.rawValue, value: String(format: message, "advance".localized))
            let advancedLegder  = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.ADVANCELEDGER.rawValue, value: self.receiptApproval?.ADV_PAYM_NM)
            let debit_date      = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.DEBITDATE.rawValue, value: self.receiptApproval?.TRSC_DT2)
            numberOfRows?.content.insert(debit_date, at: purposeIndex)
            numberOfRows?.content.insert(advancedLegder, at: purposeIndex)
            numberOfRows?.content.insert(paymentMethod, at: purposeIndex)
        }
        
//            numberOfRows?.content.removeAll(where: {
//                $0.code != ReceiptRow.HEADER.rawValue
//                && $0.code != ReceiptRow.ATTACHMEMNT.rawValue
//                && $0.code != ReceiptRow.RECEIPTNO.rawValue
//                && $0.code != ReceiptRow.PURPOSE.rawValue
//                && $0.code != ReceiptRow.DESCRIPTION.rawValue
//                && $0.code != ReceiptRow.USER.rawValue
//                && $0.code != ReceiptRow.PAYMENT_METHOD.rawValue
//                && $0.code != ReceiptRow.IMPORT_TRANSACTION.rawValue
//                && $0.code != ReceiptRow.BANK.rawValue
//                && $0.code != ReceiptRow.ADVANCELEDGER.rawValue
//                && $0.code != ReceiptRow.DEBITDATE.rawValue
//            })
//        }
        
        if (self.receiptApproval?.PAY_WAY_CD?.isNotEmpty ?? false) {
            numberOfRows?.content.removeAll(where: { $0.code == ReceiptRow.DEBITDATE.rawValue
                && $0.code == ReceiptRow.IMPORT_TRANSACTION.rawValue
                && $0.code == ReceiptRow.BANK.rawValue
            })
        }

        
        // Vietnam
        if self.editReceiptVM.responseR012?.ENV_SET_CONT != "Y" { //Seanghay > Check Project Site API <
            removeIndexOf(key: .PROJECT_SITE)
        }
        
    }
    
    // For data response from api MREC_R006
    private func setupRow() {
        
        
        var username: String = ""
        if let USER_NM = self.receiptList?.USER_NM {
            username = USER_NM.isEmpty ? (Shared.R002_DATA?.USER_NM ?? "") : USER_NM
        }
        else {
            username = Shared.R002_DATA?.USER_NM ?? ""
        }
        
        let currency    = "\(self.receiptList?.TRCO_TRSC_CCY_CD ?? "") \(customFormatCurrency(CCY_CD: self.receiptList?.TRCO_TRSC_CCY_CD ?? "", amount: (self.receiptList?.TOTL_AMT ?? "")))"
        
        var img_url = ""
        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
        let imageURL        = receiptList?.REC1?.first?.FILE_URL ?? ""
        let split_url       = imageURL.components(separatedBy: "?")
        img_url             = "\(split_url.first ?? "")?token=\(authorization)&\(split_url.last ?? "")"
        
        let usag_nm = self.receiptList?.USAG_NM?.isEmpty ?? false ? ("None") : self.receiptList?.USAG_NM ?? ""
        let taxAmount = calculateTaxAmount(amount: receiptList?.TOTL_AMT ?? "0", rate: receiptList?.TAX_RATE ?? "")
          
        //        let formatTaxtAmt = formatCurrency(type: receiptList?.TRCO_TRSC_CCY_CD ?? "", amount: taxAmount)
        numberOfRows = ReceiptDetailsRow.receiptRow(content: [
            ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.HEADER.rawValue,             value: currency),
            ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.WITH_HOLDING_TAX.rawValue,   value: (self.receiptList?.WHT_NM ?? "")),
            ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.TAX_AMOUNT.rawValue,         value: taxAmount),
            ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PURPOSE.rawValue,            value: usag_nm),
            ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.USER.rawValue,               value: username) ,
            ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.DESCRIPTION.rawValue,        value: self.receiptList?.CONT),
            ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.ATTACHMEMNT.rawValue,        value: img_url),
        ])
        
        for (_,content) in (numberOfRows?.content ?? []).enumerated() {
            if (content.value == "" || content.value?.isEmpty ?? true || content.value == "0" || content.value == "0.00") {
                numberOfRows?.content.removeAll(where: {$0.code == content.code})
            }
        }
        
        // TRCO_TYPE
        self.supplier(type: TypeOfSupplier(rawValue: self.receiptList?.TRCO_TYPE ?? "1") ?? .TaxablePerson)
        
//        /**
//         Check display cell based on Input Item from Settings
//         - "Y" : Open ( false ),
//         - "N" : Close ( true )
//         */
//        if !(self.settingVM.settingsResponse?.INPUT_FIELD_SET_YN ?? false) {
//            numberOfRows?.content.removeAll(where: { $0.code != ReceiptRow.HEADER.rawValue
//                && $0.code != ReceiptRow.ATTACHMEMNT.rawValue
//                && $0.code != ReceiptRow.RECEIPTNO.rawValue
//                && $0.code != ReceiptRow.DESCRIPTION.rawValue
//                && $0.code != ReceiptRow.TEL.rawValue
//                && $0.code != ReceiptRow.EMAIL.rawValue
//                && $0.code != ReceiptRow.ADDRESS.rawValue
//                && $0.code != ReceiptRow.WITH_HOLDING_TAX.rawValue
//                && $0.code != ReceiptRow.TAX_AMOUNT.rawValue
//            })
//        }
//        else {
//            if !(self.settingVM.settingsResponse?.TRSC_AMT_YN ?? false) {
//                removeIndexOf(key: .AMOUNT)
//            }
//            if !(self.settingVM.settingsResponse?.TRSC_DT_YN ?? false) {
//                removeIndexOf(key: .DATE)
//            }
//            if !(self.settingVM.settingsResponse?.USAG_CD_YN ?? false) {
//                removeIndexOf(key: .PURPOSE)
//            }
//            if !(self.settingVM.settingsResponse?.USER_NM_YN ?? false) {
//                removeIndexOf(key: .USER)
//            }
//        }
        
//        if (self.receiptList?.PAY_WAY_CD?.isNotEmpty ?? false) {
//            numberOfRows?.content.removeAll(where: { $0.code == ReceiptRow.DEBITDATE.rawValue
//                && $0.code == ReceiptRow.IMPORT_TRANSACTION.rawValue
//                && $0.code == ReceiptRow.BANK.rawValue
//            })
//        }
        
        var purposeIndex = 1
        
        if numberOfRows?.content.contains(where: { $0.code == ReceiptRow.TAX_AMOUNT.rawValue }) ?? false {
            purposeIndex = self.getIdx(cell_code: .TAX_AMOUNT) + 1
        }
        
        if numberOfRows?.content.contains(where: { $0.code == ReceiptRow.PURPOSE.rawValue }) ?? false {
            purposeIndex = self.getIdx(cell_code: .PURPOSE) + 1
        }
        
        //        let purposeIndex    = (numberOfRows?.content.contains(where: { $0.code == ReceiptRow.PURPOSE.rawValue }) ?? false) ? self.getIdx(cell_code: .PURPOSE) + 1 : 1
        
        let chequeMessage   = "OOO_cheque_number_is_OOO".localized
        let message         = "paid_with_OOO".localized
        
        if let PRJT_NM = self.receiptList?.PRJT_NM {
            let project_site    = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PROJECT_SITE.rawValue, value: PRJT_NM)
            numberOfRows?.content.insert(project_site, at: purposeIndex)
        }
        
        // Q For Paid with Cheque
        if self.receiptList?.PAY_WAY_CD == "Q" {
            let paymentMethod   = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PAYMENT_METHOD.rawValue, value:  String(format: message, "cheque".localized))
            let bankValue       = String(format: chequeMessage, "\(self.receiptList?.BANK_NM ?? "")", "\(self.receiptList?.CHEQ_NUM ?? "")")
            let bank            = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.BANK.rawValue, value: bankValue)
            let debit_date      = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.DEBITDATE.rawValue, value: self.receiptList?.TRSC_DT2)
            //            let project_site        = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PROJECT_SITE.rawValue, value: self.receiptList?.PRJT_NO ?? "None")
            
            numberOfRows?.content.insert(debit_date, at: purposeIndex)
            numberOfRows?.content.insert(bank, at: purposeIndex)
            //            numberOfRows?.content.insert(project_site, at: purposeIndex)
            numberOfRows?.content.insert(paymentMethod, at: purposeIndex)
        }
        
        // Empty For None paid
        if self.receiptList?.PAY_WAY_CD == "" || self.receiptList?.PAY_WAY_CD == nil {
            let paymentMethod   = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PAYMENT_METHOD.rawValue, value: "none".localized)
            numberOfRows?.content.insert(paymentMethod, at: purposeIndex)
        }
        
        // A For Paid with Bank Account
        if self.receiptList?.PAY_WAY_CD == "A" {
            let paymentMethod       = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PAYMENT_METHOD.rawValue, value: String(format: message, "bank_transfer".localized))
            var amountUSD           = ""
            var payWayAmount        = ""
            
            let amountVND   = (self.receiptList?.PAY_WAY_AMT ?? "").vndCurrency.components(separatedBy: ",").first ?? ""
            amountUSD       = (self.receiptList?.PAY_WAY_AMT ?? "").vndCurrency
            payWayAmount    = "\(self.receiptList?.TRCO_TRSC_CCY_CD == "USD" ? "$\(amountUSD)" : "\(amountVND)₫")"
            
            
            //            let payWayAmount        = "\(self.receiptList?.TRCO_TRSC_CCY_CD == "USD" ? "$\(amountUSD)" : (self.receiptList?.TRCO_TRSC_CCY_CD == "KHR" ? "R\(amountKHR)" : "\(amountVND)₫"))"
            let message             = "OOO_OOO_match".localized
            let importTransValue    = String(format: message, "\(formatteDate(date: self.receiptList?.TRSC_DT2 ?? ""))", "\(payWayAmount)")
            
            //            let importTransValue    = "\(formatteDate(date: self.receiptList?.TRSC_DT2 ?? "")) \(self.receiptList?.RCPT_TYPE ?? "")\(usdOrKhr) \("match".localized)"
            let importTransaction   = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.IMPORT_TRANSACTION.rawValue, value: importTransValue)
            //            let project_site        = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PROJECT_SITE.rawValue, value: self.receiptList?.PRJT_NO ?? "None")
            
            numberOfRows?.content.insert(importTransaction, at: purposeIndex)
            //            numberOfRows?.content.insert(project_site, at: purposeIndex)
            numberOfRows?.content.insert(paymentMethod, at: purposeIndex)
        }
        
        // C For Paid with Cash
        if self.receiptList?.PAY_WAY_CD == "C" {
            let paymentMethod   = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PAYMENT_METHOD.rawValue, value: String(format: message, "cash".localized))
            let debit_date      = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.DEBITDATE.rawValue, value: self.receiptList?.TRSC_DT2)
            //            let project_site        = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PROJECT_SITE.rawValue, value: self.receiptList?.PRJT_NO ?? "None")
            
            numberOfRows?.content.insert(debit_date, at: purposeIndex)
            //            numberOfRows?.content.insert(project_site, at: purposeIndex)
            numberOfRows?.content.insert(paymentMethod, at: purposeIndex)
            
        }
        
        // P For Paid with Advanced Ledger
        if self.receiptList?.PAY_WAY_CD == "P" {
            let paymentMethod   = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PAYMENT_METHOD.rawValue, value: String(format: message, "advance".localized))
            let advancedLegder  = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.ADVANCELEDGER.rawValue, value: self.receiptList?.ADV_PAYM_NM)
            let debit_date      = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.DEBITDATE.rawValue, value: self.receiptList?.TRSC_DT2)
            //            let project_site    = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.PROJECT_SITE.rawValue, value: self.receiptList?.PRJT_NO ?? "None")
            numberOfRows?.content.insert(debit_date, at: purposeIndex)
            numberOfRows?.content.insert(advancedLegder, at: purposeIndex)
            //            numberOfRows?.content.insert(project_site, at: purposeIndex)
            numberOfRows?.content.insert(paymentMethod, at: purposeIndex)
        }
        
//        /**
//         Check display cell based on Input Item from Settings
//         - "Y" : Open ( false ),
//         - "N" : Close ( true )
//         */
//        if !(self.settingVM.settingsResponse?.INPUT_FIELD_SET_YN ?? false) {
//            numberOfRows?.content.removeAll(where: { $0.code != ReceiptRow.HEADER.rawValue
//                && $0.code != ReceiptRow.ATTACHMEMNT.rawValue
//                && $0.code != ReceiptRow.RECEIPTNO.rawValue
//                && $0.code != ReceiptRow.DESCRIPTION.rawValue
//                && $0.code != ReceiptRow.TEL.rawValue
//                && $0.code != ReceiptRow.EMAIL.rawValue
//                && $0.code != ReceiptRow.ADDRESS.rawValue
//                && $0.code != ReceiptRow.WITH_HOLDING_TAX.rawValue
//                && $0.code != ReceiptRow.TAX_AMOUNT.rawValue
//            })
//        }
//        else {
//            if !(self.settingVM.settingsResponse?.TRSC_AMT_YN ?? false) {
//                removeIndexOf(key: .AMOUNT)
//            }
//            if !(self.settingVM.settingsResponse?.TRSC_DT_YN ?? false) {
//                removeIndexOf(key: .DATE)
//            }
//            if !(self.settingVM.settingsResponse?.USAG_CD_YN ?? false) {
//                removeIndexOf(key: .PURPOSE)
//            }
//            if !(self.settingVM.settingsResponse?.USER_NM_YN ?? false) {
//                removeIndexOf(key: .USER)
//            }
//            if !(self.settingVM.settingsResponse?.PRJT_NO_YN ?? false) {
//                removeIndexOf(key: .PROJECT_SITE)
//            }
//        }
        
        if (self.receiptList?.PAY_WAY_CD?.isNotEmpty ?? false) {
            numberOfRows?.content.removeAll(where: { $0.code == ReceiptRow.DEBITDATE.rawValue
                && $0.code == ReceiptRow.IMPORT_TRANSACTION.rawValue
                && $0.code == ReceiptRow.BANK.rawValue
            })
        }
        
        // Vietname
        if self.editReceiptVM.responseR012?.ENV_SET_CONT != "Y" { //Seanghay > Check Project Site API <
            removeIndexOf(key: .PROJECT_SITE)
        }
        
        
        
        
        //            numberOfRows?.content.removeAll(where: {
        //                   $0.code != ReceiptRow.HEADER.rawValue
        //                && $0.code != ReceiptRow.ATTACHMEMNT.rawValue
        //                && $0.code != ReceiptRow.RECEIPTNO.rawValue
        //                && $0.code != ReceiptRow.PURPOSE.rawValue
        //                && $0.code != ReceiptRow.DESCRIPTION.rawValue
        //                && $0.code != ReceiptRow.USER.rawValue
        //                && $0.code != ReceiptRow.PAYMENT_METHOD.rawValue
        //                && $0.code != ReceiptRow.IMPORT_TRANSACTION.rawValue
        //                && $0.code != ReceiptRow.BANK.rawValue
        //                && $0.code != ReceiptRow.ADVANCELEDGER.rawValue
        //                && $0.code != ReceiptRow.DEBITDATE.rawValue
        //            })
        //        }
        
        
        //        let purp2 = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.ADVANCELEDGER.rawValue, value: self.receiptList?.ADV_PAYM_NM)
        //        let debit_date = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.DEBITDATE.rawValue, value: self.receiptList?.TRSC_DT)
        //
        //        if (self.settingVM.settingsResponse?.USAG_CD_YN ?? false) { // If purpose was closed in setting, advance legder and Debit date are hidden too.
        //            if let _ = self.receiptList?.ADV_PAYM_TRNS_SEQ, let _ = self.receiptList?.ADV_PAYM_NM {
        //                (self.settingVM.settingsResponse?.USAG_CD_YN ?? false) ? numberOfRows?.content.insert(purp2, at: 1) : ()
        //
        //                // What if in receipt detail dispay date of Advance Ledger, display here
        //                (self.settingVM.settingsResponse?.USAG_CD_YN ?? false) ? numberOfRows?.content.insert( debit_date, at: 3) : ()
        //                self.tableView.reloadData()
        //            }
        //            else {
        //                return
        //            }
        //        }
    }
    
    func calculateTaxAmount(amount : String,rate : String) -> String {
        let amountIn = Double(amount) ?? 0.0
        let taxRate = Double(rate) ?? 0.0
        let taxCalMoney = Double(( amountIn * (taxRate / 100.0)))
        return String(format: "%.2f", taxCalMoney)
    }
    
    private func removeIndexOf(key: ReceiptRow) {
        numberOfRows?.content.removeAll(where: { $0.code == key.rawValue})
    }
    
    // retrieve value base on code
    private func getValue(from code: ReceiptRow) -> [String] {
        var val = [String]()
        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
        
        for (_, value) in (numberOfRows?.content ?? []).enumerated() {
            if value.code == code.rawValue {
                if isRequestApproval{
                    if receiptApproval?.REC1.count == 0 {
                        val.append("noimage")
                    }else{
                        if let image = receiptApproval?.REC1{
                            for imgUrl in image.filter( {($0.ORG_FILE_NM ?? "").contains(".jpg")}) {
                                let split_url       = imgUrl.FILE_URL?.components(separatedBy: "?")
                                let img_url         = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")"
                                val.append(img_url)
                            }
                        }
                    }
                    
                }else{
                    if receiptList?.REC1?.count == 0 {
                        val.append("noimage")
                    }else{
                        if let image = receiptList?.REC1{
                            for imgUrl in image.filter( {($0.ORG_FILE_NM ?? "").contains(".jpg")}) {
                                let split_url       = imgUrl.FILE_URL?.components(separatedBy: "?")
                                let img_url         = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")"
                                val.append(img_url)
                            }
                        }
                    }
                }
            }
        }
        
        return val
    }
    
    private func getIdx(cell_code: ReceiptRow) -> Int {
        var idx: Int = -1
        if let content = numberOfRows?.content {
            for (index, value) in content.enumerated() {
                if value.code == cell_code.rawValue {
                    idx = index
                    break
                }
            }
        }
        return idx
    }
    
    private func alertMessage(title: String = "", msg: String, _ completion: @escaping () -> () = {}) {
        self.customAlert(type       : .CONFIRM_ALERT,
                         image      : "badge_failed",
                         title      : title,
                         message    : msg,
                         redTitle   : "",
                         greyTitle  : "ok".localized) { (_) in
            completion()
        }
    }
    
    // For files response from MREC_R009
    private func setupTableApproval() {
        
        // Acceptable File extension: .pdf, .ppt, .xls, .doc, .pptx, .key
        self.fileREC009 = (receiptApproval?.REC1 ?? []).filter({ obj1 in
            let fileExtension = obj1.ORG_FILE_NM?.components(separatedBy: ".").last?.lowercased() ?? ""
            
            return fileExtension.contains("pdf") || fileExtension.contains("ppt") || fileExtension.contains("xls") || fileExtension.contains("doc") || fileExtension.contains("pptx") || fileExtension.contains("key")
        })
        
        self.imgREC009 = (receiptApproval?.REC1 ?? []).filter({ obj1 in
            let fileExtension = obj1.ORG_FILE_NM?.components(separatedBy: ".").last?.lowercased() ?? ""
            
            return !fileExtension.contains("pdf") && !fileExtension.contains("ppt") && !fileExtension.contains("xls") && !fileExtension.contains("doc") && !fileExtension.contains("pptx") && !fileExtension.contains("key")
        })
        self.tableView.tableFooterView  = UIView()
    }
    
    // For data response from api MREC_R006
    private func setupTable() {
        
        // Acceptable File extension: .pdf, .ppt, .xls, .doc
        self.fileREC = (receiptList?.REC1 ?? []).filter({ obj1 in
            let fileExtension = obj1.ORG_FILE_NM?.components(separatedBy: ".").last?.lowercased() ?? ""
            
            return fileExtension.contains("pdf") || fileExtension.contains("ppt") || fileExtension.contains("xls") || fileExtension.contains("doc")
            
        })
        
        self.imgREC = (receiptList?.REC1 ?? []).filter({ obj1 in
            let fileExtension = obj1.ORG_FILE_NM?.components(separatedBy: ".").last?.lowercased() ?? ""
            
            return !fileExtension.contains("pdf") && !fileExtension.contains("ppt") && !fileExtension.contains("xls") && !fileExtension.contains("doc")
            
        })
        
        self.tableView.tableFooterView  = UIView()
    }
    
    private func setLocalized() {
        self.labelReceiptTitle.text = "receipt_details".localized
        self.labelReceiptTitle.getlocalizedFont()
        
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
    
    // get idx for insert email, tel, address if Type of Supplier is Non-Taxable Person or Oversea Company
    private func validatedWithSettingIndex() -> Int {
        var index : Int = -1
        if let content = numberOfRows?.content {
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
    
    private func supplier(type: TypeOfSupplier) {
        switch type {
        case .TaxablePerson:
            print("TaxablePerson")
        case .NonTaxablePerson:
            
            // old format
            //            if let content = numberOfRows?.content {
            //                if !(content.contains(where: { $0.code == ReceiptRow.TEL.rawValue })) {
            //                    let split_tel = (self.receiptList?.TRCO_RPRS_TLPH ?? "").components(separatedBy: "-")
            //                    var tel : String = ""
            //                    if (split_tel.last ?? "").prefix(1) == "0" {
            //                        tel = String((split_tel.last ?? "").dropFirst())
            //                    }
            //                    else {
            //                        tel = split_tel.last ?? ""
            //                    }
            //
            //                    let phone = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.TEL.rawValue, value: tel)
            //                    let row = self.validatedWithSettingIndex()
            //                    numberOfRows?.content.insert(phone, at: row)
            //                }
            //            }
            
            if let content = numberOfRows?.content {
                if !(content.contains(where: { $0.code == ReceiptRow.TEL.rawValue })) {
                    
                    // To check if key empty or less than 5 digit
                    let TRCO_RPRS_TLPH   = receiptList?.TRCO_RPRS_TLPH ?? ""
                    
                    let isNil             = TRCO_RPRS_TLPH == "" || TRCO_RPRS_TLPH.count < 5
                    
                    let headerCodePrefix  = isNil ? "" : TRCO_RPRS_TLPH.prefix(5)
                    
                    // to get header country code
                    //                    let headerCode        = headerCodePrefix.replacingOccurrences(of: "0", with: "")
                    
                    let phoneNumber       = isNil ? "" : TRCO_RPRS_TLPH[5...] // "+\(headerCodePrefix)"
                    
                    let tel               = isNil ? "" : "0\(phoneNumber)"
                    
                    let phone = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.TEL.rawValue, value: tel)
                    let row = self.validatedWithSettingIndex()
                    numberOfRows?.content.insert(phone, at: row)
                }
            }
            
        case .OverseaCompany:
            if let content = numberOfRows?.content {
                if !(content.contains(where: { $0.code == ReceiptRow.TEL.rawValue })) {
                    
                    // old format
                    //                    let split_tel = (self.receiptList?.TRCO_RPRS_TLPH ?? "").components(separatedBy: "-")
                    //                    var tel : String = ""
                    //                    if (split_tel.last ?? "").prefix(1) == "0" {
                    //                        tel = String((split_tel.last ?? "").dropFirst())
                    //                    }
                    //                    else {
                    //                        tel = split_tel.last ?? ""
                    //                    }
                    
                    var TRCO_RPRS_TLPH = ""
                    if isRequestApproval {
                        TRCO_RPRS_TLPH   = receiptApproval?.TRCO_RPRS_TLPH ?? ""
                    } else {
                        TRCO_RPRS_TLPH   = receiptList?.TRCO_RPRS_TLPH ?? ""
                    }
                    
                    // To check if key empty or less than 5 digit
                    let isNil             = TRCO_RPRS_TLPH == "" || TRCO_RPRS_TLPH.count < 5
                    
                    let headerCodePrefix  = isNil ? "" : (TRCO_RPRS_TLPH.prefix(5))
                    
                    // to get header country code
                    //                    let headerCode        = headerCodePrefix.replacingOccurrences(of: "0", with: "")
                    
                    let phoneNumber       = isNil ? "" : TRCO_RPRS_TLPH[5...] //"+\(headerCodePrefix)"
                    
                    let tel               = isNil ? "" : "0\(phoneNumber)"
                    
                    let phone = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.TEL.rawValue, value: tel)
                    let row = self.validatedWithSettingIndex()
                    numberOfRows?.content.insert(phone, at: row)
                }
                if !(content.contains(where: { $0.code == ReceiptRow.EMAIL.rawValue })) {
                    
                    var email = ReceiptDetailsRow.receiptRow.contents(code: "", value: "")
                    if isRequestApproval {
                        email = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.EMAIL.rawValue, value: receiptApproval?.EML) //new
                    } else {
                        email = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.EMAIL.rawValue, value: receiptList?.EML) //old
                    }
                    
                    let row = self.validatedWithSettingIndex()
                    numberOfRows?.content.insert(email, at: row)
                }
                if !(content.contains(where: { $0.code == ReceiptRow.ADDRESS.rawValue })) {
                    var add : [String] = []
                    if isRequestApproval {
                        add = [receiptApproval?.TRCO_BSUN_POST_ADRS ?? "", receiptApproval?.TRCO_BSUN_DTL_ADRS ?? "",receiptApproval?.TRCO_BSUN_CITY ?? "", receiptApproval?.TRCO_BSUN_ST ?? ""]
                    } else {
                        add = [receiptList?.TRCO_BSUN_POST_ADRS ?? "", receiptList?.TRCO_BSUN_DTL_ADRS ?? "",receiptList?.TRCO_BSUN_CITY ?? "", receiptList?.TRCO_BSUN_ST ?? ""]
                    }
                    
                    let new_address = add.filter({ !($0.isEmpty) }).joined(separator: ", ")
                    let address = ReceiptDetailsRow.receiptRow.contents(code: ReceiptRow.ADDRESS.rawValue, value: new_address)
                    let row = self.validatedWithSettingIndex()
                    numberOfRows?.content.insert(address, at: row)
                }
            }
        }
    }
    
    // Fetching API
    private func updateOrDeleteReceipt(CORR_TYPE: String) {
        if self.receiptList?.TOTL_AMT == "0" {  // if The total amount equal "0" => The total amount is empty
            self.receiptList?.TOTL_AMT = ""
        }
        
        var REC1 : [MREC_C004.REQUEST.REC1] = []
        
        if let rec1 = self.receiptList?.REC1 {
            for value in rec1 {
                REC1.append(MREC_C004.REQUEST.REC1(FILE_ID: value.FILE_ID))
            }
        }
        
        var REC2 : [MREC_C004.REQUEST.REC2] = []
        
        if let img = receiptImage?.image {
            if let base64 = convertToBase64(img) {
                let formatter           = DateFormatter()
                formatter.dateFormat    = "yyyMMddHHmm"
                REC2.append(MREC_C004.REQUEST.REC2(FILE_NM : "\(formatter.string(from: Date())).jpg", FILE_DATA: base64))
            }
        }
        
        
        self.receiptDetailVM.updateOrDelete(body: MREC_C004.REQUEST(
//            CORR_TYPE           : CORR_TYPE,
//            DOC_ID              : self.receiptList?.DOC_ID ?? "",
            CORR_TYPE           : CORR_TYPE,
            DOC_ID              : self.receiptList?.DOC_ID ?? "",
            TRCO_CMNM           : self.receiptList?.TRCO_CMNM ?? "",
            USE_DT              : self.receiptList?.USE_DT ?? "",
            TRCO_TRSC_CCY_CD    : self.receiptList?.TRCO_TRSC_CCY_CD ?? "",
            TOTL_AMT            : self.receiptList?.TOTL_AMT ?? "",
            BUSA_USAG_CD        : self.receiptList?.BUSA_USAG_CD ?? "",
            CONT                : self.receiptList?.CONT ?? "",
            USER_NM             : self.receiptList?.USAG_NM ?? "",
            REG_DT              : self.receiptList?.REG_DT ?? "",
            SEQ_NO              : self.receiptList?.SEQ_NO ?? "",
            FILE_URL            : self.receiptList?.SAVE_FILE_NM ?? "",
            ADV_PAYM_TRNS_SEQ   : self.receiptList?.ADV_PAYM_TRNS_SEQ ?? "",
            ADV_PAYM_SEQ        : self.receiptList?.ADV_PAYM_SEQ ?? "",
            HAND_DOC_ID         : self.receiptList?.HAND_DOC_ID ?? "",
            TRCO_TYPE           : self.receiptList?.TRCO_TYPE ?? "",
            TRCO_TAX_ID         : self.receiptList?.TRCO_TAX_ID ?? "",
            APLY_EXCH_RATE      : self.receiptList?.APLY_EXCH_RATE ?? "",
            TRCO_RPRS_TLPH      : self.receiptList?.TRCO_RPRS_TLPH ?? "+000",
            GST_NO              : self.receiptList?.GST_NO ?? "",
            EML                 : self.receiptList?.EML ?? "",
            TRCO_BSUN_POST_ADRS : self.receiptList?.TRCO_BSUN_POST_ADRS ?? "",
            TRCO_BSUN_DTL_ADRS  : self.receiptList?.TRCO_BSUN_DTL_ADRS ?? "",
            TRCO_BSUN_ST        : self.receiptList?.TRCO_BSUN_ST ?? "",
            TRCO_BSUN_CITY      : self.receiptList?.TRCO_BSUN_CITY ?? "",
            TRCO_KEY            : self.receiptList?.TRCO_KEY ?? "",
            WHT_CD              : self.receiptList?.WHT_CD ?? "" ,
            PAY_WAY_CD          : self.receiptList?.PAY_WAY_CD ?? "",
            PAY_WAY_AMT         : self.receiptList?.PAY_WAY_AMT ?? "",
            BANK_CD             : self.receiptList?.BANK_CD ?? "",
            ACCT_NO             : self.receiptList?.ACCT_NO ?? "",
            REF_NO              : self.receiptList?.REF_NO ?? "",
            TRSC_DT2            : self.receiptList?.TRSC_DT2 ?? "",
            EINV_CON_DOC_ID     : self.receiptList?.EINV_CON_DOC_ID ?? "",
            PRJT_NO             : self.receiptList?.PRJT_NO ?? "",
            REC1                : REC1,
            REC2                : REC2)) { (result) in
                
                switch result  {
                case .success(_):
                    self.dismiss(animated: true) {
                        MyNotify.send(name: .reloadAfterUpdateOrDeleteOrSubmit, object: ["CORR_TYPE": "D"] as AnyObject)
                    }
                case .failure(let error):
                    self.alertMessage(title: "notice".localized, msg: error.localizedDescription)
                }
            }
    }
    
    private func fetchingSetting() {
        self.settingVM.fetchInputSettings { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async { [self] in
                    if isRequestApproval {
                        self.setupTableApproval()
                        self.setupRowApproval()
                        
                    }else {
                        //old process
                        self.setupRow()
                    }
                    self.tableView.reloadData()
                }
            case .failure(let error):
                self.alertMessage(title: "notice".localized, msg: error.localizedDescription)
            }
        }
    }
    
    //MARK: - @objc func
    @objc func previewImage() {
        self.performSegue(withIdentifier: NotifyKey.gotoPhotoPreviewVC.rawValue, sender: nil)
    }
    
}

//MARK: - UITableView
extension ReceiptDetailsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (numberOfRows?.content.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? MultiAttachmentDetailCell {
            cell.collectionView.delegate   = self
            cell.collectionView.dataSource = self
            DispatchQueue.main.async {
                cell.collectionView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.isRequestApproval {
            let data        = self.receiptApproval
            let rows        = numberOfRows?.content[indexPath.row]
            let mappingRow  = ReceiptRow(rawValue: rows?.code ?? "")
            let taxable     = mappingTypeOfSupplier(value: data?.TRCO_TYPE ?? "1")
            let TRCO_TYPE   = data?.TRCO_TYPE ?? ""
            let tax_id      = TRCO_TYPE == "3" ? (data?.GST_NO ?? "") : (data?.TRCO_TAX_ID ?? "")
            let merchant_value = data?.TRCO_NICK_NM ?? ""
            
            if mappingRow == .HEADER {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderReceiptDetailsCell", for: indexPath) as! HeaderReceiptDetailsCell
                
                cell.configCell(title       : rows?.value ?? "",
                                date        : data?.USE_DT ?? "",
                                week        : data?.TRSC_WEEK ?? "",
                                receipt_no  : data?.HAND_DOC_ID ?? "",
                                merchant    : merchant_value,
                                taxable     : taxable,
                                tax_id      : tax_id)
                
                return cell
            }
            else if mappingRow == .ATTACHMEMNT {
                for data in data?.REC1 ?? [] {
                    if (data.ORG_FILE_NM ?? "").contains("pdf") || (data.ORG_FILE_NM ?? "").contains("ppt") || (data.ORG_FILE_NM ?? "").contains("xls") || (data.ORG_FILE_NM ?? "").contains("doc") || (data.ORG_FILE_NM ?? "").contains("pptx") || (data.ORG_FILE_NM ?? "").contains("key"){
                        isJPG = false
                        break
                    }
                }
                
                if !isJPG { //hay: when no attachment file
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MultiAttachmentDetailCell", for: indexPath) as! MultiAttachmentDetailCell
                    return cell
                    
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentDetailsCell", for: indexPath) as! AttachmentDetailsCell
                    // Preview image
                    cell.imageViewImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previewImage)))
                    
                    // assign Image View for zoom animation
                    receiptImage = cell.imageViewImg
                    
                    // hold image to preview
                    if #available(iOS 13.0, *) {
                        let interaction = UIContextMenuInteraction(delegate: self)
                        cell.imageViewImg.addInteraction(interaction)
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    let imageFiltered =  data?.REC1.filter({ obj in // let imageFiltered =  receiptList?.REC1?.filter({ ($0.ORG_FILE_NM ?? "").contains(".jpg") })
                        (obj.ORG_FILE_NM ?? "").contains(".jpg") || (obj.ORG_FILE_NM ?? "").contains(".png")
                    })
                    let imageRows        = imageFiltered?.first
                    let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
                    let split_url       = imageRows?.FILE_URL?.components(separatedBy: "?")
                    let file_url        = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")"
                    let isMultiImage = (imageFiltered?.count ?? 0) >= 2 ? true : false
                    cell.configCell(img: file_url, isMultiImage: isMultiImage)
                    return cell
                }
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiptDetailCell", for: indexPath) as! ReceiptDetailCell
                cell.strCurency = self.strCurreny
                cell.setUpCell(row: (rows ?? ReceiptDetailsRow.receiptRow.contents(code: "")))
                return cell
            } //end approval
            
        } else {
            let rows        = numberOfRows?.content[indexPath.row]
            let mappingRow  = ReceiptRow(rawValue: rows?.code ?? "")
            let taxable     = mappingTypeOfSupplier(value: self.receiptList?.TRCO_TYPE ?? "1")
            let tax_id      = self.receiptList?.TRCO_TYPE == "3" ? (receiptList?.GST_NO ?? "") : (receiptList?.TRCO_TAX_ID ?? "")
            var merchant_value = ""
            
            if self.receiptList?.TRCO_NICK_NM == "" || self.receiptList?.TRCO_NICK_NM == nil{
                merchant_value = self.receiptList?.TRCO_CMENM ?? ""
            }else{
                merchant_value = self.receiptList?.TRCO_NICK_NM ?? ""
            }
            
            if mappingRow == .HEADER {
                let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderReceiptDetailsCell", for: indexPath) as! HeaderReceiptDetailsCell
                cell.configCell(title       : rows?.value ?? "",
                                date        : self.receiptList?.USE_DT ?? "",
                                week        : self.receiptList?.TRSC_WEEK ?? "",
                                receipt_no  : self.receiptList?.HAND_DOC_ID ?? "",
                                merchant    : merchant_value ,
                                taxable     : taxable,
                                tax_id      : tax_id)
                
                return cell
            }
            else if mappingRow == .ATTACHMEMNT {
                for data in receiptList?.REC1 ?? [] {
                    if (data.ORG_FILE_NM ?? "").contains("pdf") || (data.ORG_FILE_NM ?? "").contains("ppt") || (data.ORG_FILE_NM ?? "").contains("xls") || (data.ORG_FILE_NM ?? "").contains("doc"){
                        isJPG = false
                        break
                    }
                }
                
                if !isJPG { //hay: when no attachment file
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MultiAttachmentDetailCell", for: indexPath) as! MultiAttachmentDetailCell
                    return cell
                    
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentDetailsCell", for: indexPath) as! AttachmentDetailsCell
                    
                    // Preview image
                    cell.imageViewImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previewImage)))
                    
                    // assign Image View for zoom animation
                    receiptImage = cell.imageViewImg
                    
                    
                    // hold image to preview
                    if #available(iOS 13.0, *) {
                        let interaction = UIContextMenuInteraction(delegate: self)
                        cell.imageViewImg.addInteraction(interaction)
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    let imageFiltered =  receiptList?.REC1?.filter({ obj in // let imageFiltered =  receiptList?.REC1?.filter({ ($0.ORG_FILE_NM ?? "").contains(".jpg") })
                        (obj.ORG_FILE_NM ?? "").contains(".jpg") || (obj.ORG_FILE_NM ?? "").contains(".png")
                    })
                    let imageRows        = imageFiltered?.first
                    let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
                    let split_url       = imageRows?.FILE_URL?.components(separatedBy: "?")
                    let file_url        = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")"
                    let isMultiImage = (imageFiltered?.count ?? 0) >= 2 ? true : false
                    cell.configCell(img: file_url, isMultiImage: isMultiImage)
                    return cell
                }
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiptDetailCell", for: indexPath) as! ReceiptDetailCell
                cell.strCurency = self.strCurreny
                cell.setUpCell(row: (rows ?? ReceiptDetailsRow.receiptRow.contents(code: "")))
                return cell
            }
            
        }
        
    }
}

//MARK: hold on image to preview
extension ReceiptDetailsVC: UIContextMenuInteractionDelegate{
    /*
     
     The `previewProvider` argument needs a function
     that returns a view controller. You can do this with a
     closure, or pass in a method that creates the view controller
     (in this case, the preview view controller initializer).
     
     We can also implement `willPerformPreviewActionForMenuWith`
     to respond to the user tapping on the preview.
     
     */
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        // We have to create an NSString since the identifier must conform to NSCopying
        let identifier = NSString(string: receiptList?.REC1?.first?.FILE_ID ?? "")
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
            return PhotoPreviewViewController(image: ((self.receiptImage?.image ?? UIImage(named: "noimage"))!))
        }, actionProvider: { suggestedActions in
            return self.makeDefaultDemoMenu()
        })
        
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        // If we used a view controller for our preview, we can pull it out of the animator and show it once the commit animation is complete.
        //        animator.addCompletion {
        //            if let viewController = animator.previewViewController {
        //                viewController.modalPresentationStyle = .overFullScreen
        //                self.show(viewController, sender: self)
        //            }
        //        }
    }
}

//MARK: - UICollectionView Delegate and DataSource
extension ReceiptDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// Hold down to preview image
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? MultiAttachImageCell else {
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
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        // We should have our image name set as the identifier of the configuration
//        if let identifier = configuration.identifier as? String {
//            let viewController = PhotoDetailViewController(imageName: identifier)
//            self.show(viewController, sender: self)
//        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // For response from api MREC_R009 => return imgREC009 or fileREC009
        switch section {
        case 0:
            return isRequestApproval ? self.imgREC009.count : self.imgREC.count
            
        case 1:
            return isRequestApproval ? fileREC009.count : self.fileREC.count
        default: return 0
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
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (isRequestApproval ? imgREC009.count == 0 : self.imgREC.count == 0 || isRequestApproval ? fileREC009.count == 0 : self.fileREC.count == 0) ? 0 : 7) // 7 spacing
            
        } else {
            
            if (isRequestApproval ? imgREC009.count : imgREC.count ) + (isRequestApproval ? fileREC009.count : fileREC.count ) >= Shared.MAX_IMAGES {
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
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiAttachImageCell", for: indexPath) as! MultiAttachImageCell
            let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
            
            if isRequestApproval {
                //For file response from api MREC_R009
                let imageFiltered = self.imgREC009
                let imageRows = imageFiltered.first
                let split_url   = imageRows?.FILE_URL?.components(separatedBy: "?")
                let file_url    = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")"
                
                //Preview Image
                cell.attachmentImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previewImage)))
                // assign image view for zoom animation
                receiptImage = cell.attachmentImgView
                // hold image to preview
                if #available(iOS 13.0, *) {
                    let interaction = UIContextMenuInteraction(delegate: self)
                    cell.attachmentImgView.addInteraction(interaction)
                }else{
                    // Fallback on ealier versions
                }
                if (imageFiltered.count) == 1 {
                    let isMultiImage = (imageFiltered.count) < 2 ? false : true
                    cell.configCell(img: file_url, isMultiImage: isMultiImage)
                }else{
                    cell.configCell(img: file_url, isMultiImage: false)
                }
                
                cell.loadImage(imageURL: file_url)
                
                if cell.attachmentImgView.image != UIImage(named: "noimage") {
                    /// preview img by clicking
                    cell.attachmentImgView.didTap {
                        // assign Image View for zoom animation
                        self.receiptImage   = cell.attachmentImgView
                        self.selectedImages = cell.attachmentImgView.image // img for long press to preview
                        
                        self.currentIndexPathImage = indexPath
                        self.performSegue(withIdentifier: NotifyKey.gotoPhotoPreviewVC.rawValue, sender: nil)
                    }
                }
                
            }else {
                //For file response from api MREC_R006
                let imageFiltered = self.imgREC
                let imageRows = imageFiltered.first
                let split_url   = imageRows?.FILE_URL?.components(separatedBy: "?")
                let file_url    = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")"
                
                //Preview Image
                cell.attachmentImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previewImage)))
                // assign image view for zoom animation
                receiptImage = cell.attachmentImgView
                // hold image to preview
                if #available(iOS 13.0, *) {
                    let interaction = UIContextMenuInteraction(delegate: self)
                    cell.attachmentImgView.addInteraction(interaction)
                }else{
                    // Fallback on ealier versions
                }
                if (imageFiltered.count) == 1 {
                    let isMultiImage = (imageFiltered.count) < 2 ? false : true
                    cell.configCell(img: file_url, isMultiImage: isMultiImage)
                }else{
                    cell.configCell(img: file_url, isMultiImage: false)
                }
                
                cell.loadImage(imageURL: file_url)
                
                if cell.attachmentImgView.image != UIImage(named: "noimage") {
                    /// preview img by clicking
                    cell.attachmentImgView.didTap {
                        // assign Image View for zoom animation
                        self.receiptImage   = cell.attachmentImgView
                        self.selectedImages = cell.attachmentImgView.image // img for long press to preview
                        
                        self.currentIndexPathImage = indexPath
                        self.performSegue(withIdentifier: NotifyKey.gotoPhotoPreviewVC.rawValue, sender: nil)
                    }
                }
            }
            return cell
            
        case 1:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiAttachFileCell", for: indexPath) as! MultiAttachFileCell
            
            if isRequestApproval{
                //For file response from api MREC_R009
                let rows = self.fileREC009[indexPath.row]
                let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
                let file_name       = rows.ORG_FILE_NM ?? ""
                let split_url       = rows.FILE_URL?.components(separatedBy: "?")
                let file_url        = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")" + "&\(file_name)"
                
                cell.configReceiptDetailCellNew(data: rows)
                cell.openAttachFileButton.didTap {
                    
                    //                    let linked_file = "\(rows.FILE_URL ?? "")&\(rows.ORG_FILE_NM ?? "")"
                    
                    DataAccess.shared.downloadTask(withURL: file_url, shouldShowLoading: true) { (data, error) in
                        if error == nil {
                            let path = self.getDocumentsDirectory()
                            let fileUrl = path.appendingPathComponent(rows.ORG_FILE_NM ?? "")
                            do {
                                try data?.write(to: fileUrl)
                                DispatchQueue.main.async {
                                    let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
                                    if let popoverPresentationController = activityViewController.popoverPresentationController {
                                        popoverPresentationController.sourceView = self.view
                                        popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                                        popoverPresentationController.permittedArrowDirections = []
                                    }
                                    self.present(activityViewController, animated: true, completion: nil)
                                }
                            } catch {
                                print(error)
                            }
                        }else {
                            self.customAlert(message: error?.localizedDescription ?? "")
                        }
                    }
                }
            }else{
                //For file response from api MREC_R006
                let rows = self.fileREC[indexPath.row]
                let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
                let file_name   = rows.ORG_FILE_NM ?? ""
                let split_url   = rows.FILE_URL?.components(separatedBy: "?")
                let file_url    = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")" + "&\(file_name)"
                
                cell.configReceiptDetailCell(data: rows)
                cell.openAttachFileButton.didTap {
                    
//                    let linked_file = "\(rows.FILE_URL ?? "")&\(rows.ORG_FILE_NM ?? "")"
                    DataAccess.shared.downloadTask(withURL: file_url, shouldShowLoading: true) { [weak self] (data, error) in
                        guard let self = self else { return }
                        if error == nil ,  let data = data {
                            let path = self.getDocumentsDirectory()
                            let fileUrl = path.appendingPathComponent(rows.ORG_FILE_NM ?? "")
                            print(fileUrl.pathExtension)
                            
                            do {
                                try data.write(to: fileUrl)
                                self.quickLook(urls: [fileUrl]) // Call the updated quickLook method with an array
                            } catch {
                                print(error)
                            }
                        }else {
                            self.customAlert(message: error?.localizedDescription ?? "")
                        }
                    }
                }
            }
            return cell
            
        default: return UICollectionViewCell()
            
        }
    }
}

//here
// MARK: - Extention Preview file Multifile
extension ReceiptDetailsVC: QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { previewItems.count }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem { previewItems[index] }
    
    // MARK: - Check file Preview
    func quickLook(urls: [URL]) {
        // Clear previous preview items
        clearPreviewItems()
        
        let dispatchGroup = DispatchGroup()
        
        for url in urls {
            dispatchGroup.enter()
            downloadFile(from: url) { result in
                switch result {
                case .success(let previewURL):
                    let previewItem = PreviewItem(url: previewURL)
                    self.previewItems.append(previewItem)
                case .failure(let error):
                    print("Failed to download file: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            // Present the QLPreviewController with all preview items
            if !self.previewItems.isEmpty {
                self.previewController.reloadData() // Ensure the data is reloaded
                self.present(self.previewController, animated: true)
            } else {
                self.presentAlertController(with: "No valid files to preview.")
            }
        }
    }

    // MARK: - Method downloadFile url response
    private func downloadFile(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            let fileExtension = url.pathExtension
            guard self.isValidFileExtension(fileExtension) else {
                completion(.failure(URLError(.unsupportedURL)))
                return
            }
            do {
                let suggestedFilename = response?.suggestedFilename ?? "quicklook"
                let previewURL = FileManager.default.temporaryDirectory.appendingPathComponent(suggestedFilename)
                try data.write(to: previewURL, options: .atomic)
                completion(.success(previewURL))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - QLPreviewControllerDelegate
    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        // Delay the clearing of preview items to ensure smooth transition between previews
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

extension URL {
    var hasHiddenExtension: Bool {
        get { (try? resourceValues(forKeys: [.hasHiddenExtensionKey]))?.hasHiddenExtension == true }
        set {
            var resourceValues = URLResourceValues()
            resourceValues.hasHiddenExtension = newValue
            try? setResourceValues(resourceValues)
        }
    }
}
    

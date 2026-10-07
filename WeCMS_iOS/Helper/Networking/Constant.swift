//
//  Constant.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 5/1/21.
//

import Foundation
import UIKit

typealias Completion                = ()                -> Void
typealias Completion_Int            = (Int)             -> Void
typealias Completion_Bool           = (Bool)            -> Void
typealias Completion_NSError        = (NSError?)        -> Void
typealias Completion_String         = (String)          -> Void
typealias Completion_String_Error   = (String, Error?)  -> Void
typealias Completion_ArrayOfString  = ([String])        -> Void

typealias Completion_String_Bool    = (String, Bool)    -> Void


enum HTTPMethod : String {
    case GET    = "GET"
    case POST   = "POST"
    case PUT    = "PUT"
    case PATCH  = "PATCH"
    case DELETE = "DELETE"
}

enum MasterID {
    // ⚠️ Giá trị gửi lên server, KHÔNG đổi tên dù còn chữ WABOOK.
    //    Chỉ đổi được khi backend đổi định danh master.
    static let key    = "master_id"
    static let value  = "I_WABOOK_G_1"
}

enum APIKey: String {
    
    static var AUTHENTICATION_KEY : String {
//        #if DEBUG
//        if Shared.isDevelopServer {
//            return "mob-s-20190703-biz-memo-erudnf"
//        } else {
//            return "metc650e-ce68-48ea-a96e-6c554d91165"
//        }
//        #else
//        return "metc650e-ce68-48ea-a96e-6c554d91165"
//        #endif
        return "mob-s-20190703-biz-memo-erudnf"
    }
    
    
    static var AppSettingURL : String {
        #if DEBUG
        switch Shared.environment {
        case .Development, .UAT:
            return "https://mg.kosign.dev/" //  /api/v1/app/setting/cb8fec18-1ef2-4a7a-bdd8-32a61ba08b7e?os=IOS"
        case .Production:
            return "https://mg.wecambodia.com/" //  /api/v1/app/setting/cb8fec18-1ef2-4a7a-bdd8-32a61ba08b7e?os=IOS"
        }
        #else
        return "https://mg.wecambodia.com/" // /api/v1/app/setting/cb8fec18-1ef2-4a7a-bdd8-32a61ba08b7e?os=IOS"
        #endif
    }
    
    static var AppID : String {
        #if DEBUG
        switch Shared.environment{
        case .Development, .UAT:
            return "cb8fec18-1ef2-4a7a-bdd8-32a61ba08b7e"
        case .Production:
            return "43bcf8d7-6497-4431-a406-56829b1803a0"
        }
        
        #else
        return "43bcf8d7-6497-4431-a406-56829b1803a0"
        #endif
    }
     
    
    case login                  = "/auth/login"
    
    
    // Version 1.0.2 : "20210617"
    // Version 1.0.3 : "20210709"
    // Version 1.0.4 : "20210802"
    // Version 1.0.5
    
    case XAPPVERSION             = "20211103"
    
    case MG                      = "MG"
    
    //BipleReceipt
    case BOARD_DETAIL_LIST_R001  = "board_detail_list_r001"
    
    // ⚠️ KHÔNG ĐỔI phần giá trị "WABOOKS_MREC_…" bên phải.
    //    Đó là API_SVC_ID gửi thẳng lên gateway; server WeCMS hiện vẫn nhận đúng
    //    tên cũ này. Tên `case` bên trái chỉ là định danh trong Swift nên đã bỏ
    //    tiền tố WABOOKS. Chỉ đổi được phần chuỗi khi backend đổi tên API.
    case MREC_R001       = "WABOOKS_MREC_R001"
    case MREC_R002       = "WABOOKS_MREC_R002"
    case MREC_R003       = "WABOOKS_MREC_R003"
    case MREC_R004       = "WABOOKS_MREC_R004"
    case MREC_R005       = "WABOOKS_MREC_R005"
    case MREC_R006       = "WABOOKS_MREC_R006"
    case MREC_R007       = "WABOOKS_MREC_R007"
    case MREC_R008       = "WABOOKS_MREC_R008"
    case MREC_C001       = "WABOOKS_MREC_C001"
    case MREC_C002       = "WABOOKS_MREC_C002"
    case MREC_C003       = "WABOOKS_MREC_C003"
    case MREC_C004       = "WABOOKS_MREC_C004"
    case MREC_C005       = "WABOOKS_MREC_C005"
    case MREC_D001       = "WABOOKS_MREC_D001"
    case MREC_C006       = "WABOOKS_MREC_C006"
    case MREC_R010       = "WABOOKS_MREC_R010"
    case MREC_U001       = "WABOOKS_MREC_U001"
    
    case MREC_R012       = "WABOOKS_MREC_R012"
    
    case MREC_BLTB_0007_U001 = "WABOOKS_MREC_BLTB_0007_U001"
    
    case MREC_U003       = "WABOOKS_MREC_U003"
    
    case MREC_R020       = "WABOOKS_MREC_R020"
    case MREC_R040       = "WABOOKS_MREC_R040" // Exchange rate
    case MREC_R050       = "WABOOKS_MREC_R050" // Cancel receipt
    case MREC_R901       = "WABOOKS_MREC_R901" //Withholding Common  (API)
    
    case MREC_R060       = "WABOOKS_MREC_R060" // e-invoice 목록조회(API) (API (v2023.1.0.4 추가))
    case MREC_R070       = "WABOOKS_MREC_R070" // e-invoice 목록조회(API) (API (v2023.1.0.5 추가))
    
    case MREC_C080       = "WABOOKS_MREC_C080" // Create BookMark
    case MREC_D080       = "WABOOKS_MREC_D080" // Delete BookMark
    
    case AppSetting              = "api/v2/app/setting/"
    
    //LanguageAPI
    case MREC_U002       = "WABOOKS_MREC_U002"
    
    // Search Contact
    case MREC_R030      = "WABOOKS_MREC_R030"
    
    //Send Phone Number Forgot ID and Forgot Password
    case MREC_MBMR_0002_R001    = "WABOOKS_MREC_MBMR_0002_R001" //==> Update from API "mbmr_0002_001_r001"
    
    case MREC_MBMR_0003_R001    = "WABOOKS_MREC_MBMR_0003_R001" //==> Update from API "mbmr_0003_001_r002"
    
    //Modify OTP Forget ID and Forgot Password
    case MREC_MBMR_0002_R002    = "WABOOKS_MREC_MBMR_0002_R002" //Update from API "mbmr_0002_001_r002"
      
    //Find Password
    case MREC_MBMR_0003_R003    = "WABOOKS_MREC_MBMR_0003_R003" //Update from API "mbmr_0003_001_r003"
    
    //Reset Password
    case MREC_MBMR_0003_U001    = "WABOOKS_MREC_MBMR_0003_U001" //Update from API "mbmr_0003_002_u001"
    
    //ID Found
    case MREC_MBMR_0002_R003    = "WABOOKS_MREC_MBMR_0002_R003" //Update from API "mbmr_0002_001_r003"
    
    case MREC_MBMR_0003_R002    = "WABOOKS_MREC_MBMR_0003_R002"
    
    //new API members
    case MREC_BLTB_0006_R001    = "WABOOKS_MREC_BLTB_0006_R001" // List Members(All)
    case MREC_BLTB_0006_R002    = "WABOOKS_MREC_BLTB_0006_R002" // List new Members (User is not yet a members on current Board)
    case MREC_BLTB_0006_C001    = "WABOOKS_MREC_BLTB_0006_C001" // Invite Members
    case MREC_BLTB_0006_U001    = "WABOOKS_MREC_BLTB_0006_U001" // Add as admin 
    case MREC_BLTB_0006_D001    = "WABOOKS_MREC_BLTB_0006_D001" // Remove member
    case MREC_BLTB_0006_D002    = "WABOOKS_MREC_BLTB_0006_D002" // Leave Board
    case MREC_BLTB_0006_R003    = "WABOOKS_MREC_BLTB_0006_R003" // List a new admin(Not an Admin)
    case MREC_BLTB_0006_U002    = "WABOOKS_MREC_BLTB_0006_U002" // Assign & Leave
    // API Screens Board
    case MREC_BLTB_0002_R005   = "WABOOKS_MREC_BLTB_0002_R005" // Inquiry Approval ===> Board> Approval
    case MREC_BLTB_0002_D001   = "WABOOKS_MREC_BLTB_0002_D001" // Delete Post ==> Delete Post (COMM)
    // Home |  Post Detail > Comments API
    case MREC_BLTB_0002_R003   = "WABOOKS_MREC_BLTB_0002_R003" // Inquiry Comments ==> List Comments (COMM)
    case MREC_BLTB_0002_C001   = "WABOOKS_MREC_BLTB_0002_C001" // Add Comments
    case MREC_BLTB_0002_D002   = "WABOOKS_MREC_BLTB_0002_D002" // Delete Comments
    case MREC_BLTB_0002_U001   = "WABOOKS_MREC_BLTB_0002_U001" // Update Comments
    //  Board> Board Details
    case MREC_BLTB_0004_C001   = "WABOOKS_MREC_BLTB_0004_C001" // Create new Article and update draft article
    case MREC_BLTB_0004_C002   = "WABOOKS_MREC_BLTB_0004_C002" // Create Approval Post & update draft Approval
    case MREC_BLTB_0004_R001   = "WABOOKS_MREC_BLTB_0004_R001" // Inquiry Mention members ==> List Mention
    case MREC_BLTB_0004_R002   = "WABOOKS_MREC_BLTB_0004_R002" // List Approver
    case MREC_BLTB_0004_R003   = "WABOOKS_MREC_BLTB_0004_R003" // List Expenses (VN>Expense E-invoice,Reciept(MOB); KH>Bill, Reciept(MOB))
    case MREC_BLTB_0004_U001  = "WABOOKS_MREC_BLTB_0004_U001" // Update Article
    case MREC_BLTB_0004_U002  = "WABOOKS_MREC_BLTB_0004_U002" // Update Pending Approval
    case MREC_BLTB_0005_R001  = "WABOOKS_MREC_BLTB_0005_R001" // Article Details
    case MREC_BLTB_0005_D001  = "WABOOKS_MREC_BLTB_0005_D001" // Delete Post file
    case MREC_BLTB_0005_D002  = "WABOOKS_MREC_BLTB_0005_D002" // Delete Comment File
    case MREC_BLTB_0005_R002  = "WABOOKS_MREC_BLTB_0005_R002" // Approval Detail
    case MREC_BLTB_0005_U001  = "WABOOKS_MREC_BLTB_0005_U001" // Update Approval or Reject
    case MREC_R009            = "WABOOKS_MREC_R009"           // Receipt Detail
    case MREC_BLTB_0002_D003  = "WABOOKS_MREC_BLTB_0002_D003" // Delete Draft Post 
    
    case MREC_BLTB_0005_R003  = "WABOOKS_MREC_BLTB_0005_R003" // Read Draft Article & Approval
    
    case comm_0102_001                = "comm_0102_001"               // Inquiry Project/Site
            
}

enum UserDefaultKey : String {
    
    case isHiddenAutoLayout = "_UIConstraintBasedLayoutLogUnsatisfiable"
    case appLang            = "appLang"
    case autoLogin          = "autoLogin"
    case IS_FIRST_COACH_APP = "IS_FIRST_COACH_APP"
    case deviceToken        = "DeviceToken"
    case firstTimeRunApp    = "firstTimeRunApp"
    case hasReceivedNotification    = "hasReceivedNotification"
    case isShowSelectVersionApp     = "isShowSelectVersionApp"
    case AllowPushNotification      =  "AllowPushNotification"
}

enum NotifyKey : String {
    case updateUsage                        = "updateUsage"
    case reloadMainVC                       = "reloadMainVC"
    case reloadAfterUploadImage             = "reloadAfterUploadImage"
    case reloadAfterUpdateOrDeleteOrSubmit  = "reloadAfterUpdateOrDeleteOrSubmit"
    case reloadLocalize                     = "reloadLocalize"
    case reloadSelectedPurpose              = "reloadSelectedPurpose"
    case reloadNotificationVC               = "reloadNotificationVC"
    case reloadReceiptListVC                = "reloadReceiptListVC"
    case reloadReceiptListWebView           = "reloadReceiptListWebView"
    case reloadAfterCreateArticle           = "reloadAfterCreateArticle"
    
    case gotoSubmitReceiptVC                = "gotoSubmitReceiptVC"
    case gotoReceiptDetailVC                = "gotoReceiptDetailVC"
    case gotoPhotoPreviewVC                 = "gotoPhotoPreviewVC"
    case gotoNotification                   = "gotoNotification"
    case checkingBadgeCount                 = "checkingBadgeCount"
    case presentLimitedLibraryPicker        = "presentLimitedLibraryPicker"
    
    case imageCount                         = "imageCount"
    case SuccessTakePhoto                   = "SuccessTakePhoto"
    case SuccessTakePhotoFromSubmitReceiptVC = "SuccessTakePhotoFromSubmitReceiptVC"
    case GotoBoard                          = "GotoBoard"
    case GotoExpenseApproval                = "GotoExpenseApproval"
    case GotoSearch                         = "GotoSearch"
    case reloadAfterComment                 = "reloadAfterComment"
    case reloadBoardVC                      = "reloadBoardVC"
    case reloadBoardVCAfterDetail           = "reloadBoardVCAfterDetail"
    case gotoSelectExpense                  = "gotoSelectExpense"
    case getDataAddManual                   = "getDataAddManual"
    case clientData                         = "clientData"
    case readAllNotification               = "readAllNotification"
    case reloadBoardLocalize               = "reloadBoardLocalize"
    case reloadFullContentBoard            = "reloadFullContentBoard"
}
 
enum ReceiptRow: String, CaseIterable {
    
    // Key to display row
    case HEADER         = "TTL"
    case ATTACHMEMNT    = "ATTC"
    case RECEIPTNO      = "RCTNO"
    case DATE           = "DATE"
    case MERCHANT       = "MRCH"
    case TYPEOFSUPPLIER = "TYPESPL"
    case TAXID          = "TAXID"
    case CURRENCY       = "CUR"
    case AMOUNT         = "AMT"
    case PURPOSE        = "PURP"
    case PAYMENT_METHOD = "PAYMENT_METHOD"
    case ADVANCELEDGER  = "ADVL"
    case BANK           = "BANK"
    case DEBITDATE      = "DEBDATE"
    case IMPORT_TRANSACTION = "IMPORT"
    case TEL            = "TEL"
    case EMAIL          = "EMAIL"
    case ADDRESS        = "ADDR"
    case USER           = "USER"
    case DESCRIPTION    = "DESCR"
    case RATE           = "RT"
    case AMOUNTKHR      = "AMTKHR"
    case WITH_HOLDING_TAX = "WITH_HOLDING_TAX"
    case TAX_AMOUNT     = "TAX_AMOUNT"
    case PROJECT_SITE   = "PROJECT_SITE"
   
    // row title
    var description: String {
        switch self {
        case .HEADER            : return "header"
        case .ATTACHMEMNT       : return "attachment"
        case .RECEIPTNO         : return "receipt_no"
        case .DATE              : return "date"
        case .MERCHANT          : return "contact"
        case .TYPEOFSUPPLIER    : return "type_of_supplier"
        case .TAXID             : return "tax_id"
        case .CURRENCY          : return "currency"
        case .AMOUNT            : return "amount"
        case .PURPOSE           : return "purpose_account"
        case .PAYMENT_METHOD    : return "payment_method"
        case .PROJECT_SITE      : return "Project/Site"
        case .ADVANCELEDGER     : return "advance_ledger"
        case .BANK              : return "bank"
        case .DEBITDATE         : return "debit_date"
        case .IMPORT_TRANSACTION : return "import_transaction"
        case .TEL               : return "tel"
        case .EMAIL             : return "email"
        case .ADDRESS           : return "address"
        case .USER              : return "user"
        case .DESCRIPTION       : return "description"
        case .RATE              : return "rate_1_usd_vnd"
        case .AMOUNTKHR         : return "amt_vnd"
        case .WITH_HOLDING_TAX  : return "withholding_tax"
        case .TAX_AMOUNT         : return "tax_amount"
        }
    }
}
 
enum TypeOfSupplier: String, CaseIterable {
    case TaxablePerson      = "1"
    case NonTaxablePerson   = "2"
    case OverseaCompany     = "3"
    
    var description : String {
        switch self {
        case .TaxablePerson     : return "enter_tax_id"
        case .NonTaxablePerson  : return "enter_national_id"
        case .OverseaCompany    : return "enter_foreigner"
        }
    }
}
 
enum CurrencyType: String, CaseIterable {
    case USD = "USD"
    case KHR = "KHR"
    case VND = "VND"
}

//
//  Share.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 5/1/21.
//

import Foundation

enum LanguageCode: String {
    case English    = "en"
    case Vietnamese = "vi"
}

enum Environment: String {
    case Development = "Development"
    case UAT         = "UAT"
    case Production  = "Production"
}
 
struct Shared {
    
    //MARK:- singleton
    static var share = Shared()
    
    private init() { }
    
    static var language                 : LanguageCode      = .Vietnamese
    static var environment              : Environment = .Development
    var token                           : String?
    static var shouldReload             : Bool = false
    
    var isClickedReadAll = false
    var isTapUnread = true
    
    static var API_SEQ_NO               = ""
    static var LST_TRAN_YN              = ""
    static var deviceToken              = ""
    static var selectUserListKey        = ""
    
    static var strDuration              = ""
    static var crtcNumber               : [String] = []
//    static var manualInput              = ""
//    static var r_text                   = ""
//    static var value                    = ""
    static var user_id                  = ""
    
    //Use in CustomPopUpCell
    static var indexPath                = 0
    
    //Use in CustomOptionPopup
    static var indexPathOption          = 0
    
    //Use in CustomOptionPopup
    static var indexPathDetail          = 0
    
    //Use in Select Country
    static var indexPathCountry         = 0
    
    static var badgeCount               = 0
    static var hasReceivedNewNotification = false
    static var isFromMainTabBar         = false
    
    //:> Seanghay <:Get and Save Notification URL
    static var notificationURL          = ""
    static var isGetNotification        = false
    
    static var c_base_url           = ""
    static var c_web_base_url       = ""
    static var DV_Cd                = ""
    static var c_inform_ver         = ""
    static var documentNo           = ""
    static var actionData           : ActionData?

      
    static var MG_DATA                  : WABOOKS_MG.Response.tran_res_data?
    static var New_MG                   : NewMG.Response?
    static var BUSINESS_EST             : WABOOKS_MREC_R001.RESPONSE?
    static var R001_DATA                : WABOOKS_MREC_R001.RESPONSE?
    static var R002_DATA                : WABOOKS_MREC_R002.RESPONSE?
    static var PERSIONAL_INFO           : WABOOKS_MREC_R002.RESPONSE?
    static var BLTB_CD                  = ""
    static var selectReceiptRowAt       : Int = -1
    static var selectReceiptSectionAt   : Int = -1
    
   static var selectedDate            : DateFilterModel?
   static var selectedDateExpenses    : DateFilterModel?
    
    static let MAX_IMAGES           : Int = 5
    static var CURRENT_MAX_IMAGES   : Int = 5
    
    static var countryData          = [CountryData]()
    
    // Navy : important
    
    static var screenWidth          : CGFloat = 0
    static var screenHeigh          : CGFloat = 0

    func getCurrentDate(date: Date) -> (dateString: String, serverDate: String, serverTime: String) {
        var calendar    = Calendar.current
        calendar.locale = Locale(identifier: Shared.language.rawValue)
        let component   = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let month   = String(format: "%02d", component.month!)
        let day     = String(format: "%02d", component.day!)
        let hour    = String(format: "%02d", component.hour!)
        let minute  = String(format: "%02d", component.minute!)
        let second  = String(format: "%02d", component.second!)
        
        let dateString      = "\(day)-\(month)-\(component.year!)"
        let serverString    = "\(component.year!)\(month)\(day)"
        let serverTime      = "\(hour)\(minute)\(second)"
        
        return (dateString, serverString, serverTime)
    }
    
    static var safeAreaTop : CGFloat {
        let root = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController
        return root?.view.safeAreaInsets.top ?? 0.0
    }
    
    static var safeAreaBottom : CGFloat {
        let root = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController
        return root?.view.safeAreaInsets.bottom ?? 0.0
    }
    
    /// Maps a font name onto the family this build actually ships.
    ///
    /// WeCMS supports Vietnamese and English only — both Latin script — so the app bundles
    /// the Inter family alone. The Khmer (NotoSerifKhmer) and Korean (NanumSquare) faces
    /// this once switched between are no longer shipped; those names are still mapped to
    /// the matching Inter weight so any lingering reference degrades gracefully instead of
    /// resolving to nil. Anything else is passed through untouched.
    func getLocalizedFont(preFontName: String) -> String {

        let name = preFontName.lowercased()

        guard name.contains("notoserifkhmer") || name.contains("nanumsquare") else {
            return preFontName
        }

        if name.contains("bold") || name.contains("eb") {
            return "inter-bold"
        } else if name.contains("medium") || name.contains("b") {
            return "inter-medium"
        } else {
            return "inter-regular"
        }
    }
}

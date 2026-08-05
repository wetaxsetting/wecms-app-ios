//
//  NotificationList.swift
//  WABOOKS_iOS_V2
//
//  Created by MacBook on 5/17/21.
//

import Foundation
 
class NotificationtListVM {
  
    private(set) var notificationList   : WABOOKS_MREC_R010.RESPONSE?
    private(set) var u001_data          : WABOOKS_MREC_U001.RESPONSE?
    private(set) var requestBody        : WABOOKS_MREC_R010.REQUEST?
    var urlStrRec                       : [String] = []
    var notificationRec                 : [WABOOKS_MREC_R010.RESPONSE.REC] = []
    var isShowLoading                   : Bool = false
    
    var totalNotificationRec                 : [WABOOKS_MREC_R010.RESPONSE.REC] = []
    
    var page            = 1
    let PAGE_PER_CNT    = 10
    var isLastRecord    = false
    var isFetching      = false
    var isRefresh       = false
    var isReload        = false
    var StrWebBaseURL   = Shared.c_web_base_url
    
    func fetching(isShowLoading:Bool = false, body: WABOOKS_MREC_R010.REQUEST,  completion: @escaping (NSError?) -> Void) {
 
        DataAccess.shared.fetchData(shouldShowLoading   : isShowLoading,
                                    apiKey              : APIKey.WABOOKS_MREC_R010,
                                    body                : body,
                                    responseType        : WABOOKS_MREC_R010.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                self.notificationList       = data
                
                
                
                if body.NOTI_TYPE == "U" {
                    Shared.badgeCount = self.notificationList?.TOT_CNT ?? 0
                    // heremen : Navy : sync app badecount with tabbar badgecount
                    UIApplication.shared.applicationIconBadgeNumber = Shared.badgeCount
                    MyNotify.send(name: .checkingBadgeCount) // notification button style has new notification
                }

                completion(nil)
                
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func fetchNotification_U001(reqBody:WABOOKS_MREC_U001.REQUEST,completion: @escaping (NSError?)->Void = { _ in }) {
        DataAccess.shared.fetchData(shouldShowLoading : false,
                                    apiKey            : APIKey.WABOOKS_MREC_U001,
                                    body              : reqBody,
                                    responseType      : WABOOKS_MREC_U001.RESPONSE.self) { (result) in
            switch result {
            case .success (let data) :
                self.u001_data = data
                completion(nil)
            case.failure(let error) :
                completion(error)
            }
        }
    }
    //WABOOKS_MREC_BLTB_0007_U001
    func fetchNotification_0007_U001(reqBody:WABOOKS_MREC_BLTB_0007_U001.REQUEST,completion: @escaping (NSError?) -> Void = { _ in }) {
        DataAccess.shared.fetchData(shouldShowLoading : true,
                                    apiKey            : APIKey.WABOOKS_MREC_BLTB_0007_U001,
                                    body              : reqBody,
                                    responseType      : WABOOKS_MREC_BLTB_0007_U001.RESPONSE.self) { (result) in
            switch result {
            case .success (_):
                completion(nil)
            case.failure(let error) :
                completion(error)
            }
        }
    }
    
    func fetchR010(isShowloading:Bool = false, NOTI_TYPE: String,completion: @escaping (NSError?) -> Void) {

//        self.isFetching = true
        
        self.fetching(isShowLoading: isShowloading,body: WABOOKS_MREC_R010.REQUEST(PAGE_NO: self.page, PAGE_PER_CNT: PAGE_PER_CNT, NOTI_TYPE: NOTI_TYPE )) { (error) in
            
            guard error == nil else {
                
                if error?.code == 1004 {//No Internet Connection
//                    self.noInternetConnectionView.isHidden = false
                } else {

                }
                
                self.isFetching = false
                
                completion(error)
                
                return
            }
            
            //Success
            (self.isRefresh || self.isReload) ? self.clearDataResponse() : () //empty nofication when pullToRefresh or reload

            self.notificationList?.REC?.forEach {
                if self.isDuplicateData(data: $0) {
                    return
                }
                self.notificationRec.append($0)
                self.urlStrRec.append(self.mapFullUrl(notification: $0))
            }
            
            self.isLastRecord   = self.notificationList?.NEXT_PAGE_YN == "N"
            self.isFetching     = false
            
            self.isReload = true
            completion(nil)
            
        }
    }
    func requestReadAllorReadOne(body: WABOOKS_MREC_BLTB_0007_U001.REQUEST,  completion: @escaping (NSError?) -> Void) {
        
        DataAccess.shared.fetchData(shouldShowLoading   : isShowLoading,
                                    apiKey              : APIKey.WABOOKS_MREC_BLTB_0007_U001,
                                    body                : body,
                                    responseType        : WABOOKS_MREC_BLTB_0007_U001.RESPONSE.self) { (result) in
            switch result {
            case .success(_):
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    private func clearDataResponse() {
        self.isReload          = false
        self.notificationRec   = []
        self.urlStrRec         = []
    }
    
    private func isDuplicateData(data: WABOOKS_MREC_R010.RESPONSE.REC) -> Bool {
        return self.notificationRec.contains(where: {$0 == data})
    }
    
    func mapFullUrl(notification: WABOOKS_MREC_R010.RESPONSE.REC) -> String {
        
        let BIZ_KEY     = Shared.R002_DATA?.BIZ_KEY ?? ""
        let SEQ_NO      = notification.SEQ_NO ?? ""
        let REG_DT      = notification.REG_DT ?? ""
        let REG_SEQ_NO  = notification.REG_SEQ_NO ?? ""
        let CD_VD       = self.mapDVCD(DV_CD: notification.DV_CD ?? "").1
        

        var urlStr = "\(StrWebBaseURL)\(CD_VD)?TITLE=&SEQ_NO=\(SEQ_NO)&BIZ_KEY=\(BIZ_KEY)&REG_DT=\(REG_DT)&REG_SEQ_NO=\(REG_SEQ_NO)"
        
        switch notification.DV_CD ?? "0" {
        case "1":
            
            let userID = Shared.R002_DATA?.USER_ID ?? ""
            urlStr = "\(StrWebBaseURL)\(CD_VD)?TITLE=&SEQ_NO=\(SEQ_NO)&BIZ_KEY=\(BIZ_KEY)&USER_ID=\(userID)"

        case "3", "4", "5":
            urlStr = "\(StrWebBaseURL)\(CD_VD)?TITLE=&SEQ_NO=\(SEQ_NO)%22&BIZ_KEY=\(BIZ_KEY)&REG_DT=\(REG_DT)&REG_SEQ_NO=\(REG_SEQ_NO)"
        default:
            urlStr = ""
        }
        
        return urlStr
    }
    
    func mapDVCD(DV_CD: String) -> (String, String) {
        switch DV_CD {
        case "1": return ("contact".localized, "mobl_0010_002.act") //거래처
        case "2": return ("급여명세", "") //not used
        case "3": return ("deposit".localized, "szon_0004_008.act") //입금
        case "4": return ("withdrawal".localized, "szon_0004_009.act") //Expense
        case "5": return ("report".localized, "szon_0004_010.act") //보고서
            default : return ("", "")
        }
    }
  
}

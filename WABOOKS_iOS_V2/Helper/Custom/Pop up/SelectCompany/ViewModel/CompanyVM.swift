//
//  CompanyVM.swift
//  PopUpScreen
//
//  Created by Tang Mouycheng on 27/3/23.
//

import Foundation


class CompanyVM{
    var cells       : [CompanyNewData<Any>] = []
    var companyRes  : WABOOKS_MREC_R001.RESPONSE?
    var company     : CompanyInfo?
    
    func initData(data : WABOOKS_MREC_R001.RESPONSE?){
        cells       = []
        let title   = CompanyInfo(images: "", compName: "Select Company")
        self.cells.append(CompanyNewData<Any>(rowType: .title    , value: title))
        for index in 0..<(data?.REC?.count ?? 0) {
            company = CompanyInfo(images: "ico_company", compName: Shared.language == .English ? data?.REC?[index].CMPN_ENM : data?.REC?[index].CMPN_NM)
            self.cells.append(CompanyNewData<Any>(rowType: .company, value: company))
        }
    }
     
    ///R002: Login
    func requestR002(shouldShowLoading: Bool = true, bizKey: String, completion: @escaping (Swift.Result<WABOOKS_MREC_R002.RESPONSE?, NSError>) -> Void) {
        
        let USER_ID = KeychainManager.getCredential("username") ?? ""
        let PWD     = KeychainManager.getCredential("password") ?? ""
        
        let requestBody = WABOOKS_MREC_R002.REQUEST(BIZ_KEY: bizKey, USER_ID: USER_ID, USER_PW: PWD)
        
        DataAccess.shared.fetchData(shouldShowLoading: shouldShowLoading, apiKey: .WABOOKS_MREC_R002, body: requestBody, responseType: WABOOKS_MREC_R002.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                Shared.R002_DATA = data
                
                if !(KeychainManager.getCredential("username") ?? "").isEmpty {
                    PushNotificationVM().pushNotification_C006(reqBody: WABOOKS_MREC_C006.REQUEST(
                        PUSHSERVER_KIND     : "APNS",
                        APP_ID              : Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? "",
                        DEVICE_ID           : UIDevice.current.identifierForVendor?.uuidString ?? "",
                        PUSH_ID             : Shared.deviceToken,
                        MODEL_NAME          : UIDevice.deviceIdentifier,
                        OS                  : UIDevice.current.systemVersion,
                        NOTE                : "",
                        RETRANS_YN          : "N", 
                        LANG_CODE           : Shared.language.rawValue.uppercased()))
                }
                
                completion(.success(data))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


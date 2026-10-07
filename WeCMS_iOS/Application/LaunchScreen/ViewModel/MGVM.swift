//
//  MGVM.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 14/1/21.
//

import Foundation

class MgVM {
    
    let locale = NSLocale.current
    var preCountryDialCodesFirstOrder : NewMG.Response.country_dial_codes_as_frist_order?
    
    //WeCMS_MG
    func requestMG(shouldShowLoading: Bool = true, completion: @escaping (Swift.Result<WeCMS_MG.Response?, NSError>) -> Void = { _ in }) {
        
        let requestBody = WeCMS_MG.Request()
        
//        DataAccess.shared.request(apiKey: .MG, body: requestBody, responseType: WeCMS_MG.Response.self) { (result) in
//            switch result {
//            case .success(let data):
//                completion(.success(data))
//
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
        
        DataAccess.shared.fetchData(shouldShowLoading: shouldShowLoading, apiKey: .MG, body: requestBody, responseType: WeCMS_MG.Response.self) { (result) in
            switch result {
            case .success(let data):
                Shared.c_base_url = data._tran_res_data?.first?.c_bizplay_url ?? ""
                completion(.success(data))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestDebugMG(completion: @escaping (Swift.Result<NewMG.Response?, NSError>) -> Void = { _ in }) {
        
        let requestBody = NewMG.Request()
        
        DataAccess.shared.fetchNewMG(shouldShowLoading: false, apiKey: .AppSetting, httpMethod: .GET, body: requestBody, responseType: NewMG.Response.self) { (result) in
            switch result {
            case .success(var data):
                
                switch Shared.environment {
                case .Development:
                    Shared.c_base_url = data.c_base_url_wecms ?? ""
                    Shared.c_web_base_url = data.c_web_base_url_wecms ?? ""

                case .UAT:
                    Shared.c_base_url = data.c_base_url_wecms_uat ?? ""
                    Shared.c_web_base_url = data.c_web_base_url_wecms_uat ?? ""

                case .Production:
                    Shared.c_base_url = data.c_base_url_wecms ?? ""
                    Shared.c_web_base_url = data.c_web_base_url_wecms ?? ""
                }
                Shared.c_inform_ver         = data.c_inform_ver ?? ""
 
                // Đưa quốc gia của người dùng lên đầu danh sách mã vùng
                do {
                    
                    // Get index if local region match with country_dial_codes_as_frist_order.code from API
                    let index = data.country_dial_codes_as_frist_order.firstIndex(where: { $0.code == self.locale.regionCode })
                    
                    // Save data before delete
                    self.preCountryDialCodesFirstOrder = data.country_dial_codes_as_frist_order[index ?? 0]
                    
                    data.country_dial_codes_as_frist_order.remove(at: index ?? 0)
                    data.country_dial_codes_as_frist_order.insert(self.preCountryDialCodesFirstOrder!, at: 0)
                }
                
                completion(.success(data))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
     
    
    func isAppVersionSmallerThan(storeVersion: String) -> Bool {
        // Ex: 1.0.1
        // -> Major.Minor.Patch
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            let appMajor = Int(appVersion.components(separatedBy: ".")[0]) ?? 0
            let appMinor = Int(appVersion.components(separatedBy: ".")[1]) ?? 0
            let appPatch = Int(appVersion.components(separatedBy: ".")[2]) ?? 0
            
            let storeMajor = Int(storeVersion.components(separatedBy: ".")[0]) ?? 0
            let storeMinor = Int(storeVersion.components(separatedBy: ".")[1]) ?? 0
            let storePatch = Int(storeVersion.components(separatedBy: ".")[2]) ?? 0
            
            if appMajor > storeMajor {
                return false
            }
            else if appMajor == storeMajor {
                if appMinor > storeMinor {
                    return false
                }
                else if appMinor == storeMinor {
                    if appPatch >= storePatch {
                        return false
                    }
                }
            }
            
            return true
        }
        return true
    }
}

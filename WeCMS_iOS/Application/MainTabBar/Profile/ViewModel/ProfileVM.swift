//
//  ProfileVM.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 15/1/21.
//

import Foundation


class ProfileVM {
    
    func logOut(Device_ID: String, completion: @escaping (Swift.Result<MREC_R003.RESPONSE, NSError>) -> Void) {
        let body = MREC_R003.REQUEST(DEVICE_ID: Device_ID)
        DataAccess.shared.fetchData(apiKey: APIKey.MREC_R003, body: body, responseType: MREC_R003.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                KeychainManager.deleteCredential("username")
                KeychainManager.deleteCredential("password")
                
                Shared.R002_DATA    = nil
                Shared.API_SEQ_NO   = ""
                
                MyDefaults.set(key: .firstTimeRunApp, value: nil)
                UIApplication.shared.applicationIconBadgeNumber = 0
                Shared.badgeCount = 0
                
                completion(.success(data))
                //disconnect session time
                DataAccess.shared.startSessionTimeout(isStart: false)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

//
//  LoginVm.swift
//  WABOOKS_iOS_V2
//
//  Created by Thea Chum on 14/1/21.
//

import Foundation

class LoginVM {
    
    //Check Business Est
    func requestR001(USER_ID: String, PWD: String, completion: @escaping (Swift.Result<WABOOKS_MREC_R001.RESPONSE?, NSError>) -> Void) {
        
        let requestBody = WABOOKS_MREC_R001.REQUEST(USER_ID: USER_ID, USER_PW: PWD)
        
        DataAccess.shared.fetchData(shouldShowLoading: true, apiKey: .WABOOKS_MREC_R001, body: requestBody, responseType: WABOOKS_MREC_R001.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                Shared.R001_DATA = data
                completion(.success(data))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

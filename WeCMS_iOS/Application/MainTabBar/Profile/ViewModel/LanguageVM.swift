//
//  LanguageVM.swift
//  WeCMS_iOS
//
//  Created by test on 7/6/21.
//

import Foundation

class LanguageVM {
    
    func fetchingU002(lang_code: String, completion: @escaping (Swift.Result<MREC_U002.RESPONSE, NSError>) -> Void) {
        
        // let body = MREC_U002.REQUEST(LANG_CODE: lang_code)
        let body = MREC_U002.REQUEST(LANG_CODE: lang_code, DEVICE_ID: UIDevice.current.identifierForVendor?.uuidString ?? "")
        DataAccess.shared.fetchData(apiKey: APIKey.MREC_U002, body: body, responseType: MREC_U002.RESPONSE.self) { (result) in
            
            switch result {
            case .success(let data):
                
                completion(.success(data))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
}

//
//  LanguageVM.swift
//  WABOOKS_iOS_V2
//
//  Created by test on 7/6/21.
//

import Foundation

class LanguageVM {
    
    func fetchingU002(lang_code: String, completion: @escaping (Swift.Result<WABOOKS_MREC_U002.RESPONSE, NSError>) -> Void) {
        
        // let body = WABOOKS_MREC_U002.REQUEST(LANG_CODE: lang_code)
        let body = WABOOKS_MREC_U002.REQUEST(LANG_CODE: lang_code, DEVICE_ID: UIDevice.current.identifierForVendor?.uuidString ?? "")
        DataAccess.shared.fetchData(apiKey: APIKey.WABOOKS_MREC_U002, body: body, responseType: WABOOKS_MREC_U002.RESPONSE.self) { (result) in
            
            switch result {
            case .success(let data):
                
                completion(.success(data))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
}

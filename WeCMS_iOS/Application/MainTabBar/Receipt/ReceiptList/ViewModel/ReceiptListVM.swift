//
//  ReceiptListVM.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 14/1/21.
//

import Foundation
 
class ReceiptListVM {
  
    var responseList : MREC_R006.RESPONSE?
    private(set) var requestBody  : MREC_R006.REQUEST?
    var isShowLoading             : Bool = false
    
    func fetching( body: MREC_R006.REQUEST,  completion: @escaping (NSError?) -> Void) {
 
        DataAccess.shared.fetchData(shouldShowLoading   : isShowLoading,
                                    apiKey              : APIKey.MREC_R006,
                                    body                : body,
                                    responseType        : MREC_R006.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                self.isShowLoading = true
                self.responseList = data
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
  
}

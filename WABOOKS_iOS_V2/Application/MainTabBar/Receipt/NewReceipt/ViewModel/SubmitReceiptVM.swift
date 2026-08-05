//
//  NewReceiptVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 12/1/21.
//

import Foundation

protocol getDataDelegate {
    func getCurrencyValue(value: String, isReset: Bool)
}
 
class SubmitReceiptVM {
    
    private(set) var reponseC003 : WABOOKS_MREC_C003.RESPONSE?
    private(set) var reponseR040 : WABOOKS_MREC_R040.RESPONSE?
    private(set) var reponseR050 : WABOOKS_MREC_R050.RESPONSE?
    private(set) var responseR012: WABOOKS_MREC_R012.RESPONSE?
    
    func deleteImage(body: WABOOKS_MREC_D001.REQUEST, completion: @escaping (NSError?) -> Void) {
        
        DataAccess.shared.fetchData(apiKey      : .WABOOKS_MREC_D001,
                                    body        : body,
                                    responseType: WABOOKS_MREC_D001.RESPONSE.self) { (result) in
            switch result {
            case .success(_):
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func checkProjectSite(body: WABOOKS_MREC_R012.REQUEST, completion: @escaping (NSError?) -> Void) {
        DataAccess.shared.fetchData(apiKey: .WABOOKS_MREC_R012, body: body, responseType: WABOOKS_MREC_R012.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                self.responseR012 = data
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func createReceipt(body: WABOOKS_MREC_C003.REQUEST, completion: @escaping (NSError?) -> Void) {
         
        DataAccess.shared.fetchData(apiKey      : .WABOOKS_MREC_C003,
                                    body        : body,
                                    responseType: WABOOKS_MREC_C003.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                self.reponseC003 = data
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func fetchingExchangedRate(body: WABOOKS_MREC_R040.REQUEST, completion: @escaping (NSError?) -> Void) {
         
        DataAccess.shared.fetchData(shouldShowLoading   : false ,
                                    apiKey              : .WABOOKS_MREC_R040,
                                    body                : body,
                                    responseType        : WABOOKS_MREC_R040.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                self.reponseR040 = data
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func fetchingReceiptNo(completion: @escaping (NSError?) -> ()) {
        let body = WABOOKS_MREC_R050.REQUEST()
        DataAccess.shared.fetchData(shouldShowLoading   : false,
                                    apiKey              : .WABOOKS_MREC_R050,
                                    body                : body,
                                    responseType        : WABOOKS_MREC_R050.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                self.reponseR050 = data
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
}

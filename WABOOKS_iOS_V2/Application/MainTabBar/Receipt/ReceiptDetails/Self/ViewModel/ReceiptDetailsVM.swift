//
//  ReceiptDetailsVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 15/1/21.
//

import Foundation
 
class ReceiptDetailsVM {
    
    var receiptDetailApprovalResponse    : WABOOKS_MREC_R009.RESPONSE?
    var response                         : WABOOKS_MREC_C004.RESPONSE?
    
    func updateOrDelete(body        : WABOOKS_MREC_C004.REQUEST,
                        completion  : @escaping (Swift.Result<WABOOKS_MREC_C004.RESPONSE, NSError>) -> Void) {
        
        DataAccess.shared.fetchData(apiKey      : .WABOOKS_MREC_C004,
                                    body        : body,
                                    responseType: WABOOKS_MREC_C004.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                self.response = data
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    

    // MARK: - fetchReceiptDetailModelView
    func fetchReceiptDetail (body: WABOOKS_MREC_R009.REQUEST, completion:@escaping (Swift.Result<WABOOKS_MREC_R009.RESPONSE, NSError>) -> Void) {
        DataAccess.shared.fetchData(apiKey: .WABOOKS_MREC_R009,
                                    body: body,
                                    responseType: WABOOKS_MREC_R009.RESPONSE.self) { result in
            switch result {
            case .success(let data) :
                print("from Api \(data)")
                self.receiptDetailApprovalResponse = data
                
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
     
}

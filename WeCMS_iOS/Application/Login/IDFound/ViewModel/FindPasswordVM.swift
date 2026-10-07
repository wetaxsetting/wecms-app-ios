//
//  FindPasswordVM.swift
//  WeCMS_iOS
//
//  Created by Nyta on 24/5/21.
//

import Foundation

class FindPasswordVM {
    
    func request_MREC_MBMR_0003_R003(body: MREC_MBMR_0003_R003.REQUEST, completion: @escaping (Swift.Result<MREC_MBMR_0003_R003.RESPONE?, NSError>) -> Void = { _ in }) {
        
        DataAccess.shared.fetchData(apiKey: .MREC_MBMR_0003_R003, body: body, responseType: MREC_MBMR_0003_R003.RESPONE.self){ (result) in
            switch result {
            case .success (let data) :
                completion(.success(data))
            case.failure(let error) :
                completion(.failure(error))
            }
        }
    }
}

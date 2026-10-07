//
//  ResetPasswordVM.swift
//  WeCMS_iOS
//
//  Created by Nyta on 20/5/21.
//

import Foundation

class ResetPasswordVM {
    
    func resetPW_MREC_MBMR_0003_U001(body: MREC_MBMR_0003_U001.REQUEST, completion: @escaping (Swift.Result<MREC_MBMR_0003_U001.RESPONE?, NSError>) -> Void = { _ in }) {

        DataAccess.shared.fetchData(apiKey: APIKey.MREC_MBMR_0003_U001, body: body, responseType: MREC_MBMR_0003_U001.RESPONE.self){ (result) in
            switch result {
            case .success (let data) :
                completion(.success(data))
            case.failure(let error) :
                completion(.failure(error))
            }
        }
    }
}



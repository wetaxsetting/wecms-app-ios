//
//  IDFoundVM.swift
//  WeCMS_iOS
//
//  Created by Nyta on 20/5/21.
//

import Foundation

class IDFoundVM{
    
    func requesdt_MREC_MBMR_0002_R003(vcType: VCType, body: MREC_MBMR_0002_R003.REQUEST, completion: @escaping (Swift.Result<MREC_MBMR_0002_R003.RESPONE?, NSError>) -> Void = { _ in }) {
        
        DataAccess.shared.fetchData(apiKey: vcType == .ForgetID ? .MREC_MBMR_0002_R003 : .MREC_MBMR_0003_R003, body: body, responseType: MREC_MBMR_0002_R003.RESPONE.self){ (result) in
            switch result {
            case .success (let data) :
                completion(.success(data))
            case.failure(let error) :
                completion(.failure(error))
            }
        }
    }
}

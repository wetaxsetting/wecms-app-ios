//
//  AddressVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 7/6/21.
//

import Foundation

protocol addressDelegate {
    func getAddess(data: [String])
}

class AddressVM {
    
    func searchCoutry(body: WABOOKS_MREC_R020.Request, completion: @escaping (Swift.Result<WABOOKS_MREC_R020.Respone, NSError>) -> Void = { _ in }) {

        DataAccess.shared.fetchData(apiKey: APIKey.WABOOKS_MREC_R020, body: body, responseType: WABOOKS_MREC_R020.Respone.self){ (result) in
            switch result {
            case .success (let data) :
                completion(.success(data))
            case.failure(let error) :
                completion(.failure(error))
            }
        }
    }
}


//
//  ContactListVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 7/6/21.
//

import Foundation


protocol getContactListDelegate {
    func getREC030_REC1(data: WABOOKS_MREC_R030.REC1, selectIndexPath: IndexPath?)
    func getREC030_REC2(data: WABOOKS_MREC_R030.REC2, selectIndexPath: IndexPath?)
}

class ContactListVM {
    
    func searchContact(body: WABOOKS_MREC_R030.Request, completion: @escaping (Swift.Result<WABOOKS_MREC_R030.Respone, NSError>) -> Void = { _ in }) {

        DataAccess.shared.fetchData(apiKey: APIKey.WABOOKS_MREC_R030, body: body, responseType: WABOOKS_MREC_R030.Respone.self){ (result) in
            switch result {
            case .success (let data) :
                completion(.success(data))
            case.failure(let error) :
                completion(.failure(error))
            }
        }
    }
}

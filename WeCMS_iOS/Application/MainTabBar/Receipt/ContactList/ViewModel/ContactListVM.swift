//
//  ContactListVM.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 7/6/21.
//

import Foundation


protocol getContactListDelegate {
    func getREC030_REC1(data: MREC_R030.REC1, selectIndexPath: IndexPath?)
    func getREC030_REC2(data: MREC_R030.REC2, selectIndexPath: IndexPath?)
}

class ContactListVM {
    
    func searchContact(body: MREC_R030.Request, completion: @escaping (Swift.Result<MREC_R030.Respone, NSError>) -> Void = { _ in }) {

        DataAccess.shared.fetchData(apiKey: APIKey.MREC_R030, body: body, responseType: MREC_R030.Respone.self){ (result) in
            switch result {
            case .success (let data) :
                completion(.success(data))
            case.failure(let error) :
                completion(.failure(error))
            }
        }
    }
}

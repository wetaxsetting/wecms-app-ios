//
//  PushNotificationVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Thea Chum on 20/1/21.
//

import Foundation

class PushNotificationVM {
    
    func pushNotification_C006(shouldShowLoading: Bool = false, reqBody:WABOOKS_MREC_C006.REQUEST,completion: @escaping (NSError?)->Void = { _ in }) {
        DataAccess.shared.fetchData(shouldShowLoading: shouldShowLoading, apiKey: APIKey.WABOOKS_MREC_C006,
                                    body: reqBody,
                                    responseType: WABOOKS_MREC_C006.RESPONSE.self) { (result) in
            switch result {
            case .success (_) :
                completion(nil)
            case.failure(let error) :
                completion(error)
            }
        }
    }
    
}

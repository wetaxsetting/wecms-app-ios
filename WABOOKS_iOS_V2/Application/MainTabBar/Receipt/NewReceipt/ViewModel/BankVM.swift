//
//  BankVM.swift
//  WABOOKS_iOS_V2
//

import Foundation

class BankVM {
       
    var sortedBankList : [WABOOKS_MREC_R008.RESPONSE.REC]?
     
    func fetchBankList(body: WABOOKS_MREC_R008.REQUEST, completion: @escaping (Swift.Result<WABOOKS_MREC_R008.RESPONSE, NSError>) -> Void = { _ in }) {

        DataAccess.shared.fetchData(apiKey: APIKey.WABOOKS_MREC_R008, body: body, responseType: WABOOKS_MREC_R008.RESPONSE.self){ (result) in
            switch result {
            case .success (let data) :
                self.sortedBankList = data.REC?.sorted(by: { $0.BANK_NM ?? "" < $1.BANK_NM ?? ""})
                
            case.failure(let error) :
                completion(.failure(error))
            }
        }
    }
}

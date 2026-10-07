//
//  BankVM.swift
//  WeCMS_iOS
//

import Foundation

class BankVM {
       
    var sortedBankList : [MREC_R008.RESPONSE.REC]?
     
    func fetchBankList(body: MREC_R008.REQUEST, completion: @escaping (Swift.Result<MREC_R008.RESPONSE, NSError>) -> Void = { _ in }) {

        DataAccess.shared.fetchData(apiKey: APIKey.MREC_R008, body: body, responseType: MREC_R008.RESPONSE.self){ (result) in
            switch result {
            case .success (let data) :
                self.sortedBankList = data.REC?.sorted(by: { $0.BANK_NM ?? "" < $1.BANK_NM ?? ""})
                
            case.failure(let error) :
                completion(.failure(error))
            }
        }
    }
}

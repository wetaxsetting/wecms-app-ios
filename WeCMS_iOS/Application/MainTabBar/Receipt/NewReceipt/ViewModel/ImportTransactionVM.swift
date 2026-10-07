//
//  ImportTransactionVM.swift
//  WeCMS_iOS
//
//  Created by Bun on 21/10/22.
//

import Foundation
 
class ImportTransactionVM {
      
    // For display data
    var importTransactionData       : MREC_R007.RESPONSE?
     
    func fetchTransactionList(body: MREC_R007.REQUEST, completion: @escaping (Swift.Result<MREC_R007.RESPONSE, NSError>) -> Void = { _ in }) {

        DataAccess.shared.fetchData(apiKey: APIKey.MREC_R007, body: body, responseType: MREC_R007.RESPONSE.self){ (result) in
            switch result {
            case .success (var data) :
                
                // To display No matching View when data from API empty
                if data.REC?.isEmpty ?? false {
                    data.REC?.append(MREC_R007.RESPONSE.REC(TRSC_DT: "", BANK_CD: "", BANK_NM: "", ACCT_NO: "", ACCT_SEQ_NO: "", CCY_CD: "", TRSC_AMT: "", RMRK: ""))
                }
                
                self.importTransactionData = data
                
                for index in 0..<(data.REC?.count ?? 0) {
                    self.importTransactionData?.REC?[index].isSelectedTransaction = false
                }
                
                completion(.success(data))
            case.failure(let error) :
                completion(.failure(error))
            }
        }
    }
}

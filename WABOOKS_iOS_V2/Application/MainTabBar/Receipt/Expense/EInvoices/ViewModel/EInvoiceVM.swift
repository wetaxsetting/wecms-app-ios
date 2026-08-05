//
//  EInvoiceVM.swift
//  WABOOKS
//
//  Created by kimlang on 3/27/23.
//

import Foundation

class EInvoiceVM {
    
    var eInvoice_userListResponse   : WABOOKS_MREC_R060.RESPONSE?
    var cells : [EInvoiceModel] = []
    
    func fectchEInvoiceList(TRCO_TAX_ID: String, TOTL_AMT: String, FROM_DT: String, TO_DT: String, completion: @escaping (NSError?)->Void) {
        let reqBody = WABOOKS_MREC_R060.REQUEST(TRCO_TAX_ID: TRCO_TAX_ID, TOTL_AMT: TOTL_AMT, FROM_DT: FROM_DT, TO_DT: TO_DT)
        
        DataAccess.shared.fetchData(apiKey: APIKey.WABOOKS_MREC_R060, body: reqBody, responseType: WABOOKS_MREC_R060.RESPONSE.self) { (result) in
            switch result {
            case .success(let data) :
                self.cells = []
                self.eInvoice_userListResponse = data
                let isENLanguage = Shared.language == .English
                for index in 0..<(data.REC.count) {
                    self.cells.append(EInvoiceModel(title: isENLanguage ? self.eInvoice_userListResponse?.REC[index].TRCO_CMENM : self.eInvoice_userListResponse?.REC[index].TRCO_CMNM, taxID: self.eInvoice_userListResponse?.REC[index].TRCO_TAX_ID, docID: self.eInvoice_userListResponse?.REC[index].DOC_ID, handDocID: self.eInvoice_userListResponse?.REC[index].HAND_DOC_ID, icon: "", balance: self.eInvoice_userListResponse?.REC[index].TOTL_AMT, date: self.eInvoice_userListResponse?.REC[index].ISSU_DT, isSelectItem: false))
                }
                completion(nil)
            case.failure(let error) :
                completion(error)
            }
        }
    }
    
    func submitEInvoice(DOC_ID: String, EINV_CON_DOC_ID: String, completion: @escaping (Result<WABOOKS_MREC_U003.RESPONSE, NSError>) -> ()) {
        let reqBody = WABOOKS_MREC_U003.REQUEST(DOC_ID: DOC_ID, EINV_CON_DOC_ID: EINV_CON_DOC_ID)
        
        DataAccess.shared.fetchData(apiKey: .WABOOKS_MREC_U003, body: reqBody, responseType: WABOOKS_MREC_U003.RESPONSE.self, completion: { result in
            switch result {
            case .success(let data):
                completion(.success(data))
                
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
}

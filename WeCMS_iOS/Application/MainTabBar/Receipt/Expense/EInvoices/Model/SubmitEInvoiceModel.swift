//
//  SubmitEInvoiceModel.swift
//  WeCMS_iOS
//
//  Created by Bun on 12/4/23.
//

import Foundation

struct MREC_U003 {
    
    struct REQUEST: Encodable {
        let DOC_ID          : String    // 문서ID
        let EINV_CON_DOC_ID : String    // e-invoice 연결문서 ID
    }
    
    struct RESPONSE: Decodable {

    }
}

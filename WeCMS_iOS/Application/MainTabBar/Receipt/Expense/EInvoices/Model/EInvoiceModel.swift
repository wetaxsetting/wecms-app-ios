//
//  EInvoiceModel.swift
//  warBookScreen
//
//  Created by kimlang on 3/27/23.
//

import Foundation



struct EInvoiceModel {
    var title           : String?
    var taxID           : String?
    var docID           : String?
    var handDocID       : String?
    var icon            : String?
    var balance         : String?
    var date            : String?
    var isSelectItem    : Bool?
}

struct MREC_R060 {
    
    struct REQUEST: Encodable {
        let TRCO_TAX_ID : String?   //  거래처세금ID (customer tax id)
        let TOTL_AMT    : String?   // 총금액 (a lump sum)
        let FROM_DT     : String?   // 검색일자 From (Search date From)
        let TO_DT       : String?    // 검색일자 To
    }
    
    struct RESPONSE: Decodable {
        let REC     : [REC]         // 목록 (List)
        struct REC: Decodable {
            let DOC_ID      : String?    //문서ID (Document ID)
            let TRCO_CMNM   : String?    // 거래처회사명 (Business partner company name)
            let TRCO_CMENM  : String?    // 거래처회사영문명 (Customer company English name)
            let TRCO_TAX_ID : String?    // 거래처세금ID Customer tax ID
            let ISSU_DT     : String?    // 발행일자 (Issue date)
            let HAND_DOC_ID : String?    // Handwritten document number
            let TOTL_AMT    : String?
            
        }
    }
}

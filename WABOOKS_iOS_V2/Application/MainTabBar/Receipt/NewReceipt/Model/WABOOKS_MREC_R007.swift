//
//  WABOOKS_MREC_R007.swift
//  WABOOKS_iOS_V2
//
//  Created by Bun on 21/10/22.
//

import Foundation

enum ImportTransactionRowType: Codable {
    case topView
    case listView
}
 
// Search Transaction
struct WABOOKS_MREC_R007 {
     
    struct REQUEST: Encodable {
        let TRSC_AMT    : String    // 거래금액
        let CCY_CD      : String    // 통화코드
        let FROM_DT     : String    // 검색일자 From
        let TO_DT       : String    // 검색일자 To
    }
    
    struct RESPONSE: Decodable {
        var REC : [REC]?
         
        struct REC: Decodable {
            // Start Model from API Document
            let TRSC_DT     : String    // 거래일자
            let BANK_CD     : String    // 은행코드
            let BANK_NM     : String    // 은행명
            let ACCT_NO     : String    // 계좌번호
            let ACCT_SEQ_NO : String    // 계좌일련번호
            let CCY_CD      : String    // 통화코드
            let TRSC_AMT    : String    // 거래금액
            let RMRK        : String    // 적요
            // End Model from API Document
            
            // Start Extra data for UI
            var isSelectedTransaction   : Bool?
            var FROM_DT                 : String?
            var TO_DT                   : String?
            // End Extra data for UI
        }
    }
}

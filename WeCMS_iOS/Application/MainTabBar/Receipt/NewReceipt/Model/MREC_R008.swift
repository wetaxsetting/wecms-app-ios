//
//  MREC_R008.swift
//  WeCMS_iOS
//

import Foundation


struct MREC_R008 {
     
    struct REQUEST: Encodable {
        let LANG_CODE       : String    // 언어코드
        let BANK_NM         : String    // 은행명
        let IS_SCRAPPING    : String    // 스크래핑지원여부
        let USE_SHORT_NAME  : String    // Short Name 사용여부
    }
    
    struct RESPONSE: Decodable {
        var REC : [REC]?
         
        struct REC: Decodable {
            let BANK_CD     : String?   // 은행코드
            let BANK_NM     : String?   // 은행명
            let IMG         : String?   // 이미지경로
        }
    }
}


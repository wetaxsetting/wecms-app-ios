//
//  MREC_R001.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 14/1/21.
//

import Foundation

/**
    API: MREC_R001 - 사업장조회
 **/

struct MREC_R001 {
    
    struct REQUEST: Encodable {
        let USER_ID     : String    // 사용자ID
        let USER_PW     : String    // 사용자비밀번호
    }
    
    struct  RESPONSE: Decodable {
        let LOCK_YN     : String?    // 잠김여부 (v2023.1.0.7 add)
        let PW_ERR_CNT  : Int?    // 패스워드오류횟수 (v2023.1.0.7 add)
        let REC         : [REC]?
        struct  REC: Decodable {
            let BIZ_KEY     : String    // 사업자키
            let CMPN_NM     : String    // 회사명
            let CMPN_ENM    : String    // 회사영문명
            let TAX_ID      : String    // 세금ID
        }
    }
    
}

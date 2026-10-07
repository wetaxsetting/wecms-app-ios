//
//  mbmr_0003_001_r003.swift
//  WeCMS_iOS
//
//  Created by Nyta on 24/5/21.
//

import Foundation

struct MREC_MBMR_0003_R003 {
    
    struct REQUEST: Encodable {
        let USER_ID     : String    // 사용자ID
        let USER_NM     : String    // 사용자명
        let CLPH_NO     : String    // 휴대전화번호
        let VERI_KEY    : String    // 인증검증용KEY
    }
    
    struct RESPONE: Decodable {
        
        let REG_SEQ_NO : Int?
        
    }
}

//
//  mbmr_0002_001_r003.swift
//  WeCMS_iOS
//
//  Created by Nyta on 20/5/21.
//

import Foundation

struct MREC_MBMR_0002_R003 {
    
    struct REQUEST: Encodable {
        let USER_ID     : String?
        let USER_NM     : String?
        let CLPH_NO     : String?
        let VERI_KEY    : String?
    }
    
    struct RESPONE: Decodable {
        
        let USER_ID     : String?
        let USER_NM     : String?
        let CLPH_NO     : String?
        let VERI_KEY    : String?
         
        let REC : [REC]
        
        struct REC : Decodable {
            let USER_ID     : String    // 사용자ID
            let REG_DTM     : String    // 등록일시
            let USER_NM     : String    // 사용자명
            let CLPH_NO     : String    // 휴대전화번호
        }
        
    }
}

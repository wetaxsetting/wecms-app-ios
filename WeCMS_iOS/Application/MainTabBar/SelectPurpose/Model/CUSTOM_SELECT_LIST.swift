//
//  CUSTOM_SELECT_LIST.swift
//  WeCMS_iOS
//
//  Created by Thorn Loemkimleak on 10/27/21.
//

import Foundation


struct LIST_POP_UP_RESPONSE : Decodable {
    
    var USE_LIST    : [USE_LIST]
    var REC         : [REC]
    var REC2        : [REC2]
    var PROJECT_SITE_LIST : [PROJECT_SITE_LIST] = []
    
    struct USE_LIST : Decodable {
        
        let USE_USAG_CD : String        // 사용용도코드
        let USAG_NM     : String        // 용도명
        
    }
    
    struct PROJECT_SITE_LIST : Decodable {
        
        let PRJT_NO : String        // 사용용도코드
        let PRJT_NM : String        // 용도명
        
    }
    
    struct REC : Decodable {
        let USE_USAG_CD : String      // 사용용도코드
        let USAG_NM     : String         // 용도명
        let USAGE_RATE  : String

    }
    struct REC2 : Decodable {
        let ADV_PAYM_SEQ        : String
        let ADV_PAYM_NM         : String
        let ADV_PAYM_RSPB_ID    : String
        let USER_NM             : String
    }
    
    
    
}

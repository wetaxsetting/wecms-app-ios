//
//  MREC_R901.swift
//  WeCMS_iOS
//
//  Created by Thorn Loemkimleak on 10/27/21.
//

import Foundation

struct MREC_R901 {
    struct REQUEST: Encodable {
        let SRCH_WD        : String    //검색어      //"테이블에서 WITH_CD를 EQUAL SEARCH.추가로 WTH_NM 을 LIKE SEARCH."
                                                    //"※ 추가 Where 조건 , USE_YN= 'Y'BIZ_KEY : (Session)"
        
    }
    
    struct RESPONE : Decodable {

        let REC        : [REC]
        struct REC: Decodable {
//            let WITH_CD     : String   //품목코드
//            let WTH_NM      : String   //품목명
            let WHT_CD      : String   //품목코드
            let WHT_NM      : String   //품목명
            let TAX_RATE    : String   //품목규격
        }
        
    }
}

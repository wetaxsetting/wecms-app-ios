//
//  comm_0102_001.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 1/7/24.
//

import Foundation

struct comm_0102_001 {
    struct REQUEST: Encodable {
        let SRCH_WD        : String    //검색어      //"테이블에서 WITH_CD를 EQUAL SEARCH.추가로 WTH_NM 을 LIKE SEARCH."
                                                    //"※ 추가 Where 조건 , USE_YN= 'Y'BIZ_KEY : (Session)"
        
    }
    
    struct RESPONE : Decodable {

        let REC        : [REC]
        struct REC: Decodable {
            var PRJT_NO: String?
            var PRJT_NM: String?
        }
        
    }
}

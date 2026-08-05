//
//  WABOOKS_MREC_U001.swift
//  WABOOKS_iOS_V2
//
//  Created by Bung on 5/25/21.
//

import Foundation

/**
    API: WABOOKS_MREC_U001 - PUSH 디바이스 등록
 **/

struct WABOOKS_MREC_U001 {
    
    struct REQUEST: Encodable {
        let SEQ_NO          : Int
        let NOTI_CNFM_YN    : String
    }
    
    struct  RESPONSE: Decodable {
        let PUSH_BADGE_COUNT : Int?
    }
    
}

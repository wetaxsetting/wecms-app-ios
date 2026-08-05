//
//  WABOOKS_MREC_R003.swift
//  WABOOKS_iOS_V2
//
//  Created by Thea Chum on 15/1/21.
//

import Foundation

/**
    API: WABOOKS_MREC_R003 - 로그아웃
 **/

struct WABOOKS_MREC_R003 {
    
    struct REQUEST: Encodable {
        var DEVICE_ID: String
    }
    
    struct RESPONSE: Decodable { }
    
}

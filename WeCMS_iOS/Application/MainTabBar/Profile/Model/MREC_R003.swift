//
//  MREC_R003.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 15/1/21.
//

import Foundation

/**
    API: MREC_R003 - 로그아웃
 **/

struct MREC_R003 {
    
    struct REQUEST: Encodable {
        var DEVICE_ID: String
    }
    
    struct RESPONSE: Decodable { }
    
}

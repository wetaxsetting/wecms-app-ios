//
//  MREC_MBMR_0003_R002.swift
//  WeCMS_iOS
//
//  Created by Bung on 5/20/21.
//

import Foundation

struct MREC_MBMR_0003_R002 {
    
    struct REQUEST: Encodable {
        let USER_NM     : String
        let CLPH_NO     : String
        let CRTC_NUM    : String
    }
    
    struct RESPONSE : Decodable {
        let CRTC_YN     : String
    }
    
}

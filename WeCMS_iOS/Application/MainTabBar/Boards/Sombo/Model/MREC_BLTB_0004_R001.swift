//
//  MREC_BLTB_0004_R001.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

//  MREC_BLTB_0004_R001
struct MREC_BLTB_0004_R001 {
    
    struct REQUEST      : MREC_BLTB_0004_R002_REQUEST {
        
        var BLTB_CD     : String?
        var USER_NM     : String?
        
    }
    
    struct RESPONSE     : Decodable {
        
        let REC         : [REC]?
        
        struct REC              : MREC_BLTB_0004_R001_0004_R002_RES {
            
            var USER_NM         : String?
            var USER_ID         : String?
            var USER_IMG_URL    : String?
            var USER_IMG        : String?
        }
    }
}


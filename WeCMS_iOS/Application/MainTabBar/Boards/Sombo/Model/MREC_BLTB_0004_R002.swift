//
//  MREC_BLTB_0004_R002.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

//MARK: - MREC_BLTB_0004_R002
struct MREC_BLTB_0004_R002     {
    
    struct REQUEST      : MREC_BLTB_0004_R002_REQUEST     {
        
        var BLTB_CD     : String?
        var USER_NM     : String?
        
    }
    
    struct RESPONSE     : Decodable {
        
        let REC1        : [REC1]?
        
        struct REC1             : MREC_BLTB_0004_R001_0004_R002_RES {
            
            var USER_NM         : String?
            var USER_ID         : String?
            var USER_IMG_URL    : String?
            var USER_IMG        : String?
            let CLPH_NO         : String?
            
        }
    }
}


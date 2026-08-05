//
//  WABOOKS_MREC_BLTB_0002_R002.swift
//  WABOOKS_iOS_V2
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

// MARK: - WABOOKS_MREC_BLTB_0002_R002
struct WABOOKS_MREC_BLTB_0002_R002 {
    
    struct REQUEST      : WABOOKS_MREC_BLTB_0006_R001_0006_R002_0002_R002_REQUEST {
        
        var BLTB_CD     : String?
        var SRCH_WD     : String?

    }
    
    struct RESPONES     : Decodable {
        
        let REC                 :  [REC]?
        
        struct REC              : WABOOKS_MREC_BLTB_0002_R002_REC {
            
            var BLTB_CD         : String?
            var BLTB_NAME       : String?
            var CONT            : String?
            
        }
        
    }
}

//
//  MREC_BLTB_0002_R002.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

// MARK: - MREC_BLTB_0002_R002
struct MREC_BLTB_0002_R002 {
    
    struct REQUEST      : MREC_BLTB_0006_R001_0006_R002_0002_R002_REQUEST {
        
        var BLTB_CD     : String?
        var SRCH_WD     : String?

    }
    
    struct RESPONES     : Decodable {
        
        let REC                 :  [REC]?
        
        struct REC              : MREC_BLTB_0002_R002_REC {
            
            var BLTB_CD         : String?
            var BLTB_NAME       : String?
            var CONT            : String?
            
        }
        
    }
}

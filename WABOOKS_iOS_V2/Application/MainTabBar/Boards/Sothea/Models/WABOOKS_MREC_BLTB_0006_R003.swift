//
//  WABOOKS_MREC_BLTB_0006_R003.swift
//  WABOOKS_iOS_V2
//  Document flow link : https://flow.team/l/PDHpx
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

struct WABOOKS_MREC_BLTB_0006_R003 {
    
    struct REQUEST : WABOOKS_MREC_BLTB_0006_R001_0006_R002_0002_R002_REQUEST {
        var BLTB_CD     : String?
        var SRCH_WD     : String?
      
    }
    
    
    struct RESPONSE : WABOOKS_MREC_BLTB_0006_R003_0006_R001_0003_R001_RESPONSE  {
        
        var TOT_CNT         : String?
        var BLTB_NAME       : String?
        var CONT            : String?
        var BLTB_USER_TYPE  : String?
        var REC             :   [REC]?

        struct REC : WABOOKS_MREC_BLTB_0006_R001_0006_R002_0006_R003_REC {
            var MMB_TYPE: String?
            
            var BLTB_USER_TYPE: String?
            

            var USER_ID         : String?
            var USER_NM         : String?
            var USER_IMG_URL    : String?
    
            var USER_IMG        : String?
            
        }
    }
}

//
//  WABOOKS_MREC_BLTB_0005_D002.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 23/2/24.
//

import Foundation

struct WABOOKS_MREC_BLTB_0005_D002 {
    
    struct REQUEST              : WABOOKS_MREC_BLTB_0005_R001_0005_R002_0002_R003_0002_D001_0005_D001_REQUEST {
        
        var POST_SEQ_NO         : String?
        var BLTB_CD             : String?
        let COMNT_SEQ_NO        : String?
        let FILE_ID             : String?
    }
    
    struct RESPONSE : Decodable {
        
    }
}

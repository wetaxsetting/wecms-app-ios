//
//  MREC_BLTB_0002_D001.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

// MARK: - MREC_BLTB_0002_D001
struct MREC_BLTB_0002_D001  {
    
    struct REQUEST          : MREC_BLTB_0005_R001_0005_R002_0002_R003_0002_D001_0005_D001_REQUEST  {
        
        var POST_SEQ_NO     : String?
        var BLTB_CD         : String?
        
    }
    
    struct RESPONSE : Decodable {
        
    }
    
}

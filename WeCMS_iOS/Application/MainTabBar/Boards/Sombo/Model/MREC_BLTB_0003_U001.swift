//
//  MREC_BLTB_0003_U001.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

// MARK: - MREC_BLTB_0003_U001
struct MREC_BLTB_0003_U001  {
    
    struct REQUEST      : MREC_BLTB_0003_U001_REQUEST {
        
        var BLTB_CD             : String?
        var BLTB_NAME           : String?
        var CONT                : String?
    }
    
    struct RESPONSE : Decodable {
        
    }
    
}


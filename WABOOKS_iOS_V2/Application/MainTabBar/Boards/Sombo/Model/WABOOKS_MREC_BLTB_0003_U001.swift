//
//  WABOOKS_MREC_BLTB_0003_U001.swift
//  WABOOKS_iOS_V2
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

// MARK: - WABOOKS_MREC_BLTB_0003_U001
struct WABOOKS_MREC_BLTB_0003_U001  {
    
    struct REQUEST      : WABOOKS_MREC_BLTB_0003_U001_REQUEST {
        
        var BLTB_CD             : String?
        var BLTB_NAME           : String?
        var CONT                : String?
    }
    
    struct RESPONSE : Decodable {
        
    }
    
}


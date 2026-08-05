//
//  WABOOKS_MREC_BLTB_0001_C001.swift
//  WABOOKS_iOS_V2
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

// MARK: - WABOOKS_MREC_BLTB_0001_C001
struct WABOOKS_MREC_BLTB_0001_C001 {
    
    struct REQUEST          : WABOOKS_MREC_BLTB_0001_C001_REQUEST {
        
        var BLTB_NAME       : String?
        var CONT            : String?
    
    }
    struct RESPONSE : Decodable , Equatable {
        let BLTB_CD : String?
    }
    
}


//
//  MREC_BLTB_0001_C001.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

// MARK: - MREC_BLTB_0001_C001
struct MREC_BLTB_0001_C001 {
    
    struct REQUEST          : MREC_BLTB_0001_C001_REQUEST {
        
        var BLTB_NAME       : String?
        var CONT            : String?
    
    }
    struct RESPONSE : Decodable , Equatable {
        let BLTB_CD : String?
    }
    
}


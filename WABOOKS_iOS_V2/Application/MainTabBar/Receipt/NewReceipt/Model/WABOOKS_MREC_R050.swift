//
//  WABOOKS_MREC_R050.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 22/7/21.
//

import Foundation

struct WABOOKS_MREC_R050 {
      
    struct REQUEST : Encodable {
        
    }
    
    struct RESPONSE : Decodable {
        let DOC_ID : String? // 문서ID
    }
    
}

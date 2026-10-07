//
//  MREC_R050.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 22/7/21.
//

import Foundation

struct MREC_R050 {
      
    struct REQUEST : Encodable {
        
    }
    
    struct RESPONSE : Decodable {
        let DOC_ID : String? // 문서ID
    }
    
}

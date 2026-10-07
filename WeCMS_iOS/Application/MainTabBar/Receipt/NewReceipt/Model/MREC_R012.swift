//
//  MREC_R012.swift
//  WeCMS_iOS
//
//  Created by Seanghay Huort on 18/7/24.
//

import Foundation
struct MREC_R012 {
    
    struct REQUEST : Encodable {
        let ENV_SET_INF  : String // 환경설정정보
    }
    
    struct RESPONSE : Decodable {
        let ENV_SET_CONT : String // 환경설정내용
    }
    
}

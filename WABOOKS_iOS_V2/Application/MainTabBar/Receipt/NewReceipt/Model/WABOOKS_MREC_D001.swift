//
//  WABOOKS_MREC_D001.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 19/1/21.
//

import Foundation

/**
    API: WABOOKS_MREC_D001 - 사진삭제
 **/

struct WABOOKS_MREC_D001 {
    
    struct REQUEST : Encodable {
        let REG_DT  : String        // 등록일자
        let SEQ_NO  : String        // 일련번호
    }
    
    struct RESPONSE : Decodable {
        
    }
    
}

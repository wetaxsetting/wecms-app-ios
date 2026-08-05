//
//  WABOOKS_MREC_MBMR_0003_U001.swift
//  WABOOKS_iOS_V2
//
//  Created by Nyta on 20/5/21.
//

import Foundation

struct WABOOKS_MREC_MBMR_0003_U001 {
    
    struct REQUEST: Encodable {
            let REG_SEQ_NO  : Int
            let USER_ID     : String
            let USER_PW     : String
            let USER_PW2    : String
    }
    
    struct RESPONE: Decodable {
    }
}



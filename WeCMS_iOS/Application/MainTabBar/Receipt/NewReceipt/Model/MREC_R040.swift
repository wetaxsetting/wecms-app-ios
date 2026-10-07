//
//  MREC_R040.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 14/7/21.
//

import Foundation

struct MREC_R040 {
    
    struct REQUEST : Encodable {
        
        let INQ_DT      : String
        let REF_CCY_CD  : String
        let CCY_CD      : String
        
    }
    
    struct RESPONSE : Decodable {
        
        let UNIT_AMT    : String?
        let BASIC_AMT   : String?
        let BUY_AMT     : String?
        let SELL_AMT    : String?
        let REF_DATE    : String?
        
    }
     
}

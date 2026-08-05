//
//  ForgotModel.swift
//  WABOOKS_iOS_V2
//
//  Created by Bung on 5/20/21.
//

import Foundation
 
struct WABOOKS_MREC_MBMR_0002_R001 {
    
    struct REQUEST: Encodable {
        let USER_NM  : String
        let CLPH_NO  : String
    }
    
    struct RESPONSE : Decodable {
        let SND_RSLT : String
    }
    
}

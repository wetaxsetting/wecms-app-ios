//
//  MREC_BLTB_0006_U002.swift
//  WeCMS_iOS
//   Document flow link : https://flow.team/l/PDHpx
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

// MARK: - MREC_BLTB_0006_U002

struct MREC_BLTB_0006_U002  {
    
    struct REQUEST : MREC_BLTB_0006_D001_0006_D002_0006_R003_0006_C001_0006_U001_REQUEST {
        
        var BLTB_CD     : String?
        var USER_ID     : String?
        
        let  REC        : [REC]?
        
        struct REC      : Encodable, Equatable {
            
            let USER_ID : String?
        }
    }
    struct RESPONSE : Decodable , Equatable {
        
    }
}


//
//  MREC_BLTB_0001_R001.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

//Inquiry Boards
struct MREC_BLTB_0001_R001 {
    
    struct REQUEST: Encodable {
        
    }
    
    struct RESPONSE                 : Decodable {
        
        let REC                     : [REC]?
        let REC2                    : [REC2]?
        
        struct REC                  : MREC_BLTB_0001_R001_REC_REC2  {
            var DEL_YN: String?
            
            var CONT                : String?
            var TOT_CNT_NEW_POST    : String?
            var BLTB_CD             : String?
            var BLTB_NAME           : String?
            var BLTB_ICON           : String?
            var BLTB_USER_TYPE      : String?
            
        }
        struct REC2                 : MREC_BLTB_0001_R001_REC_REC2  {
            var DEL_YN: String?
            
            var CONT: String?
            
            
            var TOT_CNT_NEW_POST    : String?
            var BLTB_CD             : String?
            var BLTB_NAME           : String?
            var BLTB_ICON           : String?
            var BLTB_USER_TYPE      : String?
            let FAV_YN              : String?
    
        }
    }
}


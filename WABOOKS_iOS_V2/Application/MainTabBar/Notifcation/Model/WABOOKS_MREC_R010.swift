//
//  WABOOKS_MREC_R010.swift
//  WABOOKS_iOS_V2
//
//  Created by MacBook on 5/17/21.
//

import Foundation

struct WABOOKS_MREC_R010 {
    
    struct REQUEST : Encodable {
        let PAGE_NO         : Int
        let PAGE_PER_CNT    : Int
        let NOTI_TYPE       : String
    }
    
    struct RESPONSE: Decodable {
        let TOT_CNT         : Int?
        let PAGE_NO         : Int?
        let PAGE_PER_CNT    : Int?
        let NEXT_PAGE_YN    : String?
        let REC             : [REC]?
        
        struct REC : Decodable, Equatable {
            let SEQ_NO          : String?
            let SND_DATE        : String?
            let SND_TIME        : String?
            let DV_CD           : String?
            let CONT            : String?
            let REG_DT          : String?
            let REG_SEQ_NO      : String?
            var NOTI_CNFM_YN    : String?
            let CNFR_DTM        : String?
            
            let SND_ID          : String?
            let SND_NM          : String?
            let SND_IMG_URL     : String?
            let POST_APPR_DV    : String?
            let BLTB_CD         : String?
            let COMNT_SEQ_NO    : String?
            
        }
    }
}

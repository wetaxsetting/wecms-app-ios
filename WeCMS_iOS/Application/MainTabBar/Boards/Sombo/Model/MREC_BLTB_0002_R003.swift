//
//  MREC_BLTB_0002_R003.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

// MARK: - MREC_BLTB_0002_R003
struct MREC_BLTB_0002_R003 {
    
    struct REQUEST      : MREC_BLTB_0005_R001_0005_R002_0002_R003_0002_D001_0005_D001_REQUEST {
        
        var POST_SEQ_NO     : String?
        var BLTB_CD         : String?
        
    }
    
    struct RESPONES         : Decodable {
        
        let USER_IMG_URL    : String?
        let USER_IMG        : String?
        let REC             : [REC]?
        
        struct REC              : MREC_BLTB_0002_R003_REC {
            
            var REG_NM          : String?
            var REG_DTM         : String?
            var REG_ID          : String?
            var REG_IMG_URL     : String?
            var COMNT_CONT      : String?
            var BLTB_CD         : String?
            var POST_SEQ_NO     : String?
            var COMNT_SEQ_NO    : String?
            var COMNT_DV_CD     : String?
            var COMNT_TASK_CD   : String?
            let REC2            : [WeCMSStruct.REC_Protocol]?
        }
    }
}

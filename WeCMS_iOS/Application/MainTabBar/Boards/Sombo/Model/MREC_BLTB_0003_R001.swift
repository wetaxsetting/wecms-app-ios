//
//  MREC_BLTB_0003_R001.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation


// MARK: - MREC_BLTB_0003_R001
struct MREC_BLTB_0003_R001  {
    
    struct REQUEST : MREC_BLTB_0002_R004_0002_R001_0002_R005_0003_R001_REQUEST {
        
        var POST_TYPE_CD    : String?
        var SRCH_WD         : String?
        var PAGE_NO         : String?
        var PAGE_PER_CNT    : String?
        let BLTB_CD         : String?
        var FROM_DT         : String?
        var TO_DT           : String?
    }
    
    struct RESPONSE         : MREC_BLTB_0006_R003_0006_R001_0003_R001_RESPONSE {
        
        
        var TOT_CNT         : String?
        var BLTB_NAME       : String?
        var CONT            : String?
        var BLTB_USER_TYPE  : String?
        let TOT_CNT_ART     : String?
        let TOT_CNT_APPR    : String?
        let TOT_CNT_DRAFT   : String?
        let REC             : [REC]?
        
        struct REC          : MREC_BLTB_0005_R001_0005_R002_0003_R001_RESPONSE {
            
            var DRAFT_POST_SEQ_NO: String?
            
            var BLTB_CD: String?
            
            var POST_SEQ_NO: String?
            
            var POST_TITLE: String?
            
            var POST_TYPE_CD: String?
            
            var POST_STTS: String?
            
            var POST_APPR_DV: String?
            
            var REG_NM: String?
            
            var REG_ID: String?
            
            var REG_DTM: String?
            
            var REG_IMG_URL: String?
            
            var PIN_POST_TYPE: String?
            
            var PIN_POST_DUE_DT: String?
            
            var POST_CONT: String?
            
            var TOT_CMT: String?
            
            var READ_YN: String?
            
            var DEL_YN: String?
            
            var TOT_PAY_LOC_AMT: String?
            
            var TOT_PAY_USD_AMT: String?
            
            var APPR_SEQ_NO: String?
            
            var PAY_END_YN: String?
            
            var PAY_YN: String?
            
            var DOC_NO: String?
            
            var APPR_DV: String?
            
            var PAY_REQ_DATE: String?
            
            var PAY_DATE: String?
            
            var APPR_TYPE_CD: String?
            
            var APPRVR_TOT_CNT: String?
            
            var APPRVR_APPR_TOT_CNT: String?
            
            var APPR_STTS: String?
            
            var CMTNT_REG_NM: String?
            
            var COMNT_CONT: String?
            
            var COMNT_SEQ_NO: String?
            
            var COMNT_DV_CD: String?
            
            var COMNT_TASK_CD: String?
            
            
            
        }
        
    }
}


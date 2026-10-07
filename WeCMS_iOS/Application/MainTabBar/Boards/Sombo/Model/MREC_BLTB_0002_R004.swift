//
//  MREC_BLTB_0002_R004.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

// MARK: - MREC_BLTB_0002_R004

struct MREC_BLTB_0002_R004  {
    
    struct REQUEST         : MREC_BLTB_0002_R004_0002_R001_0002_R005_0003_R001_REQUEST {
        
        var POST_TYPE_CD        : String?
        var SRCH_WD             : String?
        var PAGE_NO             : String?
        var PAGE_PER_CNT        : String?

    }
    
    struct RESPONSE : MREC_BLTB_0002_R004_0002_R001_RESPONSE  {
        
        var TOT_CNT         : String?
        var TOT_CNT_ART     : String?
        var TOT_CNT_APPR    : String?
        var TOT_CNT_DRAFT   : String?
        let RES             : [RES]?
        
        struct   RES            :  MREC_BLTB_0002_R001_0002_R004_0002_R005_0002_R004 {
            
            var DRAFT_POST_SEQ_NO   : String?
            var BLTB_CD             : String?
            var POST_SEQ_NO         : String?
            var POST_TITLE          : String?
            var POST_TYPE_CD        : String?
            var POST_STTS           : String?
            var POST_APPR_DV        : String?
            var REG_NM              : String?
            var REG_ID              : String?
            var REG_DTM             : String?
            var REG_IMG_URL         : String?
            var PIN_POST_TYPE       : String?
            var PIN_POST_DUE_DT     : String?
            var POST_CONT           : String?
            var TOT_CMT             : String?
            var APPR_SEQ_NO         : String?
            var PAY_END_YN          : String?
            var PAY_YN              : String?
            var READ_YN             : String?
            var DEL_YN              : String?
            var APPR_TYPE_CD        : String?
            var APPRVR_TOT_CNT      : String?
            var APPRVR_APPR_TOT_CNT : String?
            
               
        }
    }
}

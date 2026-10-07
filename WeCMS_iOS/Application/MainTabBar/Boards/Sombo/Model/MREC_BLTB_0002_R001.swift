//
//  MREC_BLTB_0002_R001.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

// MARK: - MREC_BLTB_0002_R001
struct MREC_BLTB_0002_R001 {
    
    struct REQUEST          : MREC_BLTB_0002_R004_0002_R001_0002_R005_0003_R001_REQUEST   {
        
        var POST_APPR_TYPE_CD: String?
        var POST_TYPE_CD    : String?
        var SRCH_WD         : String?
        var PAGE_NO         : String?
        var PAGE_PER_CNT    : String?
        var FROM_DT         : String?
        var TO_DT           : String?
    }
    struct RESPONSE         : MREC_BLTB_0002_R004_0002_R001_RESPONSE {
        
        var TOT_CNT         : String?
        var TOT_CNT_ART     : String?
        var TOT_CNT_APPR    : String?
        var TOT_CNT_DRAFT   : String?
        var NEXT_PAGE_YN    : String?
        var TOT_CNT_APPR_AP : String?
        var TOT_CNT_APPR_RJ : String?
        var TOT_CNT_APPR_PP : String?
        var TOT_CNT_APPR_PD : String?
        
        var BLTB_NAME       : String?
        var CONT            : String?
        
        let REC             : [WeCMSStruct.BoardDetail_Protocol]?
        let REC2            : [WeCMSStruct.BoardDetail_Protocol]?
        
    }
}

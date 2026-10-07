//
//  MREC_BLTB_0005_U001.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation


struct MREC_BLTB_0005_U001 {
    
    struct REQUEST      : MREC_BLTB_0005_R001_0005_R002_0003_R001_RESPONSE {
        
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
        
        
        
//        var COMNT_CONT  : String?
        
        var REC_IN      : [REC_IN]?
        var REC         : [REC_IN]?
        var REC2        : [REC_IN]?
        var REC4        : [REC_IN]?
        var REC5        : [REC_IN]?
        var REC3        : [WeCMSStruct.REC3_Protocol]?
        
        struct REC_IN       : MREC_BLTB_0004_U001_0004_U002_REQUEST_REC2_REC3_0005_U001_0002_C001_0002_U001_REC {
            var COPY_FILE_YN: String?
            
            var ORG_FILE_NM: String?
            
            var SAVE_FILE_NM: String?
            
            var FILE_SIZE: String?
            
            
            var FILE_NM         : String?
            var FILE_DATA       : String?
        }
        
    }
    
    struct RESPONSE : Decodable {
        
    }
    
}


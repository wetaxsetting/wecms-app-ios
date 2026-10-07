//
//  WeCMSStruct.swift
//  WeCMS_iOS
//
//  Created by Udam Chheng on 15/8/25.
//

struct WeCMSStruct {
    
    struct REC_Protocol: MREC_BLTB_0005_R002_0005_R001_0002_R003 {
        
        var FILE_ID: String?
        
        var ORG_FILE_NM: String?
        
        var SAVE_FILE_NM: String?
        
        var FILE_SIZE: String?
        
        var FILE_URL: String?
        
        var FILE_TYPE: String?
        
    }
    
    struct REC3_Protocol : MREC_BLTB_0005_R002_REC {
        
        var APPRVR_ID: String?
        
        var APPRVR_IMG_URL: String?
        
        var APPR_DTM: String?
        
        var CCY_CD: String?
        
        var APPRVR_STTS: String?
        
        var APPRVR_LINE_NO: String?
        
        var APPRVR_NM: String?
        
    }
    
    struct RECDoc_Protocol : MREC_BLTB_0005_R002_0004_R003_REC {
        
        var DOC_ID: String?
        
        var ISSU_DT: String?
        
        var DOC_TYPE: String?
        
        var TRCO_KEY: String?
        
        var TRCO_CMNM: String?
        
        var TRCO_CMENM: String?
        
        var CCY_CD: String?
        
        var AMT: String?
        
        var MEMO: String?
        
        var BUSA_USAG_CD: String?
        
        var USAG_NM: String?
        
        var DISP_DOC_ID: String?
        
        var TRCO_TRSC_CCY_CD: String?
        
        var TOTL_AMT: String?
        
        var COLOR: String?
        
        var TRCO_TAX_ID: String?
        
        var APPR_DV: String?
        
        
        
    }
    
    struct BoardDetail_Protocol: MREC_BLTB_0005_R001_0005_R002_0003_R001_RESPONSE {
        
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

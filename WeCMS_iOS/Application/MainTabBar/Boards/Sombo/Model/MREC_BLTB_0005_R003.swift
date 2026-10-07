//
//  MREC_BLTB_0005_R003.swift
//  WeCMS_iOS
//
//  Created by Seanghay Huort on 14/2/24.
//

import Foundation

//> Seanghay <\\ Read Draft Article & Approval
struct MREC_BLTB_0005_R003 {
    struct REQUEST              : Encodable {
        var DRAFT_POST_SEQ_NO   : String?
        var BLTB_CD             : String?
        var POST_TYPE_CD        : String
    }
    
    struct RESPONSE                 : Decodable {
        var BLTB_CD                 : String?
        var DRAFT_POST_SEQ_NO       : String?
        var POST_TITLE              : String?
        var POST_TYPE_CD            : String?
        var POST_STTS               : String?
        var DRAFT_PIN_POST_TYPE     : String?
        var DRAFT_PIN_POST_DUE_DT   : String?
        var DRAFT_REG_PIN_POST_DATE : String?
        var POST_CONT               : String?
        var REC                     : [REC]
        var REC2                    : [REC2]
        var PAY_REQ_DATE            : String?
        var PAY_DATE                : String?
        var REQ_USER_ID             : String?
        var REQ_USER_NM             : String?
        var POST_APPR_DV            : String?
        var DOC_TYPE                : String?
        var AMT                     : String?
        var TOT_PAY_KHR_AMT         : String?
        var TOT_PAY_USD_AMT         : String?
        var REC3                    : [REC3]
        
        struct REC3: Decodable {
            var APPRVR_ID   : String?
            var APPRVR_NM   : String?
            var APPRVR_STTS : String?
            var APPRVR_IMG_URL : String?
        }
        
        struct REC2: Decodable {
            var BLTB_CD                 : String?
            var DRAFT_POST_SEQ_NO       : String?
            var DRAFT_POST_DETL_SEQ_NO  : String?
            var BUSA_USAG_CD            : String?
            var CCY_CD                  : String?
            var DOC_ID                  : String?
            var DOC_TYPE                : String?
            var MEMO                    : String?
            var TRCO_KEY                : String?
            var TRCO_CMNM               : String?
            var TRCO_CMENM              : String?
            var AMT                     : String?
            var USAG_NM                 : String?
        }
        
        struct REC: Decodable {
            var FILE_ID         : String?
            var ORG_FILE_NM     : String?
            var SAVE_FILE_NM    : String?
            var FILE_SIZE       : String?
            var FILE_URL        : String?
        }
    }
}

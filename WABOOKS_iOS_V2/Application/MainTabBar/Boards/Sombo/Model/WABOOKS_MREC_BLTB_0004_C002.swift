//
//  WABOOKS_MREC_BLTB_0004_C002.swift
//  WABOOKS_iOS_V2
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

//MARK: - WABOOKS_MREC_BLTB_0004_C002
struct WABOOKS_MREC_BLTB_0004_C002  {
    
    struct REQUEST                  : Encodable {
        
        let APPR_DV                 : String?
        let PAY_DATE                : String?
        let TOT_PAY_LOC_AMT         : Int?
        let TOT_PAY_USD_AMT         : Int?
        let SAL_REG_SEQ_NO          : String?
        let PAYM_AMT_BYDF           : String?
        let PAY_REQ_DATE            : String?
        let REF_DATA_CNT            : String?
        let APLY_EXCH_RATE          : Int?
        let DRAFT_POST_SEQ_NO       : String?
        let POST_TITLE              : String?
        let POST_APPR_DV            : String?
        let POST_CONT               : String?
        let POST_DRAFT_YN           : String?
        
        let REC1                    : [REC1]?
        let REC2                    : [REC2]?
        let REC5                    : [REC5]?
        let REC6                    : [REC6]?
        let REC3                    : [REC3]?
        
        struct REC1                  : Encodable , Equatable, Hashable {
            
            let TRCO_KEY            : String?
            var TRCO_NICK_NM        : String?
            let TRCO_CMNM           : String?
            let TRCO_CMENM          : String?
            let CCY_CD              : String?
            let AMT                 : String?
            var BUSA_USAG_CD        : String?
            let MEMO                : String?
            let DOC_ID              : String?
            var DOC_TYPE            : String?
            var USAG_NM             : String?
            var APPR_DV             : String? // Approval Divition
            
        }
        
        struct REC2                 : Encodable , Equatable {
            
            let NOTE                : String?
        }
        
        struct REC5                 : WABOOKS_MREC_BLTB_0002_U001_0004_C001_REC {
            var FILE_ID: String?

        }
        
        struct REC6                 : WABOOKS_MREC_BLTB_0004_U002_REC1 {
            
            var APPRVR_ID           : String?
            var APPRVR_NM           : String?
            var APPRVR_STTS         : String?
            var APPRVR_IMG_URL      : String?
            
        }
        
        struct REC3                 :WABOOKS_MREC_BLTB_0004_U001_0004_U002_REQUEST_REC2_REC3_0005_U001_0002_C001_0002_U001_REC {
            var ORG_FILE_NM: String?
            
            var SAVE_FILE_NM: String?
            
            var FILE_SIZE: String?
            
            var COPY_FILE_YN: String?
            
            
            var FILE_NM         : String?
            var FILE_DATA       : String?
            
       
            
        }
    }
    
    struct RESPONSE: Decodable {
        
    }
}


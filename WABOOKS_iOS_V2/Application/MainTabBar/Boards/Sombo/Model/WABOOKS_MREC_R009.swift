//
//  WABOOKS_MREC_R009.swift
//  WABOOKS_iOS_V2
//
//  Created by Hai Sombo on 2/3/24.
//

import Foundation

struct WABOOKS_MREC_R009 {
    
    struct REQUEST : Encodable  {
        
        let DOC_ID : String?
        
    }
    struct RESPONSE  : Decodable    {
        
        let INQ_GRP             : String?
        let DOC_ID              : String?
        let TRCO_CMNM           : String?
        let USE_DT              : String?
        let TRCO_TRSC_CCY_CD    : String?
        let TOTL_AMT            : String?
        let BUSA_USAG_CD        : String?
        var USAG_NM             : String?
        let CONT                : String?
        let USER_NM             : String?
        let PROV_STTS           : String?
        let RCPT_TYPE           : String?
        let TRSC_WEEK           : String?
        let SEQ_NO              : String?
        let REG_DT              : String?
        let PC_MOD_YN           : String?
        let ADV_PAYM_TRNS_SEQ   : String?
        let ADV_PAYM_SEQ    : String?
        let ADV_PAYM_NM     : String?
        let HAND_DOC_ID     : String?
        let TRCO_TYPE       : String?
        let TRCO_TAX_ID     : String?
        let APLY_EXCH_RATE  : String?
        let TRCO_RPRS_TLPH  : String?
        let GST_NO          : String?
        let EML             : String?
        let TRCO_BSUN_POST_ADRS : String?
        let TRCO_BSUN_DTL_ADRS  : String?
        let TRCO_BSUN_ST        : String?
        let TRCO_BSUN_CITY      : String?
        let TRCO_CMENM          : String?
        let WHT_CD              : String?
        let TAX_RATE            : String?
        let WHT_NM              : String?
        let PAY_WAY_CD          : String?
        let PAY_WAY_AMT         : String?
        let BANK_CD             : String?
        let BANK_NM             : String?
        let REF_NO              : String?
        let ACCT_NO             : String?
        let TRSC_DT2            : String?
        let CHEQ_NUM            : String?
        let EINV_CON_DOC_ID     : String?
        let TRCO_NICK_NM        : String?
        
        let REC1                : [REC1]
        
        struct REC1             : WABOOKS_MREC_R009_REC {
            
            var REG_DT: String?
            
            var SEQ_NO: String?
            
            var FILE_ID: String?
            
            var SAVE_FILE_NM: String?
            
            var FILE_URL: String?
            
            var ORG_FILE_NM: String?
            
            var FILE_SIZE: String?
            
        }
    }
    
}

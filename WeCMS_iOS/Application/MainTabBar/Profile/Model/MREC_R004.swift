//
//  MREC_R004.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 15/1/21.
//

import Foundation

import Foundation

/**
    API: MREC_R004 - 입력항목설정조회
 **/

struct MREC_R004 {
    
    struct REQUEST: Encodable { }
       
    struct RESPONSE: Codable {
        
        let INPUT_FIELD_SET_YN      : Bool
        let TRCO_TRSC_CCY_CD_YN     : Bool    // 거래처거래통화코드사용여부
        let TRSC_AMT_YN             : Bool    // 거래금액사용여부
        let TRCO_YN                 : Bool    // 거래처사용여부
        let TRSC_DT_YN              : Bool    // 거래일자사용여부
        let USAG_CD_YN              : Bool    // 용도사용여부
        let USER_NM_YN              : Bool    // 사용자명사용여부
        let PRJT_NO_YN              : Bool
    }
}

extension MREC_R004.RESPONSE {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let INPUT_FIELD_SET_YN  = try container.decode(String.self, forKey: .INPUT_FIELD_SET_YN)
        let TRCO_TRSC_CCY_CD_YN = try container.decode(String.self, forKey: .TRCO_TRSC_CCY_CD_YN)
        let TRSC_AMT_YN         = try container.decode(String.self, forKey: .TRSC_AMT_YN)
        let TRCO_YN             = try container.decode(String.self, forKey: .TRCO_YN)
        let TRSC_DT_YN          = try container.decode(String.self, forKey: .TRSC_DT_YN)
        let USAG_CD_YN          = try container.decode(String?.self, forKey: .USAG_CD_YN)
        let USER_NM_YN          = try container.decode(String.self, forKey: .USER_NM_YN)
        let PRJT_NO_YN          = try container.decode(String.self, forKey: .PRJT_NO_YN)
        
        self.init(
//            INPUT_FIELD_SET_YN  : INPUT_FIELD_SET_YN    == "Y",
//            TRCO_TRSC_CCY_CD_YN : TRCO_TRSC_CCY_CD_YN   == "Y",
//            TRSC_AMT_YN         : TRSC_AMT_YN           == "Y",
//            TRCO_YN             : TRCO_YN               == "Y",
//            TRSC_DT_YN          : TRSC_DT_YN            == "Y",
//            USAG_CD_YN          : USAG_CD_YN            == "Y",
//            USER_NM_YN          : USER_NM_YN            == "Y"
            
            INPUT_FIELD_SET_YN  : INPUT_FIELD_SET_YN    == "Y",
            TRCO_TRSC_CCY_CD_YN : TRCO_TRSC_CCY_CD_YN   == "Y",
            TRSC_AMT_YN         : TRSC_AMT_YN           == "Y",
            TRCO_YN             : TRCO_YN               == "Y",
            TRSC_DT_YN          : TRSC_DT_YN            == "Y",
            USAG_CD_YN          : USAG_CD_YN            == "Y",
            USER_NM_YN          : USER_NM_YN            == "Y",
            PRJT_NO_YN          : PRJT_NO_YN            == "Y"
        )
        
//        if INPUT_FIELD_SET_YN == "Y" {
//            self.init(
//                INPUT_FIELD_SET_YN  : INPUT_FIELD_SET_YN == INPUT_FIELD_SET_YN ? "Y" : "N"
//                TRCO_TRSC_CCY_CD_YN : TRCO_TRSC_CCY_CD_YN == INPUT_FIELD_SET_YN  ? "Y" : "N",
//                TRSC_AMT_YN         : INPUT_FIELD_SET_YN == "Y",
//                TRCO_YN             : INPUT_FIELD_SET_YN == "Y",
//                TRSC_DT_YN          : INPUT_FIELD_SET_YN == "Y",
//                USAG_CD_YN          : INPUT_FIELD_SET_YN == "Y",
//                USER_NM_YN          : INPUT_FIELD_SET_YN == "Y"
//            )
//        }
    }
}

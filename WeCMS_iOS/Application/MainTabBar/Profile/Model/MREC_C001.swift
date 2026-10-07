//
//  MREC_C001.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 15/1/21.
//

import Foundation

/**
    API: MREC_C001 - 입력항목설정변경
 **/

struct MREC_C001 {
    
    struct REQUEST2: Encodable {
        var INPUT_FIELD_SET_YN      : String
//        var TRCO_TRSC_CCY_CD_YN     : String    // 거래처거래통화코드사용여부    | FIELD_ID가 'TRCO_TRSC_CCY_CD'인 Row의 'USE_YN' 컬럼값
//        var TRSC_AMT_YN             : String    // 거래금액사용여부             | FIELD_ID가 'TRSC_AMT'인 Row의 'USE_YN' 컬럼값
//        var TRCO_YN                 : String    // 거래처사용여부              | FIELD_ID가 'TRCO_CMNM'인 Row의 'USE_YN' 컬럼값
//        var TRSC_DT_YN              : String    // 거래일자사용여부             | FIELD_ID가 'TRSC_DT'인 Row의 'USE_YN' 컬럼값
//        var USAG_CD_YN              : String    // 용도사용여부               | FIELD_ID가 'BUSA_USAG_CD'인 Row의 'USE_YN' 컬럼값
//        var USER_NM_YN              : String    // 사용자명사용여부             | FIELD_ID가 'USER_NM'인 Row의 'USE_YN' 컬럼값
//        var PRJT_NO_YN              : String
        
                                                //        위의 설명을 참조하여 테이블의 데이터 Update.
                                                //
                                                //        - 기타 Where 조건
                                                //        BIZ_KEY, USER_ID : 공통부
                                                //        WEB_SVC_ID : 'MREC_R004'
        
        
//        init(_ obj: MREC_R004.RESPONSE) {
//            self.INPUT_FIELD_SET_YN     = obj.INPUT_FIELD_SET_YN    ? "Y" : "N"
////            self.TRCO_TRSC_CCY_CD_YN    = obj.TRCO_TRSC_CCY_CD_YN   ? "Y" : "N"
////            self.TRSC_AMT_YN            = obj.TRSC_AMT_YN           ? "Y" : "N"
////            self.TRCO_YN                = obj.TRCO_YN               ? "Y" : "N"
////            self.TRSC_DT_YN             = obj.TRSC_DT_YN            ? "Y" : "N"
////            self.USAG_CD_YN             = obj.USAG_CD_YN            ? "Y" : "N"
////            self.USER_NM_YN             = obj.USER_NM_YN            ? "Y" : "N"
//            self.PRJT_NO_YN             = obj.PRJT_NO_YN            ? "Y" : "N"
//        }
    }
    
    struct REQUEST: Encodable {
        var INPUT_FIELD_SET_YN      : String
        var TRCO_TRSC_CCY_CD_YN     : String    // 거래처거래통화코드사용여부    | FIELD_ID가 'TRCO_TRSC_CCY_CD'인 Row의 'USE_YN' 컬럼값
        var TRSC_AMT_YN             : String    // 거래금액사용여부             | FIELD_ID가 'TRSC_AMT'인 Row의 'USE_YN' 컬럼값
        var TRCO_YN                 : String    // 거래처사용여부              | FIELD_ID가 'TRCO_CMNM'인 Row의 'USE_YN' 컬럼값
        var TRSC_DT_YN              : String    // 거래일자사용여부             | FIELD_ID가 'TRSC_DT'인 Row의 'USE_YN' 컬럼값
        var USAG_CD_YN              : String    // 용도사용여부               | FIELD_ID가 'BUSA_USAG_CD'인 Row의 'USE_YN' 컬럼값
        var USER_NM_YN              : String    // 사용자명사용여부             | FIELD_ID가 'USER_NM'인 Row의 'USE_YN' 컬럼값
//        var PRJT_NO_YN              : String    
        
                                                //        위의 설명을 참조하여 테이블의 데이터 Update.
                                                //
                                                //        - 기타 Where 조건
                                                //        BIZ_KEY, USER_ID : 공통부
                                                //        WEB_SVC_ID : 'MREC_R004'
        
        
        init(_ obj: MREC_R004.RESPONSE) {
            self.INPUT_FIELD_SET_YN     = obj.INPUT_FIELD_SET_YN    ? "Y" : "N"
            self.TRCO_TRSC_CCY_CD_YN    = obj.TRCO_TRSC_CCY_CD_YN   ? "Y" : "N"
            self.TRSC_AMT_YN            = obj.TRSC_AMT_YN           ? "Y" : "N"
            self.TRCO_YN                = obj.TRCO_YN               ? "Y" : "N"
            self.TRSC_DT_YN             = obj.TRSC_DT_YN            ? "Y" : "N"
            self.USAG_CD_YN             = obj.USAG_CD_YN            ? "Y" : "N"
            self.USER_NM_YN             = obj.USER_NM_YN            ? "Y" : "N"
//            self.PRJT_NO_YN             = obj.PRJT_NO_YN            ? "Y" : "N"
        }
    }
    
    struct RESPONSE: Decodable { }
    
}


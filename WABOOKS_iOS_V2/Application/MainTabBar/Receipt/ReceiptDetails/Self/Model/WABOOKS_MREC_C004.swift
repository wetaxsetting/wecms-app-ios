//
//  WABOOKS_MREC_C004.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 18/1/21.
//

import Foundation

/**
    API: WABOOKS_MREC_C004 - 영수증수정
 **/

struct WABOOKS_MREC_C004 {
    
    struct REQUEST: Encodable {
        let CORR_TYPE           : String    // 수정타입         |   U : 수정, D : 삭제
        let DOC_ID              : String    // 문서ID          |   1, 2번 테이블 WHERE 조건
        let TRCO_CMNM           : String    // 거래처회사명      |   CORR_TYPE이 'U'일 때 1, 2번 테이블 UPDATE
        let USE_DT              : String    // 사용일시         |   CORR_TYPE이 'U'일 때 1, 2번 테이블 UPDATE
        let TRCO_TRSC_CCY_CD    : String    // 거래처거래통화코드  |   CORR_TYPE이 'U'일 때 1, 2번 테이블 UPDATE
        let TOTL_AMT            : String    // 총금액          |   CORR_TYPE이 'U'일 때 1, 2번 테이블 UPDATE
        let BUSA_USAG_CD        : String    // 매입매출용도코드   |   CORR_TYPE이 'U'일 때 1, 2번 테이블 UPDATE
        let CONT                : String    // 내용           |   CORR_TYPE이 'U'일 때 1, 2번 테이블 UPDATE
        let USER_NM             : String    // 사용자명        |   CORR_TYPE이 'U'일 때 1, 2번 테이블 UPDATE
        let REG_DT              : String    // 등록일자
        let SEQ_NO              : String    // 일련번호
        let FILE_URL            : String    // 파일URL        |   아래 설명 참조
        let ADV_PAYM_TRNS_SEQ   : String    // 전도금원장거래내역일련번호
        let ADV_PAYM_SEQ        : String    // 전도금원장일련번호
        let HAND_DOC_ID         : String    // 수기문서번호 | (2021/03/09 추가)
        
                                            //        CORR_TYPE가 'U'이면 테이블 UPDATE,
                                            //        'D'이면 DELETE.
                                            //
                                            //        - 추가 UPDATE 데이터.
                                            //        ORG_FILE_NM : FILE_URL(Input)의 파일명 부분.
                                            //        SAVE_FILE_NM : FILE_URL(Input)
                                            //        FILE_SIZE : FILE_URL로 저장된 파일의 파일 용량.
                                            //
                                            //        - 추가 WHERE 조건
                                            //        BIZ_KEY, USER_ID : 공통부
         
        let TRCO_TYPE           : String    //거래처등록유형 | "(2021/06/28 추가)
        
                                            // TRCO_KEY가 '99999999999999999999' 이면 필수.
                                            // 1. Taxable Person
                                            // 2. Non-Taxable Person
                                            // 3. Oversea"
        
        let TRCO_TAX_ID         : String    //거래처세금ID | "(2021/06/28 추가)
                                            // TRCO_KEY가 '99999999999999999999' 이고, TRCO_TYPE이 '1'이면 필수."
        
        let APLY_EXCH_RATE      : String    //적용환율 | (2021/06/28 추가)
                                            // TRCO_TRSC_CCY_CD가 'USD'이면 필수
        
        let TRCO_RPRS_TLPH      : String    //거래처대표전화 | "(2021/06/28 추가)
                                            // TRCO_KEY가 '99999999999999999999' 이고, TRCO_TYPE이 '2'이면 필수."
        
        let GST_NO              : String    //GST번호 | "(2021/06/28 추가)
                                            // TRCO_KEY가 '99999999999999999999' 이고, TRCO_TYPE이 '3'이면 필수."
        
        let EML                 : String    //이메일 | "(2021/06/28 추가)
                                            // TRCO_KEY가 '99999999999999999999' 이고, TRCO_TYPE이 '3'이면 필수."
        
        let TRCO_BSUN_POST_ADRS : String    //거래처사업장우편주소 | "(2021/06/28 추가)
                                            // TRCO_KEY가 '99999999999999999999' 이고, TRCO_TYPE이 '3'이면 필수."
        
        let TRCO_BSUN_DTL_ADRS  : String    //거래처사업장상세주소 | (2021/06/28 추가)
        let TRCO_BSUN_ST        : String    //거래처사업장국가 | "(2021/06/28 추가)
                                            // TRCO_KEY가 '99999999999999999999' 이고, TRCO_TYPE이 '3'이면 필수."
        
        let TRCO_BSUN_CITY      : String    //거래처사업장시도 | "(2021/06/28 추가)
                                            // TRCO_KEY가 '99999999999999999999' 이고, TRCO_TYPE이 '3'이면 필수."
        
        let TRCO_KEY            : String  // TRCO_KEY가 is '99999999999999999999' manaul, else auto
        let WHT_CD              : String    //원천세 코드  // "(2021/09/29 추가)
                                                        // null - not withholding
                                                        // Any value - Reference from SYS_WTH_SET_INFM (table - WABOOKS_MREC_R901  common API)
        
        let PAY_WAY_CD          : String    //지급방법코드
        let PAY_WAY_AMT         : String    //지급방법금액
        let BANK_CD             : String    //은행코드20
        let ACCT_NO             : String    //계좌번호
        let REF_NO              : String    //참조번호
        let TRSC_DT2            : String    //거래일자2
        let EINV_CON_DOC_ID     : String    //e-invoice 연결문서 ID (v2023.1.0.4 추가)
        let PRJT_NO             : String    //v2024.1.42 added
        
        let REC1 : [REC1]
        
        struct REC1 : Encodable {
            let FILE_ID : String?
        }
        
        let REC2 : [REC2]
        
        struct REC2 : Encodable {
            let FILE_NM     : String?
            let FILE_DATA   : String?
        }
    }
    
    struct  RESPONSE: Decodable { }
    
}

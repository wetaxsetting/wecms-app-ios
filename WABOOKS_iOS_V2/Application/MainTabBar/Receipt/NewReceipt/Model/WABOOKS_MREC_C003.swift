//
//  WABOOKS_MREC_C003.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 21/1/21.
//

import Foundation

/**
    API: WABOOKS_MREC_C003 - 영수증작성
 **/

struct WABOOKS_MREC_C003 {
    
    struct REQUEST : Encodable {
        let TRCO_CMNM           : String    // 거래처회사명           | 1, 2번 테이블 INSERT
        let USE_DT              : String    // 사용일시              | 1, 2번 테이블 INSERT
        let TRCO_TRSC_CCY_CD    : String    // 거래처거래통화코드       | 1, 2번 테이블 INSERT
        let TOTL_AMT            : String    // 총금액                | 1, 2번 테이블 INSERT
        let BUSA_USAG_CD        : String    // 매입매출용도코드         | 1, 2번 테이블 INSERT
        let ADV_PAYM_SEQ        : String    // 전도금
        let CONT                : String    // 내용                 | 1, 2번 테이블 INSERT
        let USER_NM             : String    // 사용자명               | 1, 2번 테이블 INSERT
        let REG_TYPE            : String    // 'D':Add Detail (From 'Receipt' Page | 'M': Add Manually (From 'Select Expense' Page)
        let REG_DT              : String    // 등록일자
        let SEQ_NO              : String    // 일련번호
        let HAND_DOC_ID         : String    // 수기문서번호 | (2021/03/09 추가)
//        let TRSC_DT             : String?   // 거래일자 | "(2021/03/19 추가)  6번 테이블 컬럼값"
        
                                            //        1, 2번 테이블 INSERT.
                                            //
                                            //        - 추가 INSERT 데이터.
                                            //        BIZ_KEY, USER_ID : (공통부)
                                            //        DOC_TYPE : 'E'
                                            //        ISSU_CMNM, ISSU_CMENM, ISSU_RPPR_NM, ISSU_RPRS_TLPH, ISSU_FXNO, ISSU_BSUN_POST_ADRS, ISSU_BSUN_DTL_ADRS, ISSU_BSUN_ST, ISSU_BSUN_CITY : 3번 테이블을 BIZ_KEY로 검색하여 각 컬럼에 알맞은 컬럼값 INSERT.
                                            //        ISSU_DT : SYSDATE
                                            //        PROV_STTS : 'EE'
                                            //        BUY_WAIT_YN : 'Y'
                                            //        ORG_FILE_NM : FILE_URL(Input)의 파일명 부분.
                                            //        SAVE_FILE_NM : FILE_URL(Input)
                                            //        FILE_SIZE : FILE_URL로 저장된 파일의 파일 용량.
                                            //        REG_CHNL : 'MOB'
        
        let TRCO_TYPE               : String  //  거래처등록유형
        let TRCO_TAX_ID             : String  // 거래처세금ID
        let APLY_EXCH_RATE          : String  // 적용환율
        let TRCO_RPRS_TLPH          : String  // 거래처대표전화
        let GST_NO                  : String  // GST번호
        let EML                     : String  // 이메일
        let TRCO_BSUN_POST_ADRS     : String  // 거래처사업장우편주소
        let TRCO_BSUN_DTL_ADRS      : String  // 거래처사업장상세주소
        let TRCO_BSUN_ST            : String  // 거래처사업장국가
        let TRCO_BSUN_CITY          : String  // 거래처사업장시도
        let TRCO_KEY                : String  // TRCO_KEY가 is '99999999999999999999' manaul, else auto
        let WHT_CD                  : String  // 원천세 코드
        let PAY_WAY_CD              : String?  // 지급방법코드
        let PAY_WAY_AMT             : String  // 지급방법금액
        let BANK_CD                 : String  // 은행코드20
        let ACCT_NO                 : String  // 계좌번호
        let REF_NO                  : String  // 참조번호
        let TRSC_DT2                : String  // 거래일자2
        let EINV_CON_DOC_ID         : String  // e-invoice 연결문서 ID (v2023.1.0.4 추가)
        let PRJT_NO                 : String  // v2024.1.42 added
         
        let REC                     : [REC]
        let REC2                    : [REC2]
        
        struct REC : Encodable {
            let FILE_NM     : String
            let FILE_DATA   : String
        }
        
        struct REC2 : Encodable {
            let REG_DT  : String
            let SEQ_NO  : String
            let FILE_ID : String
        }
                        
    }
    
    struct RESPONSE : Decodable {
        let DOC_ID              : String    // 문서ID
        let ADV_PAYM_TRNS_SEQ   : String?    // 전도금입출금일련번호
        let ADV_PAYM_SEQ        : String?    // 전도금원장일련번호
        
    }
}

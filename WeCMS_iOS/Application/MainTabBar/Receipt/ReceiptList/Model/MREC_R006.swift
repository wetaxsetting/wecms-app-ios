//
//  MREC_R006.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 14/1/21.
//

import Foundation

/**
 API: MREC_R006 - 영수증목록조회
 **/

struct MREC_R006 {
    
    struct REQUEST: Encodable {
        let PAGE_NO         : String    // 페이지번호        | 페이징 DF:1
        let PAGE_PER_CNT    : String    // 페이지별건수
        
                                        // ※ 추가 Where 조건
                                        // BIZ_KEY, USER_ID : (공통부)
                                        // DOC_TYPE : 'E'
                                        // PROV_STTS IN ('EE', 'SA')
                                        // REG_CHNL : 'MOB'
    }
    
    struct RESPONSE: Decodable {
        var PAGE_NO                 : String?   // 페이지번호            | 페이징 DF:1
        let PAGE_PER_CNT            : String?   // 페이지별건수
        let REC                     : [REC]     // 그룹
        let NEXT_PAGE_YN            : String?
        
        struct REC: Decodable,Equatable {
            let INQ_GRP             : String?   // 조회그룹     | TRSC_DT가 이번주 내 날짜이면 '0000', 그 외에는 TRSC_DT의 YYMM 을 넣어줌.
            var DOC_ID              : String?   // 문서ID
            var TRCO_CMNM           : String?   // 거래처회사명
            var USE_DT              : String?   // 사용일시
            var TRCO_TRSC_CCY_CD    : String?   // 거래처거래통화코드
            var TOTL_AMT            : String?   // 총금액
            var BUSA_USAG_CD        : String?   // 매입매출용도코드
            var USAG_NM             : String?
            var CONT                : String?   // 내용
            var USER_NM             : String?   // 사용자명
            var PROV_STTS           : String?
            var RCPT_TYPE           : String?  //''P(사진)' fix.
            var SAVE_FILE_NM        : String?  // File Url
            var TRSC_WEEK           : String?
            var SEQ_NO              : String?
            var REG_DT              : String?
            var PC_MOD_YN           : String?  // PC수정여부
            var ADV_PAYM_NM         : String?  // Yongdo2
            var ADV_PAYM_SEQ        : String?  // Yongdo2
            var ADV_PAYM_TRNS_SEQ   : String?
            var HAND_DOC_ID         : String? // 수기문서번호 |(2021/03/09 추가)
//            var TRSC_DT             : String? // 거래일자 | "(2021/03/19 추가)  6번 테이블 컬럼값"
            
            var WHT_CD              : String?   //원천세 코드
            var TAX_RATE            : String?   //원천세 RATE
            var WHT_NM              : String?   //원천세 명
            
            // Updated: 2
            var REC1                : [REC1]?
             
            struct REC1: Decodable, Equatable {
                var SAVE_FILE_NM    : String?
                var SEQ_NO          : String?
                var REG_DT          : String?
                var FILE_ID         : String?
                var FILE_URL        : String?
                var ORG_FILE_NM     : String?
                var FILE_SIZE       : String?
            }
             
            var TRCO_TYPE           : String?
            var TRCO_TAX_ID         : String?
            var APLY_EXCH_RATE      : String?
            var TRCO_RPRS_TLPH      : String?
            var GST_NO              : String?
            var EML                 : String?
            var TRCO_BSUN_POST_ADRS : String?
            var TRCO_BSUN_DTL_ADRS  : String?
            var TRCO_BSUN_ST        : String?
            var TRCO_BSUN_CITY      : String?
            
            var TRCO_KEY            : String?   // TRCO_KEY가 is '99999999999999999999' manaul, else auto
            var TRCO_CMENM          : String?   // for Merchat
            var PAY_WAY_CD          : String?   // 지급방법코드
            var PAY_WAY_AMT         : String?   // 지급방법금액
            var BANK_CD             : String?   // 은행코드20
            var BANK_NM             : String?   // 은행명
            var REF_NO              : String?   // 참조번호
            var ACCT_NO             : String?   // 계좌번호
            var TRSC_DT2            : String?   // 거래일자2
            var CHEQ_NUM            : String?   // 체크번호
            var EINV_CON_DOC_ID     : String?   // e-invoice 연결문서ID (v2023.1.0.4 추가)
            var TRCO_NICK_NM        : String?
            var PRJT_NO             : String?   // v2024.1.42 added
            var PRJT_NM             : String?   // v2024.1.42 added
        }
    }
}

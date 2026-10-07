//
//  MREC_R005.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 18/1/21.
//

import Foundation

/**
    API: MREC_R005 - 용도리스트조회
 **/

struct MREC_R005 {
    
    struct REQUEST: Encodable {
        let SCH_WORD        : String        // 2번 테이블 USAG_NM을 LIKE 검색
        
                                            // 2개의 SELECT 쿼리를 실행해야 함.
                                            //
                                            // 1. 최근사용용도 조회쿼리. (USE_LIST 반복부에 들어갈 데이터)
                                            // 1, 2번 테이블을 BUSA_USAG_CD로 JOIN하여 1번 테이블에서 사용한 BUSA_USAG_CD를 REG_DTM으로 DESC하여서 조회.
                                            // - Where 조건
                                            // BIZ_KEY, USER_ID : (공통부)
                                            // DOC_TYPE : 'E'
                                            // REG_CHNL : 'MOB'
                                            //
                                            // 2. 용도전체리스트 조회쿼리. (REC 반복부에 들어갈 데이터)
                                            // 2, 3번 테이블을 USE_USAG_CD로 JOIN하여 DISP_ORD를 ASC하여서 조회.
                                            // - Where 조건
                                            // BIZ_KEY(3번 테이블) : (공통부)
                                            // USE_YN(3번 테이블) : 'Y'
                                            // DISP_YN(3번 테이블) : 'Y'
                                            // USAG_GRP_CD : '3'
                                            // REPT_DV : '30'
    }
    
    struct RESPONE: Decodable {
        let USE_LIST        : [USE_LIST]?     // 최근사용용도
        let REC             : [REC]?          // 그룹
        let REC2            : [REC2]?         //전도금
        struct USE_LIST: Decodable {
            let USE_USAG_CD : String?        // 사용용도코드
            let USAG_NM     : String?        // 용도명
            
            init(obj : REC) {
                self.USE_USAG_CD    = obj.USE_USAG_CD
                self.USAG_NM        = obj.USAG_NM
            }
        }
        
        struct REC: Decodable {
            let USE_USAG_CD : String?        // 사용용도코드
            let USAG_NM     : String?        // 용도명
          
            
            init(obj : USE_LIST) {
                self.USE_USAG_CD    = obj.USE_USAG_CD
                self.USAG_NM        = obj.USAG_NM
            }
        }
        struct REC2 : Decodable {
            let ADV_PAYM_SEQ        : String?
            let ADV_PAYM_NM         : String?
            let USER_NM             : String?
            let ADV_PAYM_RSPB_ID    : String?
        }
    }
}

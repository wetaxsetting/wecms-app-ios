//
//  MREC_C006.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 20/1/21.
//

import Foundation

/**
    API: MREC_C006 - PUSH 디바이스 등록
 **/

struct MREC_C006 {
    
    struct REQUEST: Encodable {
        let PUSHSERVER_KIND    : String    // 푸시서버종류
        let APP_ID             : String    // 앱ID
        let DEVICE_ID          : String    // 디바이스ID
        let PUSH_ID            : String    // 푸시ID
        let MODEL_NAME         : String    // 기기모델명
        let OS                 : String    // 모바일운영체제
        let NOTE               : String    // 비고
        let RETRANS_YN         : String    // 재전송여부
        let LANG_CODE          : String    // 언어코드 "   (2021/05/26) 추가. Native의 언어코드"
    }
    
    struct  RESPONSE: Decodable {}
    
}

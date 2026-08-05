//
//  ExpenseModel.swift
//  warBookScreen
//
//  Created by kimlang on 3/21/23.
//

import Foundation

struct Expense{
    var code            : String
    var title           : String?
    var pay_way_cd      : String?
    var isSelect        : Bool?
}

//사용자별 지출방법 목록조회(API)
struct WABOOKS_MREC_R070 {
    
    struct REQUEST: Encodable {}
    
    struct RESPONE_EXPENSE : Decodable   {
        
        let CASH_USER_YN    : String       //현금출납장사용자여부
        var REC             : [REC]         // 목록
        
        struct REC : Decodable{
            let  ADV_PAYM_SEQ   : String        //전도금원장일련번호
            let   ADV_PAYM_NM   : String        //전도금원장명
        }
    }
}

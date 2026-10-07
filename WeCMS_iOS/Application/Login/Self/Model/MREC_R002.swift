//
//  LoginModel.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 5/1/21.
//

import Foundation
 
struct MREC_R002 {
    
    struct REQUEST: Encodable {
        let BIZ_KEY         : String
        let USER_ID         : String
        let USER_PW         : String
    }
     
    struct RESPONSE: Decodable {
        let TOKEN_TYPE      : String?
        let ACCESS_TOKEN    : String?
        let BIZ_KEY         : String?
        let CMPN_NM         : String?
        let CMPN_ENM        : String?
        let TAX_ID          : String?
        let USER_ID         : String?
        let USER_NM         : String?
        let EML             : String?
        let RPPR_NM         : String?
        let RPRS_BSUN_POST_ADRS : String?
        let RPRS_BSUN_DTL_ADRS  : String?
        let RPRS_BSUN_CITY  : String?
        let RPRS_BSUN_ST    : String?
        let CLPH_NO         : String?
        let USER_IMG_URL    : String?
        let USER_IMG        : String?
    }
}

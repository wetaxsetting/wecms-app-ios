//
//  Common.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 14/1/21.
//

import Foundation

struct Request<T: Encodable>: Encodable {
    var API_CRTS_KEY    : String
    var API_SVC_ID      : String
    var TIME_ZONE       : String
    var USER_ID         : String
    var REQ_DATA        : T?
    var NTNL_CD         : String
}

struct Response<T: Decodable>: Decodable {
    var RSLT_CD     : String?
    var RSLT_MSG    : String?
    var API_SEQ_NO  : String?
    var RESP_DATE   : String?
    var RESP_TIME   : String?
    var RESP_DATA   : T?
}
struct AlarmRequest<T: Encodable>: Encodable {
    var _tran_cd    : String    // Professional ID
    var _ptl_id     : String    // Portal ID
    var _chnl_id    : String    // Channel ID
    var _lngg_dsnc  : String    // Language classification (DF : Default)
    var _req_data   : T?
}
struct AlarmResponse<T: Decodable>: Decodable {
    var _res_cd     : String!    // Response code
    var _res_msg    : String!    // Response message
    var _tran_cd    : String!    // Professional ID
    var _ptl_id     : String!    // Portal ID
    var _chnl_id    : String!    // Channel ID
    var _res_data   : T?
}

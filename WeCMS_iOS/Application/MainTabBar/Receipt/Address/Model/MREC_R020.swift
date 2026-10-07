//
//  MREC_R020.swift
//  WeCMS_iOS
//
//  Created by Nyta on 29/6/21.
//

import Foundation

struct MREC_R020: Decodable {
    
    
    struct Request : Encodable {
        var NATL_NM     : String?
    }
    struct Respone  : Decodable {
        var REC         : [REC]
    }
    
    struct REC : Decodable{
        var NATN_NUM    : String?
        var NATL_NM     : String?
        var DEFAULT_YN  : String?
    }
}

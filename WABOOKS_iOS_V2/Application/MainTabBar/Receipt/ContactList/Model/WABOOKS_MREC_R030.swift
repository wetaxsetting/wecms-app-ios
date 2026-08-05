//
//  WABOOKS_MREC_R030.swift
//  WABOOKS_iOS_V2
//
//  Created by Nyta on 30/6/21.
//

import Foundation

struct WABOOKS_MREC_R030 {
    struct Request : Encodable {
        var TRCO_CMNM     : String?
        var TRSC_CCY_CD     : String?
    }
    struct Respone  : Decodable {
        var REC1         : [REC1]
        var REC2         : [REC2]
        var REC3         : [REC3]
    }
    
    struct REC1 : Decodable, Equatable {
        var TRCO_KEY            : String?
        var TRCO_CMNM           : String?
        var TRCO_CMENM          : String?
        var TRSC_CCY_CD         : String?
        var TRCO_BSUN_POST_ADRS : String?
        var TRCO_BSUN_DTL_ADRS  : String?
        var TRCO_BSUN_CITY      : String?
        var TRCO_BSUN_ST        : String?
        var TRCO_RPRS_TLPH      : String?
        var TRCO_FXNO           : String?
        var TRCO_TAX_ID         : String?
        var TRCO_RPPR_NM        : String?
        var TRCO_RPPR_ENM       : String?
        var TRCO_TYPE           : String?
        var GST_NO              : String?
        var EML                 : String?
        var TRCO_NICK_NM        : String?
    }
    
    struct REC2 : Decodable, Equatable {
        var TRCO_KEY            : String?
        var TRCO_CMNM           : String?
        var TRCO_CMENM          : String?
        var TRSC_CCY_CD         : String?
        var TRCO_BSUN_POST_ADRS : String?
        var TRCO_BSUN_DTL_ADRS  : String?
        var TRCO_BSUN_CITY      : String?
        var TRCO_BSUN_ST        : String?
        var TRCO_RPRS_TLPH      : String?
        var TRCO_FXNO           : String?
        var TRCO_TAX_ID         : String?
        var TRCO_RPPR_NM        : String?
        var TRCO_NICK_NM        : String?
        var TRCO_RPPR_ENM       : String?
        var TRCO_TYPE           : String?
        var GST_NO              : String?
        var EML                 : String?
    }
    
    struct REC3 : Decodable, Equatable {
        var TRCO_KEY            : String?
        var TRCO_CMNM           : String?
        var TRCO_CMENM          : String?
        var TRSC_CCY_CD         : String?
        var TRCO_BSUN_POST_ADRS : String?
        var TRCO_BSUN_DTL_ADRS  : String?
        var TRCO_BSUN_CITY      : String?
        var TRCO_BSUN_ST        : String?
        var TRCO_RPRS_TLPH      : String?
        var TRCO_FXNO           : String?
        var TRCO_TAX_ID         : String?
        var TRCO_RPPR_NM        : String?
        var TRCO_RPPR_ENM       : String?
        var TRCO_TYPE           : String?
        var GST_NO              : String?
        var EML                 : String?
        var TRCO_NICK_NM        : String?
    }
}

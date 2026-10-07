//
//  Client.swift
//  RecipetDetail
//
//  Created by Bong Kokkheang on 28/3/23.
//

import Foundation

struct Client {
    
    enum SectionType: String {
        case Recently   = "recent"
        case Favorite   = "favorite"
        case All        = "all"
    }
    
    enum RowType {
        case Title
        case Item
        case Search
    }
    
    struct InfoData<T> {
        var rowType: RowType
        var value: T? = nil
    }
    
    struct ContentBody {
        var title: String
        var item: [InfoData<Any>]
        var sectionType: SectionType
        
        struct Item {
            var isSelected  : Bool?
            var l_text      : String
            var r_text      : String?
            var isFavourite : Bool?
            let TRCO_CMNM   : String?
            let TRCO_CMENM  : String?
            var TRCO_KEY    : String
            var TRSC_CCY_CD : String
            var TRCO_RPRS_TLPH : String
            var TRCO_TYPE   : String?
            var EML         : String?
            var TRCO_BSUN_POST_ADRS : String?
            var TRCO_BSUN_DTL_ADRS  : String?
            var TRCO_BSUN_CITY      : String?
            var TRCO_BSUN_ST        : String?
        }
    }
}

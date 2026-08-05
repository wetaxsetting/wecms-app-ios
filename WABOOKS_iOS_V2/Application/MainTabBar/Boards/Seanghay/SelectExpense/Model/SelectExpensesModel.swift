//
//  SelectExpensesModel.swift
//  WABOOKS_iOS_V2
//
//  Created by Seanghay Huort on 18/1/24.
//

import Foundation

enum ItemType {
    case BILL
    case RECEIPT
}

struct SelectExpenses {
    var itemTitle       : String?
    var tabSelect       : Bool?
    var cellType        : ItemType?
}

struct SelectExpensesModel <T> {
    var value: T?
}

struct SelectApproversItem: Equatable {
    var USER_NM         : String?
    var USER_ID         : String?
    var USER_IMG_URL    : String?
    var USER_IMG        : String?
    var CLPH_NO         : String?
    
    
    
}

struct SelectExpensesReceiptBill: Equatable {
    var USAG_NM         : String? // USERNAME
    var DOC_ID          : String? // Document ID
    var ISSU_DT         : String? // Date of issue
    var DOC_TYPE        : String? // Document Type
    var TRCO_KEY        : String? // account key
    var TRCO_CMNM       : String? // Customer company name
    var TRCO_CMENM      : String? // Customer company English name
    var CCY_CD          : String?
    var AMT             : String?
    var MEMO            : String?
    var BUSA_USAG_CD    : String? // Purchase and sales usage code
    let TRCO_TRSC_CCY_CD: String? // Customer transaction currency code
    let TOTL_AMT        : String? // Total Amount
    let COLOR           : String?
    let TRCO_TAX_ID     : String? // Contacts Tax ID
    let APPR_DV         : String? // Approval Divition
}


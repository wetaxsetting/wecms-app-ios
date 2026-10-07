//
//  AddOtherExpenseModel.swift
//  WeCMS_iOS
//
//  Created by SteveChea  on 12/3/24.
//

import Foundation

enum AddOtherExpenseRow {
    case PURPOSE
    case CONTACT
    case CURRENCY
    case AMOUNT
    case DESCRIPTION
    case PROJECT
}

struct AddOtherExpenseModel{
    var value : AddOtherExpenseData
    var rowType : AddOtherExpenseRow?
}

struct AddOtherExpenseData{
    var leftImg : String?
    var title   : String?
    var rightImg: String?
    var dec     : String?
    var requireImg    : String?
    var placeholder : String?
    var otherValue : String?
    var key : String?
}
 

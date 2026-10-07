//
//  SimpleApprovalModel.swift
//  WeCMS_iOS
//
//  Created by Seanghay Huort on 17/1/24.
//

import Foundation

enum RequestApprovalItem {
    case CONTENT
    case IMAGE
    case ATTACMENT
    case LINE
    case POST
    case MARK
    case DOCUMENTNO
    case REQUESTOR
    case REQUESTSCHEDULED
    case TOTALAMOUNT
    case APPROVERS
    case EXPENSES
    case EXPENSESITEM
    case SEEMORE
}

struct ApprovalContent {
    
    var Title           : String?
    var TitleHolder     : String?
    var nickName        : String?
    var TRCO_CMENM       : String?
    var Description     : String?
    var DescriptionHolder: String?
    var DescriptionCount: String?
    var Image           : String?
    var Value           : String?
    var CCY_CD          : String?
    var DOC_ID          : String?
    var DOC_TYPE        : String?
    var TRCO_KEY        : String?
    var BUSA_USAG_CD    : String?
    var MEMO            : String?
    var clientData      : [Client.ContentBody] = []
    var insertImage     : UIImage? = UIImage()
    var fileName        : String?
    var fileData        : String?
    var filePath        : String?
    
    var ApprovalItem    : RequestApprovalItem? = nil
}

struct ApprovalModel <T> {
    var value    : T?
}

// For Date Filter
enum RowType: String, CaseIterable {
    case LastOneMonth   = "Last 1 month"
    case LastThreeMonth = "Last 3 months"
    case LastSixMonth   = "Last 6 months"
    case FilterMaually  = "Filter manually"
    case FromDate
    case SelectFromDate
    case ToDate
    case SelectToDate
}

struct DateFilter {
    var Title           : String?
    var Description     : String?
    var Image           : String?
    var fromDate        : String?
    var toDate          : String?
    var isSelected      : Bool = false
}

struct DateFilterModel {
    var value    : DateFilter
    var rowType  : RowType?
}

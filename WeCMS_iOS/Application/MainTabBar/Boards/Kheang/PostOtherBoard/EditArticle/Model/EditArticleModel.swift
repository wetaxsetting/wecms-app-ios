//
//  EditArticleModel.swift
//  WeCMS_iOS
//
//  Created by Kimlang on 30/1/24.
//

import Foundation


enum EditArticleRowType{
    case    NEW_ARTICLE
    case    ATTACHMENT
    case    IMAGE
    case    POST_PUBLIC
    case    MAKE
    case    ADD_ATTACHMENT
    case    LINE
    case    DOCUMENTNO
    case    REQUESTOR
    case    REQUESTSCHEDULED
    case    TOTALAMOUNT
    case    APPROVERS
    case    EXPENSES
    case    EXPENSESITEM
    case    SEEMORE
}

struct EditArticleData{
    var rowType     : EditArticleRowType?
    var title       : String?
    var decription  : String?
    var icon        : String?
    var Value       : String?
    var startDate   : String?
    var endDate     : String?
    var valueKH     : String?
    var insertImage : String?
    var postType    : String?
    var fileName    : String?
    var fileData    : String?
    var filePath    : String?
    var DOC_TYPE    : String?
    var DOC_ID      : String?
    var CCY_CD      : String?
    var BUSA_USAG_CD: String?
    var MEMO        : String?
    var FILE_REC    : WeCMSStruct.REC_Protocol? = nil
    var IMAGE_REC   : WeCMSStruct.REC_Protocol? = nil
}
struct PreviewModel {
    var fileName : String?
    var image    : Any
}


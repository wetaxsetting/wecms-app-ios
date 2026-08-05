//
//  ExpenseApproval.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 25/1/24.
//

import Foundation

struct ExpenseApproval {
    var rowType: RowType
    var REC: WABOOKS_MREC_BLTB_0005_R002.RESPONSE?
    var ARTICLE_REC: WABOOKS_MREC_BLTB_0005_R001.RESPONSE?
    var EXPENSE_REC: [WABOOKSStruct.RECDoc_Protocol]?
    var FILE_REC: [WABOOKSStruct.REC_Protocol]?
    var IMAGE_REC: [WABOOKSStruct.REC_Protocol]?
    var APPROVER_REC: [WABOOKSStruct.REC3_Protocol]?
    var DETELE_FILE : [WABOOKS_MREC_BLTB_0005_D001.RESPONSE]?
    var Comment_REC: WABOOKS_MREC_BLTB_0002_R003.RESPONES.REC?
    var FILE_COMMENT_REC: [WABOOKSStruct.REC_Protocol] = []
    var IMAGE_COMMENT_REC: [WABOOKSStruct.REC_Protocol] = []

    enum RowType {
        case STATUS
        case AMOUNT
        case DESC
        case FILE
        case IMAGE
        case EXPENSE_TITLE
        case EXPENSE_LIST
        case APPROVER
        case UNDER_LINE
        case SPLIT_LINE
        case COMMENT_HEADER
        case COMMENT_IMAGE
        case COMMENT_USER
        case COMMENT_TextView
        case COMMENT_File
        case NoComment
    }
}

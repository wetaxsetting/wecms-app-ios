//
//  ApprovalSharedTypes.swift
//  WABOOKS_iOS_V2
//
//  Types shared across the approval / article screens.
//  Relocated here from SimpleApprovalVC, EditDraftVC and ExpenseApprovalVC so the
//  WeCMS screens (RequestApprovalVC, EditDraftWeCMSVC, ExpenseApprovalWeCMSVC,
//  EditDraftVM, CommentVC) no longer depend on those files.
//

import UIKit

enum TextViewType{
    case TITLE
    case DESCRIPTION
}

enum ApprovalType {
    case SIMPLEAPPROVAl
    case EXPENSEAPPROVAL
    case NEWARTICLE
    case NEWARTICLEONLY
}

struct ImageFullSize {
    var image   : UIImage?
    var name    : String?
}

enum DraftApprovalType {
    case SIMPLEAPPROVAl
    case EXPENSEAPPROVAL
    case NEWARTICLE
}

struct ImageFullSizeDraft {
    var image      : UIImage?
    var name       : String?
    var FILE_DATA  : String?
}

enum ApprovalStatus: String {
    case Approve = "A"
    case Reject = "R"
}

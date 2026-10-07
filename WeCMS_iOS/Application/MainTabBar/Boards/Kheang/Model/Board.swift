//
//  Model.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 15/1/24.
//

import Foundation

struct Boards {
    var sectionType: SectionType
    var isPin: Bool = false
    var title: String?
    var page = 1
    var content: [Content] = []
    
    struct Content {
        var REC: WeCMSStruct.BoardDetail_Protocol
        var title: String?
        var nameUserPost: String?
        var image: String?
        var desc: String?
        var commentCount: String?
        var nameUserComment: String?
        var comment: String?
        var status: Status?
        var rowType: RowType
        
        enum Status {
            case pending
            case reject
            case progress
        }
        
        enum RowType {
            case STATUS
            case DESCRIPTION
            case COMMENT
            case LINEFOOTER
        }
        
    }
    
    enum SectionType {
        case TITLE
        case CONTENT
        case SHOWMORE
        case SHOWLESS
        case PINLINE
    }
    
    struct Section: Equatable {
        var name: String?
        var title: String?
        var image: String?
        var count: String? = "0"
        var isSelected: Bool = false
        var sectionType: SectionType
        
        enum SectionType: String {
            case ALL = ""
            case DRAFT = "03"
            case DOCUMENT = "01"
            case CHECK = "02"
            case More
            case Less
            case Pending = "04"
            case Progress = "05"
            case Reject = "06"
            case Approved = "07"
        }
    }
    
    /// WeCMS only ever shows the Approval board. The Home / My Posts / General cases
    /// belonged to the WABOOKS bulletin-board side menu and went with it.
    enum BoardType: String {
        case Approval = "Approval"
    }
    
    enum ApprovalSectionType: String {
        case Pending = "04"
        case Progress = "05"
        case Reject = "06"
        case Approved = "07"
    }
}

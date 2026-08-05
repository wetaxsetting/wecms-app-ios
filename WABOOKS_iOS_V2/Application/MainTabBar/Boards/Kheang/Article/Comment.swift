//
//  Article.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 11/1/24.
//

import Foundation

struct Comment {
    var text: String?
    var file: FileModel?
    var image: [UIImage] = []
    var rowType: RowType
    var REC: WABOOKS_MREC_BLTB_0002_R003.RESPONES.REC?
//    var FILE_REC: [any WABOOKS_MREC_BLTB_0005_R002_0005_R001_0002_R003]?
    var FILE_COMMENT_REC: [WABOOKSStruct.REC_Protocol] = []
    var IMAGE_COMMENT_REC: [WABOOKSStruct.REC_Protocol] = []
    
    enum RowType {
        case TextView
        case FileType
        case ImageType
        case User
        case NoComment
        case Footer
    }
}

//
//  Article.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 11/1/24.
//

import Foundation

struct Comment {
    var text: String?
    var file: FileModel?
    var image: [UIImage] = []
    var rowType: RowType
    var REC: MREC_BLTB_0002_R003.RESPONES.REC?
//    var FILE_REC: [any MREC_BLTB_0005_R002_0005_R001_0002_R003]?
    var FILE_COMMENT_REC: [WeCMSStruct.REC_Protocol] = []
    var IMAGE_COMMENT_REC: [WeCMSStruct.REC_Protocol] = []
    
    enum RowType {
        case TextView
        case FileType
        case ImageType
        case User
        case NoComment
        case Footer
    }
}

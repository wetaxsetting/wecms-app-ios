//
//  CommentViewModel.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 5/2/24.
//

import Foundation

struct CommentViewModel {
    var text: String?
    var file: [FileModel] = []
    var image: [ImageModel] = []
    var rowType: RowType
    
    enum RowType {
        case TextView
        case FileType
        case ImageType
    }
    
    struct ImageModel {
        var image: UIImage
        var isFromLocal: Bool = true
    }
}

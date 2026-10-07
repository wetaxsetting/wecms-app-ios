//
//  CommentViewVM.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 5/2/24.
//

import Foundation

class CommentViewVM {
    var content : [CommentViewModel]                        = []
    var REC     : [MREC_BLTB_0002_U001.REQUEST.REC] = []
    
    func initData() {
        content = [
            CommentViewModel(rowType: .TextView),
        ]
    }
    
    func checkHideActionButton() -> Bool {
        return imageCount() + fileCount() >= 5
    }
    
    func fileCount() -> Int {
        guard let REC = content.first(where: {$0.rowType == .FileType}) else {
            return 0
        }
        return REC.file.count
    }
    
    func imageCount() -> Int {
        guard let REC = content.first(where: {$0.rowType == .ImageType}) else {
            return 0
        }
        return REC.image.count
    }
}

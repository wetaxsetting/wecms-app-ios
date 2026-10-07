//
//  Preview.swift
//  WeCMS_iOS
//
//  Created by Huort Seanghay on 19/5/23.
//

import Foundation
import QuickLook

class PreviewItem: NSObject, QLPreviewItem {
    var previewItemURL: URL?
    var previewItemTitle: String?

    init(url: URL, title: String? = nil) {
        self.previewItemURL = url
        self.previewItemTitle = title
    }

    // QLPreviewItem protocol properties
    var previewItemUrl: URL? {
        return self.previewItemURL
    }

    var previewItemName : String? {
        return self.previewItemTitle
    }
}

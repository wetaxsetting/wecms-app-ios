//
//  Download.swift
//  WABOOKS_iOS_V2
//
//  Created by Huort Seanghay on 22/5/23.
//

import UIKit

class Download {
    
    // Download service sets these values:
    var task: URLSessionDownloadTask?
    
    // downloaded Data
    var resumeData: Data?
    
    var data: Data?
    var isDownloading = false
    
}

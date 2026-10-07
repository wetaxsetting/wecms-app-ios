//
//  DocumentsManager.swift
//  WeCMS_iOS
//
//  Created by Huort Seanghay on 16/5/23.
//

import Foundation
import UIKit
import MobileCoreServices

class DocumentsManager : NSObject, UIDocumentPickerDelegate {
    
    /// a view controller
    var viewController          : UIViewController? = nil
    var files                   = [FileModel]()
    let compleBlock             : (() -> ())? = nil
    var fileResponse            = [MREC_C002.RESPONSE]()
    var completionFileInfo      : ([MREC_C002.RESPONSE]) -> Void = { _ in }
    var completionFilesModel    : ([FileModel]) -> Void = { _ in }
    var completionError         : (NSError) -> Void = { _ in }
    var isNotFromSubmit         = false
    
    var maintabVM               = MainTabBarVM()
    private var responseImage   : MREC_C002.RESPONSE?
    
    init(_ viewController : UIViewController) {
        self.viewController = viewController
    }

    func openDocument() {
        
        let pdf         = String(kUTTypePDF)
        let spreadsheet = String(kUTTypeSpreadsheet)
        let ppt         = String(kUTTypePresentation)
        let docs        = String(kUTTypeCompositeContent)
//        let movie       = String(kUTTypeMovie)
//        let aviMovie    = String(kUTTypeAVIMovie)
//        let img         = String(kUTTypeImage)
//        let png         = String(kUTTypePNG)
//        let jpeg        = String(kUTTypeJPEG)
//        let txt         = String(kUTTypeText)
//        let zip         = String(kUTTypeZipArchive)
//        let msg1        = String(kUTTypeEmailMessage)
//        let msg2        = String(kUTTypeMessage)
        
        
//        let documentTypes = [String(kUTTypePDF), String(kUTTypePNG), String(kUTTypeJPEG)]
        let documentTypes   = [pdf,spreadsheet,docs,ppt]
        let documentPicker  = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
        documentPicker.modalPresentationStyle   = .overFullScreen
        documentPicker.delegate                 = self
        
        if #available(iOS 11.0, *) {
//            documentPicker.allowsMultipleSelection = true
        } else {
            // Fallback on earlier versions
        }
        
        self.viewController?.present(documentPicker, animated: true, completion: nil)
    }
        
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var files       = [FileModel]()
        var datas       = [Data]()
        var data        = Data()
        var fileNames   = [String]()
        
        for url in urls {
            let strURL = url.absoluteString
            let lastPath = (strURL as NSString).lastPathComponent
            //> Seanghay <\\ HERE CONVERT DATA
            let fileSize = String(url.fileSize)
            do {
                data = try Data(contentsOf: URL(string: strURL)!)
                
                let obj = FileModel(fileName: lastPath, filePath: strURL, fileData: data, fileSize: fileSize, fileURL: nil, isFromLocal: true)
                let fileName = url.lastPathComponent
                files.append(obj)
                datas.append(data)
                fileNames.append(fileName)
            }
            catch let error {
                #if DEBUG
                log.e(error.localizedDescription)
                #endif
            }
            let fileInfo = url.lastPathComponent
            if isNotFromSubmit {
                self.uploadImageAfterCaptureSucess(urlData: data, fileInfo: fileInfo)
            }
        }
        self.files = files
        self.completionFilesModel(self.files)
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        #if DEBUG
        print(#function)
        #endif
    }
    
    func uploadImageAfterCaptureSucess (urlData : Data, fileInfo: String) {
        
        var REC_IN : [MREC_C002.REQUEST.REC] = []
        let formatter           = DateFormatter()
        formatter.dateFormat    = "yyyMMddHHmmssA"

        REC_IN.append(MREC_C002.REQUEST.REC(FILE_NM: "\(fileInfo)", FILE_DATA: urlData.base64EncodedString(options: .endLineWithLineFeed)))
        
            // Upload Image after taking a photo
            self.uploadImage(body: MREC_C002.REQUEST(REC_IN: REC_IN)) {
                // Reload Receipt List After Upload Image Success
                MyNotify.send(name: .reloadAfterUploadImage)
            }
    }
    
    // Fetching API
    private func uploadImage(body: MREC_C002.REQUEST, _ completion: @escaping () -> () = {}) {
        self.maintabVM.uploadImage(body: body) { (error) in
            if error != nil {
//                self.customAlert(type       : .CONFIRM_ALERT,
//                                 image      : "badge_failed",
//                                 title      : "uploaded_fail".localized,
//                                 message    : "uploaded_fail_descr".localized,
//                                 redTitle   : "",
//                                 greyTitle  : "ok".localized) { (_) in
//                }
//                return
                print("ERROR")
            }
            
            self.responseImage = self.maintabVM.reponseImage
            completion()
        }
    }

}

extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }

    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }

    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}

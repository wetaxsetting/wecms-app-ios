//
//  CommentVM.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 17/1/24.
//

import Foundation

class CommentVM {
    var content : [Comment] = []
    var response: MREC_BLTB_0002_R003.RESPONES?
    var REC2: [MREC_BLTB_0002_U001.REQUEST.REC2] = []
    
    func initData() {
        self.content = [] // Must clear to prevent redundancy
        for (_, c) in response!.REC!.enumerated() {
            self.content.append(Comment(rowType: .User, REC: c))
            self.content.append(Comment(rowType: .TextView, REC: c))
            var imgREC: [WeCMSStruct.REC_Protocol] = []
            var fileREC: [WeCMSStruct.REC_Protocol] = []
            if let REC2 = c.REC2 {
                for (_, c) in REC2.enumerated() {
                    let filename: NSString = c.SAVE_FILE_NM! as NSString
                    let pathExtention = filename.pathExtension
                    
                    if pathExtention == "docx" || pathExtention == "doc" || pathExtention == "pdf" || pathExtention == "xlsx" || pathExtention == "pptx" {
                        fileREC.append(c)
                    } else {
                        imgREC.append(c)
                    }
                }
                if fileREC.count > 0 {
                    self.content.append(Comment(rowType: .FileType, REC: c, FILE_COMMENT_REC: fileREC))
                }
                if imgREC.count > 0 {
                    self.content.append(Comment(rowType: .ImageType, REC: c, IMAGE_COMMENT_REC: imgREC))
                }
            }
//            self.content.append(Comment(rowType: .Footer))
        }
        if content.count == 0 {
            self.content.append(Comment(rowType: .NoComment))
        }
    }
    
    
    func fetchComment(POST_SEQ_NO: String, BLTB_CD: String, completion  : @escaping (Swift.Result<MREC_BLTB_0002_R003.RESPONES, NSError>) -> Void) {
        //        let body = MREC_BLTB_0002_R003.REQUEST(POST_SEQ_NO: "710", BLTB_CD: "999999999999999") // for dev
        let body = MREC_BLTB_0002_R003.REQUEST(POST_SEQ_NO: POST_SEQ_NO, BLTB_CD: BLTB_CD)      // for real
        DataAccess.shared.fetchData(shouldShowLoading   : false,
                                    apiKey              : APIKey.MREC_BLTB_0002_R003,
                                    body                : body,
                                    responseType        : MREC_BLTB_0002_R003.RESPONES.self) { (result) in
            switch result {
            case .success(let data):
                self.response = data
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func requestAddComment(body: MREC_BLTB_0002_C001.REQUEST, completion: @escaping (Swift.Result<MREC_BLTB_0002_C001.RESPONSE?, NSError>) -> Void) {
        DataAccess.shared.fetchData(shouldShowLoading: false, apiKey: .MREC_BLTB_0002_C001,httpMethod: .POST, body: body, responseType: MREC_BLTB_0002_C001.RESPONSE.self) { (result) in
            switch result {
            case .success(_):
                completion(.success(nil))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func requestDeleteComment(body: MREC_BLTB_0002_D002.REQUEST, completion: @escaping (Swift.Result<MREC_BLTB_0002_D002.RESPONSE?, NSError>) -> Void) {
        DataAccess.shared.fetchData(shouldShowLoading: false, apiKey: .MREC_BLTB_0002_D002, httpMethod: .POST, body: body, responseType: MREC_BLTB_0002_D002.RESPONSE.self) { (result) in
            switch result {
            case .success(_):
                completion(.success(nil))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func requestUpdateComment(body: MREC_BLTB_0002_U001.REQUEST, completion: @escaping (Swift.Result<MREC_BLTB_0002_U001.RESPONSE?, NSError>) -> Void) {
        DataAccess.shared.fetchData(shouldShowLoading: false, apiKey: .MREC_BLTB_0002_U001,httpMethod: .POST, body: body, responseType: MREC_BLTB_0002_U001.RESPONSE.self) { (result) in
            switch result {
            case .success(_):
                completion(.success(nil))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

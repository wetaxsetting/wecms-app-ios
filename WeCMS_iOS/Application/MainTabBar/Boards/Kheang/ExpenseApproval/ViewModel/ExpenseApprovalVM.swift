//
//  ExpenseApprovalVM.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 25/1/24.
//

import Foundation

class ExpenseApprovalVM {
    
    var content: [ExpenseApproval] = []
    var POST_APPR_DV = ""
    var POST_TYPE_CD = ""
    var isApprover : Bool = false
    var responseBoardDetail : MREC_BLTB_0005_R002.RESPONSE?
    var responseArticle     : MREC_BLTB_0005_R001.RESPONSE?
    var responseListComment : MREC_BLTB_0002_R003.RESPONES?
    var boardType: Boards.BoardType = .Approval
    
    // MARK: - init simple section
    func initSimple() {
        
        content = []
        
        content.append(ExpenseApproval(rowType: .STATUS, REC: responseBoardDetail))
        content.append(ExpenseApproval(rowType: .DESC, REC: responseBoardDetail))
        
        let imgREC      = checkImageExtension(data: responseBoardDetail!.REC2!)
        let fileREC     = checkFileExtension(data: responseBoardDetail!.REC2!)
        var ApproverREC : [WeCMSStruct.REC3_Protocol] = []

        if fileREC.count > 0 {
            content.append(ExpenseApproval(rowType: .FILE, FILE_REC: fileREC))
        }
        if imgREC.count > 0 {
            content.append(ExpenseApproval(rowType: .IMAGE, IMAGE_REC: imgREC))
        }
        for (_, c) in responseBoardDetail!.REC3!.enumerated() {
            if Shared.R002_DATA?.USER_ID == c.APPRVR_ID && c.APPRVR_STTS == "P" {
                isApprover = true
            }
            ApproverREC.append(c)
        }
        content.append(ExpenseApproval(rowType: .APPROVER, REC: responseBoardDetail, APPROVER_REC: ApproverREC))
        content.append(ExpenseApproval(rowType: .SPLIT_LINE, REC: responseBoardDetail))
        
        self.content.append(ExpenseApproval(rowType: .COMMENT_HEADER, REC: self.responseBoardDetail))
        
        if responseBoardDetail?.TOT_CMT == "0" {
            self.content.append(ExpenseApproval(rowType: .NoComment))
        } else {
            /*
             - init comment
             */
            initComment()
        }
    }
    
    // MARK: - init expense section
    func initExpense() {
        
        content = []
        
        content.append(ExpenseApproval(rowType: .STATUS, REC: responseBoardDetail))
        content.append(ExpenseApproval(rowType: .UNDER_LINE, REC: responseBoardDetail))
        content.append(ExpenseApproval(rowType: .AMOUNT, REC: responseBoardDetail))
        content.append(ExpenseApproval(rowType: .DESC, REC: responseBoardDetail))
        
        let imgREC      = checkImageExtension(data: responseBoardDetail!.REC2!)
        let fileREC     = checkFileExtension(data: responseBoardDetail!.REC2!)
        var ApproverREC : [WeCMSStruct.REC3_Protocol] = []
        
        if fileREC.count > 0 {
            content.append(ExpenseApproval(rowType: .FILE, FILE_REC: fileREC))
        }
        if imgREC.count > 0 {
            content.append(ExpenseApproval(rowType: .IMAGE, IMAGE_REC: imgREC))
        }
        content.append(ExpenseApproval(rowType: .EXPENSE_TITLE, REC: responseBoardDetail))
        content.append(ExpenseApproval(rowType: .EXPENSE_LIST, EXPENSE_REC: responseBoardDetail?.REC))
        
        for (_, c) in responseBoardDetail!.REC3!.enumerated() {
            if Shared.R002_DATA?.USER_ID == c.APPRVR_ID && c.APPRVR_STTS == "P" {
                isApprover = true
            }
            ApproverREC.append(c)
        }
        
        content.append(ExpenseApproval(rowType: .APPROVER, REC: responseBoardDetail, APPROVER_REC: ApproverREC))
        content.append(ExpenseApproval(rowType: .SPLIT_LINE))
        
        self.content.append(ExpenseApproval(rowType: .COMMENT_HEADER, REC: self.responseBoardDetail))
        
        if responseBoardDetail?.TOT_CMT == "0" {
            self.content.append(ExpenseApproval(rowType: .NoComment))
        } else {
            /*
             - init comment
             */
            initComment()
        }
    }
    
    func initExpenseWeCMS() {
        
        content = []
        
        content.append(ExpenseApproval(rowType: .STATUS, REC: responseBoardDetail))
        content.append(ExpenseApproval(rowType: .UNDER_LINE, REC: responseBoardDetail))
        content.append(ExpenseApproval(rowType: .AMOUNT, REC: responseBoardDetail))
        content.append(ExpenseApproval(rowType: .DESC, REC: responseBoardDetail))
        
        let imgREC      = checkImageExtension(data: responseBoardDetail!.REC2!)
        let fileREC     = checkFileExtension(data: responseBoardDetail!.REC2!)
        var ApproverREC : [WeCMSStruct.REC3_Protocol] = []
        
        if fileREC.count > 0 {
            content.append(ExpenseApproval(rowType: .FILE, FILE_REC: fileREC))
        }
        if imgREC.count > 0 {
            content.append(ExpenseApproval(rowType: .IMAGE, IMAGE_REC: imgREC))
        }
        content.append(ExpenseApproval(rowType: .EXPENSE_TITLE, REC: responseBoardDetail))
        content.append(ExpenseApproval(rowType: .EXPENSE_LIST, EXPENSE_REC: responseBoardDetail?.REC))
        
        for (_, c) in responseBoardDetail!.REC3!.enumerated() {
            if Shared.R002_DATA?.USER_ID == c.APPRVR_ID && c.APPRVR_STTS == "P" {
                isApprover = true
            }
            ApproverREC.append(c)
        }
        
        content.append(ExpenseApproval(rowType: .APPROVER, REC: responseBoardDetail, APPROVER_REC: ApproverREC))
        content.append(ExpenseApproval(rowType: .SPLIT_LINE))
        
        self.content.append(ExpenseApproval(rowType: .COMMENT_HEADER, REC: self.responseBoardDetail))
        
        if responseBoardDetail?.TOT_CMT == "0" {
            self.content.append(ExpenseApproval(rowType: .NoComment))
        } else {
            /*
             - init comment
             */
            initComment()
        }
    }
    
    // MARK: - init article section
    func initArticle() {
        content = []
        
        content.append(ExpenseApproval(rowType: .STATUS, ARTICLE_REC: self.responseArticle))
        content.append(ExpenseApproval(rowType: .DESC, ARTICLE_REC: self.responseArticle))
        
        let imgREC = checkImageExtension(data: responseArticle!.REC!)
        let fileREC = checkFileExtension(data: responseArticle!.REC!)
        
        if fileREC.count > 0 {
            content.append(ExpenseApproval(rowType: .FILE, FILE_REC: fileREC))
        }
        if imgREC.count > 0 {
            content.append(ExpenseApproval(rowType: .IMAGE, IMAGE_REC: imgREC))
        }
        
        content.append(ExpenseApproval(rowType: .SPLIT_LINE))
        
        self.content.append(ExpenseApproval(rowType: .COMMENT_HEADER, ARTICLE_REC: self.responseArticle))
        
        if responseArticle?.TOT_CMT == "0" {
            content.append(ExpenseApproval(rowType: .NoComment))
        } else {
            /*
             - init comment
             */
            initComment()
        }
    }
    
    private func checkFileExtension(data: [WeCMSStruct.REC_Protocol]) ->  [WeCMSStruct.REC_Protocol] {
        var fileREC: [WeCMSStruct.REC_Protocol] = []
        for (_, c) in data.enumerated(){
            let filename: NSString = c.ORG_FILE_NM! as NSString
            let pathExtention = filename.pathExtension
            if pathExtention == "docx" || pathExtention == "doc" || pathExtention == "pdf" || pathExtention == "xlsx" || pathExtention == "pptx" {
                fileREC.append(c)
            }
        }
        return fileREC
    }
    
    private func checkImageExtension(data: [WeCMSStruct.REC_Protocol]) ->  [WeCMSStruct.REC_Protocol] {
        var imgREC: [WeCMSStruct.REC_Protocol] = []
        for (_, c) in data.enumerated(){
            let filename: NSString = c.ORG_FILE_NM! as NSString
            let pathExtention = filename.pathExtension
            if pathExtention == "png" || pathExtention == "jpg" {
                imgREC.append(c)
            }
        }
        return imgREC
    }
    
    // MARK: - init Comment section
    private func initComment() {
        for (_, c) in responseListComment!.REC!.enumerated() {
            self.content.append(ExpenseApproval(rowType: .COMMENT_USER, Comment_REC: c))
            self.content.append(ExpenseApproval(rowType: .COMMENT_TextView, Comment_REC: c))
            if let REC2 = c.REC2 {
                
                let imgREC  = checkImageExtension(data: REC2)
                let fileREC = checkFileExtension(data: REC2)
                
                if fileREC.count > 0 {
                    self.content.append(ExpenseApproval(rowType: .COMMENT_File, Comment_REC: c, FILE_COMMENT_REC: fileREC))
                }
                if imgREC.count > 0 {
                    self.content.append(ExpenseApproval(rowType: .COMMENT_IMAGE, Comment_REC: c, IMAGE_COMMENT_REC: imgREC))
                }
            }
        }
    }
    
    func fetchArticle(showLoading: Bool, POST_SEQ_NO: String, BLTB_CD: String, completion  : @escaping (Swift.Result<MREC_BLTB_0005_R001.RESPONSE, NSError>) -> Void) {
        let body = MREC_BLTB_0005_R001.REQUEST(POST_SEQ_NO: POST_SEQ_NO, BLTB_CD: BLTB_CD)
        DataAccess.shared.fetchData(shouldShowLoading   : showLoading,
                                    apiKey              : APIKey.MREC_BLTB_0005_R001,
                                    body                : body,
                                    responseType        : MREC_BLTB_0005_R001.RESPONSE.self) { (result) in
            switch result {
            case .success(let boardData):
                self.responseArticle = boardData
                self.fetchComment(POST_SEQ_NO: POST_SEQ_NO, BLTB_CD: BLTB_CD) { result in
                    switch result {
                    case .success(let commentData):
                        self.responseListComment = commentData
                        self.initArticle()
                        completion(.success(boardData))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func fetchBoardDetail(showLoading: Bool, POST_SEQ_NO: String, BLTB_CD: String, completion  : @escaping (Swift.Result<MREC_BLTB_0005_R002.RESPONSE, NSError>) -> Void) {
        let body = MREC_BLTB_0005_R001.REQUEST(POST_SEQ_NO: POST_SEQ_NO, BLTB_CD: BLTB_CD)
        DataAccess.shared.fetchData(shouldShowLoading   : showLoading,
                                    apiKey              : POST_TYPE_CD == "01" ? APIKey.MREC_BLTB_0005_R001 : APIKey.MREC_BLTB_0005_R002,
                                    body                : body,
                                    responseType        : MREC_BLTB_0005_R002.RESPONSE.self) { (result) in
            switch result {
            case .success(let boardData):
                self.responseBoardDetail = boardData
                self.fetchComment(POST_SEQ_NO: POST_SEQ_NO, BLTB_CD: BLTB_CD) { result in
                    switch result {
                    case .success(let commentData):
                        self.responseListComment = commentData
                        self.POST_APPR_DV == "00" ? self.initSimple() : self.initExpense()
                        completion(.success(boardData))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchBoardDetailWeCMS(showLoading: Bool, POST_SEQ_NO: String, BLTB_CD: String, completion  : @escaping (Swift.Result<MREC_BLTB_0005_R002.RESPONSE, NSError>) -> Void) {
        let body = MREC_BLTB_0005_R001.REQUEST(POST_SEQ_NO: POST_SEQ_NO, BLTB_CD: BLTB_CD)
        DataAccess.shared.fetchData(shouldShowLoading   : showLoading,
                                    apiKey              : POST_TYPE_CD == "01" ? APIKey.MREC_BLTB_0005_R001 : APIKey.MREC_BLTB_0005_R002,
                                    body                : body,
                                    responseType        : MREC_BLTB_0005_R002.RESPONSE.self) { (result) in
            switch result {
            case .success(let boardData):
                self.responseBoardDetail = boardData
                self.fetchComment(POST_SEQ_NO: POST_SEQ_NO, BLTB_CD: BLTB_CD) { result in
                    switch result {
                    case .success(let commentData):
                        self.responseListComment = commentData
                        self.initExpenseWeCMS()
                        completion(.success(boardData))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestDeleteFileComment(body: MREC_BLTB_0005_D002.REQUEST, completion: @escaping (NSError?) -> ()) {
        DataAccess.shared.fetchData(shouldShowLoading   : false,
                                    apiKey: .MREC_BLTB_0005_D002,
                                    body: body,
                                    responseType: MREC_BLTB_0005_D002.RESPONSE.self) { result in
            switch result {
            case .success(_) :
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func requestDeletePhoto(body: MREC_BLTB_0005_D001.REQUEST, completion: @escaping (NSError?) -> ()) {
        DataAccess.shared.fetchData(shouldShowLoading   : false,
                                    apiKey: .MREC_BLTB_0005_D001,
                                    body: body,
                                    responseType: MREC_BLTB_0005_D001.RESPONSE.self) { result in
            switch result {
            case .success(_) :
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    
    func fetchComment(POST_SEQ_NO: String, BLTB_CD: String, completion  : @escaping (Swift.Result<MREC_BLTB_0002_R003.RESPONES, NSError>) -> Void) {
//                let body = MREC_BLTB_0002_R003.REQUEST(POST_SEQ_NO: "710", BLTB_CD: "999999999999999") // for dev
        let body = MREC_BLTB_0002_R003.REQUEST(POST_SEQ_NO: POST_SEQ_NO, BLTB_CD: BLTB_CD)      // for real
        DataAccess.shared.fetchData(shouldShowLoading   : false,
                                    apiKey              : APIKey.MREC_BLTB_0002_R003,
                                    body                : body,
                                    responseType        : MREC_BLTB_0002_R003.RESPONES.self) { (result) in
            switch result {
            case .success(let data):
                self.responseListComment = data
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func requestApproveOrReject(APPR_SEQ_NO: String, APPRVR_STTS: String, BLTB_CD: String, COMNT_CONT: String, REC_IN: [MREC_BLTB_0005_U001.REQUEST.REC_IN],  completion  : @escaping (Swift.Result<MREC_BLTB_0005_U001.RESPONSE, NSError>) -> Void) {
        
        let REC3 = self.responseBoardDetail?.REC3 ?? []
        
        // Using map for functional approach
        let modifiedRecords = REC3.enumerated().map { (index, record) in
            var modified = record
            modified.APPRVR_LINE_NO = "\(index+1)"
            return modified
        }
        
        self.responseBoardDetail?.REC3 = modifiedRecords
        self.responseBoardDetail?.APPRVR_STTS = APPRVR_STTS
        
        let body = self.responseBoardDetail
        
        
    
        
        
//        let body = MREC_BLTB_0005_U001.REQUEST(BLTB_CD: BLTB_CD, POST_SEQ_NO: APPR_SEQ_NO, POST_TITLE: APPRVR_STTS, POST_TYPE_CD: COMNT_CONT, POST_STTS: REC_IN, REG_NM: modifiedRecords)

        
        DataAccess.shared.fetchData(shouldShowLoading   : false,
                                    apiKey              : APIKey.MREC_BLTB_0005_U001,
                                    body                : body,
                                    responseType        : MREC_BLTB_0005_U001.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                completion(.success(data))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

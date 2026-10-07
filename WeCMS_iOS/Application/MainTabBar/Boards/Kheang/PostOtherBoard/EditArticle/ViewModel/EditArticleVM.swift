//
//  EditArticleVM.swift
//  WeCMS_iOS
//
//  Created by Kimlang on 30/1/24.
//

import Foundation


class EditArticleVM {
    
    // MARK: - Variable -
    var cells               = [EditArticleData]()
    //For Edit Article
    var attacmentREC2   : [MREC_BLTB_0004_U001.REQUEST.REC2] = []
    var REC2   : [MREC_BLTB_0004_U001.REQUEST.REC2] = []
    var REC : [MREC_BLTB_0004_U001.REQUEST.REC] = []
    
    //For Edit Approval
    var attacmentREC3       : [MREC_BLTB_0004_U002.REQUEST.REC3] = []
    var REC1                : [MREC_BLTB_0004_U002.REQUEST.REC1] = []  // For get from api
    
    var REC3                : [MREC_BLTB_0004_U002.REQUEST.REC3] = []
    var REC4                : [MREC_BLTB_0004_U002.REQUEST.REC4] = []
    var REC2APPR            : [MREC_BLTB_0004_U002.REQUEST.REC2] = []
    
    var rec005_R002         : MREC_BLTB_0005_R002.RESPONSE? //Approval
    var rec005_R001         : MREC_BLTB_0005_R001.RESPONSE? //Article
    var POST_APPR_DV        = ""
    var tempDescription     = ""
    var PIN_POST_DUE_DT     = "permanently".localized

    
    func appendFileImage(){
        if (self.rec005_R002?.REC2?.count ?? 0) != 0 {
            for REC2 in self.rec005_R002?.REC2 ?? [] {
                let fileName = REC2.ORG_FILE_NM ?? ""
                if fileName.contains(".jpg") || fileName.contains(".png") {
                    cells.append(EditArticleData(rowType: .IMAGE, insertImage:  REC2.FILE_URL, IMAGE_REC: REC2))
                }
            }
            for REC2 in self.rec005_R002?.REC2 ?? [] {
                let fileType = REC2.ORG_FILE_NM ?? ""
                if !fileType.contains(".jpg") && !fileType.contains(".png") {
                    cells.append(EditArticleData(rowType: .ATTACHMENT, insertImage: REC2.FILE_URL, fileName: REC2.ORG_FILE_NM, fileData: REC2.FILE_SIZE, filePath: "",  IMAGE_REC: REC2))
                }
            }
        }
    }
    
    //MARK: - APPROVAL
    func getDataApproval(isUploadImage: Bool = false, isUploadFile: Bool = false, selectApprover: String = "", selectExpenses: String = ""){
        
        cells = []
        tempDescription = rec005_R002?.POST_CONT ?? ""
        cells.append(EditArticleData(rowType: .NEW_ARTICLE ,title: rec005_R002?.POST_TITLE, decription: tempDescription))
        
        if POST_APPR_DV == "00" { // MARK: - SIMPLE APPROVAL
            self.appendFileImage()
            cells.append(EditArticleData(rowType: .LINE))
            cells.append(EditArticleData(rowType: .REQUESTOR,title: "requestor".localized, icon: "list_employee_ico", Value: rec005_R002?.REG_NM))
            cells.append(EditArticleData(rowType: .APPROVERS,title: "approvers".localized, icon: "ico_check-1", Value: selectApprover ==  "" ? "\(self.rec005_R002?.APPRVR_TOT_CNT ?? "")/4" : selectApprover))
            
        } else if POST_APPR_DV == "10"{ // MARK: - EXPENSES APPROVAL
            self.appendFileImage()

            cells.append(EditArticleData(rowType: .LINE))
            
            cells.append(EditArticleData(rowType: .DOCUMENTNO,title: "document_no.".localized, icon: "ico_hashtag", Value: rec005_R002?.DOC_NO ?? ""))
            
            cells.append(EditArticleData(rowType: .EXPENSES,title: "expenses".localized, icon: "ico_stack-1", Value:  selectExpenses == "" ? "\(rec005_R002?.REC?.count ?? 0)" : selectExpenses))
            
//            if rec005_R002?.REC?.count != 0 {
//                for (index,item) in (rec005_R002?.REC ?? []).enumerated()  {
//                    if index < 2 {
//                        cells.append(EditArticleData(rowType: .EXPENSESITEM, title: item.TRCO_CMENM, decription: item.USAG_NM, icon:  item.AMT, Value: item.DOC_ID, startDate: item.DOC_TYPE, endDate: item.CCY_CD, MEMO: item.MEMO))
//                    }
//                }
//            }
            
            if rec005_R002?.REC?.count != 0 {
                for (index,item) in (rec005_R002?.REC ?? []).enumerated()  {
                    if index < 2 {
                        cells.append(EditArticleData(rowType: .EXPENSESITEM, title: item.TRCO_CMENM, decription: item.USAG_NM, Value: item.AMT, DOC_TYPE: item.DOC_TYPE, DOC_ID: item.DOC_ID, CCY_CD: item.CCY_CD, MEMO: item.MEMO))
                    }
                }
            }
            if rec005_R002?.REC?.count ?? 0 > 2 {
                cells.append(EditArticleData(rowType: .SEEMORE))
            }
            
            
            cells.append(EditArticleData(rowType: .APPROVERS,title: "approvers".localized, icon: "ico_check-1", Value:  selectApprover ==  "" ? "\(self.rec005_R002?.APPRVR_TOT_CNT ?? "")/4" : selectApprover))
            
            cells.append(EditArticleData( rowType: .REQUESTOR,title: "requestor".localized, icon: "list_employee_ico", Value: rec005_R002?.REG_NM))
            
            cells.append(EditArticleData(rowType: .REQUESTSCHEDULED,title: "requested".localized,decription: "scheduled".localized, icon: "ico_calendar-1", startDate: rec005_R002?.PAY_REQ_DATE, endDate: rec005_R002?.REG_DTM))
            
            cells.append(EditArticleData(rowType: .TOTALAMOUNT,title: "total_amount".localized, icon: "ico_card", Value: rec005_R002?.TOT_PAY_USD_AMT ?? "", valueKH: rec005_R002?.TOT_PAY_LOC_AMT ?? "" ))
            
        }
    }
    
    func getDataApprovalWeCMS(isUploadImage: Bool = false, isUploadFile: Bool = false, selectApprover: String = "", selectExpenses: String = "") {
        
        cells = []
        tempDescription = rec005_R002?.POST_CONT ?? ""
        cells.append(EditArticleData(rowType: .NEW_ARTICLE ,title: rec005_R002?.POST_TITLE, decription: tempDescription))
        
        self.appendFileImage()
        
        cells.append(EditArticleData(rowType: .LINE))
        
        cells.append(EditArticleData(rowType: .REQUESTOR,title: "document_no.".localized, icon: "ico_hashtag", Value: rec005_R002?.DOC_NO ?? ""))
        
        cells.append(EditArticleData( rowType: .REQUESTOR,title: "requestor".localized, icon: "list_employee_ico", Value: rec005_R002?.REG_NM))
        
        cells.append(EditArticleData(rowType: .REQUESTSCHEDULED,title: "requested".localized,decription: "scheduled".localized, icon: "ico_calendar-1", startDate: rec005_R002?.PAY_REQ_DATE, endDate: rec005_R002?.REG_DTM))
        
        cells.append(EditArticleData(rowType: .TOTALAMOUNT,title: "Transfer amount", icon: "ico_card", Value: rec005_R002?.TOT_PAY_USD_AMT ?? "", valueKH: rec005_R002?.TOT_PAY_LOC_AMT ?? "" ))
        
        cells.append(EditArticleData(rowType: .APPROVERS,title: "approvers".localized, icon: "ico_check-1", Value:  selectApprover ==  "" ? "\(self.rec005_R002?.APPRVR_TOT_CNT ?? "")/4" : selectApprover))
        
        cells.append(EditArticleData(rowType: .EXPENSES,title: "receipt".localized, icon: "ico_stack-1", Value:  selectExpenses == "" ? "\(rec005_R002?.REC?.count ?? 0)" : selectExpenses))
        
//        if rec005_R002?.REC?.count != 0 {
//            for (index,item) in (rec005_R002?.REC ?? []).enumerated()  {
//                if index < 2 {
//                    cells.append(EditArticleData(rowType: .EXPENSESITEM, title: item.TRCO_CMENM, decription: item.USAG_NM, Value: item.AMT, DOC_TYPE: item.DOC_TYPE, DOC_ID: item.DOC_ID, CCY_CD: item.CCY_CD, MEMO: item.MEMO))
//                }
//            }
//        }
//        if rec005_R002?.REC?.count ?? 0 > 2 {
//            cells.append(EditArticleData(rowType: .SEEMORE))
//        }
        
    }
    
    func updateApprovalWeCMS(selectApprover: String = "", index: Int) {
        let dataUpdate = EditArticleData(rowType: .APPROVERS,title: "approvers".localized, icon: "ico_check-1", Value:  selectApprover ==  "" ? "\(self.rec005_R002?.APPRVR_TOT_CNT ?? "")/4" : selectApprover)
        
        cells[index] = dataUpdate
        
    }
    
    //MARK: -  ARTICLE
    func getDataArticle(){
        cells = []
        
        tempDescription = rec005_R001?.POST_CONT ?? ""
        cells.append(EditArticleData(rowType: .NEW_ARTICLE, title: rec005_R001?.POST_TITLE, decription: tempDescription))
        
        if (self.rec005_R001?.REC?.count ?? 0) != 0 {
            for REC in self.rec005_R001?.REC ?? [] {
                let fileName = REC.ORG_FILE_NM ?? ""
                if fileName.contains(".jpg") || fileName.contains(".png")  {
                    cells.append(EditArticleData(rowType: .IMAGE, insertImage:  REC.FILE_URL, IMAGE_REC: REC))
                }
                
            }
            for REC in self.rec005_R001?.REC ?? [] {
                let fileType = REC.ORG_FILE_NM ?? ""
                if !fileType.contains("jpg") && !fileType.contains("png") {
                    cells.append(EditArticleData(rowType: .ATTACHMENT, insertImage: REC.FILE_URL, fileName: REC.ORG_FILE_NM, fileData: REC.FILE_SIZE, filePath: "",  IMAGE_REC: REC))
                }
            }
        }
        cells.append(EditArticleData(rowType: .LINE))
        cells.append(EditArticleData(rowType: .POST_PUBLIC, title: "post_as_public".localized, decription: "toggle_off_will_post_as_private".localized, icon: "ico_earth", postType: rec005_R001?.POST_STTS))
        
        cells.append(EditArticleData(rowType: .MAKE, title: "mark_as_important".localized, decription: rec005_R001?.PIN_POST_TYPE == "" ? "pin_the_post_until_specific_date".localized : "until".localized, icon: "ico_warning", Value: self.PIN_POST_DUE_DT , postType: rec005_R001?.PIN_POST_TYPE))
    }
    
    // MARK: - Request API MREC_BLTB_0004_U001 - edit article
    func request_0004_U001(BLTB_CD: String?, POST_SEQ_NO: String?, POST_TITLE: String?, POST_CONT: String?, POST_TYPE_CD: String?, POST_STTS: String?, PIN_POST_TYPE: String?, PIN_POST_DUE_DT: String?, REC: [MREC_BLTB_0004_U001.REQUEST.REC], REC2: [MREC_BLTB_0004_U001.REQUEST.REC2],  completion  : @escaping (Swift.Result<MREC_BLTB_0004_U001.RESPONSE, NSError>) -> Void) {
        
        let body = MREC_BLTB_0004_U001.REQUEST(BLTB_CD: BLTB_CD, POST_SEQ_NO: POST_SEQ_NO, POST_TITLE: POST_TITLE, POST_CONT: POST_CONT, POST_TYPE_CD: POST_TYPE_CD, POST_STTS: POST_STTS, PIN_POST_TYPE: PIN_POST_TYPE, PIN_POST_DUE_DT: PIN_POST_DUE_DT, REC: REC, REC2: REC2 )
        
        DataAccess.shared.fetchData(shouldShowLoading   : true,
                                    apiKey              : APIKey.MREC_BLTB_0004_U001,
                                    body                : body,
                                    responseType        : MREC_BLTB_0004_U001.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                completion(.success(data))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    // MARK: - Request API MREC_BLTB_0004_U002 Edit Approval(COMM) -
    func request_0004_U002(BLTB_CD: String?, POST_SEQ_NO: String?, POST_TITLE: String?, POST_CONT: String?, REC1: [MREC_BLTB_0004_U002.REQUEST.REC1], REC2: [MREC_BLTB_0004_U002.REQUEST.REC2],REC3: [MREC_BLTB_0004_U002.REQUEST.REC3],REC4: [MREC_BLTB_0004_U002.REQUEST.REC4],  completion  : @escaping (Swift.Result<MREC_BLTB_0004_U002.RESPONSE, NSError>) -> Void) {
        
        let body = MREC_BLTB_0004_U002.REQUEST(BLTB_CD: BLTB_CD, POST_SEQ_NO: POST_SEQ_NO, POST_TITLE: POST_TITLE, POST_CONT: POST_CONT, REC1: REC1, REC2: REC2, REC3: REC3, REC4: REC4 )
        
        DataAccess.shared.fetchData(shouldShowLoading   : true,
                                    apiKey              : APIKey.MREC_BLTB_0004_U002,
                                    body                : body,
                                    responseType        : MREC_BLTB_0004_U002.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                completion(.success(data))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    //MARK: -  APPROVAL
    // request Board details for display in Edit Article
    func fetchEditBoardDetailApproval(POST_SEQ_NO: String, BLTB_CD: String, completion  : @escaping (Swift.Result<MREC_BLTB_0005_R002.RESPONSE, NSError>) -> Void) {
        let body = MREC_BLTB_0005_R002.REQUEST(POST_SEQ_NO: POST_SEQ_NO, BLTB_CD: BLTB_CD)      // for real
        DataAccess.shared.fetchData(shouldShowLoading   : true,
                                    apiKey              : APIKey.MREC_BLTB_0005_R002,
                                    body                : body,
                                    responseType        : MREC_BLTB_0005_R002.RESPONSE.self) { (result) in
            switch result {
            case .success(let boardData):
                self.rec005_R002 = boardData
                for item in (boardData.REC2 ?? []){
                   // let fileData = convertImageURLSession(imageURL: item.FILE_URL ?? "")
                    self.attacmentREC3.append(MREC_BLTB_0004_U002.REQUEST.REC3(FILE_NM: item.ORG_FILE_NM, FILE_DATA: item.FILE_URL?.toBase64 ?? ""))
                    self.REC3.append(MREC_BLTB_0004_U002.REQUEST.REC3(FILE_NM: item.ORG_FILE_NM, FILE_DATA: item.FILE_URL ?? ""))
                }
                self.getDataApproval()
                completion(.success(boardData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchEditBoardDetailApprovalWeCMS(POST_SEQ_NO: String, BLTB_CD: String, completion  : @escaping (Swift.Result<MREC_BLTB_0005_R002.RESPONSE, NSError>) -> Void) {
        let body = MREC_BLTB_0005_R002.REQUEST(POST_SEQ_NO: POST_SEQ_NO, BLTB_CD: BLTB_CD)      // for real
        DataAccess.shared.fetchData(shouldShowLoading   : true,
                                    apiKey              : APIKey.MREC_BLTB_0005_R002,
                                    body                : body,
                                    responseType        : MREC_BLTB_0005_R002.RESPONSE.self) { (result) in
            switch result {
            case .success(let boardData):
                self.rec005_R002 = boardData
                for item in (boardData.REC2 ?? []){
                   // let fileData = convertImageURLSession(imageURL: item.FILE_URL ?? "")
                    self.attacmentREC3.append(MREC_BLTB_0004_U002.REQUEST.REC3(FILE_NM: item.ORG_FILE_NM, FILE_DATA: item.FILE_URL?.toBase64 ?? ""))
                    self.REC3.append(MREC_BLTB_0004_U002.REQUEST.REC3(FILE_NM: item.ORG_FILE_NM, FILE_DATA: item.FILE_URL ?? ""))
                }
                self.getDataApprovalWeCMS()
                completion(.success(boardData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //MARK: -  ARTICLE
    func fetchEditBoardDetailArticle(POST_SEQ_NO: String, BLTB_CD: String, completion  : @escaping (Swift.Result<MREC_BLTB_0005_R001.RESPONSE, NSError>) -> Void) {
        let body = MREC_BLTB_0005_R001.REQUEST(POST_SEQ_NO: POST_SEQ_NO, BLTB_CD: BLTB_CD)
        DataAccess.shared.fetchData(shouldShowLoading   : true,
                                    apiKey              : APIKey.MREC_BLTB_0005_R001,
                                    body                : body,
                                    responseType        : MREC_BLTB_0005_R001.RESPONSE.self) { (result) in
            switch result {
            case .success(let boardData):
                self.rec005_R001 = boardData
                for (index,item) in (boardData.REC ?? []).enumerated(){
                   // let fileData = convertImage(imageURL: item.FILE_URL ?? "")
                    self.attacmentREC2.append(MREC_BLTB_0004_U001.REQUEST.REC2(FILE_NM: item.ORG_FILE_NM, FILE_DATA: item.FILE_URL?.toBase64))
                    self.REC2.append(MREC_BLTB_0004_U001.REQUEST.REC2(FILE_NM: item.ORG_FILE_NM, FILE_DATA: item.FILE_URL ?? ""))
//                    if index == ((boardData.REC ?? []).count - 1) {
//                        LoadingView.hide()
//                    }
                }
                self.PIN_POST_DUE_DT = self.rec005_R001?.PIN_POST_TYPE == "UD" ? "permanently".localized : self.rec005_R001?.PIN_POST_DUE_DT ?? ""
                self.getDataArticle()
                completion(.success(boardData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    func setContent(rowType: EditArticleRowType, desc: String?, title: String?){
        for (index, value) in (self.cells.enumerated()){
            if value.rowType == rowType {
                self.cells[index].decription = desc
                self.cells[index].title = title
            }
        }
    }
}

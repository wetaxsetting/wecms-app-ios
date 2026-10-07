//
//  EditDraftVM.swift
//  WeCMS_iOS
//
//  Created by Seanghay Huort on 14/2/24.
//

import Foundation
class EditDraftVM {
    var simpleApproval          : [ApprovalContent] = []
    var expenseApproval         : [ApprovalContent] = []
    var newArticleApproval      : [ApprovalContent] = []
    var dateFilterModel         : [DateFilterModel] = []
    
    var attacmentREC            : [MREC_BLTB_0004_C002.REQUEST.REC3] = []
    var attacmentArticleREC     : [MREC_BLTB_0004_C001.REQUEST.REC] = []
    var REC                     : [WeCMSStruct.BoardDetail_Protocol] = []
    var fileREC                 : [MREC_BLTB_0005_R003.RESPONSE.REC] = []
    var imageIntPairs: [ImageFullSizeDraft] = []
    
    var responseDraft           : MREC_BLTB_0005_R003.RESPONSE?
    var requestExpense  : [MREC_BLTB_0004_C002.REQUEST.REC1] = []
    var selectApproversCount = ""
    var selectExpenseCount   = ""
    
    func injectData(selectApprover: String = "") {
        simpleApproval      = []
        expenseApproval     = []
        newArticleApproval  = []
        
        //MARK: - ============================================== SIMPLE APPROVAL ==============================================
        simpleApproval.append(ApprovalContent(Title: self.responseDraft?.POST_TITLE, TitleHolder: "title".localized, Description: self.responseDraft?.POST_CONT, DescriptionHolder: "Description".localized + " " + "max_200_characters".localized, ApprovalItem: .CONTENT))
        
        if attacmentREC.count != 0 {
            for (_, item) in attacmentREC.enumerated() {
                simpleApproval.append(ApprovalContent(insertImage: item.FILE_DATA?.toImage(),fileName: item.FILE_NM, fileData: item.FILE_DATA, filePath: "", ApprovalItem: (item.FILE_NM ?? "").contains("jpg") ? .IMAGE : .ATTACMENT))
            }
        }
        simpleApproval.append(ApprovalContent(ApprovalItem: .LINE))
        
        simpleApproval.append(ApprovalContent(Title: "approvers".localized, Image: "ico_check-1", Value: selectApprover == "" ? "\(self.responseDraft?.REC3.count ?? 0)/4" : selectApprover, ApprovalItem: .APPROVERS))
        simpleApproval.append(ApprovalContent(Title: "requestor".localized, Image: "list_employee_ico", Value: self.responseDraft?.REQ_USER_NM, ApprovalItem: .REQUESTOR))
        
        //MARK: - ============================================== EXPENSE APPROVAL ==============================================
        expenseApproval.append(ApprovalContent(Title: self.responseDraft?.POST_TITLE, TitleHolder: "title".localized, Description: self.responseDraft?.POST_CONT, DescriptionHolder: "Description".localized + " " + "max_200_characters".localized, ApprovalItem: .CONTENT))
        if attacmentREC.count != 0 {
            for (_, item) in attacmentREC.enumerated() {
                expenseApproval.append(ApprovalContent(insertImage: item.FILE_DATA?.toImage(), fileName: item.FILE_NM, fileData: item.FILE_DATA, filePath: "", ApprovalItem: (item.FILE_NM ?? "").contains("jpg") ? .IMAGE : .ATTACMENT))
            }
        }
        expenseApproval.append(ApprovalContent(ApprovalItem: .LINE))
        expenseApproval.append(ApprovalContent(Title: "expenses".localized, Image: "ico_stack-1", Value: self.requestExpense.count == 0 ? "select".localized : "\(self.requestExpense.count)", ApprovalItem: .EXPENSES))
        for (index, item ) in requestExpense.enumerated() {
            if index < 2 {
                expenseApproval.append(ApprovalContent(Title: item.TRCO_CMNM, TRCO_CMENM: item.TRCO_CMENM, Description: item.USAG_NM, Value: item.AMT, CCY_CD: item.CCY_CD, DOC_ID: item.DOC_ID, DOC_TYPE: item.DOC_TYPE, ApprovalItem: .EXPENSESITEM))
            }
        }
        if self.requestExpense.count > 2 {
            expenseApproval.append(ApprovalContent(Title: "see_more".localized, Image: "ico_check-1", Value: "", ApprovalItem: .SEEMORE))
        }
        expenseApproval.append(ApprovalContent(Title: "approvers".localized, Image: "ico_check-1", Value: selectApprover == "" ? "\(self.responseDraft?.REC3.count ?? 0)/4" : selectApprover, ApprovalItem: .APPROVERS))
        expenseApproval.append(ApprovalContent(Title: "requestor".localized, Image: "list_employee_ico", Value: Shared.R002_DATA?.USER_NM ?? "", ApprovalItem: .REQUESTOR))
        expenseApproval.append(ApprovalContent(Title: "requested".localized, Description: "scheduled".localized, Image: "ico_calendar-1", ApprovalItem: .REQUESTSCHEDULED))
        expenseApproval.append(ApprovalContent(Title: "total_amount".localized, Image: "ico_card", Value: self.responseDraft?.AMT ?? "", ApprovalItem: .TOTALAMOUNT))
        
        //MARK: - ============================================== NEW ARTICLE ==============================================
        newArticleApproval.append(ApprovalContent(Title: self.responseDraft?.POST_TITLE, TitleHolder: "title".localized, Description: self.responseDraft?.POST_CONT, DescriptionHolder: "Description".localized, ApprovalItem: .CONTENT))
        if attacmentArticleREC.count != 0 {
            for (_, item) in attacmentArticleREC.enumerated() {
                newArticleApproval.append(ApprovalContent(insertImage: item.FILE_DATA?.toImage(), fileName: item.FILE_NM, fileData: item.FILE_DATA, filePath: "", ApprovalItem: (item.FILE_NM ?? "").contains("jpg") ? .IMAGE : .ATTACMENT))
            }
        }
        newArticleApproval.append(ApprovalContent( ApprovalItem: .LINE))
        newArticleApproval.append(ApprovalContent(Title: "post_as_public".localized, Description: "toggle_off_will_post_as_private".localized, Image: "ico_earth", ApprovalItem: .POST))
        newArticleApproval.append(ApprovalContent(Title: "mark_as_important".localized, Description: "pin_the_post_until_specific_date".localized, Image: "ico_warning", ApprovalItem: .MARK))
        
    }
    
    func injectDataWeCMS(isFromApprover: Bool = false) {
        expenseApproval     = []
        
        //MARK: - ============================================== EXPENSE APPROVAL ==============================================
        expenseApproval.append(ApprovalContent(Title: self.responseDraft?.POST_TITLE, TitleHolder: "title".localized, Description: self.responseDraft?.POST_CONT, DescriptionHolder: "Description".localized + " " + "max_200_characters".localized, ApprovalItem: .CONTENT))
        if attacmentREC.count != 0 {
            for (_, item) in attacmentREC.enumerated() {
                expenseApproval.append(ApprovalContent(insertImage: item.FILE_DATA?.toImage(), fileName: item.FILE_NM, fileData: item.FILE_DATA, filePath: "", ApprovalItem: (item.FILE_NM ?? "").contains("jpg") || (item.FILE_NM ?? "").contains("png") ? .IMAGE : .ATTACMENT))
            }
        }
        expenseApproval.append(ApprovalContent(ApprovalItem: .LINE))
        expenseApproval.append(ApprovalContent(Title: "document_no.".localized,    Image: "ico_hashtag", Value: Shared.documentNo, ApprovalItem: .REQUESTOR))
        expenseApproval.append(ApprovalContent(Title: "requestor".localized, Image: "list_employee_ico", Value: Shared.R002_DATA?.USER_NM ?? "", ApprovalItem: .REQUESTOR))
        expenseApproval.append(ApprovalContent(Title: "requested".localized, Description: "scheduled".localized, Image: "ico_calendar-1", ApprovalItem: .REQUESTSCHEDULED))
        expenseApproval.append(ApprovalContent(Title: "Transfer amount", Image: "ico_card", Value: self.responseDraft?.AMT ?? "", ApprovalItem: .TOTALAMOUNT))
        
        
        let dataApproval = selectApproversCount == "" ? "select".localized : isFromApprover ? selectApproversCount : "\(self.responseDraft?.REC3.count ?? 0)/4"
        expenseApproval.append(ApprovalContent(Title: "approvers".localized, Image: "ico_check-1", Value: dataApproval, ApprovalItem: .APPROVERS))
        expenseApproval.append(ApprovalContent(Title: "receipt".localized, Image: "ico_stack-1", Value: self.requestExpense.count == 0 ? "select".localized : "\(self.requestExpense.count)", ApprovalItem: .EXPENSES))
        
//        for (index, item ) in requestExpense.enumerated() {
//            if index < 2 {
//                expenseApproval.append(ApprovalContent(Title: item.TRCO_CMNM, TRCO_CMENM: item.TRCO_CMENM, Description: item.USAG_NM, Value: item.AMT, CCY_CD: item.CCY_CD, DOC_ID: item.DOC_ID, DOC_TYPE: item.DOC_TYPE, ApprovalItem: .EXPENSESITEM))
//            }
//        }
//        if self.requestExpense.count > 2 {
//            expenseApproval.append(ApprovalContent(Title: "see_more".localized, Image: "ico_check-1", Value: "", ApprovalItem: .SEEMORE))
//        }
        
    }
    
    func fetchEditDraft(DRAFT_POST_SEQ_NO: String, BLTB_CD: String, POST_TYPE_CD: String, completion: @escaping (Swift.Result<MREC_BLTB_0005_R003.RESPONSE, NSError>) -> Void) {
        let body = MREC_BLTB_0005_R003.REQUEST(DRAFT_POST_SEQ_NO: DRAFT_POST_SEQ_NO, BLTB_CD: BLTB_CD, POST_TYPE_CD: POST_TYPE_CD)
        
        DataAccess.shared.fetchData(apiKey : .MREC_BLTB_0005_R003, body : body, responseType: MREC_BLTB_0005_R003.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                self.responseDraft = data
                if data.REC.count != 0 {
                    for item in data.REC {
//                        let itemImage = item.FILE_URL?.toBase64
//                        let itemImage = convertImage(imageURL: item.FILE_URL ?? "")
                        if data.POST_TYPE_CD == "01" {
                            self.attacmentArticleREC.append(MREC_BLTB_0004_C001.REQUEST.REC(FILE_NM: item.ORG_FILE_NM, FILE_DATA: item.FILE_URL))
                            self.imageIntPairs.append(ImageFullSizeDraft(image: item.FILE_URL?.toImage(), name: item.ORG_FILE_NM))
                        }else{
                            self.attacmentREC.append(MREC_BLTB_0004_C002.REQUEST.REC3(FILE_NM: item.ORG_FILE_NM, FILE_DATA: item.FILE_URL))
                            self.imageIntPairs.append(ImageFullSizeDraft(image: item.FILE_URL?.toImage(), name: item.ORG_FILE_NM))
                        }
                        self.fileREC.append(MREC_BLTB_0005_R003.RESPONSE.REC(FILE_ID: item.FILE_ID, ORG_FILE_NM: item.ORG_FILE_NM, SAVE_FILE_NM: item.SAVE_FILE_NM, FILE_SIZE : item.FILE_SIZE, FILE_URL : item.FILE_URL))
                    }
                }
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchEditDraftWeCMS(DRAFT_POST_SEQ_NO: String, BLTB_CD: String, POST_TYPE_CD: String, completion: @escaping (Swift.Result<MREC_BLTB_0005_R003.RESPONSE, NSError>) -> Void) {
        let body = MREC_BLTB_0005_R003.REQUEST(DRAFT_POST_SEQ_NO: DRAFT_POST_SEQ_NO, BLTB_CD: BLTB_CD, POST_TYPE_CD: POST_TYPE_CD)
        
        DataAccess.shared.fetchData(apiKey : .MREC_BLTB_0005_R003, body : body, responseType: MREC_BLTB_0005_R003.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                self.responseDraft = data
                if data.REC.count != 0 {
                    self.imageIntPairs.removeAll()
                    for item in data.REC {
                        if data.POST_TYPE_CD == "01" {
                            self.attacmentArticleREC.append(MREC_BLTB_0004_C001.REQUEST.REC(FILE_NM: item.ORG_FILE_NM, FILE_DATA: item.FILE_URL))
                            self.validateAndCreateImage(from: item.FILE_URL) { validatedImage, isNoImage in
                                self.imageIntPairs.append(ImageFullSizeDraft(image: validatedImage, name: item.ORG_FILE_NM, FILE_DATA: item.FILE_URL))

                            }
                        }else{
                            self.attacmentREC.append(MREC_BLTB_0004_C002.REQUEST.REC3(FILE_NM: item.ORG_FILE_NM, FILE_DATA: item.FILE_URL))
                            self.validateAndCreateImage(from: item.FILE_URL) { validatedImage, isNoImage in
                                self.imageIntPairs.append(ImageFullSizeDraft(image: validatedImage, name: item.ORG_FILE_NM, FILE_DATA: item.FILE_URL))

                            }
                        }
                        self.fileREC.append(MREC_BLTB_0005_R003.RESPONSE.REC(FILE_ID: item.FILE_ID, ORG_FILE_NM: item.ORG_FILE_NM, SAVE_FILE_NM: item.SAVE_FILE_NM, FILE_SIZE : item.FILE_SIZE, FILE_URL : item.FILE_URL))
                    }
                }
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func validateAndCreateImage(from fileURL: String?, completion: @escaping (UIImage?, Bool) -> Void) {
        guard let fileURL = fileURL else {
            print("FILE_URL is nil. Returning placeholder.")
            completion(UIImage(named: "noimage") ?? UIImage(), true)
            return
        }
        
        // Check if the URL is valid
        if fileURL.contains("\(Shared.c_web_base_url)"), let url = URL(string: fileURL) {
            // Load image asynchronously
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Failed to load image from URL: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(UIImage(named: "noimage") ?? UIImage(), true)
                    }
                    return
                }
                
                if let data = data, let image = UIImage(data: data), image.size != .zero {
                    print("Successfully loaded image from URL: \(fileURL)")
                    DispatchQueue.main.async {
                        completion(image, false)
                    }
                } else {
                    print("Invalid image data or zero size. Returning placeholder.")
                    DispatchQueue.main.async {
                        completion(UIImage(named: "noimage") ?? UIImage(), true)
                    }
                }
            }.resume()
            return
        }
        
        // Check if it's a Base64 string
        if let image = fileURL.toImage(), image.size != .zero {
            print("Successfully converted Base64 to UIImage.")
            completion(image, false)
            return
        }
        
        // If all else fails, return a placeholder
        print("Invalid FILE_URL. Returning placeholder.")
        completion(UIImage(named: "placeholder") ?? UIImage(), true)
    }
    
    func cropToSquare(image: UIImage) -> UIImage {
        let size = image.size
        let sideLength = min(size.width, size.height)
        let xOffset = (size.width - sideLength) / 2.0
        let yOffset = (size.height - sideLength) / 2.0
        let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength)
        
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage)
        }
        
        print("Failed to crop image. Returning original image.")
        return image
    }

}

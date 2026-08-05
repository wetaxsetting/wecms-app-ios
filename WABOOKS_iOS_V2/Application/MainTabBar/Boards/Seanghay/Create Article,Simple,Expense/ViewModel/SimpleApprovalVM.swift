//
//  SimpleApprovalVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Seanghay Huort on 17/1/24.
//

import Foundation

class SimpleApprovalVM {
    var simpleApproval          : [ApprovalContent] = []
    var expenseApproval         : [ApprovalContent] = []
    var newArticleApproval      : [ApprovalContent] = []
    var dateFilterModel         : [DateFilterModel] = []
    
    var attacmentREC            : [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC3] = []
    var attacmentArticleREC     : [WABOOKS_MREC_BLTB_0004_C001.REQUEST.REC] = []
    var REC                     : [WABOOKSStruct.BoardDetail_Protocol] = []
    
    var requestExpense          : [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1] = []
    var selectApproversCount = ""
    var selectExpenseCount   = ""
    
    func initData(isUploadImage: Bool = false, isUploadFile: Bool = false, selectApprover: String = "") {
        simpleApproval      = []
        expenseApproval     = []
        newArticleApproval  = []
        
        //MARK: - ============================================== SIMPLE APPROVAL ==============================================
        simpleApproval.append(ApprovalContent(Title: "title".localized, Description: "Description".localized + " " + "max_200_characters".localized , ApprovalItem: .CONTENT))

        if attacmentREC.count != 0 {
            for (_, item) in attacmentREC.enumerated() {
                simpleApproval.append(ApprovalContent(insertImage: item.FILE_DATA?.toImage(),fileName: item.FILE_NM, fileData: item.FILE_DATA, filePath: "", ApprovalItem: (item.FILE_NM ?? "").contains("jpg") ? .IMAGE : .ATTACMENT))
            }
        }
        simpleApproval.append(ApprovalContent(ApprovalItem: .LINE))
        
        simpleApproval.append(ApprovalContent(Title: "approvers".localized, Image: "ico_check-1", Value: self.selectApproversCount == "" ? "select".localized : self.selectApproversCount, ApprovalItem: .APPROVERS))
        simpleApproval.append(ApprovalContent(Title: "requestor".localized, Image: "list_employee_ico", Value: Shared.R002_DATA?.USER_NM ?? "", ApprovalItem: .REQUESTOR))
        
        //MARK: - ============================================== EXPENSE APPROVAL ==============================================
        expenseApproval.append(ApprovalContent(Title: "title".localized, Description: "Description".localized + " " + "max_200_characters".localized, ApprovalItem: .CONTENT))
        if attacmentREC.count != 0 {
            for (_, item) in attacmentREC.enumerated() {
                expenseApproval.append(ApprovalContent(insertImage: item.FILE_DATA?.toImage(), fileName: item.FILE_NM, fileData: item.FILE_DATA, filePath: "", ApprovalItem: (item.FILE_NM ?? "").contains("jpg") ? .IMAGE : .ATTACMENT))
            }
        }
        expenseApproval.append(ApprovalContent(ApprovalItem: .LINE))
//        expenseApproval.append(ApprovalContent(Title: "Document No.", Image: "ico_hashtag", Value: "", ApprovalItem: .DOCUMENTNO))
        expenseApproval.append(ApprovalContent(Title: "expenses".localized, Image: "ico_stack-1", Value: self.requestExpense.count == 0 ? "select".localized : "\(self.requestExpense.count)", ApprovalItem: .EXPENSES))

        for (index, item ) in requestExpense.enumerated() {
            if index < 2 {
                expenseApproval.append(ApprovalContent(Title: item.TRCO_CMNM, nickName: item.TRCO_NICK_NM, TRCO_CMENM: item.TRCO_CMENM, Description: item.USAG_NM, Value: item.AMT, CCY_CD: item.CCY_CD, DOC_ID: item.DOC_ID, DOC_TYPE: item.DOC_TYPE, TRCO_KEY: item.TRCO_KEY, BUSA_USAG_CD: item.BUSA_USAG_CD, MEMO: item.MEMO , ApprovalItem: .EXPENSESITEM))
            }
        }
        if self.requestExpense.count > 2 {
            expenseApproval.append(ApprovalContent(Title: "see_more".localized, Image: "ico_check-1", Value: "", ApprovalItem: .SEEMORE))
        }
        expenseApproval.append(ApprovalContent(Title: "approvers".localized,    Image: "ico_check-1", Value: self.selectApproversCount == "" ? "select".localized : self.selectApproversCount, ApprovalItem: .APPROVERS))
        expenseApproval.append(ApprovalContent(Title: "requestor".localized,    Image: "list_employee_ico", Value: Shared.R002_DATA?.USER_NM ?? "", ApprovalItem: .REQUESTOR))
        expenseApproval.append(ApprovalContent(Title: "requested".localized,    Description: "scheduled".localized, Image: "ico_calendar-1", ApprovalItem: .REQUESTSCHEDULED))
        expenseApproval.append(ApprovalContent(Title: "total_amount".localized, Image: "ico_card", Value: "USD 0.00", ApprovalItem: .TOTALAMOUNT))
        
        
        
        
        //MARK: - ============================================== NEW ARTICLE ==============================================
        newArticleApproval.append(ApprovalContent(Title: "title".localized, Description: "Description".localized, ApprovalItem: .CONTENT))
        if attacmentArticleREC.count != 0 {
            for (_, item) in attacmentArticleREC.enumerated() {
                newArticleApproval.append(ApprovalContent(insertImage: item.FILE_DATA?.toImage(), fileName: item.FILE_NM, fileData: item.FILE_DATA, filePath: "", ApprovalItem: (item.FILE_NM ?? "").contains("jpg") ? .IMAGE : .ATTACMENT))
            }
        }
        newArticleApproval.append(ApprovalContent(ApprovalItem: .LINE))
        newArticleApproval.append(ApprovalContent(Title: "post_as_public".localized, Description: "toggle_off_will_post_as_private".localized, Image: "ico_earth", ApprovalItem: .POST))
        newArticleApproval.append(ApprovalContent(Title: "mark_as_important".localized, Description: "pin_the_post_until_specific_date".localized, Image: "ico_warning", ApprovalItem: .MARK))
    }
    
    func initDataWeCMS() {
        expenseApproval     = []
        
        expenseApproval.append(ApprovalContent(Title: "title".localized, Description: "Description".localized + " " + "max_200_characters".localized, ApprovalItem: .CONTENT))
        
        if attacmentREC.count != 0 {
            for (_, item) in attacmentREC.enumerated() {
                expenseApproval.append(ApprovalContent(insertImage: item.FILE_DATA?.toImage(), fileName: item.FILE_NM, fileData: item.FILE_DATA, filePath: "", ApprovalItem: (item.FILE_NM ?? "").contains("jpg") ? .IMAGE : .ATTACMENT))
            }
        }
        
        expenseApproval.append(ApprovalContent(ApprovalItem: .LINE))
        expenseApproval.append(ApprovalContent(Title: "document_no.".localized,    Image: "ico_hashtag", Value: Shared.documentNo, ApprovalItem: .REQUESTOR))
        expenseApproval.append(ApprovalContent(Title: "requestor".localized,    Image: "list_employee_ico", Value: Shared.R002_DATA?.USER_NM ?? "", ApprovalItem: .REQUESTOR))
        expenseApproval.append(ApprovalContent(Title: "requested".localized,    Description: "scheduled".localized, Image: "ico_calendar-1", ApprovalItem: .REQUESTSCHEDULED))
        expenseApproval.append(ApprovalContent(Title: "Transfer amount", Image: "ico_card", Value: "USD 0.00", ApprovalItem: .TOTALAMOUNT))
        expenseApproval.append(ApprovalContent(Title: "approvers".localized,    Image: "ico_check-1", Value: self.selectApproversCount == "" ? "select".localized : self.selectApproversCount, ApprovalItem: .APPROVERS))
        expenseApproval.append(ApprovalContent(Title: "receipt".localized, Image: "ico_stack-1", Value: self.requestExpense.count == 0 ? "select".localized : "\(self.requestExpense.count)", ApprovalItem: .EXPENSES))
        
        //        for (index, item ) in requestExpense.enumerated() {
        //            if index < 2 {
        //                expenseApproval.append(ApprovalContent(Title: item.TRCO_CMNM, nickName: item.TRCO_NICK_NM, TRCO_CMENM: item.TRCO_CMENM, Description: item.USAG_NM, Value: item.AMT, CCY_CD: item.CCY_CD, DOC_ID: item.DOC_ID, DOC_TYPE: item.DOC_TYPE, TRCO_KEY: item.TRCO_KEY, BUSA_USAG_CD: item.BUSA_USAG_CD, MEMO: item.MEMO , ApprovalItem: .EXPENSESITEM))
        //            }
        //        }
        //        if self.requestExpense.count > 2 {
        //            expenseApproval.append(ApprovalContent(Title: "see_more".localized, Image: "ico_check-1", Value: "", ApprovalItem: .SEEMORE))
        //        }
        
    }
    
    func createApproval(body: WABOOKS_MREC_BLTB_0004_C002.REQUEST, completion: @escaping (NSError?) -> ()) {
        
        DataAccess.shared.fetchData(apiKey      : .WABOOKS_MREC_BLTB_0004_C002,
                                    body        : body,
                                    responseType: WABOOKS_MREC_BLTB_0004_C002.RESPONSE.self) { (result) in
            switch result {
            case .success(_):
                
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func createNewArticle(body:WABOOKS_MREC_BLTB_0004_C001.REQUEST, completion: @escaping (NSError?) -> Void = { _ in }){
        
        DataAccess.shared.fetchData(apiKey      : .WABOOKS_MREC_BLTB_0004_C001,
                                    body        : body,
                                    responseType: WABOOKS_MREC_BLTB_0004_C001.RESPONSE.self) { (result) in
            switch result {
            case .success(_):
                
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    //MARK: - Show 4 row
    func initDateFilter(){
        dateFilterModel = []
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_1_month".localized, Description: "", Image: "ico_check-2", isSelected: true), rowType: .LastOneMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_3_months".localized, Description: "", Image: ""), rowType: .LastThreeMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_6_months".localized, Description: "", Image: ""), rowType: .LastSixMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "filter_manually".localized, Description: "", Image: ""), rowType: .FilterMaually))
    }
    
    //MARK: - Show 4 row
    func initNewDateFilter(){
        dateFilterModel = []
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_1_month".localized, Description: "", Image: "ico_check-2"), rowType: .LastOneMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_3_months".localized, Description: "", Image: ""), rowType: .LastThreeMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_6_months".localized, Description: "", Image: ""), rowType: .LastSixMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "filter_manually".localized, Description: "", Image: ""), rowType: .FilterMaually))
    }
    
    //MARK: - Append when click Filter Manually
    func initCustomDateFilter() {
        dateFilterModel = []
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_1_month".localized, Description: "", Image: "ico_check-2"), rowType: .LastOneMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_3_months".localized, Description: "", Image: ""), rowType: .LastThreeMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_6_months".localized, Description: "", Image: ""), rowType: .LastSixMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "filter_manually".localized, Description: "", Image: "", isSelected: true), rowType: .FilterMaually))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "from_date".localized, Description: "28-Jan-2024", Image: "date"), rowType: .FromDate))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "to_date".localized, Description: "28-Jan-2024", Image: "date"), rowType: .ToDate))
    }
    
    func initNewCustomDateFilter() {
        dateFilterModel = []
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_1_month".localized, Description: "", Image: "ico_check-2"), rowType: .LastOneMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_3_months".localized, Description: "", Image: ""), rowType: .LastThreeMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_6_months".localized, Description: "", Image: ""), rowType: .LastSixMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "filter_manually".localized, Description: "", Image: ""), rowType: .FilterMaually))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "from_date".localized, Description: "28-Jan-2024", Image: "date"), rowType: .FromDate))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "to_date".localized, Description: "28-Jan-2024", Image: "date"), rowType: .ToDate))
    }
    
    func initFromDateFilter() {
        dateFilterModel = []
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_1_month".localized, Description: "", Image: "ico_check-2"), rowType: .LastOneMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_3_months".localized, Description: "", Image: ""), rowType: .LastThreeMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_6_months".localized, Description: "", Image: ""), rowType: .LastSixMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "filter_manually".localized, Description: "", Image: "", isSelected: true), rowType: .FilterMaually))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "from_date".localized, Description: "28-Jan-2024", Image: "date"), rowType: .FromDate))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "", Description: "", Image: ""), rowType: .SelectFromDate))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "to_date".localized, Description: "28-Jan-2024", Image: "date"), rowType: .ToDate))
    }
    
    func initToDate() {
        dateFilterModel = []
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_1_month".localized, Description: "", Image: "ico_check-2"), rowType: .LastOneMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_3_months".localized, Description: "", Image: ""), rowType: .LastThreeMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "last_6_months".localized, Description: "", Image: ""), rowType: .LastSixMonth))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "filter_manually".localized, Description: "", Image: "", isSelected: true), rowType: .FilterMaually))
        
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "from_date".localized, Description: "28-Jan-2024", Image: "date"), rowType: .FromDate))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "to_date".localized, Description: "28-Jan-2024", Image: "date"), rowType: .ToDate))
        dateFilterModel.append(DateFilterModel(value: DateFilter(Title: "", Description: "", Image: ""), rowType: .SelectToDate))
    }
    
    func setValue(rowType: RowType, fromdate: String, toDate: String) {
        for (index, value) in (self.dateFilterModel.enumerated()){
            if value.rowType == rowType {
                self.dateFilterModel[index].value.fromDate = fromdate
                self.dateFilterModel[index].value.toDate = toDate
            }
        }
    }
    
    func setFromDate(rowType: RowType, fromDate: String){
        for (index, value) in (self.dateFilterModel.enumerated()){
            if value.rowType == rowType {
                self.dateFilterModel[index].value.fromDate = fromDate
            }
        }
    }
    
}

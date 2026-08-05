//
//  SelectExpensesVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Seanghay Huort on 18/1/24.
//

import Foundation
class SelectExpensesVM {
    var tabExpense          : [SelectExpensesModel<Any>] = []
    
    var itemApprovers       : [SelectApproversItem] = []
    var itemSelectApprovers : [SelectApproversItem] = []
    
    var itemExpenseBill     : [WABOOKSStruct.RECDoc_Protocol] = []
    var itemExpenseReceipt  : [WABOOKSStruct.RECDoc_Protocol] = []
//    var itemSelectExpense      : [WABOOKS_MREC_BLTB_0004_R003.RESPONES.REC] = []
    var itemSelectBILL          : [WABOOKSStruct.RECDoc_Protocol] = []
    var itemSelectRECEIPT       : [WABOOKSStruct.RECDoc_Protocol] = []
    
    var selectApprovalResponse          : WABOOKS_MREC_BLTB_0004_R002.RESPONSE?
    var selectExpenseBillResponse       : WABOOKS_MREC_BLTB_0004_R003.RESPONES?
    var selectExpenseReceiptResponse    : WABOOKS_MREC_BLTB_0004_R003.RESPONES?
    
    var filterTypeBill      : RowType = .LastOneMonth
    var filterTypeReceipt   : RowType = .LastOneMonth
    
    var selectedDate            : DateFilterModel?
    var selectedDateExpenses    : DateFilterModel?
    
    var expenseType = ""
    var filterApprover : [SelectApproversItem] = []
    
    func initData() {
        tabExpense          = []
        itemExpenseBill     = []
        itemApprovers       = []
        itemExpenseReceipt  = []
        
        //MARK: - tab
        tabExpense.append(SelectExpensesModel(value: SelectExpenses(itemTitle: "E_invoice".localized,    tabSelect: true,   cellType: .BILL)))
        tabExpense.append(SelectExpensesModel(value: SelectExpenses(itemTitle: "receipt".localized, tabSelect: false,  cellType: .RECEIPT)))
        
    }
    
    func initDataWeCMS() {
        tabExpense          = []
        itemExpenseBill     = []
        itemExpenseReceipt  = []
        
        tabExpense.append(SelectExpensesModel(value: SelectExpenses(itemTitle: "receipt".localized, tabSelect: false,  cellType: .RECEIPT)))
        
    }
    
    func appendSelectBill(item: WABOOKSStruct.RECDoc_Protocol) {
        
        let obj = WABOOKSStruct.RECDoc_Protocol(DOC_ID: item.DOC_ID, ISSU_DT: item.ISSU_DT, DOC_TYPE: item.DOC_TYPE, TRCO_KEY: item.TRCO_KEY, TRCO_CMNM: item.TRCO_CMNM, TRCO_CMENM: item.TRCO_CMENM, CCY_CD: item.CCY_CD, AMT: item.AMT, MEMO: item.MEMO, BUSA_USAG_CD: item.BUSA_USAG_CD, USAG_NM: item.USAG_NM, DISP_DOC_ID: item.DISP_DOC_ID, TRCO_TRSC_CCY_CD: item.TRCO_TRSC_CCY_CD, TOTL_AMT: item.TOTL_AMT, COLOR: item.COLOR, TRCO_TAX_ID: item.TRCO_TAX_ID, APPR_DV: item.APPR_DV)
        
        itemSelectBILL.append(obj)
        
//        print("SELECTED ITEM BILL \(itemSelectExpense)")
    }
    
    func appendSelectReceipt(item: WABOOKSStruct.RECDoc_Protocol) {
        
        let obj = WABOOKSStruct.RECDoc_Protocol(DOC_ID: item.DOC_ID, ISSU_DT: item.ISSU_DT, DOC_TYPE: item.DOC_TYPE, TRCO_KEY: item.TRCO_KEY, TRCO_CMNM: item.TRCO_CMNM, TRCO_CMENM: item.TRCO_CMENM, CCY_CD: item.CCY_CD, AMT: item.AMT, MEMO: item.MEMO, BUSA_USAG_CD: item.BUSA_USAG_CD, USAG_NM: item.USAG_NM, DISP_DOC_ID: item.DISP_DOC_ID, TRCO_TRSC_CCY_CD: item.TRCO_TRSC_CCY_CD, TOTL_AMT: item.TOTL_AMT, COLOR: item.COLOR, TRCO_TAX_ID: item.TRCO_TAX_ID, APPR_DV: item.APPR_DV)
        
        itemSelectRECEIPT.append(obj)
//        print("SELECTED ITEM BILL \(itemSelectExpense)")
    }
    
    func appendSelectItem(item: SelectApproversItem){
        itemSelectApprovers.append(SelectApproversItem(USER_NM: item.USER_NM, USER_ID: item.USER_ID, USER_IMG_URL: item.USER_IMG_URL, USER_IMG: item.USER_IMG, CLPH_NO: item.CLPH_NO))
    }
    
    func appendExpensesBillData(isPagination: Bool = false) {
        if !isPagination {
            itemExpenseBill = []
        }
        for (_, item) in (self.selectExpenseBillResponse?.REC ?? []).enumerated() {
            
            let total_amount = item.TRCO_TRSC_CCY_CD == "USD" ? item.TOTL_AMT : item.TOTL_AMT?.components(separatedBy: ".").first
            
            let obj = WABOOKSStruct.RECDoc_Protocol(DOC_ID: item.DOC_ID, ISSU_DT: item.ISSU_DT, DOC_TYPE: item.DOC_TYPE, TRCO_KEY: item.TRCO_KEY, TRCO_CMNM: item.TRCO_CMNM, TRCO_CMENM: item.TRCO_CMENM, CCY_CD: item.CCY_CD, AMT: item.AMT, MEMO: item.MEMO, BUSA_USAG_CD: item.BUSA_USAG_CD, USAG_NM: item.USAG_NM, DISP_DOC_ID: item.DISP_DOC_ID, TRCO_TRSC_CCY_CD: item.TRCO_TRSC_CCY_CD, TOTL_AMT: total_amount, COLOR: item.COLOR, TRCO_TAX_ID: item.TRCO_TAX_ID, APPR_DV: item.APPR_DV)
            
            itemExpenseBill.append(obj)
        }
    }
    
    func appendExpensesReceiptData(isPagination: Bool = false) {
        if !isPagination{
            itemExpenseReceipt = []
        }
        for (_, item) in (self.selectExpenseReceiptResponse?.REC ?? []).enumerated() {
            
            
            let obj = WABOOKSStruct.RECDoc_Protocol(DOC_ID: item.DOC_ID, ISSU_DT: item.ISSU_DT, DOC_TYPE: item.DOC_TYPE, TRCO_KEY: item.TRCO_KEY, TRCO_CMNM: item.TRCO_CMNM, TRCO_CMENM: item.TRCO_CMENM, CCY_CD: item.CCY_CD, AMT: item.AMT, MEMO: item.MEMO, BUSA_USAG_CD: item.BUSA_USAG_CD, USAG_NM: item.USAG_NM, DISP_DOC_ID: item.DISP_DOC_ID, TRCO_TRSC_CCY_CD: item.TRCO_TRSC_CCY_CD, TOTL_AMT: item.TOTL_AMT, COLOR: item.COLOR, TRCO_TAX_ID: item.TRCO_TAX_ID, APPR_DV: item.APPR_DV)

            itemExpenseReceipt.append(obj)
        }
    }
    
//    func searchApprovalItem(searchText: String) {
//
//        if searchText != ""{
//            for (_, item) in itemExpenseReceipt.enumerated() {
//                let searchItem = item.value as! SelectExpenses
//                if (searchItem.itemTitle ?? "").lowercased().contains(searchText) || (searchItem.itemValue ?? "").lowercased().contains(searchText) {
//                    itemExpenseBill.append(SelectExpensesModel(value: SelectExpenses(image: searchItem.image, itemTitle: searchItem.itemTitle, itemTypeTitle: searchItem.itemTypeTitle, itemValue: searchItem.itemValue, itemID: searchItem.itemID, cellType: .BILL)))
//                }else{
//                    itemExpenseBill = []
//                    itemApprovers = []
//                    itemExpenseReceipt = []
//                }
//            }
//        }else{
//            self.initData()
//        }
//    }
    
    func initApprover(isSearching: Bool = false, data: WABOOKS_MREC_BLTB_0004_R002.RESPONSE){
        if !isSearching{
            itemApprovers = []
        }
        self.itemApprovers.append(SelectApproversItem())
        for (_, item) in (data.REC1 ?? []).enumerated() {
            self.itemApprovers.append(SelectApproversItem(USER_NM : item.USER_NM,
                                                     USER_ID      : item.USER_ID,
                                                     USER_IMG_URL : item.USER_IMG_URL,
                                                     USER_IMG     : item.USER_IMG,
                                                     CLPH_NO      : item.CLPH_NO))
        }
    }
    
    func fetApproval(BLTB_CD: String, USER_NM: String, isShowLoading: Bool = true, isSearching: Bool = false, completion: @escaping (Swift.Result<WABOOKS_MREC_BLTB_0004_R002.RESPONSE, NSError>) -> Void = { _ in }){
        let body = WABOOKS_MREC_BLTB_0004_R002.REQUEST(BLTB_CD: BLTB_CD, USER_NM: USER_NM)
        
        DataAccess.shared.fetchData(shouldShowLoading: isShowLoading ,apiKey: APIKey.WABOOKS_MREC_BLTB_0004_R002, body: body, responseType: WABOOKS_MREC_BLTB_0004_R002.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                if !isSearching{
                    self.itemApprovers.append(SelectApproversItem())
                    for (_, item) in (data.REC1 ?? []).enumerated() {
                        self.itemApprovers.append(SelectApproversItem(USER_NM      : item.USER_NM,
                                                                      USER_ID      : item.USER_ID,
                                                                      USER_IMG_URL : item.USER_IMG_URL,
                                                                      USER_IMG     : item.USER_IMG,
                                                                      CLPH_NO      : item.CLPH_NO))
                    }
                }
                completion(.success(data))
            case .failure(let error):
                print("error")
                completion(.failure(error))
            }
        }
    }
    
    func fetExpense(SRCH_WD: String = "", EXPT_TYPE: String, FROM_DT: String = "", TO_DT: String = "", PAGE_NO: Int, PAGE_PER_CNT: Int, isShowLoading :Bool = true, isPaginationBill: Bool = false, isPaginationReceipt: Bool = false, completion: @escaping (Swift.Result<WABOOKS_MREC_BLTB_0004_R003.RESPONES, NSError>) -> Void = { _ in }){
        let body = WABOOKS_MREC_BLTB_0004_R003.REQUEST(SRCH_WD: SRCH_WD, EXPT_TYPE: EXPT_TYPE, FROM_DT: FROM_DT, TO_DT: TO_DT, PAGE_NO : PAGE_NO, PAGE_PER_CNT: PAGE_PER_CNT)
        
        DataAccess.shared.fetchData(shouldShowLoading: isShowLoading, apiKey: APIKey.WABOOKS_MREC_BLTB_0004_R003, body: body, responseType: WABOOKS_MREC_BLTB_0004_R003.RESPONES.self) { (result) in
            switch result {
            case .success(let data):
                if EXPT_TYPE == "B" || EXPT_TYPE == "E" {
                     self.selectExpenseBillResponse = data
                    self.appendExpensesBillData(isPagination: isPaginationBill)
                    
                }else{
                    self.selectExpenseReceiptResponse = data
                    self.appendExpensesReceiptData(isPagination: isPaginationReceipt)
                   
                }
                completion(.success(data))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

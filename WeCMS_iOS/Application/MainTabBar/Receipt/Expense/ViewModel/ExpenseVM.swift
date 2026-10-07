//
//  CompanyExpendVM.swift
//  warBookScreen
//
//  Created by kimlang on 3/21/23.
//

import Foundation

class ExpenseVM{
    var pay_way_cd             : String?
    var ADV_PAYM_SEQ           : String?
    var ADV_PAYM_SEQ_Default   = ""
    var expense_ListResponse   : MREC_R070.RESPONE_EXPENSE?
    var cells                  : [Expense] = []
    var isSelected             = false
    
    func appendData(){
        cells.append(Expense(code: "", title: "None", pay_way_cd: ""))
        cells.append(Expense(code: "", title: "Cash", pay_way_cd: "C"))
        
        for index in 0..<cells.count {
             if let pay_way_cd = pay_way_cd {
                 cells[index].isSelect = (cells[index].pay_way_cd == pay_way_cd)
             } else {
                 cells[index].isSelect = (cells[index].pay_way_cd?.isEmpty)
             }
         }
    }
    
    
    func fectchExpenseList(completion: @escaping (Result<MREC_R070.RESPONE_EXPENSE, NSError>)->Void) {
        // let reqBody = MREC_R005.REQUEST.init(SCH_WORD: self.sch_word)
        DataAccess.shared.fetchData(apiKey: APIKey.MREC_R070, body: MREC_R070.REQUEST(), responseType: MREC_R070.RESPONE_EXPENSE.self) { (result) in
            switch result {
            case .success(let data) :
                // Clear data
                self.cells = []
                self.expense_ListResponse = data
                
                if self.expense_ListResponse?.CASH_USER_YN.uppercased() == "Y" {
                    
                    let rec = MREC_R070.RESPONE_EXPENSE.REC(ADV_PAYM_SEQ: "0", ADV_PAYM_NM: "cash".localized)
                    self.expense_ListResponse?.REC.insert(rec, at: 0)
                   
                }
                let rec1 = MREC_R070.RESPONE_EXPENSE.REC(ADV_PAYM_SEQ: "", ADV_PAYM_NM: "none".localized)
                self.expense_ListResponse?.REC.append(rec1)
                // Static data
//                self.cells?.append(Expense(title: "cash".localized, isSelect: false))
               
                for index in 0..<(self.expense_ListResponse?.REC.count ?? 0){
                    if let adv_paym_seq = self.ADV_PAYM_SEQ  {
                        self.isSelected = self.expense_ListResponse?.REC[index].ADV_PAYM_SEQ == adv_paym_seq ? true : false
                    }else {
                        self.isSelected = self.expense_ListResponse?.REC[index].ADV_PAYM_SEQ == self.ADV_PAYM_SEQ_Default ? true : false
                         
                    }
                    self.cells.append(Expense(code: self.expense_ListResponse?.REC[index].ADV_PAYM_SEQ ?? "", title: self.expense_ListResponse?.REC[index].ADV_PAYM_NM, isSelect: self.isSelected ))
                }
                

                
                completion(.success(data))
            case.failure(let error) :
                completion(.failure(error))
            }
        }
    }
}

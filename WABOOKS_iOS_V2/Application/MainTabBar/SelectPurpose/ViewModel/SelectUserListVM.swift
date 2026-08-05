//
//  SelectPurposeVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Thea Chum on 18/1/21.
//

import Foundation

class SelectUserListVM {
    
    var userListResponse: LIST_POP_UP_RESPONSE?
    
    var original_userListResponse: WABOOKS_MREC_R005.RESPONE?
    var original_widthHoldingTax : WABOOKS_MREC_R901.RESPONE?
    var original_project_site    : comm_0102_001.RESPONE?
    
    
    var sch_word        : String = ""
    
    func fectchUserList(completion: @escaping (NSError?)->Void) {
        
        let reqBody = WABOOKS_MREC_R005.REQUEST.init(SCH_WORD: self.sch_word)
       
        DataAccess.shared.fetchData(apiKey: APIKey.WABOOKS_MREC_R005, body: reqBody, responseType: WABOOKS_MREC_R005.RESPONE.self) { (result) in
            switch result {
            case .success(let data) :
                self.original_userListResponse = data
                self.configUserListData()
                completion(nil)
            case.failure(let error) :
                completion(error)
            }
        }
    }
    
    func fetch_Project_Site (completion : @escaping (NSError?)->Void) {
        
        let reqBody = comm_0102_001.REQUEST.init(SRCH_WD: self.sch_word)
       
        DataAccess.shared.fetchData(apiKey: APIKey.comm_0102_001, body: reqBody, responseType: comm_0102_001.RESPONE.self) { (result) in
            switch result {
            case .success(let data) :
                self.original_project_site = data
                self.config_Project_Sit_Data()
                completion(nil)
            case.failure(let error) :
                completion(error)
            }
        }
    }
    
    func fetchWithHoldingTax (completion : @escaping (NSError?)->Void) {
        
        let reqBody = WABOOKS_MREC_R901.REQUEST.init(SRCH_WD: self.sch_word)
       
        DataAccess.shared.fetchData(apiKey: APIKey.WABOOKS_MREC_R901, body: reqBody, responseType: WABOOKS_MREC_R901.RESPONE.self) { (result) in
            switch result {
            case .success(let data) :
                self.original_widthHoldingTax = data
                self.configHoldingTaxData()
                completion(nil)
            case.failure(let error) :
                completion(error)
            }
        }
    }
    
    func config_Project_Sit_Data () {
//        var recData = [LIST_POP_UP_RESPONSE.PROJECT_SITE_LIST]()
        var recData = [LIST_POP_UP_RESPONSE.USE_LIST]()
        original_project_site?.REC.forEach({ rec in
            recData.append(LIST_POP_UP_RESPONSE.USE_LIST(USE_USAG_CD: rec.PRJT_NO ?? "", USAG_NM: rec.PRJT_NM ?? ""))
        })
        
        userListResponse = LIST_POP_UP_RESPONSE(USE_LIST: recData, REC: [] ,REC2: [])
    }
    
    func configHoldingTaxData () {
        var recData = [LIST_POP_UP_RESPONSE.REC]()
        original_widthHoldingTax?.REC.forEach({ rec in
            recData.append(LIST_POP_UP_RESPONSE.REC(USE_USAG_CD: rec.WHT_CD, USAG_NM: rec.WHT_NM, USAGE_RATE: rec.TAX_RATE))
        })
        
        userListResponse = LIST_POP_UP_RESPONSE(USE_LIST: [], REC: recData, REC2: [])
    }
    
    func configUserListData() {
        
        var useListData = [LIST_POP_UP_RESPONSE.USE_LIST]()
        original_userListResponse?.USE_LIST?.forEach({ usrList in
            useListData.append(LIST_POP_UP_RESPONSE.USE_LIST(USE_USAG_CD: usrList.USE_USAG_CD ?? "", USAG_NM: usrList.USAG_NM ?? ""))
        })
        
        var recData = [LIST_POP_UP_RESPONSE.REC]()
        original_userListResponse?.REC?.forEach({ rec in
            recData.append(LIST_POP_UP_RESPONSE.REC(USE_USAG_CD:rec.USE_USAG_CD ?? "", USAG_NM: rec.USAG_NM ?? "", USAGE_RATE: ""))
        })
        
        var rec2Data = [LIST_POP_UP_RESPONSE.REC2]()
        original_userListResponse?.REC2?.forEach({ rec in
            rec2Data.append(LIST_POP_UP_RESPONSE.REC2(ADV_PAYM_SEQ: rec.ADV_PAYM_SEQ ?? "", ADV_PAYM_NM: rec.ADV_PAYM_NM ?? "", ADV_PAYM_RSPB_ID: rec.ADV_PAYM_RSPB_ID ?? "", USER_NM: rec.USER_NM ?? ""))
        })
        
        userListResponse = LIST_POP_UP_RESPONSE(USE_LIST: useListData, REC: recData, REC2: rec2Data)
    }
}

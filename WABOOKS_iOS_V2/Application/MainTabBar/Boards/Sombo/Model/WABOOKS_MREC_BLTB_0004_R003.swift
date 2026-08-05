//
//  WABOOKS_MREC_BLTB_0004_R003.swift
//  WABOOKS_iOS_V2
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

//MARK: - WABOOKS_MREC_BLTB_0004_R003
struct WABOOKS_MREC_BLTB_0004_R003     {
    
    struct REQUEST      : WABOOKS_MREC_BLTB_0004_R003_REQUEST {
        
        var SRCH_WD     : String?
        var EXPT_TYPE   : String?
        var FROM_DT     : String?
        var TO_DT       : String?
        var PAGE_NO     : Int?
        var PAGE_PER_CNT: Int?
        
    }
    
    struct RESPONES     : Codable {
        
        let NEXT_PAGE_YN : String?
        let TOT_CNT_RCPT : Int?  // Total receipts
        let TOT_CNT_EINV : Int?  // Total E-Invoices
        let TOT_CNT_BILL : Int?  // Total Bills
        let REC          : [WABOOKSStruct.RECDoc_Protocol]?
    }
    
}


//
//  NewReceiptModel.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 12/1/21.
//

import Foundation
 
struct SubmitReceiptModel {
    
    let RECEIPTROW :  [reeceipRow]
    
    struct reeceipRow {
  
        var content : [content]
        
        struct content {
            let code    : String
            var value   : String?
            var key     : String?
            var other    : String?
        }
    }
}



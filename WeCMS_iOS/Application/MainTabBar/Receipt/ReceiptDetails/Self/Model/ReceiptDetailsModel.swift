//
//  ReceiptDetailsModel.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 15/1/21.
//

import Foundation


struct ReceiptDetailsRow {
    
    let receipRow :  [receiptRow]
    
    struct receiptRow {
  
        var content : [contents]
        
        struct contents {
            let code    : String
            var value   : String?
        }
    }
}

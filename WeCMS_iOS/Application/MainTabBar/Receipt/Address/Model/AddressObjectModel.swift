//
//  AddressObjectModel.swift
//  WeCMS_iOS
//
//  Created by Bung on 6/2/21.
//

import Foundation

struct AddressObjectModel {
    
    let receiptRow :  [receiptRow]
    
    struct receiptRow {
  
        var content : [content]
        
        struct content {
            let code    : String
            var value   : String?
             
        }
    }
}

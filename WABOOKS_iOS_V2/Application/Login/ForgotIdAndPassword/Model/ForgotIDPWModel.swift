//
//  ForgotIDPWModel.swift
//  WABOOKS_iOS_V2
//
//  Created by Bung on 5/20/21.
//

import Foundation

struct ForgotIDPWModel {
    
    let ForgotIDPWROW :  [ForgotIDPWROW]
    
    struct ForgotIDPWROW {
  
        var CONTENT : [CONTENTS]
        
        struct CONTENTS {
            var CODE            : String?
            var KEY             : String?
            var VALUE           : String?
        }
    }
}

//
//  WABOOKS_MREC_BLTB_0004_U001.swift
//  WABOOKS_iOS_V2
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

struct WABOOKS_MREC_BLTB_0004_U001     {
    
    struct RESPONSE: Decodable {
        
    }
    
    struct REQUEST :  WABOOKS_MREC_BLTB_0004_U001_0004_U002_REQUEST {
        
        var BLTB_CD         : String?
        var POST_SEQ_NO     : String?
        var POST_TITLE      : String?
        var POST_CONT       : String?
        let POST_TYPE_CD    : String?
        let POST_STTS       : String?
        let PIN_POST_TYPE   : String?
        let PIN_POST_DUE_DT : String?
     
        let REC             : [REC]?
        let REC2            : [REC2]?
        
        struct REC          : WABOOKS_MREC_BLTB_0002_U001_0004_C001_REC {
            
            var FILE_ID     : String?
           
        }
        
        struct REC2         : WABOOKS_MREC_BLTB_0004_U001_0004_U002_REQUEST_REC2_REC3_0005_U001_0002_C001_0002_U001_REC {
            var COPY_FILE_YN: String?
            
            var ORG_FILE_NM: String?
            
            var SAVE_FILE_NM: String?
            
            var FILE_SIZE: String?
            
            
            var FILE_NM         : String?
            var FILE_DATA       : String?
        
        }
    }
}


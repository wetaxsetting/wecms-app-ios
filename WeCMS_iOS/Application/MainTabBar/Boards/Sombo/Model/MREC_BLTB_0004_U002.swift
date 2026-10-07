//
//  MREC_BLTB_0004_U002.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

struct MREC_BLTB_0004_U002    {
    
    struct REQUEST : MREC_BLTB_0004_U001_0004_U002_REQUEST {

        var BLTB_CD             : String?
        var POST_SEQ_NO         : String?
        var POST_TITLE          : String?
        var POST_CONT           : String?
        
        
        let REC1        : [REC1]?
        let REC2        : [REC2]?
        let REC3        : [REC3]?
        let REC4        : [REC4]?
        
        struct REC1 : MREC_BLTB_0004_U002_REC1 {
            
            var APPRVR_ID   : String?
            var APPRVR_NM   : String?
        
        }
        
        struct REC2 : MREC_BLTB_0004_U002_REC1 {
            var APPRVR_NM: String?
            var APPRVR_ID       : String?
        }
        
        struct REC3 : MREC_BLTB_0004_U001_0004_U002_REQUEST_REC2_REC3_0005_U001_0002_C001_0002_U001_REC {
            var ORG_FILE_NM: String?
            
            var SAVE_FILE_NM: String?
            
            var FILE_SIZE: String?
            
            var COPY_FILE_YN: String?
            
    
            var FILE_NM         : String?
            var FILE_DATA       : String?
        }
        
        struct REC4 : MREC_BLTB_0004_U002_REC {
            
            var FILE_TYPE       : String?
            var FILE_ID         : String?
        }
    }
    
    struct RESPONSE : Decodable {
        
    }
    
}


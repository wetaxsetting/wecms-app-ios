//
//  MREC_BLTB_0002_C001.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

// MARK: - MREC_BLTB_0002_C001
struct MREC_BLTB_0002_C001  { // CommentModel
    
    struct REQUEST : MREC_BLTB_0002_C001_REQUEST {
        
        var BLTB_CD             : String?
        var POST_SEQ_NO         : String?
        var COMNT_DV_CD         : String?
        var COMNT_TASK_CD       : String?
        var COMNT_CONT          : String?
        let REC                 : [REC]?
        
        struct REC         : MREC_BLTB_0004_U001_0004_U002_REQUEST_REC2_REC3_0005_U001_0002_C001_0002_U001_REC {
            var ORG_FILE_NM: String?
            
            var SAVE_FILE_NM: String?
            
            var FILE_SIZE: String?
            
            var COPY_FILE_YN: String?
            
            var FILE_NM         : String?
            var FILE_DATA       : String?
        }
    }
    
    struct RESPONSE : Decodable {
        
    }
    
}


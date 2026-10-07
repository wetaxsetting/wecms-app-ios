//
//  MREC_BLTB_0004_C001.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

// MARK: - MREC_BLTB_0004_C001
struct MREC_BLTB_0004_C001  {
    
    struct REQUEST : Encodable {
        
        let DRAFT_POST_SEQ_NO   : String?
        let POST_TITLE          : String?
        let POST_ANTH_BLTB_YN   : String?
        let POST_TYPE_CD        : String?
        let POST_CONT           : String?
        let POST_STTS           : String?
        let POST_DRAFT_YN       : String?
        let PIN_POST_TYPE       : String?
        let PIN_POST_DUE_DT     : String?
        let REF_BLTB_CD         : String?
        let REF_POST_SEQ_NO     : String?
    
        let REC3                : [REC3]?
        let REC2                : [REC2]?
        let REC                 : [REC]?
        
        struct  REC3            : MREC_BLTB_0002_U001_0004_C001_REC {
            var FILE_ID         : String?
        }
        
        struct REC              :MREC_BLTB_0004_U001_0004_U002_REQUEST_REC2_REC3_0005_U001_0002_C001_0002_U001_REC {
            var ORG_FILE_NM: String?
            
            var SAVE_FILE_NM: String?
            
            var FILE_SIZE: String?
            
            var COPY_FILE_YN: String?
            
            
            var FILE_NM         : String?
            var FILE_DATA       : String?
           
        }
        
        struct REC2 : MREC_BLTB_0001_U001_0003_D001_REQUEST{
            var BLTB_CD         : String?
        }
    }
    
    struct RESPONSE : Decodable {
        
    }
}


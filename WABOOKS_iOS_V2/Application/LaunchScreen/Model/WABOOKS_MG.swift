//
//  MGModel.swift
//  WABOOKS_iOS_V2
//
//  Created by Thea Chum on 14/1/21.
//

import Foundation

struct WABOOKS_MG {
    
    struct Request: Encodable {
        
    }
    
    struct Response: Decodable {
        let _tran_res_data : [tran_res_data]?
        
        struct tran_res_data: Decodable {
            let c_available_service : Bool?
            let c_update_date       : String?
            let _locale             : String?
            let c_update_act        : String?
            let c_act_close         : String?
            let c_appstore_url      : String?
            let c_session_time      : String?
            let c_bizplay_url       : String?
            let c_program_ver       : String?
            let c_minimum_ver       : String?
            let c_act               : String?
            let c_update_close      : String?
            let c_act_yn            : String?
            let _master_id          : String?
            let c_cloude_uri        : String?
            let c_cloude_key        : String?
            let c_forget_pw_url     : String?
            let c_forget_id_url     : String?
            let c_member_url        : String?
            let c_member_url2       : String?
            
            let c_approval_url          : String?
            let c_approval_channel_id   : String?
            let c_approval_portal_id    : String?
            
            let _app_info           :[app_info]?
            
            var c_qna_url           : URL
            
            let c_alarm             : String?
            struct app_info:Decodable {
                let c_name      : String?
                let c_reason    : String?
                let c_available : String?
                let c_app_id    : String?
                let c_app_url   : String?
            }
        }
    }
}

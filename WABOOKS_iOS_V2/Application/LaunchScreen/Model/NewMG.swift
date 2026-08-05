//
//  NewMG.swift
//  WABOOKS_iOS_V2
//
//  Created by Thea Chum on 13/7/21.
//

import Foundation
 
struct NewMG {
     
    struct Request : Encodable {
        
    }
    
    struct Response : Decodable {
        let c_act_msg                          : c_act_msg
        let c_act_update                       : String?
        let c_act_yn                           : String?
        let c_appstore_url                     : String?
        let c_available_service                : String?
        let c_available_service_msg            : c_act_msg
        let c_base_url_wecms                   : String?
        let c_base_url_wecms_uat               : String?
        let c_web_base_url_wecms               : String?
        let c_web_base_url_wecms_uat           : String?
        let c_master_id                        : String?
        let c_program_ver                      : String?
        let c_inform_ver                       : String?
        let c_update_act                       : String?
        let c_act_update_msg                   : c_act_msg
        var country_dial_codes_as_frist_order  : [country_dial_codes_as_frist_order]
        let country_dial_codes_url             : String?
        
        struct country_dial_codes_as_frist_order: Decodable {
            let name                : String?
            let dial_code           : String?
            let code                : String?
            
        }
        
    }
    
    struct c_act_msg                : Decodable {
        let kr                      : String?
        let en                      : String?
        let kh                      : String?
        let vi                      : String?
    }
}


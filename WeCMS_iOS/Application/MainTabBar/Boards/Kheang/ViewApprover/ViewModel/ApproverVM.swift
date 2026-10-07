//
//  ApproverVM.swift
//  WeCMS_iOS
//
//  Created by Kimlang on 31/1/24.
//

import Foundation


class ApproverVM {
    
    var cells       : [ApproverData] = []
    var data        : [WeCMSStruct.REC3_Protocol] = []
    var requestor   : String = ""
    
    func getData() {
        for data in data {
            cells.append(ApproverData(id:data.APPRVR_ID, title: data.APPRVR_NM, status: data.APPRVR_STTS, date: data.APPR_DTM, icon: data.APPRVR_STTS, profile: data.APPRVR_IMG_URL))
        }
    }
}


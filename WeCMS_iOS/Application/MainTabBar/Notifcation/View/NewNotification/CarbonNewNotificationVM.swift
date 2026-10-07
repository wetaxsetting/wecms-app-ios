//
//  CarbonNewNotificationVM.swift
//  Bizcard4.0
//
//  Created by kimlang on 9/11/23.
//  Copyright © 2023 KOSIGN. All rights reserved.
//

import Foundation

struct CarbonNewNotificationModel {
    let titleButton : String?
    var isSelected  : Bool?
}

class CarbonNewNotificationVM {
    var carbonData = [CarbonNewNotificationModel]()

    func getData() {
        carbonData = [CarbonNewNotificationModel(titleButton: "Unread".localized, isSelected: true),
                      CarbonNewNotificationModel(titleButton: "all".localized, isSelected: false)]
    }
    
}


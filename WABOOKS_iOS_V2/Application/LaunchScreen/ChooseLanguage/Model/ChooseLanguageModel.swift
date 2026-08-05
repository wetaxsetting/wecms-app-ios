//
//  ChooseLanguageModel.swift
//  WABOOKS_iOS_V2
//
//  Created by Bun on 3/1/23.
//

import Foundation

enum ChooseLanguageCellType {
    case ChooseLanguageTopCell
    case ChooseLanguageCell
}

struct ChooseLanguageModel {
    
    var strTitle    : String
    var strSubTitle : String
    var strImage    : String
    var isSelected  : Bool
    let rowType     : ChooseLanguageCellType
    
}

//
//  ChooseLanguageVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Bun on 3/1/23.
//

import Foundation

class ChooseLanguageVM {
    
    var chooseLanguageRec : [ChooseLanguageModel]?
    
    func initChooseLanguage() {
        
        let customTitle         = "Vietnamese"
        let customCode          = "vi"
        let customTopImage      = "ico_vn_flag"
        let customBottomImage   = "txt_ico_vn_lang_"

        let appLang             = MyDefaults.get(key: .appLang) as? String ?? "vi"
        
        self.chooseLanguageRec = [
            ChooseLanguageModel(strTitle    : "good_day_WeCMS_user.",
                                strSubTitle : "please_select_your_language",
                                strImage    : customTopImage,
                                isSelected  : false,
                                rowType     : .ChooseLanguageTopCell),
            
            ChooseLanguageModel(strTitle    : customTitle,
                                strSubTitle : customCode,
                                strImage    : customBottomImage,
                                isSelected  : appLang == "vi" ? true : false,
                                rowType     : .ChooseLanguageCell),
            
            ChooseLanguageModel(strTitle    : "English",
                                strSubTitle : "en",
                                strImage    : "txt_ico_eng_lang_",
                                isSelected  : appLang == "en" ? true : false,
                                rowType     : .ChooseLanguageCell),
        ]
    }
    
}

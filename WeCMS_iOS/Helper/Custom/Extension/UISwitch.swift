//
//  UISwitch.swift
//  WeCMS_iOS
//
//  Relocated from EditDraftVC.swift (removed with the WABOOKS-only screens).
//  Still used by EditDraftWeCMSVC and EditArticleWeCMSVC.
//

import UIKit

//MARK: - UISwitch Extension
@available(iOS 14.0, *)
extension UISwitch {

    func setOnValueChangeListener(onValueChanged :@escaping () -> Void){
        self.addAction(UIAction(){ action in

            onValueChanged()

        }, for: .valueChanged)
    }
}

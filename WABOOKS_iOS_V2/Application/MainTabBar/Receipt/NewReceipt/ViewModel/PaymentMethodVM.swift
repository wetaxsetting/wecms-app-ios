//
//  PaymentMethodVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Bun on 19/10/22.
//

import Foundation

class PaymentMethodVM {
    
    var paymentData = [PaymentMethodModel(title: "payment_method".localized,  subTitle: "please_select_payment_method".localized, strImage: "cancel", isSelected: false),
                       PaymentMethodModel(title: "none".localized,            subTitle: "".localized, strImage: "def_radio_on", isSelected: true),
                       PaymentMethodModel(title: "cash".localized,            subTitle: "".localized, strImage: "def_radio_off", isSelected: false),
                       PaymentMethodModel(title: "cheque".localized,          subTitle: "".localized, strImage: "def_radio_off", isSelected: false),
                       PaymentMethodModel(title: "transfer".localized,        subTitle: "".localized, strImage: "def_radio_off", isSelected: false),
                       PaymentMethodModel(title: "advance".localized,         subTitle: "".localized, strImage: "def_radio_off", isSelected: false)]
    
//    var paymentData     = [PaymentMethodModel(title: "payment_method".localized,  subTitle: "please_select_payment_method".localized, strImage: "cancel", isSelected: false)]
    
    var paymentImageRec = ["def_radio_on", "def_radio_off", "def_radio_off", "def_radio_off", "def_radio_off"]
    var paymentTitleRec = ["payment_method".localized, "none".localized, "cash".localized, "cheque".localized, "transfer".localized, "advance".localized]
    
    func setIsSelected(indexPath: Int) {
        for (index, _) in paymentData.enumerated() {
            self.paymentImageRec[index] = index == indexPath ? "def_radio_on" : "def_radio_off"
        }
    }
    
} 

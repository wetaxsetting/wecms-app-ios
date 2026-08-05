//
//  ForgotTableViewCell.swift
//  WABOOKS_iOS_V2
//
//  Created by SteveChea  on 15/1/25.
//

import UIKit

class ForgotTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    // Enter Name View
    @IBOutlet weak var enterIDNameView          : UIView!
    @IBOutlet weak var textfieldIDandName       : UITextField!
    
    // Enter Phone Number View
    @IBOutlet weak var lblCountryCode           : UILabel!
    @IBOutlet weak var enterPhoneView           : UIView!
    @IBOutlet weak var textfieldPhoneNumber     : VSTextField!
    @IBOutlet weak var btnDropDown              : UIButton!
    @IBOutlet weak var btnSendAuthCode          : UIButton!
    
    // Enter Auth Code View
    @IBOutlet weak var enterAuthCodeView        : UIView!
    @IBOutlet weak var textfieldAuthCode        : VSTextField!
    @IBOutlet weak var btnVerifyAuthCode        : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textfieldIDandName.delegate             = self
        textfieldPhoneNumber.delegate           = self
        textfieldAuthCode.delegate              = self
        btnSendAuthCode.isHidden                = true
        customizeTextField()
    }
    
    private func customizeTextField(){
        lblCountryCode.font = UIFont(name: "Inter-Medium", size: 15.0)
        btnDropDown.titleLabel?.font = UIFont(name: "Inter-Medium", size: 15.0)
        textfieldIDandName.font = UIFont(name: "Inter-Medium", size: 15.0)
        textfieldAuthCode.font = UIFont(name: "Inter-Medium", size: 15.0)
        textfieldPhoneNumber.font = UIFont(name: "Inter-Medium", size: 15.0)
    }
    
    func enableSMS(isEnable: Bool) {
        self.btnSendAuthCode.isEnabled          = isEnable
        self.btnSendAuthCode.isSelected         = isEnable
    }
    
    func enableOTP(isEnable: Bool) {
        self.btnVerifyAuthCode.isEnabled        = isEnable
        self.btnVerifyAuthCode.isSelected       = isEnable
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1000           : textField.keyboardType    = UIKeyboardType.default
        case 1001, 1002     : textField.keyboardType    = UIKeyboardType.decimalPad
        case 1003           : textField.keyboardType    = UIKeyboardType.emailAddress
        default: break
        }
        return true
    }
    
    func configCell(data: ForgotIDPWModel.ForgotIDPWROW.CONTENTS, vcType: VCType) {
        switch data.CODE {
        case "ID":
            textfieldIDandName.tag                          = 1003
            textfieldIDandName.autocapitalizationType       = .none
            enterIDNameView.isHidden                        = false
            enterPhoneView.isHidden                         = true
            enterAuthCodeView.isHidden                      = true
            textfieldIDandName.placeholder                  = "enter_id_email".localized
            textfieldIDandName.getlocalizedFont()
            textfieldIDandName.text                         = data.VALUE ?? ""
            lblCountryCode.isUserInteractionEnabled         = false
        case "NAME":
            textfieldIDandName.tag                          = 1000
            enterIDNameView.isHidden                        = false
            enterPhoneView.isHidden                         = true
            enterAuthCodeView.isHidden                      = true
            textfieldIDandName.placeholder                  = "enter_id".localized
            textfieldIDandName.getlocalizedFont()
            textfieldIDandName.text                         = data.VALUE
            lblCountryCode.isUserInteractionEnabled         = false
        case "PHONE":
            textfieldPhoneNumber.tag                        = 1001
            enterIDNameView.isHidden                        = true
            enterPhoneView.isHidden                         = false
            enterAuthCodeView.isHidden                      = true
            textfieldPhoneNumber.placeholder                = "enter_phone_number".localized
            textfieldPhoneNumber.getlocalizedFont()
            lblCountryCode.text                             = data.KEY
            textfieldPhoneNumber.text                       = data.VALUE
             
        case "AUTH":
            enterIDNameView.isHidden                        = true
            enterPhoneView.isHidden                         = true
            enterAuthCodeView.isHidden                      = false
            textfieldAuthCode.placeholder                   = "enter_auth_code".localized
            textfieldAuthCode.getlocalizedFont()
            lblCountryCode.isUserInteractionEnabled         = false
        default: break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let tempText = textField.text, let textRange = Range(range, in: tempText) {
            let updatedText = tempText.replacingCharacters(in: textRange, with: string)
            
            if textField.tag == 1001 {
                // Limit textfield Phone Number
                return updatedText.count <= 11
            }
        }
        
        return true
    }
}

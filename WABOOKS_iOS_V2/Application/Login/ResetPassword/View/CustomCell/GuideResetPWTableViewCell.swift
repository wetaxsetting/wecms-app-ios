//
//  GuideResetPWTableViewCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Bun on 28/9/22.
//

import UIKit

class GuideResetPWTableViewCell: UITableViewCell {

    // Guide Reset Password
    @IBOutlet weak var lblPwMustBe                  : UILabel!
    @IBOutlet weak var lblPwLongerThan              : UILabel!
    @IBOutlet weak var lblIncludeAllChar            : UILabel!
    @IBOutlet weak var lblExcludeSpecialChar        : UILabel!
    
    // New Password
    @IBOutlet weak var viewNewPassword              : UIView!
    @IBOutlet weak var btnShowHidePassword          : UIButton!
    @IBOutlet weak var tfNewPassword                : UITextField!
     
    // Confirm Password
    @IBOutlet weak var viewConfirmPassword          : UIView!
    @IBOutlet weak var btnShowHideConfirmPassword   : UIButton!
    @IBOutlet weak var tfConfirmPassword            : UITextField!
    
    var owner               : UIViewController?
    var strNewPassword      : String = ""
    var strConfirmPassword  : String = ""
    var resetCompletion     : (String, String, Bool) -> Void = {_ , _, _ in}
      
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
 
        self.delegateTextField()
        self.getLocalizedFont()
        self.customizeComponent()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func delegateTextField() {
        self.tfNewPassword.tag           = 1000
        self.tfNewPassword.delegate      = self
        self.tfNewPassword.becomeFirstResponder()
        
        self.tfConfirmPassword.tag       = 1001
        self.tfConfirmPassword.delegate  = self
    }
    
    private func customizeComponent(){
        self.tfNewPassword.font = UIFont(name: "Inter-Medium", size: 15)
        self.tfConfirmPassword.font = UIFont(name: "Inter-Medium", size: 15)

        self.btnShowHideConfirmPassword.tintColor = UIColor(hexString: "#494949")
        self.btnShowHidePassword.tintColor = UIColor(hexString: "#494949")
    }
       
    private func getLocalizedFont(){
        self.btnShowHideConfirmPassword.tintColor = UIColor(hexString: "#494949")
        self.tfNewPassword.placeholder       = "enter_new_password".localized
        self.tfConfirmPassword.placeholder   = "enter_confirm_password".localized
    
        self.lblPwMustBe.text                = "password_must_be".localized
        self.lblPwLongerThan.text            = "at_lease_10_characters".localized
        self.lblIncludeAllChar.text          = "include_alphabets_numbers_and_special_characters".localized
        self.lblExcludeSpecialChar.text      = "exclude_some_special_characters".localized
        
        self.lblPwMustBe.getlocalizedFont()
        self.tfNewPassword.getlocalizedFont()
        self.tfConfirmPassword.getlocalizedFont()
        
        self.lblPwLongerThan.getlocalizedFont()
        self.lblIncludeAllChar.getlocalizedFont()
        self.lblExcludeSpecialChar.getlocalizedFont()
    }
     
    // Button New Password
    @IBAction func didTapShowHideNewPassword(_ sender: UIButton) {
        // Update button status each time user's click on btnShowHidePassword
        sender.isSelected = !sender.isSelected
        
        // Update isSecureTextEntry status for textfield each time user's click on btnShowHidePassword
        self.tfNewPassword.isSecureTextEntry.toggle()
        self.btnShowHidePassword.tintColor = UIColor(hexString: self.tfNewPassword.isSecureTextEntry == true ? "#494949" : "#0069B9")
    }
    
    // Button Confirm password
    @IBAction func didTapShowHideConfirmPassword(_ sender: UIButton) {
        // Update button status each time user's click on btnShowHidePassword
        sender.isSelected = !sender.isSelected
        
        // Update isSecureTextEntry status for textfield each time user's click on btnShowHidePassword
        self.tfConfirmPassword.isSecureTextEntry.toggle()
        self.btnShowHideConfirmPassword.tintColor = UIColor(hexString: self.tfConfirmPassword.isSecureTextEntry == true ? "#494949" : "#0069B9")
    }
    
}

//MARK: - UITextFieldDelegate
extension GuideResetPWTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let tempText = textField.text, let textRange = Range(range, in: tempText) {
            let updatedText = tempText.replacingCharacters(in: textRange, with: string)
            
            if textField.tag == 1000 {
                self.strNewPassword = updatedText
                
            } else {
                self.strConfirmPassword = updatedText
            }
             
            let isEnable = self.strNewPassword.count == self.strConfirmPassword.count ? true : false
            
            // Completion back to VC
            self.resetCompletion(strNewPassword, strConfirmPassword, isEnable)
             
        }
        
        return true
    }
}

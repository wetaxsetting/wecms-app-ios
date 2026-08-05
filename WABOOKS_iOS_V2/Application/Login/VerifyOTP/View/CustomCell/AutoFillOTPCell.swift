//
//  AutoFillOTPCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Bun on 13/9/22.
//

import UIKit

class AutoFillOTPCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var lbGuideTitle         : UILabel!
    @IBOutlet weak var lbGuideDescription   : UILabel!
      
    @IBOutlet weak var lbDuration           : UILabel!
    @IBOutlet weak var lbResendCodeTitle    : UILabel!
    @IBOutlet weak var btnResendCode        : UIButton!
    
    @IBOutlet weak var textfield1           : CustomTextFieldBackward!
    @IBOutlet weak var textfield2           : CustomTextFieldBackward!
    @IBOutlet weak var textfield3           : CustomTextFieldBackward!
    @IBOutlet weak var textfield4           : CustomTextFieldBackward!
    @IBOutlet weak var textfield5           : CustomTextFieldBackward!
    @IBOutlet weak var textfield6           : CustomTextFieldBackward!
     
    var count               = 180
    var minutes             = 0
    var seconds             = 0
    let totalTextField      = 6
    var vcType              : VCType?
    
    var isColor             : UIColor!
    var timer               : Timer?
    var username            : String    = ""
    var phoneNumber         : String    = ""
    var duration            : String    = ""
    var isEnable            : Bool      = false
    var CRTC_YN             : Bool      = true
    
    var isCompletion        : (String, Bool?) -> Void = { _, _ in}
      
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Shared.crtcNumber.removeAll()
        
        // Initialization code
        self.setup()
        
        // Count Down duration for resend OTP
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerDidFire(timer:)), userInfo: nil, repeats: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func setup() {
        
        self.lbGuideTitle.text          = "enter_auth_code".localized
        self.lbGuideDescription.text    = "we've_just_sent_the_code_to_your_phone_number".localized
        self.lbResendCodeTitle.text     = "i_didn't_received_a_code".localized
        self.btnResendCode.setTitle("resend_code".localized, for: .normal)
        
        self.lbGuideTitle.getlocalizedFont()
        self.lbGuideDescription.getlocalizedFont()
        self.lbResendCodeTitle.getlocalizedFont()
        self.btnResendCode.getlocalizedFont()
         
        self.textfield1.tag         = 1000
        self.textfield1.delegate    = self
        self.textfield1.isUserInteractionEnabled = true
        
        self.textfield2.tag         = 2000
        self.textfield2.delegate    = self
        self.textfield2.isUserInteractionEnabled = false
        
        self.textfield3.tag         = 3000
        self.textfield3.delegate    = self
        self.textfield3.isUserInteractionEnabled = false
        
        self.textfield4.tag         = 4000
        self.textfield4.delegate    = self
        self.textfield4.isUserInteractionEnabled = false
        
        self.textfield5.tag         = 5000
        self.textfield5.delegate    = self
        self.textfield5.isUserInteractionEnabled = false
        
        self.textfield6.tag         = 6000
        self.textfield6.delegate    = self
        self.textfield6.isUserInteractionEnabled = false
        self.textfield1.borderColor  = UIColor(hexString: "#0069B9")
    }
    
    func configCell(optValue: [String], username: String, phoneNumber: String) {
        textfield1.becomeFirstResponder()
        
        self.username           = username
        self.phoneNumber        = phoneNumber
        
        self.minutes            = Int(self.count) / 60 % 60
        self.seconds            = Int(self.count) % 60
        
        // isEnable true when duration == 0:00
        self.textfield1.borderColor = isEnable ? isColor : UIColor(hexString: "#0069B9")
        self.textfield2.borderColor = isEnable ? isColor : UIColor(hexString: "#ECEFF1")
        self.textfield3.borderColor = isEnable ? isColor : UIColor(hexString: "#ECEFF1")
        self.textfield4.borderColor = isEnable ? isColor : UIColor(hexString: "#ECEFF1")
        self.textfield5.borderColor = isEnable ? isColor : UIColor(hexString: "#ECEFF1")
        self.textfield6.borderColor = isEnable ? isColor : UIColor(hexString: "#ECEFF1")
        
        self.lbDuration.text        = String(format:"%01i:%02i", self.minutes, self.seconds)
    }
      
    private func requestSendPhoneNumber(USER_NM: String, CLPH_NO: String) {
        ForgotVM().requestSendPhoneNumber(vcType: self.vcType ?? .ForgetID, USER_NM: USER_NM, CLPH_NO: CLPH_NO) { (result) in
            switch result {
            case .success(_):
                self.isEnable        = false
                self.count           = 180 + 1 // extra 1 to make duration 3:00 after format
                
                // Clear all textfields
                self.textfield1.text = ""
                self.textfield2.text = ""
                self.textfield3.text = ""
                self.textfield4.text = ""
                self.textfield5.text = ""
                self.textfield6.text = ""
                
                // Set all textfield to default color
                self.textfield1.borderColor = UIColor(hexString: "#0069B9")
                self.textfield2.borderColor = UIColor(hexString: "#ECEFF1")
                self.textfield3.borderColor = UIColor(hexString: "#ECEFF1")
                self.textfield4.borderColor = UIColor(hexString: "#ECEFF1")
                self.textfield5.borderColor = UIColor(hexString: "#ECEFF1")
                self.textfield6.borderColor = UIColor(hexString: "#ECEFF1")
                 
                self.textfield1.isUserInteractionEnabled = true
                self.textfield2.isUserInteractionEnabled = false
                self.textfield3.isUserInteractionEnabled = false
                self.textfield4.isUserInteractionEnabled = false
                self.textfield5.isUserInteractionEnabled = false
                self.textfield6.isUserInteractionEnabled = false
                  
                self.textfield1.becomeFirstResponder()
                
                // Clear OTP when user's click button Resend Code
                Shared.crtcNumber.removeAll()
                
                // Completion for confirm button
                self.isCompletion(Shared.crtcNumber.joined(), false)
                 
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func didTapResendCode(_ sender: UIButton) {
        self.requestSendPhoneNumber(USER_NM: self.username, CLPH_NO: self.phoneNumber)
    }
    
    // Count Down duration for OTP
    @objc private func timerDidFire(timer: Timer) {
         
        self.count      = self.count > 0 ? self.count - 1 : 0
        let minutes     = Int(self.count) / 60 % 60
        let seconds     = Int(self.count) % 60
        self.duration   = String(format:"%01i:%02i", minutes, seconds)
        
        self.isEnable   = self.duration == "0:00" ? true : false
        self.isColor    = self.duration == "0:00" ? UIColor(hexString: "#CB0D0D") : UIColor(hexString: "#0069B9")
        
        self.lbDuration.text        = self.duration
        self.lbDuration.textColor   = self.isColor
        Shared.strDuration          = self.duration
         
        self.btnResendCode.isEnabled = self.isEnable
        self.btnResendCode.setTitleColor(UIColor(hexString: self.isEnable ? "#0069B9" : "#A6A6A6"), for: .normal)
        
        self.textfield1.borderColor  = self.CRTC_YN ? self.isColor : UIColor(hexString: "#CB0D0D")
       
        // If btnResendCode isEnable =>> Set all textfield borderColor to Red ("CB0D0D") except textfield1
        if self.isEnable {
            self.textfield2.borderColor = UIColor(hexString: "#CB0D0D")
            self.textfield3.borderColor = UIColor(hexString: "#CB0D0D")
            self.textfield4.borderColor = UIColor(hexString: "#CB0D0D")
            self.textfield5.borderColor = UIColor(hexString: "#CB0D0D")
            self.textfield6.borderColor = UIColor(hexString: "#CB0D0D")
            
            // Show I didn't receipt a code! and Resend Code while OTP not fill success
            self.lbResendCodeTitle.isHidden = false
            self.btnResendCode.isHidden     = false
        }
    }
  
}

//MARK: - UITextViewDelegate
extension AutoFillOTPCell: UITextViewDelegate {
     
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let point = CGPoint(x: textField.center.x + 1, y: textField.center.y)
//        textField.beginFloatingCursor(at: point)
        textField.updateFloatingCursor(at: point)
        textField.endFloatingCursor()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         
        // To decide which textfield's gonna becomeFirstResponder()
        let nextTextField        = textField.superview?.viewWithTag((textField.tag/1000 + 1)*1000) as? UITextField
        let currentTextField     = textField.superview?.viewWithTag(textField.tag) as? UITextField
        let previouseTextField   = textField.superview?.viewWithTag((textField.tag/1000 - 1)*1000) as? UITextField
 
        if string.trimmingCharacters(in: CharacterSet.whitespaces).count != 0 {
            // Check which textfield's gonna replace with string
            if textField.text != "" {
                nextTextField?.text = string
            }
            else {
                textField.text = string
            }
             
            if textField.tag < totalTextField*1000 {
                // Set border color and enable next textfield
                nextTextField?.borderColor                  = lbDuration.text == "0:00" ? isColor : UIColor(hexString: "#0069B9")
                nextTextField?.isUserInteractionEnabled     = true
                nextTextField?.becomeFirstResponder()
                currentTextField?.isUserInteractionEnabled  = false
            }
            
            if textField.tag == totalTextField*1000 {  // OTP already filled (Auto fill)
                textField.resignFirstResponder()
            }
            
            // To check OTP already filled (crtcNumber.count == 6 OTP is already filled)
            if Shared.crtcNumber.count < 6 {
                Shared.crtcNumber.append(string)
            }
            
            if Shared.crtcNumber.count == 6 { // OTP already filled (User fill)
                
                // Hide I didn't receipt a code! and Resend Code while OTP already fill success
                // Condition (self.duration == "0:00") to prevent reload I didn't receipt a code! and Resend Code
                self.lbResendCodeTitle.isHidden = self.duration == "0:00" ? false : true
                self.btnResendCode.isHidden     = self.duration == "0:00" ? false : true
                
                nextTextField?.resignFirstResponder()
            }
            
            // Completion for confirm button
            self.isCompletion(Shared.crtcNumber.joined(), Shared.crtcNumber.count == 6 ? true : false)
        }
        else if string.count == 0 { // is backspace
            // Show I didn't receipt a code! and Resend Code while OTP not fill success
            self.lbResendCodeTitle.isHidden = false
            self.btnResendCode.isHidden     = false
            
            if textField.text != "" {
                Shared.crtcNumber.removeLast()
            }
            self.CRTC_YN            = true
            textField.text          = ""
            textField.borderColor   = textField.tag == 1000 ? isColor : (lbDuration.text == "0:00" ? isColor : UIColor(hexString: "#ECEFF1"))
               
            // Set border color when backspace
            self.textfield1.borderColor = self.duration == "0:00" ? UIColor(hexString: "#CB0D0D") : UIColor(hexString: "#0069B9")
            self.textfield2.borderColor = self.duration == "0:00" ? UIColor(hexString: "#CB0D0D") : (self.textfield2.text == "" ? UIColor(hexString: "#ECEFF1") : UIColor(hexString: "#0069B9"))
            self.textfield3.borderColor = self.duration == "0:00" ? UIColor(hexString: "#CB0D0D") : (self.textfield3.text == "" ? UIColor(hexString: "#ECEFF1") : UIColor(hexString: "#0069B9"))
            self.textfield4.borderColor = self.duration == "0:00" ? UIColor(hexString: "#CB0D0D") : (self.textfield4.text == "" ? UIColor(hexString: "#ECEFF1") : UIColor(hexString: "#0069B9"))
            self.textfield5.borderColor = self.duration == "0:00" ? UIColor(hexString: "#CB0D0D") : (self.textfield5.text == "" ? UIColor(hexString: "#ECEFF1") : UIColor(hexString: "#0069B9"))
            self.textfield6.borderColor = self.duration == "0:00" ? UIColor(hexString: "#CB0D0D") : (self.textfield6.text == "" ? UIColor(hexString: "#ECEFF1") : UIColor(hexString: "#0069B9"))
            
            previouseTextField?.isUserInteractionEnabled    = true
            previouseTextField?.becomeFirstResponder()
            currentTextField?.isUserInteractionEnabled      = textField.tag == 1000 ? true : false
            
            // Completion for confirm button
            self.isCompletion(Shared.crtcNumber.joined(), false)
        }
           
        return false
    }
}


class CustomTextFieldBackward: UITextField {

    override func deleteBackward() {
        super.deleteBackward()
           
        if self.text == "" {
            if 1000...6000 ~= self.tag { //tag 1000 to 6000 is textfields for Auto Fill OTP
                if self.tag - 1 >= 1000 {
                    
                    self.text = ""
                    
                    // To decide which textfield's gonna becomeFirstResponder()
                    let currentView     = superview?.viewWithTag(self.tag) as? UITextField
                    let previouseView   = superview?.viewWithTag(self.tag - 1000) as? UITextField
                   
                    currentView?.borderColor = Shared.strDuration == "0:00" ? UIColor(hexString: "#CB0D0D") : UIColor(hexString: "#ECEFF1")
                    previouseView?.isUserInteractionEnabled     = true
                    previouseView?.becomeFirstResponder()
                    previouseView?.text = ""
                    Shared.crtcNumber.removeLast()
                    currentView?.isUserInteractionEnabled       = false
                }
            }
        }
    }
}

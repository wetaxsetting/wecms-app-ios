//
//  PwResetVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Nyta on 17/5/21.
//

import UIKit

class PwResetVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView    : UITableView!
    @IBOutlet weak var lblResetPW   : UILabel!
    @IBOutlet weak var btnConfirm   : UIButton!
 
    //variable to check validation
    var email       : String?
    
    //variable to get data from ForgotVC
    var USER_ID     : String?
    var USER_NM     : String?
    var CLPH_NO     : String?
    var REG_SEQ_NO  : Int?
    var VERI_KEY    : String?
    
    var strNewPassword      : String = ""
    var strConfirmPassword  : String = ""
     
    var greyColor  : UIColor    = UIColor(hexString: "494949")
    var blueColor  : UIColor    = UIColor(hexString: "0069B9")
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        lblResetPW.font = UIFont(name: "Inter-Bold", size: 21)
        localizeText()
        localizeFont()
        setUpNav()
        enableBtnConfirm(isEnable: false)
    }
    
    private func localizeText(){
        email = USER_ID ?? ""
        lblResetPW.text = "reset_password".localized
        btnConfirm.setTitle("comfirm".localized, for: .normal)
    }
    
    private func localizeFont(){
        lblResetPW.getlocalizedFont()
        btnConfirm.getlocalizedFont()
    }
    
    private func setUpNav() {
        // Custom Back Button Item
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "arrow_back"), for: .normal)
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.contentHorizontalAlignment = .left
        let barButton = UIBarButtonItem(customView: button)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.leftBarButtonItems = [barButton]
    }
 
    private func goToLogin() {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
      
    private func enableBtnConfirm(isEnable: Bool) {
        btnConfirm.setTitleColor(isEnable ? UIColor(hexString: "FFFFFF") : UIColor(hexString: "9FADB9"), for: .normal)
        btnConfirm.isUserInteractionEnabled = isEnable
        btnConfirm.backgroundColor = UIColor(hexString: isEnable ? "0069B9" : "FAFAFA")
    }
    
    @objc func dismissAction() {
        popOrDismissVC()
    }

    //MARK: - Custom Alert
    private func passwordNotMatchAlert() {      
        customAlert(type        : .CONFIRM_ALERT,
                    image       : "badge_failed",
                    title       : "mismatched_password".localized,
                    message     : "password_does_not_match_please_check_and_try_again".localized,
                    redTitle    : "",
                    greyTitle   : "try_again".localized,
                    completion  : { (isRedPressed) in
        })
    }
      
    private func successAlert() {
        customAlert(type        : .CONFIRM_ALERT,
                    image       : "badge_success",
                    title       : "password_changed".localized,
                    message     : "you_can_now_log_in_with_the_new_password".localized,
                    redTitle    : "",
                    greyTitle   : "log_in".localized,
                    completion  : { (isRedPressed) in
            
            //Do action when user clicks on button in Popup
            self.goToLogin()
        })
    }
      
    private func passwordDoesNotMatch() {
        self.customToastwithColor(image: "badge_failed_white", message: "password_does_not_match".localized, backgroundColor: UIColor(hexString: "CB0D0D"))
    }
    
    private func passwordIsNotvalid() {
        self.customToastwithColor(image: "badge_failed_white", message: "password_is_not_valid".localized, backgroundColor: UIColor(hexString: "CB0D0D"))
    }
    
    private func passwordIsTooShort() {
        self.customToastwithColor(image: "badge_failed_white", message: "password_is_too_short".localized, backgroundColor: UIColor(hexString: "CB0D0D"))
    }
    
    private func textfieldValidation() {
        let includePassword = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!*?])[A-Za-z\\d$@$!*?]{10,}$")
        let excludePassword = NSPredicate(format:"SELF MATCHES %@", ".*[+%#&’”\\<>]+.*")
        
        if strNewPassword != strConfirmPassword {
            self.passwordDoesNotMatch()
        }
        else if (excludePassword.evaluate(with: strNewPassword) == true || includePassword.evaluate(with: strNewPassword) == false) && (strNewPassword.count > 9 && strConfirmPassword.count > 9) {
            self.passwordIsNotvalid()
        }
        else if strNewPassword.count < 10 {
            self.passwordIsTooShort()
        }
        else {
            self.enableBtnConfirm(isEnable: true)
            self.resetPassword()
        }
    }
      
    private func resetPassword(){
        //Request Data from API mbmr_0003_002_u001
        ResetPasswordVM().resetPW_WABOOKS_MREC_MBMR_0003_U001(body: WABOOKS_MREC_MBMR_0003_U001.REQUEST(REG_SEQ_NO: self.REG_SEQ_NO ?? 0,
                                                                                                        USER_ID   : USER_ID ?? "",
                                                                                                        USER_PW   : self.strNewPassword,
                                                                                                        USER_PW2  : self.strConfirmPassword)) { result in

            switch result {
            case .success(_):
 
                //Show Popup
                self.successAlert()

            case .failure(let err):
                //Show Error Message in Alert Popup
                self.customAlert(type: .CONFIRM_ALERT,
                                 image: "add_circle",
                                 title: "notice".localized,
                                 message: err.localizedDescription, redTitle: "",
                                 greyTitle: "close".localized) { (isRedPress) in }
            }
        }
    }
    
    @IBAction func actionConfirm(_ sender: UIButton) {
        self.textfieldValidation()
    }
}

extension PwResetVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GuideResetPWTableViewCell", for: indexPath) as! GuideResetPWTableViewCell
        cell.owner = self
        
        cell.resetCompletion = { strNewPassword, strConfirmPassword, isEnable in
            self.strNewPassword     = strNewPassword
            self.strConfirmPassword = strConfirmPassword
            self.enableBtnConfirm(isEnable: isEnable)
        }
        
        return cell
    }
     
}

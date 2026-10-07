//
//  LoginVC.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 5/1/21.
//

import UIKit

import IQKeyboardManagerSwift
import IQKeyboardToolbar
import IQKeyboardToolbarManager

protocol checkForgetType {
    func checkForgetType(forgetType: String)
}

class LoginVC: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: - IBOutlet
    @IBOutlet weak var tfId                 : UITextField!
    @IBOutlet weak var tfPassword           : UITextField!
    @IBOutlet weak var btnLogin             : UIButton!
    @IBOutlet weak var btnForgetID          : UIButton!
    @IBOutlet weak var btnForgetPassword    : UIButton!
    @IBOutlet weak var btnShowPassword      : UIButton!
    @IBOutlet weak var btnProductVersion    : UIButton!
    @IBOutlet weak var logoImage            : UIImageView!
    
    
    var businessEstRec  : [MREC_R001.RESPONSE.REC]?
    var delegate        : checkForgetType?
    
    var companyVM       = CompanyVM()
    var loginR001     : MREC_R001.RESPONSE?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.setupView()
        self.setupLocalized()
        self.setUpTextFieldDelegate()
        
        // set to 0 when not logged in
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        interactivePopGestureRecognizer(isEnable: false)
        
        //Check height biiger than screen 6, 6s, 7, 8, 5, 5s, 5c, SE
        if UIScreen.main.bounds.height > 700 {
            if Shared.user_id == "" {
                tfId.becomeFirstResponder()
            } else {
                tfPassword.becomeFirstResponder()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initUserID()
        setNavigationBarStyle(isHidden: true, animated: animated, title: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        interactivePopGestureRecognizer(isEnable: true)
        IQKeyboardToolbarManager.shared.toolbarConfiguration.doneBarButtonConfiguration = IQBarButtonItemConfiguration(title: "done".localized) //Localized for done button keyboard
    }
    
    private func setUpUI() {
        self.logoImage.image        = UIImage(named: "logo_WeCMS")
        self.tfId.font              = UIFont(name: "Inter-Medium", size: 15)
        self.tfPassword.font        = UIFont(name: "Inter-Medium", size: 15)
        self.btnLogin.titleLabel?.font    = UIFont(name: "Inter-Bold", size: 15)
    }
    
    //Enable Swiping
    private func interactivePopGestureRecognizer(isEnable: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnable
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func setupLocalized() {
        tfId?.placeholder        = "enter_id".localized
        tfPassword?.placeholder  = "enter_password".localized
        
        btnLogin?.setTitle("log_in".localized, for: .normal)
        btnForgetID?.setTitle("forget_id".localized, for: .normal)
        btnForgetPassword?.setTitle("forget_password".localized, for: .normal)
    }
    
    private func setupView() {
        initUserID()
        
        // Product switching removed: this build is WeCMS only.
        self.btnProductVersion?.isHidden = true

        tfId?.getlocalizedFont()
        tfPassword?.getlocalizedFont()
        btnLogin?.getlocalizedFont()
        btnForgetID?.getlocalizedFont()
        btnForgetPassword?.getlocalizedFont()
        
        //fix LoginBtn UX on Device which turn on AutoFill Password
        tfId?.autocorrectionType         = .no
        tfPassword?.autocorrectionType   = .no
        
        if #available(iOS 12.0, *) {
            tfId?.textContentType        = .oneTimeCode
            tfPassword?.textContentType  = .oneTimeCode
        } else {
            // Fallback on earlier versions
        }
        
        self.enableBtnLogin()
    }
     
    private func enableBtnLogin() {
        btnLogin?.setTitleColor(isValid() ? UIColor(hexString: "FFFFFF") : UIColor(hexString: "A6A6A6"), for: .normal)
        if isValid() {
            btnLogin?.backgroundColor    = UIColor(hexString: "0069B9")
        } else {
            btnLogin?.backgroundColor    = UIColor(hexString: "FAFAFA")
        }
    }
    
    private func initUserID() {
        self.tfId?.text = Shared.user_id
    }
    
    private
    func isValidTfID() -> Bool {
        return tfId.text?.isNotEmpty ?? false
    }
    
    private
    func isValidTfPassword() -> Bool {
        return tfPassword.text?.isNotEmpty ?? false
    }
    
    private
    func isValid() -> Bool {
        let tfIDStr         = tfId?.text ?? ""
        let tfPasswordStr   = tfPassword?.text ?? ""
        let isValid = tfIDStr.isNotEmpty && tfPasswordStr.isNotEmpty
        return isValid
    }
    
    private func setUpTextFieldDelegate() {
        tfId?.delegate       = self
//        tfPassword.delegate = self
    }
    
    // MARK: - IBActions -
    @IBAction func didTapBtnShowPassword(_ sender: UIButton) {
        btnShowPassword.isSelected.toggle()
        tfPassword.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func didTapBtnLogin(_ sender: UIButton) {
        self.view.endEditing(true) //dismiss keyboard
        if isValid() {
            let USER_ID = tfId.text ?? ""
            let PWD     = tfPassword.text ?? ""
            self.checkBusinessEst(USER_ID: USER_ID, PWD: PWD) //R001
        }
    }
    
    @IBAction func didTapBtnForgetID(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = self.VC(sbName: "ForgotSB", identifier: "ForgotVC") as! ForgotVC
        vc.vcType = .ForgetID
        self.pushVC(viewController: vc)
    }
    
    @IBAction func didTapBtnForgetPWD(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = self.VC(sbName: "ForgotSB", identifier: "ForgotVC") as! ForgotVC
        vc.vcType = .Forget_Password
        self.pushVC(viewController: vc)
    }
    
    ///TextField
    @IBAction func didEditingChangedTFID(_ sender: UITextField) {
        self.enableBtnLogin()
    }
    

    @IBAction func didEditingChangedTfPassword(_ sender: UITextField) {
        //Display System Font when the text is SecureText Entry
        if tfPassword.isSecureTextEntry{
            tfPassword?.font = UIFont.systemFont(ofSize: 14.0)
        }
        self.enableBtnLogin()
    }

    @IBAction func didTapNextTfEnterID(_ sender: UITextField) {
        tfPassword?.becomeFirstResponder()
    }
    
    @IBAction func didTapDoneTfPassword(_ sender: UITextField) {
        self.view.endEditing(true)
    }
    
}

//Alert Message
extension LoginVC {
    func showAlertSuccuss(title: String, message: String, completion: @escaping Completion) {
        self.customAlert(type      : .CONFIRM_ALERT,
                         image     : "popup_failed_badge",
                         title     : title,
                         message   : message,
                         redTitle  : "",
                         greyTitle : "comfirm".localized) { (_) in
            completion()
        }
    }
    
    func showAlertSelectCompany(title: String, message: String, data: [String], subDataRec: [String], completion: @escaping Completion_Int) {
        self.customOption(type    : .Detail,
                          image   : "popup_failed_badge".localized,
                          title   : title,
                          message : message,
                          data    : data,
                          subDataRec : subDataRec) { selectRowAt in
            completion(selectRowAt)
        }
    }
}

// MARK: - API -
extension LoginVC {
    
    func openWebView(withURL: String) {
        let findIdWebView        = WebKitViewController(withURL: withURL)
        findIdWebView.webKitType = .General
        self.navigationController?.pushViewController(findIdWebView, animated: true)
    }
    
    func checkBusinessEst(USER_ID: String, PWD: String){
        LoginVM().requestR001(USER_ID: USER_ID, PWD: PWD) { (result) in
            switch result {
            case .success(let data):
                if data?.PW_ERR_CNT == nil || data?.PW_ERR_CNT == 0 {
                    KeychainManager.setCredential(USER_ID, forKey: "username")
                    KeychainManager.setCredential(PWD, forKey: "password")
                    
                    self.businessEstRec = data?.REC
                    self.loginR001    = data
                    
                    if !(data?.REC?.isEmpty ?? false) && (data?.REC?.count ?? 0) > 1 {
                        
                        var titles  : [String] = [] //title

                        self.businessEstRec?.forEach({ (REC) in
                            titles.append(REC.CMPN_NM)
                        })
                        self.customOptionCompany(type: .Detail, data: titles, loginR001: self.loginR001)

                    }else {
                        self.requestLoginAPI(bizKey: self.loginR001?.REC?.first?.BIZ_KEY ?? "", USER_ID: USER_ID, PWD: PWD)
                    }
                }else{
                    self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: "passwords_do_not_match".localized + " (\(data?.PW_ERR_CNT ?? 1)/5 " + "attempts".localized + ")" , redTitle: "", greyTitle: "ok".localized.uppercased()) { (isRedPress) in }
                }

            case .failure(let error):
                self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: error.localizedDescription, redTitle: "", greyTitle: "ok".localized.uppercased()) { (isRedPress) in }
            }
        }
    }
}

// alert popup
extension LoginVC {

    func showLoginSuccessPopup (id: String, completion: @escaping Completion) {
        self.showAlertSuccuss(title: "confirmation".localized, message: "\("new_password_has_been_reset_successfully".localized) “\(id)”") {
            completion()
        }
    }
    
    func showChooseCompanyPopup (completion: @escaping Completion_Int) {
        var data    : [String] = [] //title
        var subData : [String] = [] //subtitle
        
        self.businessEstRec?.forEach({ (REC) in
            data.append(REC.CMPN_NM)
            subData.append(REC.BIZ_KEY)
        })
        
        self.showAlertSelectCompany(title   : "select_a_company".localized,
                                    message : "please_select_a_company".localized,
                                    data    : data,
                                    subDataRec: subData) { (selectRowAt) in
            completion(selectRowAt)
        }
    }
    
    func requestLoginAPI(bizKey: String, USER_ID: String, PWD: String){
        self.companyVM.requestR002(bizKey: bizKey/* , USER_ID: USER_ID, PWD: PWD*/) { (result) in
            switch result {
            case .success(_):
                // Check allow notification
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.registerForRemoteNotifications()
                MyDefaults.set(key: .autoLogin, value: true)
                UserDefaults.standard.setValue(bizKey, forKey: "bizKey")
                
                self.setRootViewController(sbName: "MainTabBarSB", identifier: "MainTabBarNav", direction: .toRight)

            case .failure(let error):
                self.showAlertSuccuss(title: "notice".localized, message: error.localizedDescription) {}
            }
        }
    }
}

// extension UITextFieldDelegate
extension LoginVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Updated text done on keyboard
        IQKeyboardToolbarManager.shared.toolbarConfiguration.doneBarButtonConfiguration = IQBarButtonItemConfiguration(title: "done".localized) //Localized for done button keyboard
        
        if string == " " {
            return false
        }
        return true
    }
}


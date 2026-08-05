//
//  LaunchScreenVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 5/1/21.
//

import UIKit


class LaunchScreenVC: UIViewController {
    
    var session_timeout = false
    var countryDataVM   = CountryDataVM()
    var wabooksR001     : WABOOKS_MREC_R001.RESPONSE?
    var indexPath : IndexPath = []
   
//    var isResume = false
    var window: UIWindow?
    
    @IBOutlet weak var imgAppLogo: UIImageView!
    @IBOutlet weak var lblVersion: UILabel!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")  /// Disable autolayout Constraint Error Messages
        
        imgAppLogo.image = UIImage(named: "w_mobile_logo")
        lblVersion.text = "WMobile \(self.getAppVersion())"
        
        lblVersion.getlocalizedFont()
        getScreenWidthAndHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if DEBUG
            self.showServerPopup()
        #else
            self.requestNewMG()
        #endif
    }
    
    func checkBusinessEst() {
        let USER_ID = KeychainManager.getCredential("username") ?? ""
        let PWD     = KeychainManager.getCredential("password") ?? ""

        LoginVM().requestR001(USER_ID: USER_ID, PWD: PWD) { (result) in
            switch result {
            case .success(_):
                self.requestLogin() //R002
                
            case .failure(let error):
                
                MyDefaults.set(key: .autoLogin, value: false)
                
                //Go to Login Screen
                self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: error.localizedDescription, redTitle: "", greyTitle: "close".localized) { (isRedPressed) in
                    self.gotoLoginScreen()
                }
            }
        }
    }
    
    func getScreenWidthAndHeight() {
        let width  = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        if width > height {
            Shared.screenWidth = height
            Shared.screenHeigh = width
        } else {
            Shared.screenWidth = width
            Shared.screenHeigh = height
        }
    }
    
    func gotoLogin(){
        // Check auto login
        if MyDefaults.bool(key: .autoLogin) {
            self.checkBusinessEst()
        }
        else {
            self.setRootNavViewController(sbName: "ChooseLanguageSB", identifier: "ChooseLanguageNav", direction: .toRight)
        }
    }
    
    private
    func requestMG() {
        if session_timeout {
            self.checkIntroMessageFromMG()
        } else {
            self.requestMG { isSuccess in
                if isSuccess {
                    self.checkIntroMessageFromMG()
                }
            }
            Shared.language = LanguageCode(rawValue: MyDefaults.string(key: .appLang)) ?? LanguageCode.Vietnamese
        }

    }
    
    private
    func requestNewMG() {
        if session_timeout {
            self.checkIntroMessageFromNewMG()
        } else {
            self.requestNewMG { isSuccess in
                if isSuccess {
                    self.checkIntroMessageFromNewMG()
                    self.countryDataVM.getCountryData() // get getCountryData form url to show on SubmitReceiptVC
                }
            }
            Shared.language = LanguageCode(rawValue: MyDefaults.string(key: .appLang)) ?? LanguageCode.Vietnamese
        }
        
    }
    
    private
    func checkIntroMessageFromNewMG() {
        
        if let availableService = Shared.New_MG?.c_available_service, availableService != "true" { //Show Popup and exit app
            
            let c_available_service_msg = (Shared.language == .English
                                           ? Shared.New_MG?.c_available_service_msg.en
                                           : Shared.New_MG?.c_available_service_msg.vi)?.replacingOccurrences(of: "+", with: " ") ?? ""
            
            
            DispatchQueue.main.async {
                self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "coming_soon".localized, message: c_available_service_msg, redTitle: "", greyTitle: "close".localized) { (_) in
                    exit(0)
                }
            }
            
        } else { //checking update new version
            
            let c_program_ver   = Shared.New_MG?.c_program_ver ?? ""
            
            if MgVM().isAppVersionSmallerThan(storeVersion: c_program_ver) {
                
                let c_act_update        = Shared.New_MG?.c_act_update ?? ""
                let c_act_update_msg    = (Shared.language == .English
                                           ? Shared.New_MG?.c_act_update_msg.en
                                           : Shared.New_MG?.c_act_update_msg.vi)?.replacingOccurrences(of: "+", with: " ") ?? ""
                
                if c_act_update == "true" { //Force Update
                    
                    DispatchQueue.main.async {
                        self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "new_version_avaiable".localized, message: c_act_update_msg, redTitle: "comfirm".localized, greyTitle: "update".localized) { (isRedPressed) in
                            if !isRedPressed {
                                if let url = URL(string: Shared.New_MG?.c_appstore_url ?? "") {
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url)
                                    } else {
                                        print("Can not open url a \n\(Shared.New_MG?.c_appstore_url ?? "")")
                                    }
                                }
                            }
                        }
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.customAlert(type: .YES_OR_NO_ALERT, image: "badge_failed", title: "new_version_avaiable".localized, message: c_act_update_msg, redTitle: "update".localized, greyTitle: "cancel".localized) { (isRedPressed) in
                            if isRedPressed {
                                if let url = URL(string: Shared.New_MG?.c_appstore_url ?? "") {
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url)
                                    } else {
                                        
//                                        self.showCustomAlert(titlte: "notice".localized, message: "Can not open url b \n\(Shared.New_MG?.c_appstore_url ?? "")") {}
                                        print("Can not open url b \n\(Shared.New_MG?.c_appstore_url ?? "")")
                                    }
                                }
                            }
                            else { //Pressed Cancel, move to app without any update
                                if Shared.New_MG?.c_act_update == "true" {
                                    exit(0)
                                } else {
//                                    if self.isResume {
//                                        
//                                    } else {
                                        self.gotoLogin()
//                                    }
                                }
                            }
                        }
                    }
                }
                
            } else {
                if let c_act_yn = Shared.New_MG?.c_act_yn,  c_act_yn == "true" {
                    let c_act           = (Shared.language == .English
                                           ? Shared.New_MG?.c_act_msg.en
                                           : Shared.New_MG?.c_act_msg.vi)?.replacingOccurrences(of: "+", with: " ") ?? ""
                    DispatchQueue.main.async {
                        self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: c_act, redTitle: "", greyTitle: "comfirm".localized) { (_) in
                            DispatchQueue.main.async {
                                self.gotoLogin()
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.gotoLogin()
                    }
                }
            }
        }
    }
    
    
    private func checkIntroMessageFromMG() {
        let c_update_act    = Shared.MG_DATA?.c_update_act?.replacingOccurrences(of: "+", with: " ") ?? ""
        let c_act           = Shared.MG_DATA?.c_act?.replacingOccurrences(of: "+", with: " ") ?? ""
        
        if let availableService = Shared.MG_DATA?.c_available_service, !availableService {
            self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: c_act.isEmpty ? "mg_service_reason".localized : c_act, redTitle: "", greyTitle: "confrim".localized) { (_) in}
        } else {
            
            let c_act_close     = Shared.MG_DATA?.c_act_close
            
            let c_program_ver   = Shared.MG_DATA?.c_program_ver ?? ""
            
            if let c_act_yn = Shared.MG_DATA?.c_act_yn {
                
                if c_act_yn == "true" {
                    self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: c_act.isEmpty ? "mg_service_reason".localized : c_act, redTitle: "", greyTitle: "confrim".localized) { (_) in
                        
                        if let isCloseUpdate = c_act_close, isCloseUpdate == "false" {
                            
                            //Goto flow 2
                            if MgVM().isAppVersionSmallerThan(storeVersion: c_program_ver) {
                                
                                self.customAlert(type: .YES_OR_NO_ALERT, image: "badge_failed", title: "notice".localized, message: c_update_act, redTitle: "comfirm".localized, greyTitle: "cancel".localized) { (isRedPressed) in
                                    if isRedPressed {
                                        if let url = URL(string: Shared.MG_DATA?.c_appstore_url ?? "") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    else {
                                        if Shared.MG_DATA?.c_update_close == "true" {
                                            exit(0)
                                        } else {
                                            self.gotoLogin()
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    //goto flow 2
                    if MgVM().isAppVersionSmallerThan(storeVersion: c_program_ver) {
                        self.customAlert(type: .YES_OR_NO_ALERT, image: "badge_failed", title: "notice".localized, message: c_update_act, redTitle: "comfirm".localized, greyTitle: "cancel".localized) { (isPressedRed) in
                            if isPressedRed {
                                if let url = URL(string: Shared.MG_DATA?.c_appstore_url ?? "") {
                                    UIApplication.shared.open(url)
                                }
                            } else {
                                if  Shared.MG_DATA?.c_update_close == "true" {
                                    exit(0)
                                }else {
                                    self.gotoLogin() //run app
                                }
                            }
                        }
                    } else {
                        self.gotoLogin() //runapp
                    }
                }
            }
        }
    }

}

// MARK: - API -
extension LaunchScreenVC {
    
    func requestMG(completion: @escaping Completion_Bool) {
        MgVM().requestMG(shouldShowLoading: false) { result in
            switch result {
            case .success(let data):
                Shared.MG_DATA = data?._tran_res_data?.first //server response MG data as array
                completion(true)
            case .failure(let error):
                self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: error.localizedDescription, redTitle: "", greyTitle: "close".localized) { (_) in
                    completion(false)
                }
            }
        }
    }
    
    func requestNewMG(completion: @escaping Completion_Bool) {
        MgVM().requestDebugMG { (result) in
            switch result {
            case .success(let data):
                
                Shared.New_MG = data //server response MG data as array
                completion(true)
                
            case .failure(let error):
                self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: error.localizedDescription, redTitle: "", greyTitle: "close".localized) { (_) in
                    completion(false)
                }
            }
        }
    }
    
}

// MARK: - Custom -
extension LaunchScreenVC {
    
    ///Choose Language
    func showCoach() -> Bool {
        let isFirstLaunch = MyDefaults.get(key: .IS_FIRST_COACH_APP) as? Bool ?? false
        if !isFirstLaunch {
            self.setRootNavViewController(sbName: "ChooseLanguageSB", identifier: "ChooseLanguageNav", direction: .toRight)
        }
        return isFirstLaunch
    }
    
    ///Show choosing Server either 개발 or 운영
    func showServerPopup() {//"서버선택"
        self.alertPromptMessage(
            title: "Select Server",
            message: "Please choose a server to connect.",
            topButtonTitle: "Development",
            centerButtonTitle: "UAT",
            bottomButtonTitle: "Production",
            
            topButtonCompletion: { [weak self] in
                Shared.environment = .Development
                self?.requestNewMG()
            },
            centerButtonCompletion: { [weak self] in
                Shared.environment = .UAT
                self?.requestNewMG()
            },
            bottomButtonCompletion: { [weak self] in
                Shared.environment = .Production
                self?.requestNewMG()
            }
        )
    }
    
    func gotoLoginScreen() {
        let vc  = self.VC(sbName: "LoginSB", identifier: "LoginVC") as! LoginVC
        self.pushVC(viewController: vc)
    }
    
    func requestLogin() {
        
        if (Shared.R001_DATA?.REC?.count ?? 0) > 1 {
            var data : [String] = []
            Shared.BUSINESS_EST?.REC?.forEach({ (rec) in
                data.append(rec.CMPN_NM)
            })
            let bisKey = UserDefaults.standard.string(forKey: "bizKey") ?? ""
            self.requestLoginData(bizKey: bisKey)
        } else {
            self.requestLoginData(bizKey: Shared.R001_DATA?.REC?.first?.BIZ_KEY ?? "")
        }
        
    }
    //KH_CAM0001_000132
    //KH_CAM0001_000051
    
    func requestLoginData(bizKey: String) {
        let USER_ID = KeychainManager.getCredential("username") ?? ""
        let PWD     = KeychainManager.getCredential("password") ?? ""
        CompanyVM().requestR002(shouldShowLoading: false, bizKey: bizKey/*, USER_ID: USER_ID, PWD: PWD*/) { (result) in
            switch result {
            case .success(_):
//                if self.isResume  {
//                    
//                } else {
                    self.setRootViewController(sbName: "MainTabBarSB", identifier: "MainTabBarNav", direction: .toRight)
//                }
             
            case .failure(let error):
                self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "", message: error.localizedDescription, redTitle: "", greyTitle: "ok".localized) { (isRedPress) in
                    self.gotoLoginScreen()
                }
            }
        }
    }
}

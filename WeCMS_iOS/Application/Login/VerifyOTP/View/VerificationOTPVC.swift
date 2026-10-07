//
//  VerificationOTPVC.swift
//  WeCMS_iOS
//
//  Created by Bun on 13/9/22.
//

import UIKit

class VerificationOTPVC: UIViewController {

    @IBOutlet weak var lbTitle      : UILabel!
    @IBOutlet weak var tableView    : UITableView!
    @IBOutlet weak var btnConfirm   : UIButton!
    
    let notice      = "notice".localized
    var isEnable    = false
    
    var vcType              : VCType?
    var USER_ID             : String = ""
    var USER_NM             : String = ""
    var CLPH_NO             : String = ""
    var shortPhoneNumber    : String = ""
    var countryCode         : String = ""
    var CRTC_NUM            : String = ""
    var REG_SEQ_NO          : Int = 0
    var preAutoCode         : [String] = []
     
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarStyle(isHidden: false, animated: true, title: "", leftBarButtonImage: "arrow_back", tintColor: "#0069B9", leftSelector: #selector(backButtonAction))
        self.lbTitle.font = UIFont(name: "Inter-Bold", size: 21)
        self.btnConfirm.isEnabled = false
        self.setupLocalized()
        self.tableView.register(UINib(nibName: "AutoFillOTPCell", bundle: nil), forCellReuseIdentifier: "AutoFillOTPCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // clear all textfield
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AutoFillOTPCell {
            Shared.crtcNumber.removeAll()
            cell.count              = 0
            cell.textfield1.text    = ""
            cell.textfield1.becomeFirstResponder()
            cell.textfield1.isUserInteractionEnabled = true
            
            cell.textfield2.text = ""
            cell.textfield3.text = ""
            cell.textfield4.text = ""
            cell.textfield5.text = ""
            
            cell.textfield6.text = ""
            cell.textfield6.isUserInteractionEnabled = false
        }
    }
     
    @IBAction func didTapBtnConfirm(_ sender: UIButton) {
        requestModifyOTP(USER_NM: self.USER_NM, CLPH_NO: self.CLPH_NO, CRTC_NUM: self.CRTC_NUM)
    }
    
    @objc func backButtonAction() {
        popOrDismissVC()
    }

    private func setupLocalized() {
        self.lbTitle.text = "verification".localized
        self.lbTitle.getlocalizedFont()

        self.btnConfirm.titleLabel?.font = UIFont(name: "Inter-Bold", size: 15)
        self.btnConfirm.setTitle("confirm".localized, for: .normal)
        self.btnConfirm.getlocalizedFont()
    }
    
    private func setupNavigation() {
        // Custom Back Button Item
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "arrow_back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        button.frame = CGRect(x: -30, y: 0, width: 30, height: 30)
        button.contentHorizontalAlignment = .left
        let barButton = UIBarButtonItem(customView: button)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.leftBarButtonItems = [barButton]
    }
    
    private func findPassword(VERI_KEY: String) {
        FindPasswordVM().request_MREC_MBMR_0003_R003(body: MREC_MBMR_0003_R003.REQUEST(USER_ID: self.USER_ID , USER_NM: self.USER_NM, CLPH_NO: CLPH_NO, VERI_KEY: VERI_KEY), completion: { result in
            switch result {
            case .success(let data):
                
                let vc = self.VC(sbName: "PasswordSB", identifier: "PwResetVC") as! PwResetVC
                vc.USER_NM      = self.USER_NM
                vc.USER_ID      = self.USER_ID
                vc.CLPH_NO      = self.CLPH_NO
                vc.REG_SEQ_NO   = data?.REG_SEQ_NO ?? 0
                self.REG_SEQ_NO = data?.REG_SEQ_NO ?? 0
                self.pushVC(viewController: vc)
                 
            case .failure(let error):
                self.customAlert(type       : .CONFIRM_ALERT,
                                 image      : "badge_failed",
                                 title      : "notice".localized,
                                 message    : error.localizedDescription,
                                 redTitle   : "",
                                 greyTitle  : "close".localized) { (_) in
                }
            }
        })
    }
    
    private func requestModifyOTP(USER_NM: String, CLPH_NO: String, CRTC_NUM: String) {
        ForgotVM().requestModifyOTP(vcType: self.vcType ?? .ForgetID, USER_NM: USER_NM, CLPH_NO: CLPH_NO, CRTC_NUM: CRTC_NUM) { (result) in
            switch result {
            case .success(let data):
                
                // Set color for textfield
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AutoFillOTPCell {
                    cell.CRTC_YN = data?.CRTC_YN == "N" ? false : true
                    cell.textfield1.borderColor = data?.CRTC_YN == "N" ? UIColor(hexString: "#CB0D0D") : UIColor(hexString: "#0069B9")
                    cell.textfield2.borderColor = data?.CRTC_YN == "N" ? UIColor(hexString: "#CB0D0D") : UIColor(hexString: "#0069B9")
                    cell.textfield3.borderColor = data?.CRTC_YN == "N" ? UIColor(hexString: "#CB0D0D") : UIColor(hexString: "#0069B9")
                    cell.textfield4.borderColor = data?.CRTC_YN == "N" ? UIColor(hexString: "#CB0D0D") : UIColor(hexString: "#0069B9")
                    cell.textfield5.borderColor = data?.CRTC_YN == "N" ? UIColor(hexString: "#CB0D0D") : UIColor(hexString: "#0069B9")
                    cell.textfield6.borderColor = data?.CRTC_YN == "N" ? UIColor(hexString: "#CB0D0D") : UIColor(hexString: "#0069B9")
                    cell.textfield6.isUserInteractionEnabled = true
                }
                 
                if data?.CRTC_YN == "Y" {
                    UIView.animate(withDuration: 5, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                        self.customToastwithColor(image: "toast_success_ico", message: "auth_code_verified".localized, backgroundColor: UIColor(hexString: "#49535B"))
                    }, completion: {_ in
                        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
                            switch self.vcType {
                            case .ForgetID:
                                self.requestFoundID(VERI_KEY: data?.VERI_KEY ?? "")
                                
                            case .Forget_Password:
                                self.findPassword(VERI_KEY: data?.VERI_KEY ?? "")
                                 
                            default: break
                            }
                        })
                    })
                }
                else {
                    UIView.animate(withDuration: 5, delay: 0, options: .curveEaseOut, animations: {
                        self.customToastwithColor(image: "badge_failed_white", message: "code_does_not_match".localized, backgroundColor: UIColor(hexString: "#CB0D0D"))
                    }, completion: nil)
                }
                
            case .failure(let error):
                self.customAlert(type       : .CONFIRM_ALERT,
                                 image      : "badge_failed",
                                 title      : "notice".localized,
                                 message    : error.localizedDescription,
                                 redTitle   : "",
                                 greyTitle  : "close".localized) { (_) in
                }
            }
        }
    }
    
    private func requestFoundID(VERI_KEY: String){
         
        let body = MREC_MBMR_0002_R003.REQUEST(USER_ID: self.USER_ID, USER_NM: self.USER_NM, CLPH_NO: self.CLPH_NO, VERI_KEY: VERI_KEY)
        
        IDFoundVM().requesdt_MREC_MBMR_0002_R003(vcType: self.vcType ?? .ForgetID, body: body, completion: { result in
            switch result {
            case .success(let data):
                let vc = self.VC(sbName: "IDFoundSB", identifier: "IDFoundVC") as! IDFoundVC
                vc.arrayID      = data?.REC ?? []
                vc.USER_NM      = self.USER_NM
                vc.CRTC_INFO    = self.shortPhoneNumber
                vc.countryCode  = self.countryCode
                vc.REG_SEQ_NO   = self.REG_SEQ_NO
                self.pushVC(viewController: vc)
                  
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
  
}

extension VerificationOTPVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoFillOTPCell") as! AutoFillOTPCell
        
        cell.vcType = self.vcType
        cell.isCompletion = { (crtcNumber, isEnable) in
            
            self.CRTC_NUM   = crtcNumber
            self.isEnable   = isEnable ?? false
            
            self.btnConfirm.isEnabled        = self.isEnable
            self.btnConfirm.backgroundColor  = UIColor(hexString: self.isEnable ? "#0069B9" : "#FAFAFA")
            self.btnConfirm.setTitleColor(UIColor(hexString: self.isEnable ? "#FFFFFF" : "#A6A6A6"), for: .normal)
        }
        
        cell.configCell(optValue: ["1", "6", "8", "1", "6", "8"], username: self.USER_NM, phoneNumber: self.CLPH_NO)
        return cell
    }
    
} 

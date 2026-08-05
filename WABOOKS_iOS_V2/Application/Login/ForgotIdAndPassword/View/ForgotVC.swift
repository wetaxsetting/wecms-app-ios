//
//  ForgotIDVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Bung on 5/18/21.
//

import UIKit

enum VCType: String {
    case ForgetID           = "Forgot ID"
    case Forget_Password    = "Forgot Password"
    
    var description: String {
        switch self {
        case .ForgetID              : return "recover_your_forgotten_id".localized
        case .Forget_Password       : return "recover_your_forgotten_password".localized
        }
    }
}

class ForgotVC: UIViewController {
    
    @IBOutlet weak var setConstraintBtnFindID       : NSLayoutConstraint!
    @IBOutlet weak var lblHeaderTitle               : UILabel!
    @IBOutlet weak var lblHeaderDescription         : UILabel!
    @IBOutlet weak var lblRecoverForgottenID        : UILabel!
    @IBOutlet weak var btnFindID                    : UIButton!
    @IBOutlet weak var pickerView                   : UIPickerView!
    @IBOutlet weak var pickerViewTopConstraint      : NSLayoutConstraint!
    @IBOutlet weak var tableView                    : UITableView!

    var USER_ID         : String?
    var USER_NM         : String?
    var CRTC_INFO       : String = ""
    var REG_SEQ_NO      : Int?
    var vcType          : VCType?
    var cellValue       : ForgotIDPWModel.ForgotIDPWROW?
    var countryCode     : String?
    var findPasswordVM  = FindPasswordVM()
    var findIdVM        = IDFoundVM()
    
    // Localize
    let name            = "name".localized
    let mobile_no       = "mobile_no".localized
    let phone           = "phone".localized
    let notice          = "notice".localized
    let find_id         = "find_id".localized
    let forget_id       = "forget_id".localized
    let get_code        = "get_code".localized
    
    var isVerifyAuth    = false
    var isEnable        = false
    let locale          = NSLocale.current
    var isDropdownVisible = false
    private var dropdownView : DropdownView?
    private var overlayView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.setNavigationBarStyle(isHidden: false, animated: true, title: "", leftBarButtonImage: "arrow_back", tintColor: "#0069B9", leftSelector: #selector(didTapLeftBarButton))
        
        self.customizeFont()
        self.setRow()
        self.checkButtonFindID(isEnable: isEnable)
        getLocalizeFont()
        
        // Auto selected country code
        let index = Shared.New_MG?.country_dial_codes_as_frist_order.firstIndex(where: { $0.dial_code == self.countryCode })
        self.pickerView.selectRow(index ?? 0, inComponent: 0, animated: true)
        
        // Validate btn get code
        self.validateGetCode(userID: getValue(code_cell: "ID"), username: USER_NM ?? "", phone: CRTC_INFO, phoneLength: CRTC_INFO.count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func customizeFont(){
        lblHeaderTitle.font = UIFont(name: "Inter-Bold", size: 21)
        btnFindID.titleLabel?.font = UIFont(name: "Inter-Bold", size: 15)
        lblRecoverForgottenID.font = UIFont(name: "Inter-Medium", size: 15)
    }
    
    @IBAction func btnActionFindID(_ sender: Any) {
        self.USER_ID = self.getValue(code_cell: "ID")
        self.USER_NM = self.getValue(code_cell: "NAME")
        
        switch vcType {
        case .ForgetID          : didTapRequestOTP() //foundID() ==> Bung: 13/09/2022 Change from request foundID (mbmr_0002_001_r003) to request OTP (WABOOKS_MREC_MBMR_0002_R002)
        case .Forget_Password   : didTapRequestOTP() // findPassword() ==> Bung: 13/09/2022 Change from request foundID (mbmr_0003_001_r003) to request OTP (WABOOKS_MREC_MBMR_0002_R002)
        default : break
        }
    }
    
    @IBAction func btnActionBackToLogin(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    @IBAction func btnDonePickerView(_ sender: UIButton) {
        let row = pickerView.selectedRow(inComponent: 0)
        pickerView(pickerView, didSelectRow: row, inComponent: 0)
        self.hidePickerView()
    }
    
    @IBAction func editingChangedTfForgot(_ sender: VSTextField) {
        let text = sender.text ?? ""
      
        switch sender.tag {
        
        // Tag 1000 = textField Enter Name
        case 1000:
            setValue(newValue: sender.text, code_cell: "NAME")
            let phone = getValue(code_cell: "PHONE")
            self.validateGetCode(userID: getValue(code_cell: "ID"), username: sender.text, phone: phone, phoneLength: phone.count)
//            self.validateSMS()
              
        // Tag 1001 = textField Enter PhoneNumber
        case 1001:
            var newText : String = ""
            
//            // Get value from Phone Number except first value = 0
            if  text.prefix(1) == "0" && text.count > 2 {
                newText = String(text.dropFirst())
            }
            else {
                newText = text
            }
            
            sender.text = text.applyPatternOnNumbers(pattern: "###########", replacmentCharacter: "#")
            setValue(newValue: newText, code_cell: "PHONE")
            let username = getValue(code_cell: "NAME")
            self.validateGetCode(userID: getValue(code_cell: "ID"), username: username, phone: text, phoneLength: text.count)
//            self.validateSMS()
            
        // Tag 1002 = textField Enter Auth-Code
        case 1002:
            sender.setFormatting("###-###", replacementChar: "#")
            setValue(newValue: sender.text, code_cell: "AUTH")
            self.isVerifyAuth ? () : self.validateOTP()
            
        // Tag 1003 = textField Enter ID
        case 1003:
            setValue(newValue: sender.text, code_cell: "ID")
            let phone = getValue(code_cell: "PHONE")
            self.validateGetCode(userID: getValue(code_cell: "ID"), username: sender.text, phone: phone, phoneLength: phone.count)
//            self.validateSMS()
        default: break
        }
    }
    
    // Display PickerView to Select Country-Code
    private func didTapChooseCountryCode(_ cell: ForgotTableViewCell) {
        if self.isDropdownVisible {
            self.hideDropdownWithAnimation()
        } else {
            self.showDropdownWithOverlay(cell: cell)
        }
    }
    
    @objc private func didTapRequestOTP() {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: vcType == .ForgetID ? 1 : 2 , section: 0)) as? ForgotTableViewCell {
            cell.textfieldPhoneNumber.resignFirstResponder()
        }
        
        let phone = self.getKey(code_cell: "PHONE").count >= 5 ? "+" : self.getKey(code_cell: "PHONE").count >= 4 ? "+0" : self.getKey(code_cell: "PHONE").count >= 3 ? "+00" : "+000"
        
        switch self.vcType {
           
        case .ForgetID:
            self.requestSendPhoneNumber(USER_NM: self.getValue(code_cell: "NAME"),
                                        CLPH_NO: "\(phone)\(self.getKey(code_cell: "PHONE").replace(of: "+", with: ""))\(self.getValue(code_cell: "PHONE").replace(of: "-", with: ""))")
        case .Forget_Password:
            self.requestSendPhoneNumber(USER_NM: self.getValue(code_cell: "NAME"),
                                        CLPH_NO: "\(phone)\(self.getKey(code_cell: "PHONE").replace(of: "+", with: ""))\(self.getValue(code_cell: "PHONE").replace(of: "-", with: ""))")
        default : break
        }
    }
    
    @objc private func didTapRequestVerifyOTP() {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: vcType == .ForgetID ? 2 : 3 , section: 0)) as? ForgotTableViewCell {
            cell.textfieldAuthCode.resignFirstResponder()
        }
        
        let phone = self.getKey(code_cell: "PHONE").count >= 5 ? "+" : self.getKey(code_cell: "PHONE").count >= 4 ? "+0" : self.getKey(code_cell: "PHONE").count >= 3 ? "+00" : "+000"
        
        switch vcType {
        case .ForgetID:
            requestModifyOTP(USER_NM: self.getValue(code_cell: "NAME"),
                             CLPH_NO: "\(phone)\(self.getKey(code_cell: "PHONE").replace(of: "+", with: ""))\(self.getValue(code_cell: "PHONE").replace(of: "-", with: ""))",
                             CRTC_NUM: self.getValue(code_cell: "AUTH"))
        case .Forget_Password:
            requestModifyOTP(USER_NM: self.getValue(code_cell: "NAME"),
                             CLPH_NO: "\(phone)\(self.getKey(code_cell: "PHONE").replace(of: "+", with: ""))\(self.getValue(code_cell: "PHONE").replace(of: "-", with: ""))",
                             CRTC_NUM: self.getValue(code_cell: "AUTH"))
        default : break
        }
    }
     
    
    //MARK: - Private func
    @objc func didTapLeftBarButton(){
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    // Setup Cell for ForgotID Screen
    private func setRowForgotID() {
        let regionCode = fetCountryPhoneCode(countryCode: locale.regionCode ?? "KH")
        cellValue = ForgotIDPWModel.ForgotIDPWROW(CONTENT:
                                                    [ForgotIDPWModel.ForgotIDPWROW.CONTENTS(CODE: "NAME",  KEY: "",     VALUE: ""),
                                                     ForgotIDPWModel.ForgotIDPWROW.CONTENTS(CODE: "PHONE", KEY: self.countryCode ?? "+\(regionCode)", VALUE: "")/*,
                                                     ForgotIDPWModel.ForgotIDPWROW.CONTENTS(CODE: "AUTH",  KEY: "",     VALUE: "")*/]) //Bung: 13/09/2022
    }
    
    // Setup Cell for ForgotPassword Screen
    private func setRowForgotPW() {
        let regionCode = fetCountryPhoneCode(countryCode: locale.regionCode ?? "KH")
        cellValue = ForgotIDPWModel.ForgotIDPWROW(CONTENT:
                                                    [ForgotIDPWModel.ForgotIDPWROW.CONTENTS(CODE: "ID",   KEY: "",      VALUE: ""),
                                                     ForgotIDPWModel.ForgotIDPWROW.CONTENTS(CODE: "NAME", KEY: "",      VALUE: ""),
                                                     ForgotIDPWModel.ForgotIDPWROW.CONTENTS(CODE: "PHONE",KEY: self.countryCode ?? "+\(regionCode)",  VALUE: "")/*,
                                                     ForgotIDPWModel.ForgotIDPWROW.CONTENTS(CODE: "AUTH", KEY: "",      VALUE: "")*/]) //Bung: 13/09/2022
    }
    
    private func fetCountryPhoneCode(countryCode: String) -> String {
        let countryDictionary  = ["KH":"855", "KR":"82", "VN":"84"]
        if let countryCode = countryDictionary[countryCode] {
            return countryCode
        }
        return "855"
    }
 
    private func setRow() {
        switch vcType {
        case .ForgetID:
            lblHeaderTitle.text             = forget_id
            lblHeaderDescription.text       = vcType?.description
            btnFindID.setTitle(get_code, for: .normal)
            setRowForgotID()
            
        case .Forget_Password:
            lblHeaderTitle.text             = "forget_password".localized
            lblHeaderDescription.text       = "recover_your_forgotten_password".localized
            btnFindID.setTitle(get_code, for: .normal)
            setRowForgotPW()
            setValue(newValue: USER_ID ?? "", code_cell: "ID")
            setValue(newValue: USER_NM ?? "", code_cell: "NAME")
            setValue(newValue: CRTC_INFO, code_cell: "PHONE")
            
        default: break
        }
    }
    
    private func checkButtonFindID(isEnable: Bool) {
        self.btnFindID.isEnabled        = isEnable
        self.btnFindID.backgroundColor  = UIColor(hexString: isEnable ? "#0069B9" : "#FAFAFA")
        self.btnFindID.setTitleColor(UIColor(hexString: isEnable ? "#FFFFFF" : "#A6A6A6"), for: .normal)
    }
    
    private func setValue(newValue: String, code_cell: String) {
        for (index, value) in (cellValue?.CONTENT ?? []).enumerated() {
            if value.CODE == code_cell {
                cellValue?.CONTENT[index].VALUE = newValue
            }
        }
    }
    
    private func getValue(code_cell: String) -> String {
        var str: String = ""
        for (_, value) in (cellValue?.CONTENT ?? []).enumerated() {
            if value.CODE == code_cell {
                str = value.VALUE ?? ""
            }
        }
        return str
    }
    
    private func setKey(newKey: String, code_cell: String) {
        for (index, value) in (cellValue?.CONTENT ?? []).enumerated() {
            if value.CODE == code_cell {
                cellValue?.CONTENT[index].KEY = newKey
            }
        }
    }
    
    private func getKey(code_cell: String) -> String {
        var str: String = ""
        for (_, value) in (cellValue?.CONTENT ?? []).enumerated() {
            if value.CODE == code_cell {
                str = value.KEY ?? ""
            }
        }
        return str
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func showPickerView() {
        self.dismissKeyboard()
        UIView.animate(withDuration: 0.3) {
            self.pickerViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func hidePickerView() {
        UIView.animate(withDuration: 0.3) {
            self.pickerViewTopConstraint.constant = 240
            self.view.layoutIfNeeded()
        }
    }
    
    private func isValidated() -> Bool {
        return ((getValue(code_cell: "PHONE").count < 8) || (vcType == .ForgetID ? false : getValue(code_cell: "ID").isEmpty) || (getValue(code_cell: "NAME").isEmpty)) ? false : true
    }
    
    private func validateOTP() {
        if let cell = tableView.cellForRow(at: IndexPath(row: vcType == .ForgetID ? 2: 3, section: 0)) as? ForgotTableViewCell {
            cell.enableOTP(isEnable: getValue(code_cell: "AUTH").count == 6 )
        }
    }
    
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx  = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred   = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func validateGetCode(userID: String, username: String, phone: String, phoneLength: Int) {
        switch vcType {
        case .ForgetID:
            if username.isNotEmpty && phone.isNotEmpty {
                checkButtonFindID(isEnable: true)
            } else {
                checkButtonFindID(isEnable: false)
            }
            
        case .Forget_Password:
            if userID.isNotEmpty && username.isNotEmpty && phone.isNotEmpty && isValidEmail(email: userID) {
                checkButtonFindID(isEnable: true)
            } else {
                checkButtonFindID(isEnable: false)
            }
            
        default: break
        }
    }
    
    private func validateSMS() {
        if let cell = tableView.cellForRow(at: IndexPath(row: vcType == .ForgetID ? 1 : 2, section: 0)) as? ForgotTableViewCell {
            cell.enableSMS(isEnable: isValidated())
        }
    }
    
    private func getLocalizeFont() {
        lblHeaderTitle.getlocalizedFont()
        lblHeaderDescription.getlocalizedFont()
        btnFindID.getlocalizedFont()
       
        // Custom Back Button Item
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "arrow_back"), for: .normal)
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        button.frame = CGRect(x: -30, y: 0, width: 30, height: 30)
        button.contentHorizontalAlignment = .left
        let barButton = UIBarButtonItem(customView: button)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.leftBarButtonItems = [barButton]
    }
    
    
    @objc func dismissAction() {
        popOrDismissVC()
    }
    
    private func foundID(){
        let phone = self.getKey(code_cell: "PHONE").count >= 5 ? "+" : self.getKey(code_cell: "PHONE").count >= 4 ? "+0" : self.getKey(code_cell: "PHONE").count >= 3 ? "+00" : "+000"
        
        let formatPhoneNumber = "\(phone)\(getKey(code_cell: "PHONE").replace(of: "+", with: ""))\(getValue(code_cell: "PHONE").replace(of: "-", with: ""))"
         
        let body = WABOOKS_MREC_MBMR_0002_R003.REQUEST(USER_ID: getValue(code_cell: "ID"), USER_NM: getValue(code_cell: "NAME"), CLPH_NO: formatPhoneNumber, VERI_KEY: "")
        
        //Request Data from API mbmr_0002_001_r003
        IDFoundVM().requesdt_WABOOKS_MREC_MBMR_0002_R003(vcType: self.vcType ?? .ForgetID, body: body, completion: { result in
            
            switch result {
            case .success(let data):
                self.customAlert(type       : .CONFIRM_ALERT,
                                 image      : "badge_failed",
                                 title      :  self.notice,
                                 // New Update 06 Sep 2021
                                 message    : "\("your_input_information".localized) \n\("name".localized): \(self.getValue(code_cell: "NAME")) \n\("phone".localized) 0\(self.getValue(code_cell: "PHONE").replace(of: "-", with: " "))",
                                 greyTitle  : "confirm".localized) { (isRedPress) in
                    
                    let vc = self.VC(sbName: "IDFoundSB", identifier: "IDFoundVC") as! IDFoundVC
                    vc.arrayID      = data?.REC ?? []
                    vc.USER_NM      = self.USER_NM ?? ""
                    vc.CRTC_INFO    = self.getValue(code_cell: "PHONE")
                    self.pushVC(viewController: vc)
                }
                
            case .failure(_):
                self.customAlert(type       : .CONFIRM_ALERT,
                                 image      : "badge_failed",
                                 title      :  self.notice,
                                 message    : "\("your_input_information".localized) \n\(self.name): \(self.getValue(code_cell: "NAME")) \n\(self.mobile_no): \(self.getValue(code_cell: "PHONE").replace(of: "-", with: " ")) \n\n\("if_using_the_keyboards_auto_correct_it_may_enter_automatically_a_blank_space_after_an_id".localized)",
                                 greyTitle  : "comfirm".localized) { (isRedPress) in
                }
            }
        })
    }
   
    private func requestSendPhoneNumber(USER_NM: String, CLPH_NO: String) {
        ForgotVM().requestSendPhoneNumber(vcType: self.vcType ?? .ForgetID, USER_NM: USER_NM, CLPH_NO: CLPH_NO) { (result) in
            switch result {
            case .success(_):
                //New process
                let phone = self.getKey(code_cell: "PHONE").count >= 5 ? "+" : self.getKey(code_cell: "PHONE").count >= 4 ? "+0" : self.getKey(code_cell: "PHONE").count >= 3 ? "+00" : "+000"
                
                let vc = self.VC(sbName: "VerificationOTPSB", identifier: "VerificationOTPVC") as! VerificationOTPVC
                vc.USER_NM          = USER_NM
                vc.USER_ID          = self.USER_ID ?? ""
                vc.CLPH_NO          = "\(phone)\(self.getKey(code_cell: "PHONE").replace(of: "+", with: ""))\(self.getValue(code_cell: "PHONE").replace(of: "-", with: ""))"
                vc.REG_SEQ_NO       = self.REG_SEQ_NO ?? 0
                vc.shortPhoneNumber = self.getValue(code_cell: "PHONE")
                vc.countryCode      = self.getKey(code_cell: "PHONE")
                vc.vcType           = self.vcType
                self.pushVC(viewController: vc)
                
                // Old process
               /* let messageStr = "the_auth_code_has_sent_to OOO".localized
                let msg        = "please_enter_the_code_to_find_ID".localized
                let phone = "0\(self.getValue(code_cell: "PHONE"))"
                let messageStrLocalized = String(format: messageStr, phone) + "\n" + msg
                  
                self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: self.notice, message: messageStrLocalized, redTitle: "", greyTitle: "okay".localized) { (resut) in
                    self.checkButtonFindID(isEnable: false)
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: self.vcType == .ForgetID ? 2 : 3, section: 0)) as? ForgotTableViewCell {
                        cell.textfieldAuthCode.text = ""
                        cell.enableOTP(isEnable: false)
                        cell.btnVerifyAuthCode.setImage(UIImage(named: "txt_ico_verify_off"), for: .normal)
                        self.isVerifyAuth = false
                        cell.textfieldAuthCode.becomeFirstResponder()
                    }
                } */
                
            case .failure(let error):
                // Update: change display popup from xd to get error from api (4th June 2021)
                self.customAlert(type           : .CONFIRM_ALERT,
                                 image          : "badge_failed",
                                 title          :  self.notice,
                                 message        :  error.localizedDescription, //"please_check_your_number_and_try_again".localized
                                 greyTitle      : "close".localized) { (result) in
                }
            }
        }
    }
    
    private func requestModifyOTP(USER_NM: String, CLPH_NO: String, CRTC_NUM: String) {
        ForgotVM().requestModifyOTP(vcType: self.vcType ?? .ForgetID, USER_NM: USER_NM, CLPH_NO: CLPH_NO, CRTC_NUM: CRTC_NUM) { (result) in
            switch result {
            case .success(let data):
                if data?.CRTC_YN == "Y" {
                    self.customAlert(type       : .CONFIRM_ALERT,
                                     image      : "badge_failed",
                                     title      : self.notice,
//                                     message    : "the_auth_code_does_has_been_verify".localized,
                                     message    : "auth_code_verified".localized,
                                     greyTitle  : "okay".localized) { (result) in
                        
                        self.isVerifyAuth = true
                        
                        if let cell = self.tableView.cellForRow(at: IndexPath(row: self.vcType == .ForgetID ? 2 : 3, section: 0)) as? ForgotTableViewCell {
                            cell.btnVerifyAuthCode.setImage(UIImage(named: "txt_ico_verify_on"), for: .normal)
                            cell.btnVerifyAuthCode.isEnabled    = false
                        }
                    }
                }
                else {
                    self.customAlert(type       : .CONFIRM_ALERT,
                                     image      : "badge_failed",
                                     title      :  self.notice,
                                     message    : "the_auth_code_does_not_match".localized,
                                     greyTitle  : "try_again".localized) { (result) in
                    }
                }
                
            case .failure(let error):
                self.customAlert(type           : .CONFIRM_ALERT,
                                 image          : "badge_failed",
                                 title          :  self.notice,
                                 message        : error.localizedDescription,
                                 greyTitle      : "close".localized) { (result) in
                }
            }
        }
    }
}

//MARK: - UIPickerView
extension ForgotVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Shared.New_MG?.country_dial_codes_as_frist_order.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(Shared.New_MG?.country_dial_codes_as_frist_order[row].dial_code ?? "")  \(Shared.New_MG?.country_dial_codes_as_frist_order[row].name ?? "")"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let newKey = Shared.New_MG?.country_dial_codes_as_frist_order[row].dial_code?.components(separatedBy: "  ").first ?? "+855"
        setKey(newKey: newKey, code_cell: "PHONE")
        self.validateGetCode(userID: getValue(code_cell: "ID"), username: getValue(code_cell: "NAME"), phone: getValue(code_cell: "PHONE"), phoneLength: getValue(code_cell: "PHONE").count)
        DispatchQueue.main.async {
            // Reload table
            self.tableView.reloadRows(at: [IndexPath(row: self.vcType == .ForgetID ? 1 : 2, section: 0)], with: .none)
        }
    }
}

extension ForgotVC {
    
    private func setupDropDown(_ cell: ForgotTableViewCell) -> DropdownView {
        
        let country_dial_codes = Shared.New_MG?.country_dial_codes_as_frist_order ?? []
        let dynamicItems = country_dial_codes.map { Items(code: $0.dial_code ?? "", title: $0.name) }
        
        let dropdown = DropdownView(
            items: dynamicItems,
            heightForRow: 40,
            isDropdownVisible: false
        )
        
        dropdown.onSelect = { selectedItem, isDropdownVisible in
            self.isDropdownVisible = isDropdownVisible
            self.hideDropdownWithAnimation()
            
            print("Item: \(selectedItem)")
            let countryCode = selectedItem.code ?? "+855"
    
            self.setKey(newKey: countryCode , code_cell: "PHONE")
            self.validateGetCode(userID: self.getValue(code_cell: "ID"), username: self.getValue(code_cell: "NAME"), phone: self.getValue(code_cell: "PHONE"), phoneLength: self.getValue(code_cell: "PHONE").count)
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadRows(at: [IndexPath(row: self?.vcType == .ForgetID ? 1 : 2, section: 0)], with: .none)
            }
        }
        
        positionDropdown(dropdown, relativeTo: cell)
        return dropdown
    }
    
    private func positionDropdown(_ dropdown: DropdownView, relativeTo cell: ForgotTableViewCell) {
          let cellFrameInWindow = cell.convert(cell.bounds, to: nil)
          let leadingPosition = cellFrameInWindow.minX + cell.enterPhoneView.frame.minX
          let dropdownTopPosition = cellFrameInWindow.minY + cell.enterPhoneView.frame.minY + 60
          dropdown.frame = CGRect(x: leadingPosition, y: dropdownTopPosition, width: 159, height: 140)
      }
      
    private func hideDropdownWithAnimation() {
          guard let dropdown = dropdownView else { return }
          UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
              dropdown.alpha = 0.0
          }) { _ in
              dropdown.removeFromSuperview()
              self.dropdownView = nil
              self.isDropdownVisible = false
          }
      }
    
    @objc private func hideDropdownWithAnimationWhenTapOutside() {
        overlayView?.removeFromSuperview()  // Remove overlay
        overlayView = nil
        if let dropdown = dropdownView {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                dropdown.alpha = 0.0
            }) { _ in
                dropdown.removeFromSuperview()
                self.dropdownView = nil
                self.isDropdownVisible = false
            }
        }
    }
    
    @objc private func toggleDropdown(cell: ForgotTableViewCell) {
        if isDropdownVisible {
            hideDropdownWithAnimation()
        } else {
            dropdownView = setupDropDown(cell)
            if let dropdown = dropdownView, let topLevelView = cell.window {
                topLevelView.addSubview(dropdown)
                dropdown.toggleDropdown()  // Show the dropdown
                isDropdownVisible = true
            }
        }
    }
    
    private func setupOverlay() {
        overlayView = UIView(frame: UIScreen.main.bounds)
        overlayView?.backgroundColor = UIColor.clear
        overlayView?.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideDropdownWithAnimationWhenTapOutside))
        overlayView?.addGestureRecognizer(tapGesture)
    }
    
    private func showDropdownWithOverlay(cell: ForgotTableViewCell) {
        guard let topLevelView = cell.window else { return }
        
        setupOverlay()
        
        dropdownView = setupDropDown(cell)
        if let dropdown = dropdownView, let overlay = overlayView {
            topLevelView.addSubview(overlay)
            topLevelView.addSubview(dropdown)
            dropdown.toggleDropdown()  // Show dropdown with animation
            isDropdownVisible = true
        }
    }
}

//MARK: - UITableView
extension ForgotVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellValue?.CONTENT.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForgotTableViewCell") as! ForgotTableViewCell

        cell.btnDropDown.didTap {
            self.didTapChooseCountryCode(cell)
        }
        cell.btnSendAuthCode.addTarget(self, action: #selector(didTapRequestOTP), for: .touchUpInside)
        cell.btnVerifyAuthCode.addTarget(self, action: #selector(didTapRequestVerifyOTP), for: .touchUpInside)
        
        cell.enableSMS(isEnable: isValidated())
        cell.enableOTP(isEnable: getValue(code_cell: "AUTH").count == 6 )
        
        cell.configCell(data: cellValue?.CONTENT[indexPath.row] ?? ForgotIDPWModel.ForgotIDPWROW.CONTENTS(), vcType: self.vcType ?? .ForgetID)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

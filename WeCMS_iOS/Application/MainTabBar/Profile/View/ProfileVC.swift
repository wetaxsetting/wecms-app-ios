//
//  ProfileVC.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 12/1/21.
//

import UIKit

import IQKeyboardManagerSwift
import IQKeyboardToolbar
import IQKeyboardToolbarManager
import SDWebImage

/// Enum presents the options in Settings
///Enum presents table section
enum ProfileSection : Int, CaseIterable {
    case Profile
    case CompanyProfile
    case QRCode
    case Company
    case Address
    case TaxID
    case Tel
    case Email
    case Version
}


class ProfileVC: UIViewController {
    
    // MARK: - IBOUltet -
    @IBOutlet weak var btnClose     : UIButton!
    @IBOutlet weak var lblTitle     : UILabel!
    @IBOutlet weak var btnLogout    : UIButton!
    @IBOutlet weak var tableView    : UITableView!
    
//    @IBOutlet weak var updateIcon: UIImageView!
    
    var lang            : [String] = []
    
    var selectLangRowAt = 0
    var isSelectedPersonalInfo      = false
    var isSelectIndex   = -1
    var isExspand       = false
    
    var profileVM = ProfileVM()
    var settingVM = SettingVM()
    var languageVM = LanguageVM()
    var c_inform_version = Shared.c_inform_ver
    
    var qrProfileImage : UIImage!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qrProfileImage = getQRProfile()
        
        isExspand = true
        isSelectIndex = 0
        setupTableView : do {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)
        }
        
        // WeCMS offers Vietnamese and English only; index must align with the picker below.
        self.lang               = ["vi", "en"]
        
//        let langCode            = MyDefaults.get(key: .appLang) as? String ?? ""
//        self.selectLangRowAt    = (langCode == "km" || langCode == "vi") ? 0 : langCode == "ko" ? 1 : langCode == "en" ? 2 : langCode == "vi" ? 3 : 0
        self.selectLangRowAt    = Shared.language == .English ? 1 : 0
        self.checkNotify()
        self.reloadLocalize()
        setUpNib()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardToolbarManager.shared.toolbarConfiguration.doneBarButtonConfiguration = IQBarButtonItemConfiguration(title: "done".localized) //Localized for done button keyboard
    }
    
    func getQRProfile() -> UIImage? {
        let title = ""
        let url = ""
        let names = Shared.R002_DATA?.USER_NM?.components(separatedBy: " ") ?? []
        
        let firstName = names.count > 1 ? (Shared.R002_DATA?.USER_NM?.components(separatedBy: " ").last ?? "") : ""
        let lastName = names.first ?? ""
        
        let phonenumber = Shared.R002_DATA?.CLPH_NO ?? ""
        let emailAddress = Shared.R002_DATA?.EML ?? ""
        let postAddress = (Shared.R002_DATA?.RPRS_BSUN_POST_ADRS ?? "")
        let detailAddress = (Shared.R002_DATA?.RPRS_BSUN_DTL_ADRS ?? "")
        let city = (Shared.R002_DATA?.RPRS_BSUN_CITY ?? "")
        let state = (Shared.R002_DATA?.RPRS_BSUN_ST ?? "")
        let company = (Shared.R002_DATA?.CMPN_ENM ?? "")
        let taxID = Shared.R002_DATA?.TAX_ID ?? ""
        let arrayAddress = [postAddress, detailAddress, city, state]
        
        var fullAddressForDisplayApp = ""
        
        for (index, address) in arrayAddress.enumerated() {
            
            fullAddressForDisplayApp += address
            
            // Check if there is address add ", "
            if !address.isEmpty {
                
                // Break loop if it is the last string no add ", "
                if index == arrayAddress.count - 1 {
                    break
                }
                fullAddressForDisplayApp += ", "
            }
        }

        let string_for_qr = "BEGIN:VCARD\n" +
        "VERSION:3.0\n" +
        "N:\(firstName);\(lastName)\n" +
        "TEL:\(phonenumber)\n" +
        "EMAIL:\(emailAddress)\n" +
        "ORG:\(company)\n" +
        "TITLE:\(title)\n" +
        "URL:\(url)\n" +
        "NOTE:Tax ID : \(taxID)\n" +
        "ADR:\(fullAddressForDisplayApp)\n" +
        "ENCODING: UTF-8\n" +
        "END:VCARD"

        return generateQRCodeWithLogo(from: string_for_qr)
    }
    
    private
    func checkNotify() {
        MyNotify.listen(self, selector: #selector(reloadLocalize), name: .reloadLocalize)
    }
    
    @objc func reloadLocalize() {
        lblTitle.text = "profile".localized
        btnLogout.setTitle("log_out".localized, for: .normal)
        tableView.reloadData() //reload localize in table
        
        lblTitle.getlocalizedFont()
        btnLogout.getlocalizedFont()
    }
    
    @IBAction func didTapBtnClose(_ sender: Any) {
        self.popOrDismissVC()
//        self.setRootViewController(sbName: "MainTabBarSB", identifier: "sideMenuNavigation", direction: .fade)
    }
    
    @IBAction func didTapBtnLogout(_ sender: UIButton) {
        self.showAlertLogout() //Show Logout Popup
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, completion: @escaping (Data) -> ()) {
        // Download Start
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            print("QR Finished")
            print(response?.suggestedFilename ?? url.lastPathComponent)
            
            // Download finished
            
            DispatchQueue.main.async() {
                completion(data)
            }
        }
    }
    
    func setUpNib(){
        tableView.register(UINib(nibName: "QRTableViewCell",     bundle: nil), forCellReuseIdentifier: "QRTableViewCell")
        tableView.register(UINib(nibName: "CompanyTableViewCell",     bundle: nil), forCellReuseIdentifier: "CompanyTableViewCell")
        tableView.register(UINib(nibName: "AddressCompanyTableViewCell",     bundle: nil), forCellReuseIdentifier: "AddressCompanyTableViewCell")
        tableView.register(UINib(nibName: "TaxIDTableViewCell",     bundle: nil), forCellReuseIdentifier: "TaxIDTableViewCell")
        tableView.register(UINib(nibName: "TelTableViewCell",     bundle: nil), forCellReuseIdentifier: "TelTableViewCell")
        tableView.register(UINib(nibName: "EmailTableViewCell",     bundle: nil), forCellReuseIdentifier: "EmailTableViewCell")
    }
   
   
    
}

extension ProfileVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        ProfileSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = ProfileSection(rawValue: section)
        switch section {
        case .Profile   : return 0
        case .CompanyProfile        : return 0
        case .Version   : return 0
        default         : return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = ProfileSection(rawValue: section)
        
        switch section {
        case .Profile   : return 2
        case .CompanyProfile        : return 1
        case .QRCode    : return 1
        case .Company   : return 1
        case .Address   : return 1
        case .TaxID     : return 1
        case .Tel       : return 1
        case .Email     : return 1
        case .Version   : return 1
//        default         : return 0
        default : 0

        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = ProfileSection(rawValue: indexPath.section)
        
        switch section {
        case .Profile   :
                return UITableView.automaticDimension
        case .CompanyProfile   :
            if isSelectedPersonalInfo {
                return 70
            }
            else {
                return UITableView.automaticDimension
            }
        case .Version   :
            return UITableView.automaticDimension
        case .QRCode    :
            if isExspand == true {
                return UITableView.automaticDimension
            }else {
                return 0
            }
        case .Company   :
            if isExspand == true {
                return UITableView.automaticDimension
            }else {
                return 0
            }
        case .Address   :
            if isExspand == true {
                return UITableView.automaticDimension
            }else {
                return 0
            }
        case .TaxID     :
            if isExspand == true {
                return UITableView.automaticDimension
            }else {
                return 0
            }
        case .Tel       :
            if isExspand == true {
                return UITableView.automaticDimension
            }else {
                return 0
            }
        case .Email     :
            if isExspand == true {
                return UITableView.automaticDimension
            }else {
                return 0
            }
        default         :
            return UITableView.automaticDimension
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //Init Label
        let titleLabel          = UILabel()
        titleLabel.frame        = CGRect(x: 20, y: 0, width: tableView.frame.size.width, height: 31)
        titleLabel.textColor    = UIColor(hexString: "9FADB9")
        titleLabel.font         = UIFont(name: "Inter-Regular", size: 13) //Init default font
        titleLabel.text         = "settings".localized
        titleLabel.getlocalizedFont()
       
        //Add Label To HeaderView
        let headerView              = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 34))
        headerView.backgroundColor  = UIColor(hexString: "FFFFFF")
        headerView.addSubview(titleLabel)
        
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = ProfileSection(rawValue: indexPath.section)
        
        switch section {
        case .Profile:
            
            switch indexPath.row {
            case 0:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileCell
                let value = Shared.R002_DATA?.USER_NM ?? ""
                cell.configCell(imgStr: "list_employee_ico", title: "user".localized, value: value, type: .Normal)
                cell.setHideLineView(isHidden: false)
                cell.newUpdateView.isHidden = true
                return cell
                
            case 1:
                
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileCell
                let lang = Shared.language.rawValue
                cell.configCell(imgStr: "list_lang_ico", title: "language".localized, value: lang.localized, type: .Detail)
                cell.imgViewArrow.image = UIImage(named: "chevron_right")
                cell.setHideLineView(isHidden: false)
                cell.newUpdateView.isHidden = true
                return cell

                
            default:
                return UITableViewCell()
            }
            
        case .CompanyProfile :
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "QRTaxCell", for: indexPath) as! QRTaxCell
            cell.titleLabel.text = "company_tax_info".localized 
            return cell
            
            
        case .QRCode :
       
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "QRTableViewCell") as! QRTableViewCell
            cell.QRLogo.image = qrProfileImage
            cell.selectionStyle = .none
            return cell
            
        case .Company :
           
            let cell        = self.tableView.dequeueReusableCell(withIdentifier: "CompanyTableViewCell") as! CompanyTableViewCell
            let company = (Shared.R002_DATA?.CMPN_ENM ?? "")
            cell.Company.text = "Company".localized
            cell.CompanyLabe.text = company
            cell.selectionStyle = .none
            return cell
            
        case .Address :
          
            let cell        = self.tableView.dequeueReusableCell(withIdentifier: "AddressCompanyTableViewCell") as! AddressCompanyTableViewCell
            cell.Address.text = "Address".localized
            let postAddress = (Shared.R002_DATA?.RPRS_BSUN_POST_ADRS ?? "")
            let detailAddress = (Shared.R002_DATA?.RPRS_BSUN_DTL_ADRS ?? "")
            let city = (Shared.R002_DATA?.RPRS_BSUN_CITY ?? "")
            let state = (Shared.R002_DATA?.RPRS_BSUN_ST ?? "")
            
            let arrayAddress = [postAddress, detailAddress, city, state]
            
            var fullAddressForDisplayApp = ""
            
            for (index, address) in arrayAddress.enumerated() {
                
                fullAddressForDisplayApp += address
                
                // Check if there is address add ", "
                if !address.isEmpty {
                    
                    // Break loop if it is the last string no add ", "
                    if index == arrayAddress.count - 1 {
                        break
                    }
                    fullAddressForDisplayApp += ", "
                }
            }
            cell.AddressLabel.text      = fullAddressForDisplayApp
            cell.selectionStyle = .none
            return cell
            
        case .TaxID:
            
            let cell           = self.tableView.dequeueReusableCell(withIdentifier: "TaxIDTableViewCell") as! TaxIDTableViewCell
            let taxID          = Shared.R002_DATA?.TAX_ID ?? ""
            cell.Tax.text      = "Tax ID".localized
            cell.TaxLabel.text = taxID
            cell.selectionStyle = .none
            return cell
            
        case .Tel :
           
            let cell           = self.tableView.dequeueReusableCell(withIdentifier: "TelTableViewCell") as! TelTableViewCell
            let phonenumber    = Shared.R002_DATA?.CLPH_NO ?? ""
            cell.tel.text      = "Tel".localized
            cell.TelLabel.text = phonenumber
            cell.selectionStyle = .none
            return cell
        
        case .Email :
          
            let cell           = self.tableView.dequeueReusableCell(withIdentifier: "EmailTableViewCell") as! EmailTableViewCell
            let emailAddress   = Shared.R002_DATA?.EML ?? ""
            cell.EmailLab.text = "Email".localized
            cell.Email.text    = emailAddress
            cell.selectionStyle = .none
            return cell
            

            
        case .Version:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileCell
            cell.configCell(imgStr: "list_app_vers_ico", title: "version".localized, value: self.getAppVersion(), type: .Normal)
            cell.setHideLineView(isHidden: indexPath.row == 0)
            
            let c_program_ver   = Shared.New_MG?.c_program_ver ?? ""
//            isAppVersionSmallerThan(storeVersion: Shared.c_inform_ver)
            
            if MgVM().isAppVersionSmallerThan(storeVersion: Shared.c_inform_ver){
                cell.newUpdateView.isHidden = false
            }else {
                cell.newUpdateView.isHidden = true
            }
            
            cell.newLab.text = "update".localized
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = ProfileSection(rawValue: indexPath.section)
        switch section {
        case .Profile:
            switch indexPath.row {
            case 0: break
                
            case 1:
                customOption(type           : .MultipleChoice,
                             title          : "language".localized,
                             message        : "please_select_your_language".localized,
                             data           : ["Tiếng Việt", "English"],
                             selectRowAt    : selectLangRowAt
                ) { (selectRowAt) in
                    
                    self.selectLangRowAt    = selectRowAt
                    let langCodeIndex       = self.lang[selectRowAt]
                    
                    //do not request U002 when selected same as previous language
                    if Shared.language != LanguageCode(rawValue: langCodeIndex) {
                        self.languageVM.fetchingU002(lang_code: langCodeIndex) { (result) in
                            switch result {
                            case .success(_) :
                                Shared.language     = LanguageCode(rawValue: langCodeIndex) ?? .Vietnamese
                                MyDefaults.set(key: .appLang, value: langCodeIndex)
                                DispatchQueue.main.async {
                                    MyNotify.send(name: .reloadLocalize)
                                    MyNotify.send(name: .reloadBoardVC)
                                    MyNotify.send(name: .reloadNotificationVC)
                                }
                            case .failure(let error):
                                self.alertError(message: error.localizedDescription)
                            }
                        }
                    }
                }
            default: break
            }
        case .CompanyProfile :
//            isExspand = false
            if isSelectIndex == indexPath.row {
                if self.isExspand == true {
                    isExspand = false
                }else{
                    isExspand = true
                }
            }
            
            isSelectIndex = indexPath.row
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
        
        case .Version :    

            
            if MgVM().isAppVersionSmallerThan(storeVersion: Shared.c_inform_ver){
                if let url = URL(string: Shared.New_MG?.c_appstore_url ?? "") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    print("Can not open url a \n\(Shared.New_MG?.c_appstore_url ?? "")")
                }
            }
            }else{
             
            }
     
            print("Hello world")
        default: break
        }
       
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let section = ProfileSection(rawValue: indexPath.section)
        switch section {
        case .Profile:
            switch indexPath.row {
            case 0:
                let cell = tableView.cellForRow(at: indexPath) as! ProfileCell
                cell.vContainer.backgroundColor = .white
            case 1:
                let cell = tableView.cellForRow(at: indexPath) as! ProfileCell
                cell.vContainer.backgroundColor = UIColor(hexString: "F5F9FC")
            default:
                let cell = tableView.cellForRow(at: indexPath) as! ProfileCell
                cell.vContainer.backgroundColor = .white
            }
        case .CompanyProfile :
//            let cell = tableView.cellForRow(at: indexPath) as! QRTaxCell
//            cell. backgroundColor = UIColor(hexString: "F5F9FC")
            print("Highlight")
            
            
        case .Version:
            let cell = tableView.cellForRow(at: indexPath) as! ProfileCell
            cell.vContainer.backgroundColor = .white
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        
        
        let section = ProfileSection(rawValue: indexPath.section)
        switch section {
        case .Profile:
            switch indexPath.row {
            case 0:
                let cell = tableView.cellForRow(at: indexPath) as! ProfileCell
                cell.vContainer.backgroundColor = .white
            case 1:
                let cell = tableView.cellForRow(at: indexPath) as! ProfileCell
                cell.vContainer.backgroundColor = .white
            default:
                let cell = tableView.cellForRow(at: indexPath) as! ProfileCell
                cell.vContainer.backgroundColor = .white
            }
        case .CompanyProfile :
            let cell = tableView.cellForRow(at: indexPath) as! QRTaxCell
//            cell.bkgView.backgroundColor = .white
            
            
        case .Version:
            let cell = tableView.cellForRow(at: indexPath) as! ProfileCell
            cell.vContainer.backgroundColor = .white
        default: break

        }

    }
}

//MARK: - API
extension ProfileVC {
    
    //GENERATE QRCODE WITH LOGO
    func generateQRCodeWithLogo(from string: String, logo: UIImage? = nil) -> UIImage? {
        guard let qrFilter  = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let qrData          = string.data(using: String.Encoding.utf8)
        qrFilter.setValue(qrData, forKey: "inputMessage")
        
        let qrTransform     = CGAffineTransform(scaleX: 12, y: 12)
        let qrImage         = qrFilter.outputImage?.transformed(by: qrTransform)

        if let logoCiImage  = logo?.cgImage {
            _ = qrImage?.combined(with: CIImage(cgImage: logoCiImage))
        }

        return UIImage(ciImage: qrImage!)
    }
     
    func showAlertLogout() {
        self.customAlert(type      : .YES_OR_NO_ALERT,
                         image     : "badge_warning",
                         title     : "log_out".localized.camelCased,
                         message   : "main_logout_msg".localized,
                         redTitle  : "log_out".localized.camelCased,
                         greyTitle : "cancel".localized) { (isRedBtn) in
            if isRedBtn { //Pressed Logout
                self.callLogoutAPI() //call logout API
            }
        }
    }
    
    func callLogoutAPI() {
        profileVM.logOut(Device_ID: UIDevice.current.identifierForVendor?.uuidString ?? "") { (result) in
            switch result {
            case .success(_):
                let loginVC = self.VC(sbName: "LoginSB", identifier: "LoginNav") as! UINavigationController
                
                //clear credentials for current service
                KeychainManager.deleteCredential("username")
                KeychainManager.deleteCredential("password")
                
                UserDefaults.standard.removeObject(forKey: "bizKey")
                MyDefaults.set(key: .autoLogin, value: false)
                
                UIApplication.shared.applicationIconBadgeNumber = 0
                UNUserNotificationCenter.current().removeAllDeliveredNotifications() // For removing all delivered notification
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // For removing all pending notifications which are not delivered yet but scheduled.

                self.setRootNavViewController(navigation: loginVC, direction: .toRight)
                
            case .failure(let error):
                
                    if error.code == 1004 { //no internet connection
                        self.showCustomAlert(imgStr: "badge_no_internet-1", titlte: "connection_is_unstable".localized, message: "connection_is_unstable_please_try_again_later".localized) {
                            self.callLogoutAPI()
                        }
                    } else {
                        self.showCustomAlert(titlte: "notice".localized, message: error.localizedDescription) {
                            
                        }
                    }
               
            }
        }
    }
    
    
    

    
}



//MARK: - @objc
extension ProfileVC {
    
    @objc func didCollapseExspandPersonalInfo(sender: UIButton) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! QRTaxCell
        sender.isSelected.toggle()
        isSelectedPersonalInfo = sender.isSelected
        
        let isSelected = sender.isSelected
        if isSelected{
            //rotate image
//            cell.transform = CGAffineTransform(rotationAngle: .pi)

        }else{
//            cell.transform  = CGAffineTransform.identity
        }
       
        UIView.animate(withDuration: 0.05) {
            self.tableView.reloadData()
            
        }

    }
    

}

//MARK: - Custom QRCode with Logo
extension CIImage {

    /// Combines the current image with the given image centered.
    func combined(with image: CIImage) -> CIImage? {
        guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        let centerTransform = CGAffineTransform(translationX: extent.midX - (image.extent.size.width / 2), y: extent.midY - (image.extent.size.height / 2))
        combinedFilter.setValue(image.transformed(by: centerTransform), forKey: "inputImage")
        combinedFilter.setValue(self, forKey: "inputBackgroundImage")
        return combinedFilter.outputImage!
    }
    
}

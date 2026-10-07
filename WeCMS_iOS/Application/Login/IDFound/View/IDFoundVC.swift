//
//  ForgotIDVC.swift
//  WeCMS_iOS
//
//  Created by Nyta on 18/5/21.
//

import UIKit

class IDFoundVC: UIViewController {

    @IBOutlet weak var lblIDFound       : UILabel!
    @IBOutlet weak var lblIDList        : UILabel!
    @IBOutlet weak var myTableView      : UITableView!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnLogin         : UIButton!
    @IBOutlet weak var btnBack          : UIButton!
    
    var USER_NM                         : String = ""
    var CRTC_INFO                       : String = ""
    var CRTC_TYPE                       : String = ""
    var REG_SEQ_NO                      : Int    = 0
    
    var countryCode : String = ""
    
    //Variable to check if user has selected any cell
    var isChoosen : Bool = true
    
    let IDFoundVm = IDFoundVM()
    
    //Create empty array to store ID data
    var arrayID   : [MREC_MBMR_0002_R003.RESPONE.REC] = []
    
    //Variable to get data in first selected row
    var indexPathCell   : Int?
        
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarStyle(isHidden: false, animated: true, title: "", leftBarButtonImage: "arrow_back", tintColor: "#0069B9", leftSelector: #selector(dismissAction))
        setupView()
    }
  
    //MARK: - Private Function
    private func setupView() {
        localizeText()
        localizeFont()
        choose()
    }
    
    private func localizeText(){
        lblIDFound.font = UIFont(name: "Inter-Bold", size: 21)
        lblIDFound.text     = "id_found".localized
        lblIDList.text      = "ids_that_match_your_information".localized
        
        btnLogin.isEnabled  = true
        btnLogin.setTitle("log_in".localized, for: .normal)

        btnForgotPassword.setTitle("forget_password".localized, for: .normal)
    }
    
    private func localizeFont(){
        lblIDFound.getlocalizedFont()
        lblIDList.getlocalizedFont()
        btnLogin.getlocalizedFont()
        btnForgotPassword.getlocalizedFont()
    }
    
    @objc func dismissAction() {
        popOrDismissVC()
    }
    
    private func goToLogin(){
        let vc = self.VC(sbName: "LoginSB", identifier: "LoginVC") as! LoginVC
        Shared.user_id = arrayID[indexPathCell ?? 0].USER_ID.replace(of: "**", with: "om")
        self.pushVC(viewController: vc)
    }
    
    private func goToForgotPassword(){
        
        //Format USER_ID
        let replaceUserID: String = arrayID[indexPathCell ?? 0].USER_ID
        let formatUSER_ID = replaceUserID.replace(of: "**", with: "om")
    
        let vc = self.VC(sbName: "ForgotSB", identifier: "ForgotVC") as! ForgotVC
        
        self.CRTC_INFO = arrayID[indexPathCell ?? 0].CLPH_NO
        let index = arrayID[indexPathCell ?? 0].CLPH_NO.index(arrayID[indexPathCell ?? 0].CLPH_NO.startIndex, offsetBy: 5)
        
        //Pass data to another VC
        vc.vcType       = .Forget_Password
        vc.USER_ID      = formatUSER_ID
//        vc.USER_NM      = self.USER_NM
//        vc.CRTC_INFO    = self.CRTC_INFO
        vc.USER_NM      = arrayID[indexPathCell ?? 0].USER_NM
        vc.CRTC_INFO    = String(self.CRTC_INFO.suffix(from: index))
        
        vc.isEnable     = true
        vc.countryCode  = self.countryCode
        self.pushVC(viewController: vc)
    }
    //User select any row
    private func choose(){
        isChoosen = true
        if isChoosen{
            //Enable Login Button with background color
            btnLogin.isEnabled = true
            btnLogin.backgroundColor    = UIColor(hexString: "0069B9")
        }
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        goToLogin()
    }
    
    @IBAction func actionLogin(_ sender: UIButton) {
        goToLogin()
    }
    @IBAction func actionForgotPassword(_ sender: UIButton) {
        goToForgotPassword()
    }
}

//MARK: - TableViewDelegate & TableViewDataSource
extension IDFoundVC: UITableViewDelegate, UITableViewDataSource{
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayID.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "cell") as! IDFoundCell
        
        //display data in cell
        var data = arrayID[indexPath.row].USER_ID
        let endIndex = data.index(data.endIndex, offsetBy: -2) // Get last 2 index
        data.replaceSubrange(endIndex..., with: "**") // Replace last 2 index with **
        cell.lblID.text     = data
        cell.lblDate.text   = "\("subscribed_on".localized) \(formatteDate(date: arrayID[indexPath.row].REG_DTM))"
        
        //Set selected first row as default
        self.myTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexPathCell = indexPath.row
        choose()
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = myTableView.cellForRow(at: indexPath) as! IDFoundCell
        
        choose()
        
        cell.view.backgroundColor = UIColor(hexString: "EBF7FF")
        cell.view.borderColor     = UIColor(hexString: "0069B9")
        cell.view.borderWidth     = 1
        cell.lblID.textColor = UIColor(hexString: "0069B9")
        cell.btnCircle.setImage(UIImage(named: "def_radio_on"), for: .normal)
    }
}

//MARK: - TableViewCell
class IDFoundCell: UITableViewCell{
    
    @IBOutlet weak var lblID        : UILabel!
    @IBOutlet weak var lblDate      : UILabel!
    @IBOutlet weak var btnCircle    : UIButton!
    @IBOutlet weak var view         : UIView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

            //Change background color when the cell is selected
             if isSelected {
                self.view.backgroundColor = UIColor(hexString: "EBF7FF")
                self.view.borderColor     = UIColor(hexString: "0069B9")
                self.view.borderWidth     = 1
                lblID.textColor = UIColor(hexString: "0069B9")
                btnCircle.setImage(UIImage(named: "def_radio_on"), for: .normal)
             } else {
                self.contentView.backgroundColor = .white
                self.view.backgroundColor = UIColor(hexString: "FFFFFF")
                self.view.borderColor     = UIColor(hexString: "ECEFF1")
                self.view.borderWidth     = 1
                lblID.textColor = UIColor(hexString: "494949")
                btnCircle.setImage(UIImage(named: "def_radio_off"), for: .normal)
             }
    }
    
    override func awakeFromNib() {
        self.lblID.font = UIFont(name: "Inter-Medium", size: 15)
        self.lblID.font = UIFont(name: "Inter-Medium", size: 13)
    }
}

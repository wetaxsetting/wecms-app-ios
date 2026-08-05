//
//  AddOtherExpenseVC.swift
//  WABOOKS_iOS_V2
//
//  Created by SteveChea  on 12/3/24.
//

import UIKit

import IQKeyboardManagerSwift

class AddOtherExpenseVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var submitBtnView: UIView!
    
    var completion : () -> Void = {}
    var addOtherExpenseVM   = AddOtherExpenseVM()

    var clientData : [Client.ContentBody] = []
    var dataManualExpense: ApprovalContent?
    var dataDetailExpense: WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1?
    var dataEditExpense : EditArticleData?
    var dataR002: WABOOKSStruct.RECDoc_Protocol?
    var isEditManual    = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarStyle(isHidden: true, animated: true, title: "")
        // Sheet detents are configured by the presenter
        IQKeyboardManager.shared.resignOnTouchOutside = true
    }
    
    private func setupView(){
        self.titleLb.getlocalizedFont()
        
        self.addOtherExpenseVM.initCells()
        
        if self.isEditManual == "E"{
            self.titleLb.text = "add_other_expense".localized
            self.saveBtn.isHidden = false
            setDataManual()
            
        }else if self.isEditManual == "LIST_EXPENSE"{
            self.titleLb.text = "add_other_expense".localized
            self.saveBtn.isHidden = false
            setDataManualFromListExpense()
            
        }else if self.isEditManual == "VIEW_DETAIL"{
            self.titleLb.text = "other_expense".localized
            self.saveBtn.isHidden = true
            setDataEditExpense()
            
        }else if self.isEditManual == "EDIT_EXPENSE"{
            self.titleLb.text = "other_expense".localized
            self.saveBtn.isHidden = true
            setDataExpenseListExpense()
            
        }else if self.isEditManual == "EXPENSE_APPROVAL_VC"{
            self.titleLb.text = "other_expense".localized
            self.saveBtn.isHidden = true
            dataFromR002()
            
        }else{
            self.titleLb.text = "add_other_expense".localized
        }
        
        checkingRequireField()
        self.tableView.register(UINib(nibName: "PurposeCell", bundle: nil), forCellReuseIdentifier: "PurposeCell")
        self.tableView.register(UINib(nibName: "CurrencyCell", bundle: nil), forCellReuseIdentifier: "CurrencyCell")
        self.tableView.register(UINib(nibName: "DescriptionCell", bundle: nil), forCellReuseIdentifier: "DescriptionCell")
    }
    
    private func isCheckSaveBtn(isDisable: Bool = false) {
        self.saveBtn.borderWidth = 1
        self.saveBtn.backgroundColor  = UIColor(hexString: isDisable ?"#0069B9": "#FAFAFA")
        self.saveBtn.isEnabled        = isDisable ? true : false
        self.saveBtn.borderColor      = isDisable ? UIColor(hexString: "#0069B9") : UIColor(hexString: "#D9D9D9")
        self.saveBtn.setTitleColor(UIColor(hexString: isDisable ? "#FFFFFF" : "#A6A6A6"), for: .normal)
    }
    
    private func getFullscreenHeight() -> CGFloat {
        let statusBarManager = UIApplication.shared.statusBarManagerInConnectedScenes
        let statusBarHeight = statusBarManager?.statusBarFrame.height ?? 0
        let fullscreenHeight = UIScreen.main.bounds.height - statusBarHeight
        return fullscreenHeight
    }
    
    private func checkingRequireField(){
        let isCheckPurpose = self.addOtherExpenseVM.getkey(rowType: .PURPOSE).isEmpty ? false : true
        let isCheckContact = self.addOtherExpenseVM.getkey(rowType: .CONTACT).isEmpty ? false : true
        let isCheckAmount = self.addOtherExpenseVM.getkey(rowType: .AMOUNT).isEmpty ? false : true
        let checkAllField = (isCheckPurpose == true && isCheckContact == true && isCheckAmount == true) ? true : false
        isCheckSaveBtn(isDisable: checkAllField)
    }
    
    private func setDataManualFromListExpense(){
        self.addOtherExpenseVM.setValue(rowType: .PURPOSE, value: dataDetailExpense?.USAG_NM, key: dataDetailExpense?.BUSA_USAG_CD)
        self.addOtherExpenseVM.setValue(rowType: .CONTACT, value: dataDetailExpense?.TRCO_NICK_NM, value2: dataDetailExpense?.TRCO_CMNM, otherValue: dataDetailExpense?.TRCO_CMENM, key: dataDetailExpense?.TRCO_KEY)
        self.addOtherExpenseVM.setValue(rowType: .CURRENCY, key: dataDetailExpense?.CCY_CD)
        self.addOtherExpenseVM.setValue(rowType: .AMOUNT, value2: dataDetailExpense?.AMT , key: dataDetailExpense?.AMT)
        self.addOtherExpenseVM.setValue(rowType: .DESCRIPTION, key: dataDetailExpense?.MEMO)
        self.tableView.reloadData()
    }
    
    private func setDataManual(){
        self.addOtherExpenseVM.setValue(rowType: .PURPOSE, value: dataManualExpense?.Description, key: dataManualExpense?.BUSA_USAG_CD)
        self.addOtherExpenseVM.setValue(rowType: .CONTACT, value: dataManualExpense?.nickName,value2: dataManualExpense?.Title, otherValue: dataManualExpense?.TRCO_CMENM, key: dataManualExpense?.TRCO_KEY)
        self.addOtherExpenseVM.setValue(rowType: .CURRENCY, key: dataManualExpense?.CCY_CD)
        self.addOtherExpenseVM.setValue(rowType: .AMOUNT, value2: dataManualExpense?.Value , key: dataManualExpense?.Value)
        self.addOtherExpenseVM.setValue(rowType: .DESCRIPTION, key: dataManualExpense?.MEMO)
        self.tableView.reloadData()
    }
    
    private func setDataEditExpense(){
        self.addOtherExpenseVM.setValue(rowType: .PURPOSE, value: dataEditExpense?.decription)
        self.addOtherExpenseVM.setValue(rowType: .CONTACT, value: dataEditExpense?.title)
        self.addOtherExpenseVM.setValue(rowType: .CURRENCY, key: dataEditExpense?.CCY_CD) //CCY_CD
        self.addOtherExpenseVM.setValue(rowType: .AMOUNT, value2: dataEditExpense?.Value) // AMOUNT
        self.addOtherExpenseVM.setValue(rowType: .DESCRIPTION, key: dataEditExpense?.MEMO)
        self.tableView.reloadData()
    }
    
    private func setDataExpenseListExpense(){
        self.addOtherExpenseVM.setValue(rowType: .PURPOSE, value: dataDetailExpense?.USAG_NM)
        self.addOtherExpenseVM.setValue(rowType: .CONTACT, value: dataDetailExpense?.TRCO_CMENM)
        self.addOtherExpenseVM.setValue(rowType: .CURRENCY, key: dataDetailExpense?.CCY_CD)
        self.addOtherExpenseVM.setValue(rowType: .AMOUNT, value2: dataDetailExpense?.AMT , key: dataDetailExpense?.AMT)
        self.addOtherExpenseVM.setValue(rowType: .DESCRIPTION, key: dataDetailExpense?.MEMO)
        self.tableView.reloadData()
    }
    
    private func dataFromR002(){
        self.addOtherExpenseVM.setValue(rowType: .PURPOSE, value: dataR002?.USAG_NM)
        self.addOtherExpenseVM.setValue(rowType: .CONTACT, value: dataR002?.TRCO_CMENM)
        self.addOtherExpenseVM.setValue(rowType: .CURRENCY, key: dataR002?.CCY_CD)
        self.addOtherExpenseVM.setValue(rowType: .AMOUNT, value2: dataR002?.AMT , key: dataR002?.AMT)
        self.addOtherExpenseVM.setValue(rowType: .DESCRIPTION, key: dataR002?.MEMO)
        self.tableView.reloadData()
    }
    
    @IBAction func SaveBtnAction(_ sender: UIButton) {
        // Purpose
        let user_cd = self.addOtherExpenseVM.getkey(rowType: .PURPOSE)
        let user_nm     = self.addOtherExpenseVM.getValue(rowType: .PURPOSE)
        // Contact
        let contact_cd = self.addOtherExpenseVM.getkey(rowType: .CONTACT)
        let contact_nm = self.addOtherExpenseVM.getValue(rowType: .CONTACT)
        let trco_cmnm = self.addOtherExpenseVM.getTRCO_CMNM(rowType: .CONTACT)
        let trco_cmenm = self.addOtherExpenseVM.getTRCO_CMENM(rowType: .CONTACT)
        
        let amount = self.addOtherExpenseVM.getkey(rowType: .AMOUNT)
        let currency = self.addOtherExpenseVM.getkey(rowType: .CURRENCY)
        let desc = self.addOtherExpenseVM.getkey(rowType: .DESCRIPTION)
        
        let dataManual = [user_nm, user_cd, contact_nm, contact_cd, trco_cmnm, trco_cmenm, currency, amount, desc, isEditManual, self.clientData] as [Any]
        MyNotify.send(name: .getDataAddManual, object: dataManual as AnyObject)
        MyNotify.send(name: .clientData, object: self.clientData as AnyObject)
        self.dismiss(animated: true)
    }
}

extension AddOtherExpenseVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addOtherExpenseVM.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = self.addOtherExpenseVM.cells[indexPath.row].rowType
        switch rowType{
        case .PURPOSE, .CONTACT:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PurposeCell", for: indexPath) as! PurposeCell
            cell.configCell(data: self.addOtherExpenseVM.cells[indexPath.row], isEditManual: self.isEditManual)
            return cell
            
        case .CURRENCY, .AMOUNT:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyCell
            cell.txtField.delegate = self
            cell.configCell(data: self.addOtherExpenseVM.cells[indexPath.row], CCY_CD: self.addOtherExpenseVM.getkey(rowType: .CURRENCY), isEditManual: self.isEditManual)
            return cell
        
        case .DESCRIPTION:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! DescriptionCell
            cell.textView.delegate = self
            cell.configCell(data: self.addOtherExpenseVM.cells[indexPath.row], isEditManual: self.isEditManual)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowType = self.addOtherExpenseVM.cells[indexPath.row].rowType
        switch rowType{
        case .PURPOSE:
            let vc = VC(sbName: "SelectPurposeSB", identifier: "SelectPurposeVC") as! SelectPurposeVC
            vc.delegate                 = self
            vc.headerTitle              = "select_a_purpose".localized
            vc.selectUserListKey        = self.addOtherExpenseVM.getkey(rowType: .PURPOSE)
            vc.isShowPlanned_money      = true
            vc.isShowOnlyPlanned_money  = false
            vc.modalPresentationStyle = .custom
            self.present(vc, animated: true)
            
        case .CONTACT:
            let vc = VC(sbName: "ClientSB", identifier: "ClientVC") as! ClientVC
            vc.clientData       = self.clientData
            vc.copyClientData   = self.clientData
            vc.isFromAddOtherExpense = true

            let title =  self.addOtherExpenseVM.cells[indexPath.row].value.title
            let key =  self.addOtherExpenseVM.cells[indexPath.row].value.key
            
            vc.itemKey = key ?? ""
            vc.itemTitle = title ?? ""

            vc.completion   = { data, clientData, isSearching, isManualInput in
                self.clientData = clientData
                if data.TRSC_CCY_CD != self.addOtherExpenseVM.getkey(rowType: .CURRENCY){
                    self.addOtherExpenseVM.setValue(rowType: .AMOUNT, value2: "", key: "")
                }
                self.addOtherExpenseVM.setValue(rowType: .CONTACT, value: data.l_text, value2: data.TRCO_CMNM, otherValue: data.TRCO_CMENM, key: data.TRCO_KEY)
                self.addOtherExpenseVM.setValue(rowType: .CURRENCY, key: data.TRSC_CCY_CD)
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0), IndexPath(row: 3, section: 0)], with: .none)
                self.checkingRequireField()
            }
            let nav = UINavigationController()
            nav.viewControllers = [vc]
            nav.navigationBar.isHidden = false
            nav.modalPresentationStyle = .custom
            self.present(nav, animated: true)
           
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType = self.addOtherExpenseVM.cells[indexPath.row].rowType
        switch rowType{
        case .PURPOSE, .CONTACT, .CURRENCY, .AMOUNT:
            return 56
        
        case .DESCRIPTION:
            return 180
            
        default:
            return UITableView.automaticDimension
        }
    }
}

extension AddOtherExpenseVC: UITextFieldDelegate{

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let tempText = textField.text, let textRange = Range(range, in: tempText) {
            let newLength = tempText.count + string.count - range.length
            
            switch textField.tag {
            case 2:  //Amount
                return newLength <= 15
            default: break
            }
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField.tag {
        case 2:  //Amount
            var text = textField.text ?? ""
            let cleanedString = textField.text?.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: nil)
            
            if  self.addOtherExpenseVM.getkey(rowType: .CURRENCY) == "KHR"{
                textField.text = text.khrCurrencyFormatter()
                
            }else if self.addOtherExpenseVM.getkey(rowType: .CURRENCY) == "USD" {
                
                let lastStr = "" + text.suffix(1) // convert to string
                if text.contains(".") {
                    let strDevide = text.components(separatedBy: ".")
                    if let valueBeforeDot = Double(strDevide[0].replacingOccurrences(of: ",", with: "")) {
                        
                        text = formattingNumber(valueBeforeDot) + "." + ((strDevide[1].prefix(2)).replacingOccurrences(of: ",", with: ""))
                    }
                }
                else if lastStr.contains(",") { // version upper 14.4
                    text = text.dropLast() + "."
                }
                else {
                    if let value = Double(text.replacingOccurrences(of: ",", with: "")) {
                        text = formattingNumber(value)
                    }
                }
                textField.text  = text
                
            }else{
                textField.text = text.vndCurrencyFormatter()
            }
           
            self.addOtherExpenseVM.setValue(rowType: .AMOUNT, value2: textField.text, key: cleanedString)
            checkingRequireField()

        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
    }
}

extension AddOtherExpenseVC: UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let newText = currentText.replacingCharacters(in: range, with: text)
        return newText.count <= 200 ? true : false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.addOtherExpenseVM.setValue(rowType: .DESCRIPTION, key: textView.text)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.endEditing(true)
    }
}


extension AddOtherExpenseVC: SelectPurposeDelegate{
    
    func sendProjectREC(rec: LIST_POP_UP_RESPONSE.PROJECT_SITE_LIST) {
        self.addOtherExpenseVM.setValue(rowType: .PURPOSE, value: rec.PRJT_NM, key: rec.PRJT_NO)
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        checkingRequireField()
    }
    
    // PURPOSE
    func sendRECItem(rec: LIST_POP_UP_RESPONSE.REC , type: POPUP_TYPE) {
        self.addOtherExpenseVM.setValue(rowType: .PURPOSE, value: rec.USAG_NM, key: rec.USE_USAG_CD)
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        checkingRequireField()
    }
    
    // Advance Legder
    func sendREC2Item(rec2: LIST_POP_UP_RESPONSE.REC2) {
    }
    
    // PURPOSE
    func sendUserListItem(userList: LIST_POP_UP_RESPONSE.USE_LIST) {
        self.addOtherExpenseVM.setValue(rowType: .PURPOSE, value: userList.USAG_NM, key: userList.USE_USAG_CD)
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        checkingRequireField()
    }
}

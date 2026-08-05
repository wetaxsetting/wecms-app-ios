//
//  ExpenseListVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Seanghay Huort on 13/3/24.
//

import UIKit

typealias Completion_DetailExpense  = ([WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1])          -> Void

class ExpenseListVC: UIViewController {

    @IBOutlet weak var tableView    : UITableView!
    @IBOutlet weak var titleLabel   : UILabel!
    @IBOutlet weak var backButton   : UIButton!
    
    var dataExpense  : [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1] = []
    var didExpenseCompletion    : Completion_DetailExpense = {_ in}
    var clientData : [Client.ContentBody] = []
    var selectedIndex  = 0
    var isCreate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = "\(dataExpense.count) " + "expenses".localized
        self.titleLabel.getlocalizedFont()
        self.tableView.register(UINib(nibName: "ExpenseItemCell", bundle: nil), forCellReuseIdentifier: "ExpenseItemCell")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.didExpenseCompletion(self.dataExpense)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkingNotify()
    }
    
    @IBAction func didTapBackAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func checkingNotify() {
        MyNotify.listen(self, selector: #selector(getDataAddManual), name: .getDataAddManual)
        MyNotify.listen(self, selector: #selector(getClientData), name: .clientData)
    }
    
    @objc func getDataAddManual(_ notification: Notification){
        let noti = notification.object as? [Any]
        
        if noti?[9] as! String == "LIST_EXPENSE" {
            self.dataExpense.remove(at: selectedIndex)
            self.dataExpense.insert(WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1(TRCO_KEY: "\(noti?[3] ?? "")", TRCO_NICK_NM: "\(noti?[2] ?? "")", TRCO_CMNM: "\(noti?[4] ?? "")", TRCO_CMENM: "\(noti?[5] ?? "")", CCY_CD: "\(noti?[6] ?? "")", AMT: "\(noti?[7] ?? "")", BUSA_USAG_CD: "\(noti?[1] ?? "")", MEMO: "\(noti?[8] ?? "")", DOC_ID: "", DOC_TYPE: "", USAG_NM: "\(noti?[0] ?? "")"), at: selectedIndex)
        }
        self.tableView.reloadData()
    }
    
    @objc func getClientData(_ notification: Notification){
        let noti = notification.object
        self.clientData = noti as! [Client.ContentBody]
    }
}

extension ExpenseListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataExpense.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseItemCell", for: indexPath) as! ExpenseItemCell
        cell.configPOPCell(data: self.dataExpense[indexPath.row], isCreate: self.isCreate)
        
        if isCreate{
            cell.purposeButton.didTap {
                self.selectedIndex          = indexPath.row
                let vc                      = self.VC(sbName: "SelectPurposeSB", identifier: "SelectPurposeVC" ) as! SelectPurposeVC
                vc.delegate                 = self
                vc.selectUserListKey        = self.dataExpense[indexPath.row].BUSA_USAG_CD ?? ""
                vc.isShowPlanned_money      = true
                vc.isShowOnlyPlanned_money  = false
                vc.headerTitle              = "select_a_purpose".localized
                vc.modalPresentationStyle = .custom
                self.present(vc, animated: true)
            }
            
            cell.purposeDropButton.didTap {
                self.selectedIndex          = indexPath.row
                let vc                      = self.VC(sbName: "SelectPurposeSB", identifier: "SelectPurposeVC" ) as! SelectPurposeVC
                vc.delegate                 = self
                vc.selectUserListKey        = self.dataExpense[indexPath.row].BUSA_USAG_CD ?? ""
                vc.isShowPlanned_money      = true
                vc.isShowOnlyPlanned_money  = false
                vc.headerTitle              = "select_a_purpose".localized
                vc.modalPresentationStyle = .custom
                self.present(vc, animated: true)
            }
            
            cell.deleteButton.didTap {
                let tempData1 = OptionPopupWithoutTitleModel(title: "delete".localized)
                let tempData2 = OptionPopupWithoutTitleModel(title: "Don't_delete".localized)
                let data = [tempData1, tempData2]
                let title = "delete_expense?".localized
                self.switchOption(optionData: data, title: title, description: "this_action_cannot_be_undone.".localized) { str in
                    if str == "delete".localized {
                        self.dataExpense.remove(at: indexPath.row)
                        self.titleLabel.text = "\(self.dataExpense.count) " + "expenses".localized
                        self.tableView.reloadData()
                        self.dismiss(animated: true)
                    }else{
                        self.dismiss(animated: true)
                    }
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.dataExpense[indexPath.row]
        if self.dataExpense[indexPath.row].DOC_TYPE == "E"{
            let vc = UIStoryboard(name: "ReceiptDetailsSB", bundle: nil).instantiateViewController(withIdentifier: "ReceiptDetailsVC") as! ReceiptDetailsVC
            vc.doc_id = self.dataExpense[indexPath.row].DOC_ID ?? ""
            vc.usag_nm = self.dataExpense[indexPath.row].USAG_NM ?? ""
            vc.isRequestApproval = true
            vc.isFromExpenseApproval = true
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .custom
            self.present(nav, animated: true)
            
        }else if self.dataExpense[indexPath.row].DOC_TYPE == "" || self.dataExpense[indexPath.row].DOC_TYPE == nil{
            self.selectedIndex           = indexPath.row
            self.popAddOtherManual(dataDetailExpense: data, clientData: self.clientData,  isEditManual: self.isCreate == true ? "LIST_EXPENSE" :  "EDIT_EXPENSE")
        }
    }
}

extension ExpenseListVC: SelectPurposeDelegate {
    
    // Project/Site
    func sendProjectREC(rec: LIST_POP_UP_RESPONSE.PROJECT_SITE_LIST) {
        self.dataExpense[selectedIndex].BUSA_USAG_CD = rec.PRJT_NO
        self.dataExpense[selectedIndex].USAG_NM = rec.PRJT_NM
        self.tableView.reloadData()
    }
    
    
    //Purpose
    func sendRECItem(rec: LIST_POP_UP_RESPONSE.REC, type: POPUP_TYPE) {
        //Note: selectedIndex => get specific row
        self.dataExpense[selectedIndex].BUSA_USAG_CD = rec.USE_USAG_CD
        self.dataExpense[selectedIndex].USAG_NM = rec.USAG_NM
        self.tableView.reloadData()
    }
    
    func sendREC2Item(rec2: LIST_POP_UP_RESPONSE.REC2) {
        //
    }
    
    func sendUserListItem(userList: LIST_POP_UP_RESPONSE.USE_LIST) {
        self.dataExpense[selectedIndex].BUSA_USAG_CD = userList.USE_USAG_CD
        self.dataExpense[selectedIndex].USAG_NM = userList.USAG_NM
        self.tableView.reloadData()
    }
}

extension UIViewController  {

    func expenseListPop(optionData: [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1], clientData: [Client.ContentBody] = [], isCreate: Bool = false, completion: @escaping Completion_DetailExpense = {_ in}) {
        
        let vc = self.VC(sbName: "ExpenseListSB", identifier: "ExpenseListVC") as! ExpenseListVC
        vc.clientData = clientData
        let numberOfItem = optionData.count
        vc.dataExpense = optionData
        vc.isCreate     = isCreate
        let spaces       = 60 // top & bottom spaces
        let cellHeight   = 102 * numberOfItem // 102 is height of one cell, multiples with item count to get all cells height
        let totalHeight  = CGFloat(cellHeight + spaces)
        
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in totalHeight }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = true
        }
        
        vc.didExpenseCompletion = { option in
            completion(option)
//            self.dismiss(animated: true)
        }
        
        self.present(vc, animated: true, completion: nil)
    }
}

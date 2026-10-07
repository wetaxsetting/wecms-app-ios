//
//  SearchBoardWeCMSVC.swift
//  WeCMS_iOS
//
//  Created by lymanny on 16/1/25.
//
//  Note: This class was adapted from SearchBoardVC
//  Some conditions and methods have been modified to fit the requirements of the SearchBoardWeCMS feature.

import UIKit


class SearchBoardWeCMSVC: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var tableView      : UITableView!
    @IBOutlet weak var textfield      : UITextField!
    @IBOutlet weak var clearButton    : UIButton!
    @IBOutlet weak var filterDateView : UIView!
    @IBOutlet weak var dateLabel      : UILabel!
    @IBOutlet weak var sectionLB      : UILabel!
    
    //MARK: - Properties & Variable
    var searchVM        = SearchVM()
    var BLTB_CD         : String = ""
    var selectedDate    : DateFilterModel?
    var searchText      : String = ""

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.dateFilterPressed))
        self.filterDateView.addGestureRecognizer(gesture)
        self.clearButton.isHidden = true
        searchVM.BLTB_CD = BLTB_CD
        textfield.delegate = self
        registerCell()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.fetchInitialData()
        checkingNotify()
    }
    
    //MARK: - @IBAction
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        textfield.text = ""
        clearButton.isHidden = true
        searchVM.content = []
        self.tableView.reloadData()
    }
    
    //MARK: - Function
    private func setupView() {
        self.textfield.getlocalizedFont()
        self.sectionLB.getlocalizedFont()
        self.dateLabel.getlocalizedFont()
        self.textfield.placeholder = "search".localized
        self.sectionLB.text = "quick_results".localized
        self.dateLabel.text = "date_filter".localized
        self.textfield.getlocalizedFont()
        self.sectionLB.getlocalizedFont()
    }
    
    func registerCell() {
        tableView.register(UINib(nibName: "FullContentWeCMSCell", bundle: nil), forCellReuseIdentifier: "FullContentWeCMSCell")
        tableView.register(UINib(nibName: "LineFooterCell", bundle: nil), forCellReuseIdentifier: "LineFooterCell")
    }
    
    func fetchInitialData() {
        searchVM.PAGE_NO = 1
        searchVM.isShowLoading = true
        
        searchVM.fetchSearch(SRCH_WD: "", FROM_DT: selectedDate?.value.fromDate ?? "", TO_DT: selectedDate?.value.toDate ?? "") { result in
            switch result {
            case .success(_):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.searchVM.initData()
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func checkingNotify() {
        MyNotify.listen(self, selector: #selector(reloadAfterDeleteOrUpdate), name: .GotoSearch)
    }
    
    private func getFullscreenHeight() -> CGFloat {
        let statusBarManager = UIApplication.shared.statusBarManagerInConnectedScenes
        let statusBarHeight = statusBarManager?.statusBarFrame.height ?? 0
        let fullscreenHeight = UIScreen.main.bounds.height - statusBarHeight
        return fullscreenHeight
    }
    
    //MARK: - OBJC
    @objc func reloadAfterDeleteOrUpdate(noti: Notification){
        let noti = noti.object as? [String: String]
        switch noti?["SEARCH_BOARD"] {
        case "Delete", "Edit":
            self.fetchInitialData()
        default: break
        }
    }
    
    @objc func dateFilterPressed(sender : UITapGestureRecognizer) {
        self.tableView.tableHeaderView = nil
        self.tableView.tableFooterView = nil
        
        let vc = self.VC(sbName: "SelectOptionWithTitleSB", identifier: "SelectOptionWithTitleVC") as! SelectOptionWithTitleVC
        /*
         60      => top & bottom spaces
         58 * 4  => 58 is height of one cell, and 4 multiples with item count to get all cells height
         51      => is height header view

         Kept in step with the numbers SelectOptionWithTitleVC reports through
         `heightCompletion` (`spaces = 60`), so the sheet does not resize on the first tap.
         */
        var totalHeight  = CGFloat((58 * 4) + 60 + 51)
        vc.selectedDate = self.selectedDate
        vc.isFromSearch = true
        if let data = selectedDate {
            if data.rowType == .FilterMaually {
                totalHeight += 58 * 2
            }
        }
        
        vc.CompletionDidFinishSelectDate = { selectData in
            self.searchVM.PAGE_NO  = 1
            switch selectData.rowType{
            case . LastOneMonth, .LastThreeMonth, .LastSixMonth, .FilterMaually:
                self.selectedDate = selectData
                Shared.selectedDate   = selectData
                self.dateLabel.text = self.selectedDate?.value.Title
                self.tableView.tableHeaderView = self.view.createSpinnerFooter()
                self.searchVM.fetchSearch(FROM_DT: selectData.value.fromDate ?? "", TO_DT: selectData.value.toDate ?? "") { result in
                    switch result {
                    case .success(_):
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.searchVM.initData()
                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    self.tableView.tableHeaderView = nil
                }
                self.dismiss(animated: true)
                
            default: break
            }
        }
        
        // Fit the sheet to its real content — see the same fix in
        // BoardsWeCmsVC.filterButtonPressed for why the old `.large` jump was wrong.
        let fitSheet: () -> Void = {
            guard let sheet = vc.sheetPresentationController else { return }
            totalHeight = vc.fittedSheetHeight
            if #available(iOS 16.0, *) {
                sheet.animateChanges {
                    sheet.detents = [.custom { context in min(totalHeight, context.maximumDetentValue) }, .large()]
                }
            } else {
                sheet.animateChanges { sheet.selectedDetentIdentifier = .large }
            }
        }
        vc.heightCompletion = { _ in
            DispatchQueue.main.async(execute: fitSheet)
        }
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { context in min(totalHeight, context.maximumDetentValue) }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = true
        }
        self.present(vc, animated: true) { fitSheet() }
    }
    
    @objc func moreBtnAction(sender: UIButton){
        let point           = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath       = self.tableView.indexPathForRow(at: point)!
        
        let boardREC = self.searchVM.content[indexPath.section].content[indexPath.row].REC
        var moreBoardOption : [OptionPopupWithoutTitleModel] = []
        
        if Shared.R002_DATA?.USER_ID == boardREC.REG_ID && boardREC.POST_TYPE_CD == "01"  { // check edit article
            moreBoardOption.append(OptionPopupWithoutTitleModel(icon: "ico_pen", title: "Edit_\(boardREC.DRAFT_POST_SEQ_NO == nil ? "post" : "Draft")".localized))
        } else if Shared.R002_DATA?.USER_ID == boardREC.REG_ID && boardREC.POST_TYPE_CD == "02" && (boardREC.APPR_TYPE_CD == "00" || boardREC.DRAFT_POST_SEQ_NO != nil) { // check edit approval
            moreBoardOption.append(OptionPopupWithoutTitleModel(icon: "ico_pen", title: "Edit_\(boardREC.DRAFT_POST_SEQ_NO == nil ? "post" : "Draft")".localized))
        }
        
        if boardREC.DEL_YN == "Y" {
            moreBoardOption.append(OptionPopupWithoutTitleModel(icon: "ico_bin", title: "Delete_\(boardREC.DRAFT_POST_SEQ_NO == nil ? "post" : "Draft")".localized, isRedOption: true))
        }
        
        optionPopupWithoutTitle(optionData: moreBoardOption) { [self] option, _ in
            switch option {
            case "Edit_post".localized :
                self.dismiss(animated: true)
                let vc = VC(sbName: "EditArticleWeCMSSB", identifier: "EditArticleWeCMSVC") as! EditArticleWeCMSVC
                vc.boardREC = boardREC
                self.presetVC(vc: vc, modalPresentStyle: .overFullScreen)
                
            case "Delete_post".localized :
                self.dismiss(animated: true)
                let leftTitle = "Delete_post".localized
                let message = "This_action_can’t_be_undone".localized
                self.yesNoPopup(title: leftTitle, message: message, confirmTitle: "delete".localized, cancelTitle: "Don't_delete".localized, isDeletePopup: true) { confirm in
                    
                    if confirm {
                        self.dismiss(animated: true)
                        self.searchVM.deletePost(body: MREC_BLTB_0002_D001.REQUEST(POST_SEQ_NO: boardREC.POST_SEQ_NO, BLTB_CD: boardREC.BLTB_CD )){ erorr in
                            if erorr != nil {
                                // erorr
                                self.customAlert(message: erorr?.localizedDescription ?? "")
                            } else {
                                MyNotify.send(name: .GotoSearch, object: ["SEARCH_BOARD": "Delete"] as AnyObject)
                            }
                        }
                    } else {
                        self.dismiss(animated: true)
                    }
                }
                
            case "Edit_Draft".localized :
                self.navigationController?.isNavigationBarHidden = true
                let vc = UIStoryboard(name: "EditDraftWeCMSSB", bundle: nil).instantiateViewController(withIdentifier: "EditDraftWeCMSVC") as! EditDraftWeCMSVC
                vc.BLTB_CD              = boardREC.BLTB_CD ?? ""
                vc.DRAFT_POST_SEQ_NO    = boardREC.DRAFT_POST_SEQ_NO ?? ""
                vc.POST_TYPE_CD         = boardREC.POST_TYPE_CD ?? ""
                vc.approvalType         = .EXPENSEAPPROVAL
                vc.approvalPop          = .EXPENSEAPPROVAL
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated:true, completion:nil)
                
            case "Delete_Draft".localized :
                self.dismiss(animated: true)
                let leftTitle = "Delete Draft"
                let message = "This action can’t be undone."
                
                self.yesNoPopup(title: leftTitle, message: message, confirmTitle: "Delete", cancelTitle: "Don't delete", isDeletePopup: true) { confirm in
                    if confirm {
                        self.dismiss(animated: true)
                        self.searchVM.deleteDraftPost(body: MREC_BLTB_0002_D003.REQUEST(BLTB_CD: boardREC.BLTB_CD, DRAFT_POST_SEQ_NO: boardREC.DRAFT_POST_SEQ_NO)){ erorr in
                            if erorr != nil {
                                self.customAlert(message: erorr?.localizedDescription ?? "")
                            } else {
                                MyNotify.send(name: .GotoSearch, object: ["SEARCH_BOARD": "Delete"] as AnyObject)
                            }
                        }
                        
                    } else {
                        self.dismiss(animated: true)
                    }
                }
            default:
                break
            }
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchBoardWeCMSVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return searchVM.content.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchVM.content[section].content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = searchVM.content[indexPath.section].content[indexPath.row]
        
        switch data.rowType {
            
        case .STATUS:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FullContentWeCMSCell", for: indexPath) as! FullContentWeCMSCell
            cell.config(data: data.REC)
            cell.dotPostBtn.addTarget(self, action: #selector(moreBtnAction), for: .touchUpInside)
            cell.titlePostLabel.attributedText = data.REC.POST_TITLE?.highlight(searchText: searchText, withHighlightColor: UIColor(hexString: "FFE6A3"))
            return cell
        case .LINEFOOTER:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineFooterCell", for: indexPath)
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.searchVM.content[indexPath.section].content[indexPath.row].REC.POST_SEQ_NO != nil else {return}
        displayAddFloatButton(false)
        displayTabBar(false)
        
        let vc = self.VC(sbName: "ExpenseApprovalWeCMSSB", identifier: "ExpenseApprovalWeCMSVC") as! ExpenseApprovalWeCMSVC

        // Check Later
        vc.expenseApprovalVM.POST_TYPE_CD  = self.searchVM.content[indexPath.section].content[indexPath.row].REC.POST_TYPE_CD ?? ""
        vc.expenseApprovalVM.POST_APPR_DV  = self.searchVM.content[indexPath.section].content[indexPath.row].REC.POST_APPR_DV ?? ""
        vc.boardRec      = self.searchVM.content[indexPath.section].content[indexPath.row].REC

        vc.isShouldReload = true
        pushVC(viewController: vc)

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == searchVM.content.count - 1 {
            let nextPage = self.searchVM.response?.NEXT_PAGE_YN
            if nextPage == "Y"{
                searchVM.PAGE_NO += 1
                self.tableView.tableFooterView = self.view.createSpinnerFooter()
                searchVM.isShowLoading = false
                searchVM.fetchSearch(SRCH_WD: searchText, FROM_DT: selectedDate?.value.fromDate ?? "", TO_DT: selectedDate?.value.toDate ?? "") { result in
                    switch result {
                    case .success(_):
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.searchVM.initData(isPagination: true)
                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
                self.tableView.tableFooterView = nil
            }
        }
    }
}

//MARK: - UITextFieldDelegate
extension SearchBoardWeCMSVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? ""
        DispatchQueue.main.async {
            self.searchText = text
            if text != "" {
                self.clearButton.isHidden = false
                self.tableView.tableHeaderView = self.view.createSpinnerFooter()
                self.searchVM.fetchSearch(SRCH_WD: text) { result in
                    switch result {
                    case .success(_):
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.searchVM.initData()
                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    self.tableView.tableHeaderView = nil
                }
            } else {
                self.clearButton.isHidden = true
                self.fetchInitialData()
            }
        }
    }
}

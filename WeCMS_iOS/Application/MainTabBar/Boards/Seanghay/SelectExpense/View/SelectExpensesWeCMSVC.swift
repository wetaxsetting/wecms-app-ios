//
//  SelectExpensesWeCMSVC.swift
//  WeCMS_iOS
//
//  Created by lymanny on 13/1/25.
//
//  Note: This class was adapted from SelectExpensesVC
//  Some conditions and methods have been modified to fit the requirements of the SelectExpensesWeCMS feature.

import UIKit

import IQKeyboardManagerSwift

class SelectExpensesWeCMSVC: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var tableView             : UITableView!
    @IBOutlet weak var collectionView        : UICollectionView!
    @IBOutlet weak var imageBack             : UIImageView!
    @IBOutlet weak var labelFilter           : UILabel!
    @IBOutlet weak var viewSearch            : UIView!
    @IBOutlet weak var viewFilterMonth       : UIView!
    @IBOutlet weak var viewFilterSearch      : UIView!
    @IBOutlet weak var viewFilter            : UIView!
    @IBOutlet weak var viewCoverFilterSearch : UIView!
    @IBOutlet weak var selectButton          : UIButton!
    @IBOutlet weak var searchTextField       : UITextField!
    @IBOutlet weak var clearTextButton       : UIButton!
    @IBOutlet weak var addManuallyBtn        : UIButton!
    
    //MARK: - Properties & Variable
    var didOptionCompletion     : Completion_Data = {_,_  in}
    var didExpenseCompletion    : Completion_DataExpense = {_,_,_,_,_    in}
    
    var selectExpenseVM  = SelectExpensesVM()
    var simpleApprovalVM = SimpleApprovalVM()
    
    var seleteExpenseType   : ItemType              = .RECEIPT
    var expenseSelectedData : SelectedExpenseType   = .ALLNO
    
    var billPage    = 1
    var receiptPage = 1
    var selectCount = "0"
    var BLTB_CD     = ""
    var BillNum     = 0
    var ReceiptNum  = 0
    var isFirstLoad = false
    var isSearch    = false
    
    var requestApprovers : [MREC_BLTB_0004_C002.REQUEST.REC6]    = []
    var requestExpense   : [MREC_BLTB_0004_C002.REQUEST.REC1]    = []
    var backUpExpense    : [MREC_BLTB_0004_C002.REQUEST.REC1]    = []
    var data0004_C002    : MREC_BLTB_0004_R003.RESPONES?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getLocalFont()
        self.setUpView()
        self.registerCell()
        self.selectExpenseVM.initDataWeCMS()
        self.searchTextField.delegate = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical // or .horizontal, depending on your needs
            collectionView.collectionViewLayout = LeftAlignedFlowLayout()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkingNotify()
    }
    
    //MARK: - @IBAction
    @IBAction func didTapClearSearchTextAction(_ sender: Any) {
        self.searchTextField.text = ""
        switch seleteExpenseType {
        case .BILL:
            self.selectExpenseVM.itemExpenseBill = []
            self.fetExpense(SRCH_WD         : self.searchTextField.text?.lowercased() ?? "",
                            EXPT_TYPE       : "E",
                            FROM_DT         : self.selectExpenseVM.selectedDate?.value.fromDate ?? "",
                            TO_DT           : self.selectExpenseVM.selectedDate?.value.toDate ?? "",
                            PAGE_NO         : self.billPage,
                            isShowLoading   : false,
                            isPaginationBill: true)
        case .RECEIPT:
            self.selectExpenseVM.itemExpenseReceipt = []
            self.fetExpense(SRCH_WD             : self.searchTextField.text?.lowercased() ?? "",
                            EXPT_TYPE           : "R",
                            FROM_DT             : self.selectExpenseVM.selectedDateExpenses?.value.fromDate ?? "",
                            TO_DT               : self.selectExpenseVM.selectedDateExpenses?.value.toDate ?? "",
                            PAGE_NO             : self.receiptPage,
                            isShowLoading       : false,
                            isPaginationReceipt : true)
        }
    }
    
    @IBAction func AddManuallyBtnAction(_ sender: UIButton) { //> Seanghay <\\ GO TO ADD RECEIPT MANUALLY
        self.requestExpense.removeAll()
        self.requestExpense = []
        
        for item in self.backUpExpense { //> Seanghay <\\ APPEND OLD SELECT DATA
            self.requestExpense.append(MREC_BLTB_0004_C002.REQUEST.REC1(TRCO_KEY    : item.TRCO_KEY,
                                                                                TRCO_CMNM   : item.TRCO_CMNM,
                                                                                TRCO_CMENM  : item.TRCO_CMENM,
                                                                                CCY_CD      : item.CCY_CD,
                                                                                AMT         : item.AMT,
                                                                                BUSA_USAG_CD: item.BUSA_USAG_CD,
                                                                                MEMO        : item.MEMO,
                                                                                DOC_ID      : item.DOC_ID,
                                                                                DOC_TYPE    : item.DOC_TYPE,
                                                                                USAG_NM     : item.USAG_NM,
                                                                                APPR_DV     : item.APPR_DV))
        }
        for item in self.selectExpenseVM.itemSelectBILL { //> Seanghay <\\ APPEND SELECT BILL
            self.requestExpense.append(MREC_BLTB_0004_C002.REQUEST.REC1(TRCO_KEY    : item.TRCO_KEY,
                                                                                TRCO_CMNM   : item.TRCO_CMNM,
                                                                                TRCO_CMENM  : item.TRCO_CMENM,
                                                                                CCY_CD      : item.TRCO_TRSC_CCY_CD,
                                                                                AMT         : item.TOTL_AMT,
                                                                                BUSA_USAG_CD: item.BUSA_USAG_CD,
                                                                                MEMO        : item.MEMO,
                                                                                DOC_ID      : item.DOC_ID,
                                                                                DOC_TYPE    : item.DOC_TYPE,
                                                                                USAG_NM     : item.USAG_NM,
                                                                                APPR_DV     : item.APPR_DV))
        }
        for item in self.selectExpenseVM.itemSelectRECEIPT { //> Seanghay <\\ APPEND SELECT RECEIPT
            self.requestExpense.append(MREC_BLTB_0004_C002.REQUEST.REC1(TRCO_KEY    : item.TRCO_KEY,
                                                                                TRCO_CMNM   : item.TRCO_CMNM,
                                                                                TRCO_CMENM  : item.TRCO_CMENM,
                                                                                CCY_CD      : item.TRCO_TRSC_CCY_CD,
                                                                                AMT         : item.TOTL_AMT,
                                                                                BUSA_USAG_CD: item.BUSA_USAG_CD,
                                                                                MEMO        : item.MEMO,
                                                                                DOC_ID      : item.DOC_ID,
                                                                                DOC_TYPE    : item.DOC_TYPE,
                                                                                USAG_NM     : item.USAG_NM,
                                                                                APPR_DV     : item.APPR_DV))
        }
        
        var clean: [MREC_BLTB_0004_C002.REQUEST.REC1] = []
        
        self.requestExpense.forEach { obj in
            
            var isAlreadyExisted = false
            for subObj in clean {
                if subObj.DOC_ID == obj.DOC_ID {
                    isAlreadyExisted = true
                    break
                }
            }
            
            if !isAlreadyExisted {
                clean.append(obj)
            }
        }
        self.didExpenseCompletion("\(clean.count)", self.selectExpenseVM.filterTypeBill, self.selectExpenseVM.filterTypeReceipt, clean, self.expenseSelectedData)
        
    }
    
    //MARK: - Function
    private func registerCell() {
        self.tableView.register(UINib(nibName: "SelectItemWeCMSCell", bundle: nil), forCellReuseIdentifier: "SelectItemWeCMSCell")
        self.tableView.register(UINib(nibName: "ApprovalLineCell", bundle: nil), forCellReuseIdentifier: "ApprovalLineCell")
        self.tableView.register(UINib(nibName: "EmptyCell", bundle: nil), forCellReuseIdentifier: "EmptyCell")
    }
    
    private func checkingNotify(){
        MyNotify.listen(self, selector: #selector(reloadAfterCreateReceipt), name: .gotoSelectExpense)
    }
    
    private func enableAddManualBtn(){
        self.addManuallyBtn.setTitleColor(UIColor(resource: .mainTextBulletin), for: .normal)
        self.addManuallyBtn.isUserInteractionEnabled = true
    }
    
    private func disableAddManualBtn(){
        self.addManuallyBtn.setTitleColor(UIColor(hexString: "#808080"), for: .normal)
        self.addManuallyBtn.isUserInteractionEnabled = false
    }
    
    private func setDefaultView() {
        self.searchTextField.placeholder = "search_by_name,_number_&_amount".localized
        self.selectButton.setTitle("Select Receipt", for: .normal)
        self.selectButton.setTitleColor(.black, for: .normal)
        self.selectButton.isUserInteractionEnabled  = false
    }
    
    private func setUpView() {
        let tapGestureFilterSearch = UITapGestureRecognizer(target: self, action: #selector(handleTapOnSearch))
        viewFilterSearch.addGestureRecognizer(tapGestureFilterSearch)
        
        let tapGestureImageBack = UITapGestureRecognizer(target: self, action: #selector(handleImageBackTap))
        imageBack.addGestureRecognizer(tapGestureImageBack)
        
        let tapGestureFilterMonth = UITapGestureRecognizer(target: self, action: #selector(handleFilterMonthTap))
        viewFilterMonth.addGestureRecognizer(tapGestureFilterMonth)
        
        viewFilter.isHidden = false
        viewSearch.isHidden = true
        
        self.addManuallyBtn.setTitle("done".localized, for: .normal)
        self.fetFirstLoadExpense(EXPT_TYPE: "R", PAGE_NO: 1, isShowLoading: true)
        self.isFirstLoad = true
        enableAddManualBtn()
        self.setDefaultView()
        checkBtnDoneFirst()
    }
    
    func checkSelect() { //> Seanghay <\\ check find select old data
        if self.backUpExpense.count == 0 {
            self.expenseSelectedData = .ALLNO
        }else{
            self.expenseSelectedData = self.backUpExpense.first?.DOC_TYPE == "E" ? .RECEIPT : .BILL
        }
    }
    
    func checkBtnDoneFirst() {
        if requestExpense.isEmpty {
            self.addManuallyBtn.setTitleColor(UIColor(resource: .memberText), for: .normal)
            self.addManuallyBtn.isUserInteractionEnabled = false
        } else {
            self.addManuallyBtn.setTitleColor(UIColor(resource: .mainTextBulletin), for: .normal)
            self.addManuallyBtn.isUserInteractionEnabled = true
        }
        addManuallyBtn.layoutIfNeeded()
    }
    
    func checkBtnDone() {
        if selectExpenseVM.itemSelectRECEIPT.isEmpty {
            self.addManuallyBtn.setTitleColor(UIColor(resource: .memberText), for: .normal)
            self.addManuallyBtn.isUserInteractionEnabled = false
        } else {
            self.addManuallyBtn.setTitleColor(UIColor(resource: .mainTextBulletin), for: .normal)
            self.addManuallyBtn.isUserInteractionEnabled = true
        }
        addManuallyBtn.layoutIfNeeded()
    }
    
    func getLocalFont(){
        self.selectButton.getlocalizedFont()
        self.searchTextField.getlocalizedFont()
        self.clearTextButton.getlocalizedFont()
        self.addManuallyBtn.getlocalizedFont()
    }
    
    private func getNumberOfDaysAMonth(amountMonth: Int, EXPT_TYPE: String = "") {
        let currentDate = Date()
        let calendar    = Calendar.current
        let checkEXPT_TYPE = EXPT_TYPE == "B" || EXPT_TYPE == "E"
        if amountMonth == 1000 {
            if checkEXPT_TYPE {
                self.selectExpenseVM.selectedDate           = Shared.selectedDate
            }else{
                self.selectExpenseVM.selectedDateExpenses   = Shared.selectedDateExpenses
            }
        }else{
            if let monthAgo = calendar.date(byAdding: .month, value: -amountMonth , to: currentDate){
                if checkEXPT_TYPE{
                    let dateFilter = DateFilterModel(value   : DateFilter(fromDate : formatyyyyMMdd(date: monthAgo),toDate : formatyyyyMMdd(date: currentDate)),
                                                     rowType : self.selectExpenseVM.filterTypeBill)
                    self.selectExpenseVM.selectedDate = dateFilter
                }else{
                    let dateFilter = DateFilterModel(value   : DateFilter(fromDate: formatyyyyMMdd(date: monthAgo), toDate: formatyyyyMMdd(date: currentDate)),
                                                     rowType : self.selectExpenseVM.filterTypeReceipt)
                    self.selectExpenseVM.selectedDateExpenses = dateFilter
                }
            }
        }
    }
    
    private func getFullscreenHeight() -> CGFloat {
        let statusBarManager    = UIApplication.shared.statusBarManagerInConnectedScenes
        let statusBarHeight     = statusBarManager?.statusBarFrame.height ?? 0
        let fullscreenHeight    = UIScreen.main.bounds.height - statusBarHeight
        return fullscreenHeight
    }
    
    private func findDate() -> Int {
        switch self.selectExpenseVM.filterTypeBill {
        case .LastOneMonth:     return 1
        case .LastThreeMonth:   return 3
        case .LastSixMonth:     return 6
        case .FilterMaually:    return 1000
        default:                return 1
        }
    }
    
    private func findDateReceipt() -> Int {
        switch self.selectExpenseVM.filterTypeReceipt {
        case .LastOneMonth:     return 1
        case .LastThreeMonth:   return 3
        case .LastSixMonth:     return 6
        case .FilterMaually:    return 1000
        default:                return 1
        }
    }
    
    private func formatyyyyMMdd(date: Date) -> String{ //Seanghay > convert date to string <
        var formattedString = ""
        let dateFormatter   = DateFormatter()
        
        dateFormatter.dateFormat    = "yyyyMMdd"
        formattedString             = dateFormatter.string(from: date)
        
        return formattedString
    }
    
    private func addOldData() {
        if self.requestExpense.count > 0 {
            //            self.selectExpenseVM.itemSelectBILL.removeAll()
            //            self.selectExpenseVM.itemSelectRECEIPT.removeAll()
            for item in self.requestExpense {
                for data in self.selectExpenseVM.itemExpenseBill {
                    if item.DOC_ID == data.DOC_ID {
                        if !self.selectExpenseVM.itemSelectBILL.contains(data) {
                            self.selectExpenseVM.appendSelectBill(item: data)
                        }
                    }
                }
                for data in self.selectExpenseVM.itemExpenseReceipt {
                    if item.DOC_ID == data.DOC_ID {
                        if !self.selectExpenseVM.itemSelectRECEIPT.contains(data) {
                            self.selectExpenseVM.appendSelectReceipt(item: data)
                        }
                    }
                }
            }
        }
    }
    
    private func createSpinnerFooter() -> UIView {
        let footerView  = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 150))
        let spinner     = UIActivityIndicatorView()
        spinner.center  = footerView.center
        
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }
    
    func setupFilterView(type: RowType) {
        switch type {
        case .LastOneMonth:
            labelFilter.text = "last_1_month".localized
            
        case .LastThreeMonth:
            labelFilter.text = "last_3_months".localized
            
        case .LastSixMonth:
            labelFilter.text = "last_6_months".localized
            
        case .FilterMaually:
            labelFilter.text = "filter_manually".localized
            
        default: break
            
        }
        
        viewCoverFilterSearch.layoutIfNeeded()
        
    }
    
    func fetchApproval() {
        self.selectExpenseVM.fetApproval(BLTB_CD: self.BLTB_CD, USER_NM: "") { (result) in
            switch result {
            case .success(_):
                for itemSelect in self.requestApprovers {
                    for itemData in self.selectExpenseVM.itemApprovers {
                        if itemSelect.APPRVR_ID == itemData.USER_ID {
                            self.selectExpenseVM.appendSelectItem(item: itemData)
                        }
                    }
                }
                self.tableView.reloadData()
            case .failure(let error):
                self.alert(message: error.localizedDescription)
            }
        }
    }
    
    func fetFirstLoadExpense(SRCH_WD: String = "", EXPT_TYPE: String, PAGE_NO: Int, isShowLoading: Bool = false, isPaginationBill: Bool = false, isPaginationReceipt: Bool = false) {
        var fromDate        = ""
        var toDate          = ""
        let checkEXPT_TYPE  = EXPT_TYPE == "B" || EXPT_TYPE == "E" // "B" for KH version, "E" for VN version
        
        getNumberOfDaysAMonth(amountMonth: EXPT_TYPE == "R" ? self.findDateReceipt() : self.findDate(), EXPT_TYPE: EXPT_TYPE)
        
        fromDate = checkEXPT_TYPE ? self.selectExpenseVM.selectedDate?.value.fromDate ?? "" : self.selectExpenseVM.selectedDateExpenses?.value.fromDate ?? ""
        toDate   = checkEXPT_TYPE ? self.selectExpenseVM.selectedDate?.value.toDate ?? "" : self.selectExpenseVM.selectedDateExpenses?.value.toDate ?? ""
        
        self.selectExpenseVM.fetExpense(SRCH_WD: SRCH_WD, EXPT_TYPE: EXPT_TYPE, FROM_DT: fromDate, TO_DT: toDate, PAGE_NO: PAGE_NO, PAGE_PER_CNT: 10, isShowLoading: isShowLoading, isPaginationBill: isPaginationBill, isPaginationReceipt: isPaginationReceipt) {(result) in
            switch result {
            case .success(let data):
                self.data0004_C002 = data
                self.addOldData()
                self.checkSelect()
                if EXPT_TYPE == "E" {
                    self.BillNum = data.TOT_CNT_EINV ?? 0
                }else if EXPT_TYPE == "B"{
                    self.BillNum = data.TOT_CNT_BILL ?? 0
                }
                self.ReceiptNum = data.TOT_CNT_RCPT ?? 0
                
                self.isFirstLoad        = false
                self.seleteExpenseType  = .RECEIPT
                
                self.collectionView.reloadData()
                self.tableView.reloadData()
                
            case .failure(let error):
                self.alert(message: error.localizedDescription)
            }
        }
    }
    
    func fetExpense(SRCH_WD: String = "", EXPT_TYPE: String, FROM_DT: String = "", TO_DT: String = "", PAGE_NO: Int, isShowLoading: Bool = false, isPaginationBill: Bool = false, isPaginationReceipt: Bool = false) {
        var fromDate = ""
        var toDate   = ""
        getNumberOfDaysAMonth(amountMonth: EXPT_TYPE == "R" ? self.findDateReceipt() : self.findDate(), EXPT_TYPE: EXPT_TYPE)
        if EXPT_TYPE == "B" || EXPT_TYPE == "E" {  // "B" for KH version, "E" for VN version
            fromDate = self.selectExpenseVM.selectedDate?.value.fromDate ?? ""
            toDate   = self.selectExpenseVM.selectedDate?.value.toDate ?? ""
        }else{
            fromDate = self.selectExpenseVM.selectedDateExpenses?.value.fromDate ?? ""
            toDate   = self.selectExpenseVM.selectedDateExpenses?.value.toDate ?? ""
        }
        self.selectExpenseVM.fetExpense(SRCH_WD: SRCH_WD, EXPT_TYPE: EXPT_TYPE, FROM_DT: FROM_DT == "" ? fromDate : FROM_DT, TO_DT: TO_DT == "" ? toDate : TO_DT, PAGE_NO: PAGE_NO, PAGE_PER_CNT: 10, isShowLoading: isShowLoading, isPaginationBill: isPaginationBill, isPaginationReceipt: isPaginationReceipt) {(result) in
            switch result {
            case .success(let data):
                self.data0004_C002 = data
                self.addOldData()
                switch EXPT_TYPE {
                case "B": //Seanghay > Bill <
                    self.BillNum    = data.TOT_CNT_BILL ?? 0
                case "R": //Seanghay > RECEIPT <
                    self.ReceiptNum = data.TOT_CNT_RCPT ?? 0
                default: //Seanghay > E-Invoice <
                    self.BillNum    = data.TOT_CNT_EINV ?? 0
                }
                self.collectionView.reloadData()
                self.tableView.reloadData()
            case .failure(let error):
                self.alert(message: error.localizedDescription)
            }
        }
    }
    
    //MARK: - OBJC
    @objc func reloadAfterCreateReceipt(notification: Notification) {
        let noti = notification.object as? [String: String]
        switch noti?["MANUAL_EXPENSE"] {
            
        case "CREATE" :
            self.fetFirstLoadExpense(EXPT_TYPE: "R", PAGE_NO: 1)
            
        default:
            break
        }
    }
    
    @objc func handleTapOnSearch() {
        viewSearch.isHidden = false
        viewFilter.isHidden = true
        viewCoverFilterSearch.layoutIfNeeded()
    }
    
    @objc func handleImageBackTap() {
        viewFilter.isHidden = false
        viewSearch.isHidden = true
        viewCoverFilterSearch.layoutIfNeeded()
    }
    
    @objc func handleFilterMonthTap() {
        let vc = self.VC(sbName: "SelectOptionWithTitleSB", identifier: "SelectOptionWithTitleVC") as! SelectOptionWithTitleVC
        /*
         85      => top & bottom spaces
         58 * 4  => 58 is height of one cell, and 4 multiples with item count to get all cells height
         51      => is height header view
         */
        var totalHeight  = CGFloat((58 * 4) + 85 + 51)
        vc.seleteExpenseType     = self.seleteExpenseType
        vc.selectedDateExpenses  = self.selectExpenseVM.selectedDateExpenses
        
        if let data = self.selectExpenseVM.selectedDateExpenses {
            if data.rowType == .FilterMaually {
                totalHeight += 58 * 2
            }
        }
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in totalHeight }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = true
        }
        
        self.billPage       = 1
        self.receiptPage    = 1
        
        vc.CompletionDidFinishSelectDateExpenses = { [self] selectData in
            switch selectData.rowType {
            case . LastOneMonth, .LastThreeMonth, .LastSixMonth, .FilterMaually:
                self.selectExpenseVM.selectedDateExpenses = selectData
                Shared.selectedDateExpenses               = selectData
                self.selectExpenseVM.filterTypeReceipt    = selectData.rowType ?? .LastOneMonth
                self.fetExpense(EXPT_TYPE           : "R",
                                FROM_DT             : self.selectExpenseVM.selectedDateExpenses?.value.fromDate ?? "",
                                TO_DT               : self.selectExpenseVM.selectedDateExpenses?.value.toDate ?? "",
                                PAGE_NO             :  self.receiptPage,
                                isShowLoading       : false,
                                isPaginationReceipt : false)
                setupFilterView(type: selectExpenseVM.filterTypeReceipt)
                self.dismiss(animated: true)
                
            default: break
            }
        }
        
        vc.heightCompletionExpenses = { height in
            totalHeight = CGFloat(height)
            vc.sheetPresentationController?.animateChanges {
                vc.sheetPresentationController?.selectedDetentIdentifier = .large
            }
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension SelectExpensesWeCMSVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectExpenseVM.itemExpenseReceipt.count != 0 {
            return self.selectExpenseVM.itemExpenseReceipt.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.selectExpenseVM.itemExpenseReceipt.count != 0 {
            self.tableView.isScrollEnabled = true
            return UITableView.automaticDimension
        }else{
            self.tableView.isScrollEnabled = false
            return 300
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let nextPage = self.selectExpenseVM.selectExpenseReceiptResponse?.NEXT_PAGE_YN
        if indexPath.row == selectExpenseVM.itemExpenseReceipt.count - 1 {
            if nextPage != "N" {
                self.receiptPage += 1
                self.tableView.tableFooterView = createSpinnerFooter()
                self.fetExpense(SRCH_WD             : self.searchTextField.text?.lowercased() ?? "",
                                EXPT_TYPE           : "R",
                                FROM_DT             : self.searchTextField.text != "" ? "" : self.selectExpenseVM.selectedDateExpenses?.value.fromDate ?? "",
                                TO_DT               : self.searchTextField.text != "" ? "" : self.selectExpenseVM.selectedDateExpenses?.value.toDate ?? "",
                                PAGE_NO             : self.receiptPage,
                                isShowLoading       : false,
                                isPaginationReceipt : true)
                
            }else{
                self.tableView.tableFooterView = nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.selectExpenseVM.itemExpenseReceipt.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectItemWeCMSCell", for: indexPath) as! SelectItemWeCMSCell
            
            cell.configCell(data: self.selectExpenseVM.itemExpenseReceipt[indexPath.row], searchText: self.searchTextField.text ?? "")
            
            if self.selectExpenseVM.itemSelectRECEIPT.count > 0 {
                cell.backView.backgroundColor = .white
                cell.selectImage.isHidden     = true
                
                for item in self.selectExpenseVM.itemSelectRECEIPT {
                    if item.DOC_ID == self.selectExpenseVM.itemExpenseReceipt[indexPath.row].DOC_ID {
                        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        cell.backView.backgroundColor = #colorLiteral(red: 0.9050878882, green: 0.9127636552, blue: 0.9934228063, alpha: 1)
                        cell.selectImage.isHidden     = false
                        cell.selectImage.image        = UIImage(named: "round_check_wecms")
                    }
                }
            } else {
                cell.backView.backgroundColor = .white
                cell.selectImage.isHidden     = true
            }
            
            cell.itemIDBtn.didTap {
                let vc = UIStoryboard(name: "ReceiptDetailsSB", bundle: nil).instantiateViewController(withIdentifier: "ReceiptDetailsVC") as! ReceiptDetailsVC
                
                vc.doc_id               = self.selectExpenseVM.itemExpenseReceipt[indexPath.row].DOC_ID ?? ""
                vc.isRequestApproval    = true
                
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .custom
                self.present(nav, animated:true)
            }
            return cell
            
        }else {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath) as! EmptyCell
            emptyCell.configCell(cellType: "R")
            
            return emptyCell
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tempData1 = OptionPopupWithoutTitleModel(title: "switch_now".localized)
        let tempData2 = OptionPopupWithoutTitleModel(title: "don't_switch".localized)
        
        let data = [tempData1, tempData2]
        let title = "switch_to_receipt?".localized
        if self.expenseSelectedData == .BILL {
            self.switchOption(optionData: data, title: title, description: "your_current_selection_will_not_be_saved.".localized) { str in
                if str == "switch_now".localized {
                    self.selectExpenseVM.itemSelectBILL.removeAll()
                    self.requestExpense.removeAll()
                    self.backUpExpense.removeAll()
                    self.expenseSelectedData = .RECEIPT
                    self.selectExpenseVM.appendSelectReceipt(item: self.selectExpenseVM.itemExpenseReceipt[indexPath.row])
                    self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
                }
                self.dismiss(animated: true)
            }
        }else{
            self.expenseSelectedData = .RECEIPT
            self.requestExpense.removeAll()
            self.selectExpenseVM.appendSelectReceipt(item: self.selectExpenseVM.itemExpenseReceipt[indexPath.row])
            checkBtnDone()
            self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.requestExpense.removeAll()
        
        //Seanghay > Remove data from select item <
        for (index, item) in self.selectExpenseVM.itemSelectRECEIPT.enumerated() {
            if item.DOC_ID == self.selectExpenseVM.itemExpenseReceipt[indexPath.row].DOC_ID {
                self.selectExpenseVM.itemSelectRECEIPT.remove(at: index)
            }
        }
        
        //Seanghay > Remove data from data that save <
        for (index, item) in self.backUpExpense.enumerated() {
            if item.DOC_ID == self.selectExpenseVM.itemExpenseReceipt[indexPath.row].DOC_ID {
                self.backUpExpense.remove(at: index)
            }
        }
        
        //Seanghay > Un select item <
        if let cell = self.tableView.cellForRow(at: indexPath) as? SelectItemWeCMSCell {
            cell.deSelectCell()
            checkBtnDone()
            
        }
        
        //Seanghay > Change select item type <
        if self.selectExpenseVM.itemSelectRECEIPT.isEmpty {
            self.expenseSelectedData = .ALLNO
        }
    }
}


//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension SelectExpensesWeCMSVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectExpenseVM.tabExpense.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell        = self.collectionView.dequeueReusableCell(withReuseIdentifier: "TabExpenseCell", for: indexPath) as! TabExpenseCell
        
        let dataExpense = self.selectExpenseVM.tabExpense[indexPath.row].value as! SelectExpenses
        
        cell.configCell(data: dataExpense, seleted: false, itemCount: ReceiptNum)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 10) / 3 // Adjust based on desired layout
        return CGSize(width: width, height: 44)
    }
    
}

//MARK: - UITextFieldDelegate
extension SelectExpensesWeCMSVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.searchTextField.text       = textField.text ?? ""
        
        if self.searchTextField.text == "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.receiptPage                = 1
                self.clearTextButton.isHidden   = true
                self.tableView.tableHeaderView  = nil
                self.selectExpenseVM.itemExpenseReceipt = []
                self.fetExpense(SRCH_WD             : "",
                                EXPT_TYPE           : "R",
                                FROM_DT             : self.selectExpenseVM.selectedDateExpenses?.value.fromDate ?? "",
                                TO_DT               : self.selectExpenseVM.selectedDateExpenses?.value.toDate ?? "",
                                PAGE_NO             : self.receiptPage,
                                isShowLoading       : false,
                                isPaginationReceipt : true)
            }
        }else {
            self.clearTextButton.isHidden = false
            self.fetExpense(SRCH_WD         : self.searchTextField.text?.lowercased() ?? "",
                            EXPT_TYPE       : "R",
                            PAGE_NO         : 1,
                            isShowLoading   : false)
            self.tableView.tableHeaderView = nil
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        tableView.endUpdates()
    }
}

//MARK: - UIViewController
extension UIViewController {
    func popSelectApprovalItemExpenseWeCMS(selectCount       : String = "0",
                                           filterDateBill    : RowType,
                                           filterDateReceipt : RowType,
                                           selectData        : [MREC_BLTB_0004_C002.REQUEST.REC1],
                                           selectType        : SelectedExpenseType,
                                           completion        : @escaping Completion_DataExpense = {_,_,_,_,_    in}) {
        
        let vc = self.callCommonPopup(withStorybordName: "SelectExpensesWeCMSSB", identifier: "SelectExpensesWeCMSVC") as! SelectExpensesWeCMSVC
        
        vc.requestExpense                       = selectData
        vc.backUpExpense                        = selectData
        vc.selectExpenseVM.filterTypeBill       = filterDateBill
        vc.selectExpenseVM.filterTypeReceipt    = filterDateReceipt
        vc.expenseSelectedData                  = selectType
        
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in 700 }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = false
        }
        
        vc.didExpenseCompletion = { str, filterTypeBill, filterTypeReceipt, data, selectType in
            completion(str, filterTypeBill, filterTypeReceipt,data, selectType)
            self.dismiss(animated: true)
        }
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func popAddOtherManualWeCMS(dataManualExpense: ApprovalContent? = nil,
                                dataDetailExpense: MREC_BLTB_0004_C002.REQUEST.REC1? = nil,
                                dataEditExpense  : EditArticleData? = nil,
                                dataR002         : WeCMSStruct.RECDoc_Protocol? = nil,
                                clientData       : [Client.ContentBody] = [],
                                isEditManual     : String? = nil) {
        let vc = self.callCommonPopup(withStorybordName: "AddOtherExpenseSB", identifier: "AddOtherExpenseVC") as! AddOtherExpenseVC
        vc.dataDetailExpense    = dataDetailExpense
        vc.dataManualExpense    = dataManualExpense
        vc.isEditManual         = isEditManual ?? ""
        vc.clientData           = clientData
        vc.dataEditExpense      = dataEditExpense
        vc.dataR002             = dataR002
        
        let nav = UINavigationController()
        nav.viewControllers = [vc]
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in 541 }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = false
        }
        
        vc.completion = {
            nav.sheetPresentationController?.animateChanges {
                nav.sheetPresentationController?.selectedDetentIdentifier = .large
            }
        }
        self.present(nav, animated: true, completion: nil)
    }
    
    private func getFullscreenHeight() -> CGFloat {
        let statusBarManager    = UIApplication.shared.statusBarManagerInConnectedScenes
        let statusBarHeight     = statusBarManager?.statusBarFrame.height ?? 0
        let fullscreenHeight    = UIScreen.main.bounds.height - statusBarHeight
        return fullscreenHeight
    }
}

//
//  SelectExpensesVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Seanghay Huort on 17/1/24.
//

import UIKit

import IQKeyboardManagerSwift

typealias Completion_Data         = (String, [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC6])          -> Void
typealias Completion_DataExpense  = (String, RowType, RowType, [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1], SelectedExpenseType)          -> Void
typealias Completion_SelectDocument  = ([FileModel])       -> Void

enum SelectType {
    case APPROVERS
    case EXPENSES
}

enum SelectedExpenseType {
    case BILL
    case RECEIPT
    case ALLNO
}

class SelectExpensesVC: UIViewController {

    //MARK: - @IBOutlet
    @IBOutlet weak var tableView                        : UITableView!
    @IBOutlet weak var collectionView                   : UICollectionView!
    @IBOutlet weak var selectCollectionView             : UICollectionView!
    
    @IBOutlet weak var selectButton                     : UIButton!
    @IBOutlet weak var selectExpenseTitleLabel          : UILabel!
    @IBOutlet weak var doneButton                       : UIButton!
    @IBOutlet weak var searchView                       : UIView!
    @IBOutlet weak var searchTextField                  : UITextField!
    @IBOutlet weak var clearTextButton                  : UIButton!
    @IBOutlet weak var searchIconImage                  : UIImageView!
    @IBOutlet weak var backCollectionView               : UIView!
    @IBOutlet weak var selectCollectionConstraint       : NSLayoutConstraint!
    @IBOutlet weak var selectCollectView                : UIView!
    @IBOutlet weak var searchViewtoTableConstraint      : NSLayoutConstraint!
    @IBOutlet weak var searchTextFieldtoViewConstraint  : NSLayoutConstraint!
    @IBOutlet weak var searchTextFieldTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var addManuallyBtn                   : UIButton!
    @IBOutlet weak var addManullyBtnView                : UIView!
    @IBOutlet weak var addManuallyHeightView            : NSLayoutConstraint!
    
    //MARK: - Variable
    var didOptionCompletion     : Completion_Data = {_,_  in}
    var didExpenseCompletion    : Completion_DataExpense = {_,_,_,_,_    in}
    
    var selectExpenseVM  = SelectExpensesVM()
    var simpleApprovalVM = SimpleApprovalVM()
    
    var seleteExpenseType   : ItemType              = .BILL
    var expenseSelectedData : SelectedExpenseType   = .ALLNO
    var selectType          : SelectType            = .APPROVERS
    
    var selectCollection    : [Bool]   = [false,true]
    var itemCount           : [Int]    = [0, 0]
    
    var billPage    = 1
    var receiptPage = 1
    var selectCount = "0"
    var BLTB_CD     = ""
    var BillNum     = 0
    var ReceiptNum  = 0
    var isFirstLoad = false
    
    var tagCells        : [SelectItemCollectionCell]                    = []
    var requestApprovers: [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC6]    = []
    var requestExpense  : [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1]    = []
    var backUpExpense   : [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1]    = []
    var data0004_C002   : WABOOKS_MREC_BLTB_0004_R003.RESPONES?
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getLocalFont()
        self.setUpView()
        self.registerCell()
        self.selectExpenseVM.initData()
        self.searchTextField.delegate = self
        self.selectCollectionConstraint.constant = 0
        if let layout = selectCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical // or .horizontal, depending on your needs
            selectCollectionView.collectionViewLayout = LeftAlignedFlowLayout()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkingNotify()
    }
    
    func getLocalFont(){
        self.selectButton.getlocalizedFont()
        self.selectExpenseTitleLabel.getlocalizedFont()
        self.doneButton.getlocalizedFont()
        self.searchTextField.getlocalizedFont()
        self.clearTextButton.getlocalizedFont()
        self.addManuallyBtn.getlocalizedFont()
    }
    
    //MARK: - @IBAction
    @IBAction func didTapFilter(_ sender: Any) { //> Seanghay <\\ CHOOSE FILTER MONTHS
 
        let vc = self.VC(sbName: "SelectOptionWithTitleSB", identifier: "SelectOptionWithTitleVC") as! SelectOptionWithTitleVC
        /*
        85      => top & bottom spaces
        58 * 4  => 58 is height of one cell, and 4 multiples with item count to get all cells height
        51      => is height header view
        */
        var totalHeight  = CGFloat((58 * 4) + 85 + 51)
        vc.seleteExpenseType = self.seleteExpenseType
        
        if self.seleteExpenseType == .BILL{
            vc.selectedDate      = self.selectExpenseVM.selectedDate
            if let data = self.selectExpenseVM.selectedDate {
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
            
            vc.CompletionDidFinishSelectDate = { [self] selectData in
                switch selectData.rowType{
                case . LastOneMonth, .LastThreeMonth, .LastSixMonth, .FilterMaually:
                    self.selectExpenseVM.selectedDate       = selectData
                    Shared.selectedDate                     = selectData
                    self.selectExpenseVM.filterTypeBill     = selectData.rowType ?? .LastOneMonth
                    self.fetExpense(EXPT_TYPE       : "E",
                                    FROM_DT         : self.selectExpenseVM.selectedDate?.value.fromDate ?? "",
                                    TO_DT           : self.selectExpenseVM.selectedDate?.value.toDate ?? "",
                                    PAGE_NO         : self.billPage,
                                    isShowLoading   : false,
                                    isPaginationBill: false)
                    self.dismiss(animated: true)
                    
                default: break
                }
            }
            
            vc.heightCompletion = { height in
                totalHeight = CGFloat(height)
                vc.sheetPresentationController?.animateChanges {
                    vc.sheetPresentationController?.selectedDetentIdentifier = .large
                }
            }
            self.present(vc, animated: true, completion: nil)
            
        }else{
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
                switch selectData.rowType{
                case . LastOneMonth, .LastThreeMonth, .LastSixMonth, .FilterMaually:
                    self.selectExpenseVM.selectedDateExpenses = selectData
                    Shared.selectedDateExpenses             = selectData
                    self.selectExpenseVM.filterTypeReceipt  = selectData.rowType ?? .LastOneMonth
                    self.fetExpense(EXPT_TYPE           : "R",
                                    FROM_DT             : self.selectExpenseVM.selectedDateExpenses?.value.fromDate ?? "",
                                    TO_DT               : self.selectExpenseVM.selectedDateExpenses?.value.toDate ?? "",
                                    PAGE_NO             :  self.receiptPage,
                                    isShowLoading       : false,
                                    isPaginationReceipt : false)
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

    @IBAction func didTapDoneAction(_ sender: Any) {
        switch selectType {
        case .APPROVERS:
            
            self.requestApprovers = []
            for item in self.selectExpenseVM.itemSelectApprovers {
                self.requestApprovers.append(WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC6(APPRVR_ID     : item.USER_ID,
                                                                                      APPRVR_NM     : item.USER_NM,
                                                                                      APPRVR_IMG_URL: item.USER_IMG_URL))
            }
            self.didOptionCompletion("\(self.requestApprovers.count)/4", requestApprovers)
            
        case .EXPENSES:
            self.requestExpense.removeAll()
            self.requestExpense = []
            
            for item in self.backUpExpense { //> Seanghay <\\ APPEND OLD SELECT DATA
                self.requestExpense.append(WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1(TRCO_KEY    : item.TRCO_KEY,
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
                self.requestExpense.append(WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1(TRCO_KEY    : item.TRCO_KEY,
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
                self.requestExpense.append(WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1(TRCO_KEY    : item.TRCO_KEY,
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

            var clean: [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1] = []
            
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
        self.dismiss(animated: true)
    }

    @IBAction func AddManuallyBtnAction(_ sender: UIButton) { //> Seanghay <\\ GO TO ADD RECEIPT MANUALLY
        
        switch selectType {
        case .APPROVERS:
            
            self.requestApprovers = []
            for item in self.selectExpenseVM.itemSelectApprovers {
                self.requestApprovers.append(WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC6(APPRVR_ID: item.USER_ID, APPRVR_NM: item.USER_NM, APPRVR_IMG_URL: item.USER_IMG_URL))
            }
            self.didOptionCompletion("\(self.requestApprovers.count)/4", requestApprovers)
            
        case .EXPENSES:
            let tempData1   = OptionPopupWithoutTitleModel(title: "switch_now".localized)
            let tempData2   = OptionPopupWithoutTitleModel(title: "don't_switch".localized)
            let data        = [tempData1, tempData2]
            
            if self.selectExpenseVM.itemSelectRECEIPT.count > 0 || self.selectExpenseVM.itemSelectBILL.count > 0{
                self.switchOption(optionData        : data,
                                  title             : "add_other_expense?".localized,
                                  description       : "your_current_selection_will_not_be_saved.".localized,
                                  isFromAddManual   : true) { str in
                    if str == "switch_now".localized {
                        self.dismiss(animated: true){
                            let vc = self.findsViewController()
                            vc?.popAddOtherManual()
                        }
                    }
                }
            }else{
                self.dismiss(animated: true){
                    let vc = self.findsViewController()
                    vc?.popAddOtherManual()
                }
            }
        }
    }
    
    //MARK: - private func
    private func registerCell() {
        self.selectCollectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: false)
        self.selectCollectionView.delegate      = self
        self.selectCollectionView.dataSource    = self
        self.tableView.register(UINib(nibName: "SelectItemCell", bundle: nil), forCellReuseIdentifier: "SelectItemCell")
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
    
    private func setDefaultView(isApprover: Bool) {
        self.backCollectionView.isHidden            = isApprover ? true : false
        self.searchViewtoTableConstraint.constant   = isApprover ? 0 : 44
        self.clearTextButton.isHidden               = true
        self.searchView.backgroundColor             = isApprover ? UIColor(hexString: "#FAFAFA") : .white
        self.searchView.borderWidth                 = isApprover ? 1 : 0
        self.searchView.borderColor                 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08)
        self.searchTextField.placeholder            = isApprover ? "search_by_name_or_id".localized : "search_by_name,_number_&_amount".localized
        self.selectExpenseTitleLabel.text           = isApprover ? "" : "expenses".localized
        self.selectButton.setTitle(isApprover ? "select_approvers".localized : "filter".localized, for: .normal)
        self.selectButton.setTitleColor(isApprover ? .black : UIColor(resource: .mainTextBulletin), for: .normal)
        self.selectButton.isUserInteractionEnabled  = isApprover ? false : true
    }

    private func setUpView(){
        self.addManuallyBtn.setTitle("add_manually".localized, for: .normal)
        switch selectType {
        case .APPROVERS:
            self.fetchApproval()
            self.setDefaultView(isApprover: true)
            self.addManuallyBtn.setTitle(self.selectCount == "" ? "done".localized + " (0/4)" : "done".localized + " (\(self.selectCount))", for: .normal)
            self.selectCollectionConstraint.constant = 0
            self.addManuallyHeightView.constant = 0
            checkBtnDoneFirst()
            
        case .EXPENSES:
            self.fetFirstLoadExpense(EXPT_TYPE: "E", PAGE_NO: 1, isShowLoading: true)
            self.isFirstLoad = true
            enableAddManualBtn()
            self.setDefaultView(isApprover: false)
            self.doneButton.setTitle("done".localized, for: .normal)
            self.addManuallyHeightView.constant = 77
        }
    }
    
    func checkBtnDoneFirst() {
        if requestApprovers.isEmpty {
            self.addManuallyBtn.setTitleColor(UIColor(resource: .memberText), for: .normal)
            self.addManuallyBtn.isUserInteractionEnabled = false
        } else {
            self.addManuallyBtn.setTitleColor(UIColor(resource: .mainTextBulletin), for: .normal)
            self.addManuallyBtn.isUserInteractionEnabled = true
        }
        addManuallyBtn.layoutIfNeeded()
    }
    
    func checkBtnDone() {
        if selectExpenseVM.itemSelectApprovers.isEmpty {
            self.addManuallyBtn.setTitleColor(UIColor(resource: .memberText), for: .normal)
            self.addManuallyBtn.isUserInteractionEnabled = false
        } else {
            self.addManuallyBtn.setTitleColor(UIColor(resource: .mainTextBulletin), for: .normal)
            self.addManuallyBtn.isUserInteractionEnabled = true
        }
        addManuallyBtn.layoutIfNeeded()
    }
    
//    func configCells() { //> Seanghay <\\ Init Tag Cell
//        switch self.seleteExpenseType {
//        case .BILL:
//            self.tagCells = self.selectExpenseVM.itemSelectBILL.enumerated().map({ (index, selectdata) -> SelectItemCollectionCell in
//                let cell = self.selectCollectionView.dequeueReusableCell(withReuseIdentifier: "SelectItemCollectionCell", for: IndexPath(item: index, section: 0)) as! SelectItemCollectionCell
//                
//                cell.configCell(data: selectdata)
//                cell.xButton.didTap {
//                    for (ind,item) in self.selectExpenseVM.itemSelectBILL.enumerated() {
//                        if item.DOC_ID == selectdata.DOC_ID {
//                            
//                            self.selectExpenseVM.itemSelectBILL.remove(at: ind)
//                            self.selectCollectionConstraint.constant = self.selectExpenseVM.itemSelectBILL.isEmpty ? 0 : 70
//                            self.reload()
//                            self.tableView.reloadData()
//                        }
//                    }
//                }
//                return cell
//            })
//            
//            //> Seanghay <\\ Fill spacing of UICollectionView
////            let optimalCells = self.selectCollectionView.getOptimalCells(self.tagCells, maxWidth: UIScreen.main.bounds.width)
////            self.tagCells = optimalCells.reduce(into: [SelectItemCollectionCell](), { (cells, resultCells) in
////                cells.append(resultCells)
////            }) as! [SelectItemCollectionCell]
//            self.selectCollectionView.reloadData()
//        case .RECEIPT:
//            self.tagCells = self.selectExpenseVM.itemSelectRECEIPT.enumerated().map({ (index, selectdata) -> SelectItemCollectionCell in
//                let cell = self.selectCollectionView.dequeueReusableCell(withReuseIdentifier: "SelectItemCollectionCell", for: IndexPath(item: index, section: 0)) as! SelectItemCollectionCell
//                
//                cell.itemBackView.backgroundColor = UIColor(hexString: "#ECEFF1")
//                cell.configCell(data: selectdata)
//                cell.xButton.didTap {
//                    for (ind,item) in self.selectExpenseVM.itemSelectRECEIPT.enumerated() {
//                        if item.DOC_ID == selectdata.DOC_ID {
//                            self.selectExpenseVM.itemSelectRECEIPT.remove(at: ind)
//                            self.selectCollectionConstraint.constant = self.selectExpenseVM.itemSelectRECEIPT.isEmpty ? 0 : 70
//                            self.reload()
//                            self.tableView.reloadData()
//                        }
//                    }
//                }
//                
//                return cell
//            })
//            self.selectCollectionView.reloadData()
//        }
//    }
    
    func scrollToBottom() {
        let lastSection     = selectCollectionView.numberOfSections - 1
        let lastItem        = selectCollectionView.numberOfItems(inSection: lastSection) - 1
        let lastIndexPath   = IndexPath(item: lastItem, section: lastSection)
                
        selectCollectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
    }
    
//    func reload() {
//        self.configCells()
//    }
    
    func checkSelect() { //> Seanghay <\\ check find select old data
        if self.backUpExpense.count == 0 {
            self.expenseSelectedData = .ALLNO
        }else{
            self.expenseSelectedData = self.backUpExpense.first?.DOC_TYPE == "E" ? .RECEIPT : .BILL
        }
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
    
    // create Loading view
    private func createSpinnerFooter() -> UIView {
        let footerView  = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 150))
        let spinner     = UIActivityIndicatorView()
        spinner.center  = footerView.center
        
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }
    
    //MARK: - func
    
    //MARK: - API Request
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
                    self.BillNum    = data.TOT_CNT_EINV ?? 0
                }else if EXPT_TYPE == "B"{
                    self.BillNum    = data.TOT_CNT_BILL ?? 0
                }
                self.ReceiptNum = data.TOT_CNT_RCPT ?? 0
                self.selectCollectionConstraint.constant = self.selectExpenseVM.itemSelectBILL.isEmpty ? 0 : 70
//                self.configCells()
                self.selectCollectionView.reloadData()
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
    
    //MARK: - @objc func
    
    @objc func reloadAfterCreateReceipt(notification: Notification){
        let noti = notification.object as? [String: String]
        switch noti?["MANUAL_EXPENSE"] {
            
        case "CREATE" :
           self.fetFirstLoadExpense(EXPT_TYPE: "R", PAGE_NO: 1)
            
        default:
            break
        }
    }
}

//MARK: - UITableViewDelegate
extension SelectExpensesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectType {
        case .APPROVERS:
            return self.selectExpenseVM.itemApprovers.count
            
        case .EXPENSES:
            if self.seleteExpenseType == .BILL{
                if self.selectExpenseVM.itemExpenseBill.count != 0{
                    return self.selectExpenseVM.itemExpenseBill.count
                }else{
                    return 1
                }
            }else{
                if self.selectExpenseVM.itemExpenseReceipt.count != 0{
                    return self.selectExpenseVM.itemExpenseReceipt.count
                }else{
                    return 1
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch selectType {
        case .APPROVERS:
            return UITableView.automaticDimension
            
        case .EXPENSES:
            if self.seleteExpenseType == .BILL{
                if self.selectExpenseVM.itemExpenseBill.count != 0{
                    self.tableView.isScrollEnabled = true
                    return UITableView.automaticDimension
                }else{
                    self.tableView.isScrollEnabled = false
                    return 300
                }
            }else{
                if self.selectExpenseVM.itemExpenseReceipt.count != 0{
                    self.tableView.isScrollEnabled = true
                    return UITableView.automaticDimension
                }else{
                    self.tableView.isScrollEnabled = false
                    return 300
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        switch selectType {
        case .EXPENSES:
            switch seleteExpenseType {
            case .BILL:
                let nextPage = self.selectExpenseVM.selectExpenseBillResponse?.NEXT_PAGE_YN
                if indexPath.row == selectExpenseVM.itemExpenseBill.count - 1 {
                    if nextPage != "N" {
                        let EXPT_TYPE = "E"
                        self.billPage += 1
                        self.tableView.tableFooterView = createSpinnerFooter()
                        self.fetExpense(SRCH_WD         : self.searchTextField.text?.lowercased() ?? "",
                                        EXPT_TYPE       : EXPT_TYPE,
                                        FROM_DT         : self.searchTextField.text != "" ? "" : self.selectExpenseVM.selectedDate?.value.fromDate ?? "",
                                        TO_DT           : self.searchTextField.text != "" ? "" : self.selectExpenseVM.selectedDate?.value.toDate ?? "",
                                        PAGE_NO         : self.billPage,
                                        isShowLoading   : false,
                                        isPaginationBill: true)
                    }else{
                        self.tableView.tableFooterView = nil
                    }
                }
  
            case .RECEIPT:
                let nextPage = self.selectExpenseVM.selectExpenseReceiptResponse?.NEXT_PAGE_YN
                if indexPath.row == selectExpenseVM.itemExpenseReceipt.count - 1 {
                    if nextPage != "N"{
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
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch selectType {
        case .EXPENSES:
            switch seleteExpenseType {
            case .BILL:
                if self.selectExpenseVM.itemExpenseBill.count != 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SelectItemCell", for: indexPath) as! SelectItemCell
                    cell.itemImage.image     = UIImage(named: "radio_btn_off")
                    cell.configCell(data: self.selectExpenseVM.itemExpenseBill[indexPath.row], searchText: self.searchTextField.text ?? "")
                    
                    if self.selectExpenseVM.itemSelectBILL.count > 0 {
                        cell.backView.backgroundColor = .white
                        cell.selectImage.isHidden     = true
                        for item in self.selectExpenseVM.itemSelectBILL {
                            if item.DOC_ID == self.selectExpenseVM.itemExpenseBill[indexPath.row].DOC_ID {
                                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                                cell.backView.backgroundColor               = #colorLiteral(red: 0.9050878882, green: 0.9127636552, blue: 0.9934228063, alpha: 1)
                                cell.itemImage.image                        = UIImage(named: "round_check")
                                self.doneButton.isUserInteractionEnabled    = true
                                self.doneButton.setTitleColor(.white, for: .normal)
                            }
                        }
                    }else{
                        cell.backView.backgroundColor = .white
                        cell.selectImage.isHidden     = true
                    }
                    return cell
                    
                }else{
                    let emptyCell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath) as! EmptyCell
                    emptyCell.configCell(cellType: "B")
                    return emptyCell
                }
                
            case .RECEIPT:
                if self.selectExpenseVM.itemExpenseReceipt.count != 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SelectItemCell", for: indexPath) as! SelectItemCell
                    cell.itemImage.image     = UIImage(named: "radio_btn_off")
                    cell.configCell(data: self.selectExpenseVM.itemExpenseReceipt[indexPath.row], searchText: self.searchTextField.text ?? "")
                    
                    if self.selectExpenseVM.itemSelectRECEIPT.count > 0 {
                        cell.backView.backgroundColor = .white
                        cell.selectImage.isHidden     = true
                        for item in self.selectExpenseVM.itemSelectRECEIPT {
                            if item.DOC_ID == self.selectExpenseVM.itemExpenseReceipt[indexPath.row].DOC_ID {
                                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                                cell.backView.backgroundColor               = #colorLiteral(red: 0.9050878882, green: 0.9127636552, blue: 0.9934228063, alpha: 1)
                                cell.itemImage.image                        = UIImage(named: "round_check")
                                self.doneButton.isUserInteractionEnabled    = true
                                self.doneButton.setTitleColor(.white, for: .normal)
                            }
                        }
                    }else{
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
                    
                }else{
                    let emptyCell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath) as! EmptyCell
                    emptyCell.configCell(cellType: "R")
                    return emptyCell
                }
            }
            
        case .APPROVERS:
            if indexPath.row == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "ApprovalLineCell", for: indexPath) as! ApprovalLineCell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectItemCell", for: indexPath) as! SelectItemCell
                cell.configCellApprovers(data: self.selectExpenseVM.itemApprovers[indexPath.row], searchText: self.searchTextField.text ?? "")
                cell.backView.backgroundColor = .white
                cell.selectImage.isHidden = true
                for (index, item ) in self.selectExpenseVM.itemSelectApprovers.enumerated() {
                    if item.USER_ID == self.selectExpenseVM.itemApprovers[indexPath.row].USER_ID {
                        cell.backView.backgroundColor               = #colorLiteral(red: 0.9050878882, green: 0.9127636552, blue: 0.9934228063, alpha: 1)
                        cell.selectImage.isHidden                   = false
                        self.doneButton.isUserInteractionEnabled    = true
                        self.doneButton.setTitleColor(.white, for: .normal)
                        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        cell.configSelectImage(selectCount: index + 1)
                    }
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch selectType {
        case .EXPENSES:
            return indexPath
        case .APPROVERS:
            let selectedRows = tableView.indexPathsForSelectedRows?.count ?? 0
            return selectedRows == 4 ? nil : indexPath //> Seanghay <\\ CHECK LIMIT 4 SELECTION
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tempData1 = OptionPopupWithoutTitleModel(title: "switch_now".localized)
        let tempData2 = OptionPopupWithoutTitleModel(title: "don't_switch".localized)
        switch selectType {
        case .EXPENSES:
            self.selectCollectionConstraint.constant = 70
            switch self.seleteExpenseType {
            case .BILL:
                
                //> Seanghay <\\
                let data                = [tempData1, tempData2]
                let title               = "Switch_to_E_invoice?".localized
                
                if self.expenseSelectedData == .RECEIPT {
                    self.switchOption(optionData: data, title: title, description: "your_current_selection_will_not_be_saved.".localized) { str in
                        if str == "switch_now".localized {
                            self.selectExpenseVM.itemSelectRECEIPT.removeAll()
                            self.requestExpense.removeAll()
                            self.backUpExpense.removeAll()
                            self.expenseSelectedData = .BILL
                            self.selectExpenseVM.appendSelectBill(item: self.selectExpenseVM.itemExpenseBill[indexPath.row])
                            self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
//                            self.configCells()
                            self.selectCollectionView.reloadData()
                            if self.selectExpenseVM.itemSelectBILL.count > 1 { self.scrollToBottom() }
                        }
                        self.selectCollectionConstraint.constant = self.selectExpenseVM.itemSelectBILL.isEmpty ? 0 : 70
                        self.dismiss(animated: true)
                    }
                }else{
                    self.expenseSelectedData = .BILL
                    self.requestExpense.removeAll()
                    self.selectExpenseVM.appendSelectBill(item: self.selectExpenseVM.itemExpenseBill[indexPath.row])
                    self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
//                    self.configCells()
                    self.selectCollectionView.reloadData()
                    if self.selectExpenseVM.itemSelectBILL.count > 1 { self.scrollToBottom() }
                }

            case .RECEIPT:
                //> Seanghay <\\
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
//                            self.configCells()
                            self.selectCollectionView.reloadData()
                            if self.selectExpenseVM.itemSelectRECEIPT.count > 1 { self.scrollToBottom() }
                        }
                        self.selectCollectionConstraint.constant = self.selectExpenseVM.itemSelectRECEIPT.isEmpty ? 0 : 70
                        self.dismiss(animated: true)
                    }
                }else{
                    self.expenseSelectedData = .RECEIPT
                    self.requestExpense.removeAll()
                    self.selectExpenseVM.appendSelectReceipt(item: self.selectExpenseVM.itemExpenseReceipt[indexPath.row])
                    self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
//                    self.configCells()
                    self.selectCollectionView.reloadData()
                    if self.selectExpenseVM.itemSelectRECEIPT.count > 1 { self.scrollToBottom() }
                }
            }
            
        case .APPROVERS:
            self.selectExpenseVM.appendSelectItem(item: self.selectExpenseVM.itemApprovers[indexPath.row])
            self.addManuallyBtn.setTitle("done".localized + " (\(self.selectExpenseVM.itemSelectApprovers.count)/4)", for: .normal)
            self.addManuallyBtn.setTitleColor(.blue, for: .normal)
            self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
            checkBtnDone()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        switch selectType {
        case .EXPENSES:
            switch self.seleteExpenseType {
            case .BILL:
                self.requestExpense.removeAll()
                for (index, item) in self.selectExpenseVM.itemSelectBILL.enumerated() {
                    if item.DOC_ID == self.selectExpenseVM.itemExpenseBill[indexPath.row].DOC_ID {
                        self.selectExpenseVM.itemSelectBILL.remove(at: index)
                    }
                }
                for (index, item) in self.backUpExpense.enumerated() {
                    if item.DOC_ID == self.selectExpenseVM.itemExpenseBill[indexPath.row].DOC_ID {
                        self.backUpExpense.remove(at: index)
                    }
                }
                if let cell = self.tableView.cellForRow(at: indexPath) as? SelectItemCell {
                    cell.deSelectCell()
                    
                }
                self.selectCollectionConstraint.constant = self.selectExpenseVM.itemSelectBILL.isEmpty ? 0 : 70
                if self.selectExpenseVM.itemSelectBILL.isEmpty {
                    self.expenseSelectedData = .ALLNO
                }
//                self.configCells()
                self.selectCollectionView.reloadData()
            case .RECEIPT:
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
                if let cell = self.tableView.cellForRow(at: indexPath) as? SelectItemCell {
                    cell.deSelectCell()
                    
                }
                self.selectCollectionConstraint.constant = self.selectExpenseVM.itemSelectRECEIPT.isEmpty ? 0 : 70
                
                //Seanghay > Change select item type <
                if self.selectExpenseVM.itemSelectRECEIPT.isEmpty {
                    self.expenseSelectedData = .ALLNO
                }
//                self.configCells()
                self.selectCollectionView.reloadData()
            }
        case .APPROVERS:
            
            //Seanghay > Remove data from select item <
            for (index, item) in self.selectExpenseVM.itemSelectApprovers.enumerated() {
                if item.USER_ID == self.selectExpenseVM.itemApprovers[indexPath.row].USER_ID {
                    self.selectExpenseVM.itemSelectApprovers.remove(at: index)
                }
            }
            self.addManuallyBtn.setTitle("done".localized + " (\(tableView.indexPathsForSelectedRows?.count ?? 0)/4)", for: .normal)
            self.addManuallyBtn.setTitleColor(.blue, for: .normal)
            self.tableView.reloadData()
            checkBtnDone()
        }
    }
}

extension SelectExpensesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.collectionView:
            return self.selectExpenseVM.tabExpense.count
        case self.selectCollectionView:
//            return self.tagCells.count
            switch self.seleteExpenseType {
            case .BILL:
                return self.selectExpenseVM.itemSelectBILL.count
            case .RECEIPT:
                return self.selectExpenseVM.itemSelectRECEIPT.count
            }
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.collectionView:
            let cell        = self.collectionView.dequeueReusableCell(withReuseIdentifier: "TabExpenseCell", for: indexPath) as! TabExpenseCell
            let dataExpense = self.selectExpenseVM.tabExpense[indexPath.row].value as! SelectExpenses
            self.itemCount  = [self.BillNum, self.ReceiptNum]
            cell.configCell(data: dataExpense, seleted: self.selectCollection[indexPath.row], itemCount: self.itemCount[indexPath.row])
            
            return cell
        case self.selectCollectionView:
            let cell = self.selectCollectionView.dequeueReusableCell(withReuseIdentifier: "SelectItemCollectionCell", for: indexPath) as! SelectItemCollectionCell
            switch self.seleteExpenseType {
            case .BILL:
                let dataBill = self.selectExpenseVM.itemSelectBILL[indexPath.row]
                cell.configCell(data: dataBill)
                cell.xButton.didTap {
                    for (ind,item) in self.selectExpenseVM.itemSelectBILL.enumerated() {
                        if item.DOC_ID == dataBill.DOC_ID {
                            
                            self.selectExpenseVM.itemSelectBILL.remove(at: ind)
                            self.selectCollectionConstraint.constant = self.selectExpenseVM.itemSelectBILL.isEmpty ? 0 : 70
                            self.selectCollectionView.reloadData()
                            self.tableView.reloadData()
                        }
                    }
                }
                return cell
            case .RECEIPT:
                let dataReceipt = self.selectExpenseVM.itemSelectRECEIPT[indexPath.row]
                cell.configCell(data: dataReceipt)
                cell.xButton.didTap {
                    for (ind,item) in self.selectExpenseVM.itemSelectRECEIPT.enumerated() {
                        if item.DOC_ID == dataReceipt.DOC_ID {
                            self.selectExpenseVM.itemSelectRECEIPT.remove(at: ind)
                            self.selectCollectionConstraint.constant = self.selectExpenseVM.itemSelectRECEIPT.isEmpty ? 0 : 70
                            self.selectCollectionView.reloadData()
                            self.tableView.reloadData()
                        }
                    }
                }
                
                return cell
            }
            
//            return self.tagCells[indexPath.item]
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
        case self.collectionView:
            let dataExpense = self.selectExpenseVM.tabExpense[indexPath.row].value as! SelectExpenses
            switch dataExpense.cellType {
            case .BILL: //Seanghay > WHEN TAP BILL or E-INVOICE <
                self.selectCollectionConstraint.constant    = self.selectExpenseVM.itemSelectBILL.isEmpty ? 0 : 70
                self.seleteExpenseType                      = .BILL
                self.selectCollection                       = [false, true]
                self.collectionView.reloadData()
//                self.configCells()
                self.selectCollectionView.reloadData()
                self.tableView.reloadData()
            case .RECEIPT: //Seanghay > WHEN TAP RECEIPT <
                if isFirstLoad { //Seanghay > REQUEST LIST EXPENSE WHEN FIRST TAP <
                    self.fetExpense(EXPT_TYPE: "R", PAGE_NO: 1, isShowLoading: true)
                }
                self.isFirstLoad                            = false
                self.selectCollectionConstraint.constant    = self.selectExpenseVM.itemSelectRECEIPT.isEmpty ? 0 : 70
                self.seleteExpenseType                      = .RECEIPT
                self.selectCollection                       = [true, false]
                self.collectionView.reloadData()
//                self.configCells()
                self.selectCollectionView.reloadData()
                self.tableView.reloadData()
            default:
                break
            }
        case self.selectCollectionView: //Seanghay > TAP SELECT ITEM EXPENSE TO DELETE ITEM THAT SELECTED <
            if let cell = self.selectCollectionView.cellForItem(at: indexPath) as? SelectItemCollectionCell {
                if cell.xButton.isHidden == true {
                    cell.selectCell()
                }else{
                    cell.deSelectCell()
                }
                
            }
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch collectionView {
        case self.selectCollectionView:
            if let cell = self.selectCollectionView.cellForItem(at: indexPath) as? SelectItemCollectionCell {
                cell.deSelectCell()
            }
            
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case self.selectCollectionView:
            switch self.seleteExpenseType {
            case .BILL:
                let tag             = self.selectExpenseVM.itemSelectBILL[indexPath.item]
                let textWidth       = (tag.TRCO_CMENM ?? "").size(withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium)]).width
                let textWidthAmount = (tag.TOTL_AMT ?? "").size(withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium)]).width
                let textWidthCur    = (tag.TRCO_TRSC_CCY_CD ?? "").size(withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium)]).width
                // Adjust width to fit content with padding
                let itemWidth       = textWidth + textWidthAmount + textWidthCur + 50 // Add padding for text
                let maxWidth        = collectionView.frame.width

                // Ensure the item width respects the spacing
                return CGSize(width: min(itemWidth, maxWidth - 20), height: 40)
                
            case .RECEIPT:
                let tag             = self.selectExpenseVM.itemSelectRECEIPT[indexPath.item]
                let textWidth       = (tag.TRCO_CMENM ?? "").size(withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium)]).width
                let textWidthAmount = (tag.TOTL_AMT ?? "").size(withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium)]).width
                let textWidthCur    = (tag.TRCO_TRSC_CCY_CD ?? "").size(withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium)]).width
                // Adjust width to fit content with padding
                let itemWidth       = textWidth + textWidthAmount + textWidthCur + 50 // Add padding for text
                let maxWidth        = collectionView.frame.width

                // Ensure the item width respects the spacing
                return CGSize(width: min(itemWidth, maxWidth - 20), height: 40)
                
            }
            
        default:
            return CGSize(width: 50, height: 300)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView {
        
        case self.selectCollectionView:
            return UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 5)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
}

extension UIViewController {
    func popSelectApprovalItem(selectCount: String = "0",selectData: [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC6], BLTB_CD: String = "", optionType: SelectType, completion: @escaping Completion_Data = {_,_  in}) {
        
        let vc = self.callCommonPopup(withStorybordName: "SelectExpensesSB", identifier: "SelectExpensesVC") as! SelectExpensesVC
        
        vc.selectType       = optionType
        vc.requestApprovers = selectData
        vc.selectCount      = selectCount
        vc.BLTB_CD          = BLTB_CD
        
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in 541 }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = false
        }
        vc.didOptionCompletion = { str,data in
            completion(str,data)
            self.dismiss(animated: true)
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func popSelectApprovalItemExpense(selectCount       : String = "0",
                                      filterDateBill    : RowType,
                                      filterDateReceipt : RowType,
                                      selectData        : [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1],
                                      optionType        : SelectType,
                                      selectType        : SelectedExpenseType,
                                      completion        : @escaping Completion_DataExpense = {_,_,_,_,_    in}) {
        
        let vc = self.callCommonPopup(withStorybordName: "SelectExpensesSB", identifier: "SelectExpensesVC") as! SelectExpensesVC
        
        vc.selectType                           = optionType
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
    
    func popAddOtherManual(dataManualExpense: ApprovalContent? = nil,
                           dataDetailExpense: WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1? = nil,
                           dataEditExpense  : EditArticleData? = nil,
                           dataR002         : WABOOKSStruct.RECDoc_Protocol? = nil,
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

//MARK: - UITextFieldDelegate
extension SelectExpensesVC: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.searchTextField.text       = textField.text ?? ""
        self.addManullyBtnView.isHidden = true
        switch self.selectType {
        case .APPROVERS:
            if (self.searchTextField.text != ""){
                self.tableView.tableHeaderView = self.view.createSpinnerFooter()
                self.selectExpenseVM.fetApproval(BLTB_CD        : self.BLTB_CD,
                                                 USER_NM        : self.searchTextField.text ?? "",
                                                 isShowLoading  : false,
                                                 isSearching    : true) { (result) in
                    switch result {
                    case .success(let data):
                        self.selectExpenseVM.initApprover(data: data)
                        self.tableView.tableHeaderView = nil
                        self.tableView.reloadData()

                    case .failure(let error):
                        self.alert(message: error.localizedDescription)
                    }
                }
                
            }else{
                self.selectExpenseVM.itemApprovers = []
                self.fetchApproval()
                self.tableView.tableHeaderView = nil
            }
            
        case .EXPENSES:
            switch self.seleteExpenseType{
            case .BILL:
                let EXPT_TYPE = "E"
                if  (self.searchTextField.text == ""){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.billPage                           = 1
                        self.clearTextButton.isHidden           = true
                        self.tableView.tableHeaderView          = nil
                        self.selectExpenseVM.itemExpenseBill    = []
                        
                        self.fetExpense(SRCH_WD         : "",
                                        EXPT_TYPE       : EXPT_TYPE,
                                        FROM_DT         : self.selectExpenseVM.selectedDate?.value.fromDate ?? "",
                                        TO_DT           : self.selectExpenseVM.selectedDate?.value.toDate ?? "",
                                        PAGE_NO         : self.billPage, isShowLoading: false,
                                        isPaginationBill: true)
                    }
                }else{
                    self.clearTextButton.isHidden = false
                    self.tableView.tableHeaderView = nil
                    self.fetExpense(SRCH_WD: self.searchTextField.text?.lowercased() ?? "", EXPT_TYPE: EXPT_TYPE, PAGE_NO: 1, isShowLoading: false)
                }
                
            case .RECEIPT:
                if self.searchTextField.text == ""{
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
                }else{
                    self.clearTextButton.isHidden = false
                    self.fetExpense(SRCH_WD         : self.searchTextField.text?.lowercased() ?? "",
                                    EXPT_TYPE       : "R",
                                    PAGE_NO         : 1,
                                    isShowLoading   : false)
                    self.tableView.tableHeaderView = nil
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.addManullyBtnView.isHidden = true
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           view.endEditing(true)
        self.addManullyBtnView.isHidden = false
        tableView.endUpdates()
    }
}

extension SelectExpensesVC {
    private func getFullscreenHeight() -> CGFloat {
        let statusBarManager    = UIApplication.shared.statusBarManagerInConnectedScenes
        let statusBarHeight     = statusBarManager?.statusBarFrame.height ?? 0
        let fullscreenHeight    = UIScreen.main.bounds.height - statusBarHeight
        
        return fullscreenHeight
    }
}

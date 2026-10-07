//
//  ReceiptListVC.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 8/1/21.
//

import UIKit
import SDWebImage
import IQKeyboardManagerSwift

class ReceiptListVC: UIViewController {
    
    //MARK: - @IBOutlet
    // No Invoice Registered
    @IBOutlet weak var viewNoReceiptList                : UIView!
    @IBOutlet weak var labelNoInvoiceRegister           : UILabel!
    @IBOutlet weak var labelClickOn                     : UILabel!
    @IBOutlet weak var labelButtonToAdd                 : UILabel!
    @IBOutlet weak var labelAndSubmitExspenseReceipts   : UILabel!
    
    //No Internet Connection View
    @IBOutlet weak var noInternetConnectionView         : UIView!
    @IBOutlet weak var noConDescrLbl                    : UILabel!
    @IBOutlet weak var noConTitleLbl                    : UILabel!
    @IBOutlet weak var noConTryAgainBtn                 : UIButton!
    
    @IBOutlet weak var tableView        : UITableView!
        
    //MARK: - Variable
    var receiptListVM   = ReceiptListVM()
    var eInvoiceVM      = EInvoiceVM()
     
    var receiptList     : [[MREC_R006.RESPONSE.REC]]    = [[]]
    var paginationList  : [MREC_R006.RESPONSE]          = []
    var sectionArray    = [String]()
    
    var isRefresh       = false
    var isReload        = false
    var page            = 1
    var isLastRecord    = false
    var isFetching      = false
    var isDocument      = false
     
    var indexPathUpdate = IndexPath()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return control
    }()
    
    var localImage : UIImage = UIImage()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.tableView.refreshControl = refreshControl
        
        self.checkingNotify()
        self.setUpTable()
        self.setLocalized()
         
        self.noConTitleLbl.getlocalizedFont()
        self.noConDescrLbl.getlocalizedFont()
        self.noConTryAgainBtn.getlocalizedFont()
        
        self.labelNoInvoiceRegister.getlocalizedFont()
        self.labelClickOn.getlocalizedFont()
        self.labelButtonToAdd.getlocalizedFont()
        self.labelAndSubmitExspenseReceipts.getlocalizedFont()
        
       
    }
    
    //hide navigationBar on SubmitReceiptVC
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationItem.backButtonTitle = ""
       
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Only restore nav bar when going back (popped), not when pushing forward
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    // Preapre for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case NotifyKey.gotoReceiptDetailVC.rawValue:
            let vc = segue.destination as! ReceiptDetailsVC
            vc.modalPresentationStyle = .fullScreen
            vc.receiptList = sender as? MREC_R006.RESPONSE.REC
            
        case NotifyKey.gotoSubmitReceiptVC.rawValue:
            let vc = segue.destination as! SubmitReceiptVC
            vc.isFromEditing    = "N"
//            let vc = segue.destination as! NewSubmitReceiptVC
//            vc.isFromEditing    = false
            vc.receiptList      = sender as? MREC_R006.RESPONSE.REC
            vc.modalPresentationStyle = .fullScreen
            
        default: break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.addSubview(refreshControl)
        refreshControl.layer.zPosition = -1
        refreshControl.superview?.sendSubviewToBack(self.refreshControl)
    }
    
    //MARK: - Private func
    private func setUpTable() {
        tableView.tableFooterView = UIView()
        tableView.contentInset    = UIEdgeInsets.init(top: 0, left: 0, bottom: 45, right: 0) // Top: 45 from UIView Contianer
    }
    
    @objc func setupLocalized() {
        self.labelNoInvoiceRegister.text            = "no_invoice_registered".localized
        self.labelClickOn.text                      = "tap_on".localized
        self.labelButtonToAdd.text                  = "button_to_add".localized
        self.labelAndSubmitExspenseReceipts.text    = "and_submit_expense_receipts".localized
    }
    
    private func checkingNotify() {
        MyNotify.listen(self, selector: #selector(reloadAfterUploadImage), name: .reloadAfterUploadImage)
        MyNotify.listen(self, selector: #selector(reloadAfterUpdateOrDeleteOrSubmit), name: .reloadAfterUpdateOrDeleteOrSubmit)
        MyNotify.listen(self, selector: #selector(reloadReceiptListVC), name: .reloadReceiptListVC)
        MyNotify.listen(self, selector: #selector(setupLocalized), name: .reloadLocalize)
    }
   
    private func setLocalized() {
        noConTitleLbl.text = "connection_is_unstable".localized
        noConDescrLbl.text = "connection_is_unstable_please_try_again_later".localized
        noConTryAgainBtn.setTitle("try_again".localized, for: .normal)
        
        self.labelNoInvoiceRegister.text            = "no_invoice_registered".localized
        self.labelClickOn.text                      = "tap_on".localized
        self.labelButtonToAdd.text                  = "button_to_add".localized
        self.labelAndSubmitExspenseReceipts.text    = "and_submit_expense_receipts".localized
         
    }
    
    private func alertMessage(title: String, msg: String, _ completion: @escaping () -> () = {}) {
        self.customAlert(type       : .CONFIRM_ALERT,
                         image      : "badge_failed",
                         title      : title,
                         message    : msg,
                         redTitle   : "",
                         greyTitle  : "close".localized) { (_) in
            completion()
        }
    }
     
    private func disableRefreshing() {
        if isRefresh {
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.isRefresh ? 0.3 : 0)) {
                self.isRefresh                  = false
                self.tableView.isScrollEnabled  = !self.isRefresh
                self.refreshControl.endRefreshing()
            }
        }
    }
     
    private func setIndicator(isSpin: Bool) {
        let spinner = UIActivityIndicatorView(style: .medium)
        isSpin ? spinner.startAnimating() : spinner.stopAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        self.tableView.tableFooterView = spinner
        self.tableView.tableFooterView?.isHidden = !isSpin
    }
    
    func loadingSlowFetchingList(isSpin: Bool) {
        let spinner = UIActivityIndicatorView(style: .medium)
        isSpin ? spinner.startAnimating() : spinner.stopAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        self.tableView.backgroundView = spinner
        self.tableView.tableFooterView?.isHidden = !isSpin
    }
    
    private func finalizeReceiptTransaction(shouldReloadData: Bool = true) {
        if shouldReloadData {
            self.tableView.reloadData()
        }
        
        self.checkHasReceipt()
        self.disableRefreshing()
    }
     
    private func checkHasReceipt() {
        DispatchQueue.main.async {
            self.viewNoReceiptList.isHidden = self.sectionArray.count > 0
            self.tableView.isHidden         = self.sectionArray.count < 0
        }
    }
    
    private func clearDataResponse() {
        self.isReload       = false
        self.sectionArray   = []
        self.receiptList    = [[]]
    }
    
    private func isDuplicateData(index: Int, data: MREC_R006.RESPONSE.REC) -> Bool {
        //return self.receiptList[index].contains(where: { (($0.USE_DT ?? "") == date) ? true : false })
        return self.receiptList[index].contains(where: {$0 == data})
    }
    
    func setupNoInternetConnection() {
        self.noInternetConnectionView.isHidden = false
    }
    
    // Fetching API to get the updated receiptList MREC_R006.RESPONSE.REC
    private func fetchingR006AfterUpdate() {
        self.isFetching = true
        
        //checking selectReceiptRowAt and selectReceiptSectionAt to fetch API R006
        if Shared.selectReceiptRowAt != -1 && Shared.selectReceiptSectionAt != -1 {
            let reloadSectionAt = Shared.selectReceiptSectionAt
            let reloadRowAt     = Shared.selectReceiptRowAt
            
            var rowAt   = Shared.selectReceiptRowAt % 10
            
            // Old Logic
//            let pageAt  = (Shared.selectReceiptRowAt / 10) + 1
            
            // New Logic
            var pageAt  = 0

            for index1 in 0..<(self.paginationList.count) {
                for index2 in 0..<(self.paginationList[index1].REC.count) {
                    if self.paginationList[index1].REC[index2].DOC_ID == self.receiptList[reloadSectionAt][reloadRowAt].DOC_ID {
                        pageAt = Int(self.paginationList[index1].PAGE_NO ?? "1") ?? 1
                    }
                }
            }
             
            self.receiptListVM.fetching(body: MREC_R006.REQUEST(PAGE_NO: String(pageAt), PAGE_PER_CNT: "10")) { (error) in
                
                self.receiptListVM.isShowLoading = false //!self.isRefresh
                self.loadingSlowFetchingList(isSpin: false)
                
                if error != nil {
                    if error?.code == 1004 { //No Internet Connection
                        self.setupNoInternetConnection()
                    } else {
                        self.noInternetConnectionView.isHidden = true
                        self.alertMessage(title: "notice".localized, msg: error?.localizedDescription ?? "Error") {
                            self.finalizeReceiptTransaction(shouldReloadData: false)
                        }
                    }
                    
                    self.isFetching = false
                    
                    return
                }
                
                //success
                self.isFetching = false
       
                
                // Find Index by Compare DOC_ID
                if let obj = self.receiptList[reloadSectionAt][reloadRowAt].DOC_ID {
                    if let index = self.receiptListVM.responseList?.REC.firstIndex(where: {$0.DOC_ID == obj}) {
                        rowAt = index
                    }
                }
       
                let updatedReceipt      = self.receiptListVM.responseList?.REC[rowAt]
                if let updatedReceipt   = updatedReceipt {
                    
                    DispatchQueue.main.async {
                        self.receiptList[reloadSectionAt][reloadRowAt] = updatedReceipt
                        self.tableView.reloadRows(at: [IndexPath(row: reloadRowAt, section: reloadSectionAt)], with: .automatic)
                    }
                }
            }
        }
        
    }
    
    
    // Fetching API
    private func fetchingR006() {
        self.isFetching = true
        
        self.receiptListVM.fetching(body: MREC_R006.REQUEST(PAGE_NO: String(self.page), PAGE_PER_CNT: "10")) { (error) in
            
            self.receiptListVM.isShowLoading = false //!self.isRefresh
            self.loadingSlowFetchingList(isSpin: false)
            
            if error != nil {
                if error?.code == 1004 { //No Internet Connection
                    self.setupNoInternetConnection()
                } else {
                    self.noInternetConnectionView.isHidden = true
                    self.alertMessage(title: "notice".localized, msg: error?.localizedDescription ?? "Error") {
                        self.finalizeReceiptTransaction(shouldReloadData: false)
                    }
                }
                
                self.isFetching = false
                
                return
            }
            //GGWP Create
            
            self.noInternetConnectionView.isHidden = true
            self.setIndicator(isSpin: false) // set spinner to false after fetching success
            
            (self.isRefresh || self.isReload) ? self.clearDataResponse() : ()
            self.isLastRecord = self.receiptListVM.responseList?.NEXT_PAGE_YN == "N" // "N" is not last record, "Y" is last record
            
            self.receiptListVM.responseList?.REC.forEach {
                self.sectionArray.contains($0.INQ_GRP ?? "") ? () : self.sectionArray.append($0.INQ_GRP ?? "")
                switch $0.INQ_GRP {
                case "0000" : //self.receiptList[0].append($0)
                    if self.receiptList[0].first?.INQ_GRP == nil || self.receiptList[0].first?.INQ_GRP == "0000" {
                        self.receiptList[0].append($0)
                    }else{
                        //Create new section for "0000"
                        self.receiptList.count < self.sectionArray.count ? (self.receiptList.append([$0]))
                            : (self.receiptList[(self.sectionArray.firstIndex(of: $0.INQ_GRP ?? "") ?? 0)]).append($0)
                    }
                default:
                    if self.isDuplicateData(index: (self.receiptList.count < self.sectionArray.count) ? (self.receiptList.count - 1) : (self.sectionArray.firstIndex(of: $0.INQ_GRP ?? "") ?? 0),
                                         data   : $0) {
                        return
                    }
                    
                    self.receiptList.count < self.sectionArray.count ? (self.receiptList.append([$0]))
                        : (self.receiptList[(self.sectionArray.firstIndex(of: $0.INQ_GRP ?? "") ?? 0)]).append($0)
                }
                self.receiptListVM.responseList?.PAGE_NO = String(self.page)
            }
            
            self.paginationList.append(self.receiptListVM.responseList!)
             
            self.page += 1
            self.isFetching = false
             
            self.finalizeReceiptTransaction()
        }
    }
     
    //MARK: - @objc func
    @objc func pullToRefresh() {
        self.page           = 1
        self.isRefresh      = true
        self.isLastRecord   = false
        
        self.fetchingR006()
    }
    
    @objc func reloadAfterUploadImage() {
//        self.view.toast(image: "toast_success_ico", message: "main_submit_success_msg".localized)
//        self.customToast(image: "toast_success_ico", message: "photo_saved".localized)
        
        self.view.toast(image: "toast_success_ico", message: "photo_saved".localized)
        
        // if user scroll to at some indexPath: after Upload image (create receipt) scroll to top
        if receiptList[0].count > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        
        // Reset to Page(1st)
        self.page           = 1
        self.isRefresh      = true
        self.isLastRecord   = false
        self.fetchingR006()
    }
    
    @objc func reloadAfterUpdateOrDeleteOrSubmit(notification: Notification) {
        let noti = notification.object as? [String: String]
        
        switch noti?["CORR_TYPE"] {
        
        case "S":
            
            Shared.selectReceiptRowAt = -1
            Shared.selectReceiptSectionAt = -1
            self.reloadAfterUploadImage()
            self.view.toast(image: "toast_success_ico", message: "main_submit_success_msg".localized)
             
        case "U":
            
            Shared.selectReceiptSectionAt = indexPathUpdate.section
            Shared.selectReceiptRowAt = indexPathUpdate.row
            
            fetchingR006AfterUpdate()
            self.view.toast(image: "head_edit_white_ico", message: "main_submit_success_msg".localized)
            
        case "D":
            Shared.selectReceiptRowAt = -1
            Shared.selectReceiptSectionAt = -1
            if indexPathUpdate.row == 0 { // to check section == 0 (pendding)
                self.pullToRefresh()
            }
            else {
                self.receiptList[indexPathUpdate.section].remove(at: indexPathUpdate.row) // Remove from receipt list (array list)
                self.tableView.reloadSections(IndexSet(integer: indexPathUpdate.section), with: .automatic) // Reload Update In section
                
                if indexPathUpdate.row != (self.receiptList.first?.count ?? 0) {
                    self.tableView.scrollToRow(at: IndexPath(row: indexPathUpdate.row - 1, section: indexPathUpdate.section), at: .none, animated: false)
                }
            }
            
            // Show toast message for user after delete receipt successfully
            self.view.toast(image: "head_del_white_ico", message: "main_delete_receipt_msg".localized)
            
        case "IMG":
            Shared.selectReceiptRowAt = -1
            Shared.selectReceiptSectionAt = -1
            if indexPathUpdate.row == 0 {
                self.pullToRefresh()
            }
            else {
                self.receiptList[indexPathUpdate.section].remove(at: indexPathUpdate.row) // Remove from receipt list (array list)
                self.tableView.reloadSections(IndexSet(integer: indexPathUpdate.section), with: .automatic) // Reload Update In section
                
                if indexPathUpdate.row != (self.receiptList.first?.count ?? 0) {
                    self.tableView.scrollToRow(at: IndexPath(row: indexPathUpdate.row, section: indexPathUpdate.section), at: .none, animated: false)
                }
            }
            
        default: break
             
        }
    }
      
    @objc func reloadReceiptListVC() {
        self.receiptListVM.isShowLoading = true
//        self.loadingSlowFetchingList(isSpin: true)
        if receiptList[0].count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
       
        self.page           = 1
        self.isRefresh      = true
        self.isLastRecord   = false
        self.fetchingR006()
        
        // need to set new localized after check new language
//        self.setLocalized()
        
        self.setupLocalized()
    }
    
    @IBAction func didTapTryAgainBtn(_ sender: UIButton) {
        self.fetchingR006()
    }
     
    @objc func didSelectEInvoice(sender: UIButton) {
        
//        let TRCO_TAX_ID = self.receiptList?.TRCO_TAX_ID ?? ""
//        let TOTL_AMT    = self.receiptList?.TOTL_AMT ?? ""
//        let REG_DT      = self.receiptList?.REG_DT ?? ""
        
        let date        = Date()
        let df          = DateFormatter()
        df.dateFormat   = "yyyyMMdd"
        let TO_DT       = df.string(from: date)
        
        let dateFormatter           = DateFormatter()
        dateFormatter.timeZone      = TimeZone.current
        dateFormatter.locale        = Locale.current
        dateFormatter.dateFormat    = "yyyyMMdd"
        
        let last7Days   = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -90, to: date) ?? date)
         
        let point       = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath   = self.tableView.indexPathForRow(at: point)!
        let TRCO_TAX_ID = self.receiptList[indexPath.section][indexPath.row].TRCO_TAX_ID ?? ""
        let TOTL_AMT    = self.receiptList[indexPath.section][indexPath.row].TOTL_AMT ?? ""
        
        // Here we go
        self.eInvoiceVM.fectchEInvoiceList(TRCO_TAX_ID: TRCO_TAX_ID, TOTL_AMT: TOTL_AMT, FROM_DT: last7Days, TO_DT: TO_DT, completion: { error in
            
            if error != nil {
                if error?.code == 1007 {
                    //self.noInternetView.isHidden = false
                } else {
                    //   self.noInternetView.isHidden = true
                }
                self.showCustomAlert(titlte: "notice".localized, message: error?.localizedDescription ?? "") {}
                return
            }
             
            let vc          = self.VC(sbName: "EInvoiceSB", identifier: "EInvoiceVC") as! EInvoiceVC
            vc.eInvoiceList = self.eInvoiceVM.eInvoice_userListResponse?.REC
            vc.eInvoiceData = self.eInvoiceVM.cells
            vc.receiptList  = self.receiptList[indexPath.section][indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
}

//MARK: - UITableView
extension ReceiptListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.receiptList[section].count
    }
     
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
     
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.isScrollEnabled = !isRefresh
    }
   
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == (self.sectionArray.count - 1)
            && tableView.indexPathsForVisibleRows?.last?.row == (self.receiptList[indexPath.section].count - 1)
            && !self.isLastRecord
            && !(self.isRefresh || self.isReload)
            && self.page > 1
            && self.sectionArray.count > 0
            && !self.isFetching {
            self.setIndicator(isSpin: true)
            self.fetchingR006()
             
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
        let list            = self.receiptList[indexPath.section][indexPath.row]
        let cell            = tableView.dequeueReusableCell(withIdentifier: "ReceiptListCell", for: indexPath) as! ReceiptListCell
        cell.receiptList    = self.receiptList
    
        cell.conBtn.addTarget(self, action: #selector(didSelectEInvoice(sender:)), for: .touchUpInside)
       
        var merchant_value  = (Shared.language == .Vietnamese && list.PROV_STTS == "PP") ? "Ảnh đã lưu" : (list.TRCO_CMENM ?? "")
        if merchant_value == "Photo Saved" {
            merchant_value = "photo_saved".localized
        }
        
        let isMultiImage    = (list.REC1?.count ?? 0) < 2 ? false : true
        let isEInvoiceConn  = (list.EINV_CON_DOC_ID == nil || list.EINV_CON_DOC_ID == "") ? false : true
        let isShowEInvoice  = (list.PROV_STTS == "PP" ? true : false)
        if (list.REC1?.first?.ORG_FILE_NM ?? "").contains(".jpg") {
            self.isDocument = false
        }else{
            if list.REC1?.count == 0 {
                self.isDocument = false
            }else{
                self.isDocument = true
            }
        }
        let documentName    = list.REC1?.first?.ORG_FILE_NM?.components(separatedBy: ".")
        let documentTitle   = list.REC1?.first?.ORG_FILE_NM ?? ""
        let documentType    = documentName?.last ?? ""
        
        if list.PROV_STTS   == "PP" { // "PP" : Receipt has Image (Photo registration)
            cell.configCell(hasNoImage  : false,
                            title       : isDocument ? "Draft Receipt" : merchant_value,
                            value       : "add_detail".localized,
                            week        : list.TRSC_WEEK ?? "",
                            date        : list.USE_DT ?? "",
                            img         : list.REC1?.first?.FILE_URL ?? "",
                            isMultiImage: isMultiImage,
                            isShowEInvoice: isShowEInvoice,
                            isEInvoiceConn: isEInvoiceConn,
                            isShow: false,
                            isDocument: isDocument,
                            documentTitle: documentTitle,
                            documentType: documentType
                            
            )
             
            return cell
        }
        else {
            // "OP" : Submission completed
            // "SA" :
            // "PA" :
            cell.configCell(hasNoImage  : true,
                            title       : merchant_value,
                            value       : list.TOTL_AMT ?? "", 
                            currency    : list.TRCO_TRSC_CCY_CD ?? "",
                            week        : list.TRSC_WEEK ?? "",
                            date        : list.USE_DT ?? "",
                            isMultiImage: isMultiImage,
                            isShowEInvoice: isShowEInvoice,
                            isEInvoiceConn: isEInvoiceConn,
                            isShow: true,
                            isDocument: isDocument,documentTitle: "",documentType: ""
            )
            
            //cell.conBtn.isHidden = false
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let receiptList = self.receiptList[indexPath.section][indexPath.row]
        self.indexPathUpdate = indexPath // get indexPath to reload after edit or delete receipt by user
        
        if receiptList.PROV_STTS == "PP" {
            let secondViewController = UIStoryboard(name: "SubmitReceiptSB", bundle: nil).instantiateViewController(withIdentifier: "SubmitReceiptVC") as! SubmitReceiptVC
            secondViewController.receiptList      = self.receiptList[indexPath.section][indexPath.row]
            secondViewController.isFromEditing    = "N"
            let nav = UINavigationController(rootViewController: secondViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated:true, completion:nil)
           
           
        }
        else {
            performSegue(withIdentifier: NotifyKey.gotoReceiptDetailVC.rawValue, sender: receiptList)
        }
       
    }
     
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view                = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 35))
        view.backgroundColor    = UIColor.white
         
        let label               = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.bounds.width - 30, height: 35))
        label.font              = UIFont(name: "Inter-Regular", size: 13.0) //Init default font
        label.textColor         = UIColor(hexString: "#9FADB9")
        label.text              = self.sectionArray[section] == "0000" ? "this_week".localized : dateft(date: self.sectionArray[section])
        label.getlocalizedFont()
        view.addSubview(label)
        return view
    }
     
    // Hightlight Row when user didselect at indexPath
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ReceiptListCell {
            cell.contentView.backgroundColor = UIColor(hexString: "#F5F9FC")
        }
    }
    
    // Unhightlight Row when user didselect at indexPath
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ReceiptListCell {
            cell.contentView.backgroundColor = .white
        }
    }
     
}

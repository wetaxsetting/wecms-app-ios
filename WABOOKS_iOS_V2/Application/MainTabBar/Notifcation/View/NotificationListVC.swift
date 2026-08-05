//
//  NotificationListVC.swift
//  WABOOKS_iOS_V2
//
//  Created by MacBook on 5/17/21.
//

import UIKit

class NotificationListVC: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var tableView        : UITableView!
    
    //empty view
    @IBOutlet weak var emptyView        : UIView!
    @IBOutlet weak var emptyImgView     : UIImageView!
    @IBOutlet weak var emptyTitleLbl    : UILabel!
    @IBOutlet weak var emptyDescrLbl    : UILabel!
    
    //No Internet Connection View
    @IBOutlet weak var noInternetConnectionView : UIView!
    @IBOutlet weak var noConTitleLbl            : UILabel!
    @IBOutlet weak var noConDescrLbl            : UILabel!
    
    
    //MARK: - @Properties
    
    //Notification
    private var notificationVM      = NotificationtListVM()
    var notificationList    : [WABOOKS_MREC_R010.RESPONSE.REC] = []
    //   private var notificationListUnReadFilter  : [WABOOKS_MREC_R010.RESPONSE.REC] = []
    private var urlStrRec           : [String] = []
    
    var isRefresh       = false
    var isReload        = false
    var page            = 1
    var isLastRecord    = false
    private var isFetching      = false //checking fetching
    private let PAGE_PER_CNT    = 10
    private var currentRowAt    = 0
    private var StrWebBaseURL   = Shared.c_web_base_url
    
    var isSelectedAtIndex   = "0"
    var tapReadAll          : Bool = false
    weak var carbonNotiVC   : UIViewController?
    
//    private var isTapUnread : Bool = true
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return control
    }()
    
    //MARK: - @ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        
        self.setupView()
        //        self.setupLocalize()
//        self.checkNotify()
        
//        if isSelectedAtIndex == "0" {
//            self.unReadAction()
//        }else if isSelectedAtIndex == "1" {
//            self.allAction()
//        }
        
        // Fetch the unread notification list only on the first load.
        self.unReadAction()
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if isSelectedAtIndex == "0" {
//            self.unReadAction()
//        }else if isSelectedAtIndex == "1" {
//            self.allAction()
//        }
//
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.tableView.reloadData()
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.addSubview(refreshControl)
        self.refreshControl.layer.zPosition = -1
        self.refreshControl.superview?.sendSubviewToBack(self.refreshControl)
    }
    
    //MARK: - @IBAction
    
    @IBAction func didTapTryAgainBtn(_ sender: UIButton) {
        self.fetchNotification()
    }
    
    //MARK: - All & Unread
    private func unReadAction() {
        // Old code
//        self.page = 1
//        self.notificationList.removeAll()
//        Shared.share.isTapUnread = true
//        self.fetchNotification()
//        self.tableView.reloadData()
        
        //New code
        self.page = 1
        self.isRefresh = true
        self.isLastRecord = false
        Shared.share.isTapUnread = true
        self.notificationList.removeAll()
        
        // Call fetch directly instead of through notification
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchR010(isClickReadAll: false)
        }
    }
    
    private func allAction() {
        self.page  = 1
        self.notificationList.removeAll()
        Shared.share.isTapUnread = false
        
        self.fetchNotification()
        self.tableView.reloadData()
    }
    
//    @objc func readAllAction() {
//        self.notificationVM.fetchNotification_0007_U001(reqBody: WABOOKS_MREC_BLTB_0007_U001.REQUEST(READ_TYPE: "A", SEQ_NO: nil)) { _ in
//            UIApplication.shared.applicationIconBadgeNumber = 0
//            Shared.badgeCount = 0
//            MyNotify.send(name: .checkingBadgeCount)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.notificationList.removeAll()
//                
//                self.page           = 1
//                self.isRefresh      = true
//                self.isLastRecord   = false
//                self.fetchR010(isClickReadAll: true)
//            }
//        }
//    }
    
    //MARK: - @objc func
    @objc func pullToRefresh() {
        self.page           = 1
        self.isRefresh      = true
        self.isLastRecord   = false
        self.fetchR010()
    }
    
//    @objc func reloadNotification() {
//        self.notificationVM.isShowLoading = false
//        
//        //scroll to top when refreshing
//        if notificationList.count > 0 {
//            DispatchQueue.main.async {
//                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//            }
//        }
//        
//        self.page           = 1
//        self.isRefresh      = true
//        self.isLastRecord   = false
//        
//        
//        self.notificationVM.page = 1
//        self.notificationVM.isLastRecord    = false
//        self.notificationVM.isFetching      = false
//        self.notificationVM.isRefresh       = false
//        self.notificationVM.isReload        = false
//
//        self.notificationList.removeAll()
//        self.page           = 1
//        self.isRefresh      = true
//        self.isLastRecord   = false
//        DispatchQueue.global().async {
//            self.fetchR010()
//        }
//    }
    
    @objc func reloadLocalize() {
        
        self.page           = 1
        self.isRefresh      = true
        self.isLastRecord   = false
        self.fetchR010()
    }
    
    //MARK: - Private Functions
    
    private func setIndicator(isSpin: Bool) {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        isSpin ? spinner.startAnimating() : spinner.stopAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        self.tableView.tableFooterView = spinner
        self.tableView.tableFooterView?.isHidden = !isSpin
    }
    
    private func disableRefreshing() {
        if self.isRefresh {
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.isRefresh ? 0.3 : 0)) {
                self.isRefresh                  = false
                self.tableView.isScrollEnabled  = !self.isRefresh
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func setupLocalize() {
        
        self.emptyTitleLbl.text = "empty_notification".localized
        self.emptyDescrLbl.text = "empty_notification_descr".localized
        
        self.emptyTitleLbl.getlocalizedFont()
        self.emptyDescrLbl.getlocalizedFont()
        
    }
    
    private func setupView() {
        self.emptyView.isHidden  = true
        self.tableView.contentInset    = UIEdgeInsets.init(top: 0, left: 0, bottom: 45, right: 0) // Top: 45 from UIView Contianer
    }
    
//    private func checkNotify() {
//        MyNotify.listen(self, selector: #selector(reloadNotification), name: .reloadNotificationVC)
//        MyNotify.listen(self, selector: #selector(readAllAction), name: .readAllNotification)
//    }
    
    private func fetchNotification(isClickReadAll: Bool = false) {
        self.notificationVM.page = self.page
        self.isFetching = true // disable  fetch while fetching
        self.notificationVM.fetchR010(isShowloading : true, NOTI_TYPE: isClickReadAll ? "A" : Shared.share.isTapUnread ? "U" : "A") { error in
            
            guard error == nil else {
                
                return
            }
            
            self.noInternetConnectionView.isHidden = true
            
            self.setIndicator(isSpin: false) // set spinner to false after fetching success
            
            (self.isRefresh || self.isReload) ? self.clearDataResponse() : () //empty nofication when pullToRefresh or reload
            
            
            self.urlStrRec.append(contentsOf: self.notificationVM.urlStrRec)
            self.urlStrRec.append(contentsOf: self.notificationVM.urlStrRec)
            self.notificationList.append(contentsOf: self.notificationVM.notificationRec)
            
            self.isLastRecord = self.notificationVM.notificationList?.NEXT_PAGE_YN == "N"
            
            self.page += 1 // increase page
            self.isFetching = false
            
            if Shared.isGetNotification == true {
                self.dismiss(animated: true)
                self.readNotification()
                let DV_CD = Shared.actionData?.DV_CD ?? ""
                if DV_CD == "1" || DV_CD == "2" || DV_CD == "3" || DV_CD == "4" || DV_CD == "5"{
                    if let selectedNotification = self.notificationList.first {
                        let urlStr = self.notificationVM.mapFullUrl(notification: selectedNotification)
                        let vc        = self.VC(sbName: "NotificationSB", identifier: "NotificationCollectionView") as! NotificationCollectionView
                        vc.notificationtListVM  = self.notificationVM
                        vc.urlStrRec            = [Shared.notificationURL]
                        vc.notificationRec      = self.notificationList
                        vc.delegate             = self
                        vc.currentRowAt         = 0
                        vc.urlStr               = urlStr
                        vc.currentPage          = self.page
                        if Shared.share.isTapUnread {
                            vc.NOTI_TYPE        = "U"
                        }else{
                            vc.NOTI_TYPE        = "A"
                        }
                        self.pushVC(viewController: vc)
                    }
                }else {
                    
                    
                    let vc = self.VC(sbName: "ExpenseApprovalWeCMSSB", identifier: "ExpenseApprovalWeCMSVC") as! ExpenseApprovalWeCMSVC
                    vc.DV_CD         = Shared.actionData?.DV_CD ?? ""//Shared.DV_Cd ?? ""

                    vc.expenseApprovalVM.POST_APPR_DV  = Shared.actionData?.POST_APPR_DV ?? ""
                    vc.COMNT_SEQ_NO  = Shared.actionData?.COMNT_SEQ_NO ?? ""
                    vc.editing_COMNT_SEQ_NO = Shared.actionData?.COMNT_SEQ_NO ?? ""

                    if DV_CD == "12" {
                        /// Article
                        vc.expenseApprovalVM.POST_TYPE_CD = "01"
                    }
                    else if DV_CD == "15" {
                        // This condion follow from AOS
                        if Shared.actionData?.POST_APPR_DV  == nil {
                            vc.expenseApprovalVM.POST_TYPE_CD = "01"
                        }else{
                            ///  Approval
                            vc.expenseApprovalVM.POST_TYPE_CD = "02"
                        }
                    }
                    else{
                        ///  Approval
                        vc.expenseApprovalVM.POST_TYPE_CD = "02"
                    }
                    vc.isNotification = true
                    vc.isShouldReload = true
                    self.pushVC(viewController: vc)


                }
                Shared.isGetNotification = false
                Shared.notificationURL   = ""
            }
            self.finalizeNotiTransaction()
        }
    }
    
    func readNotification() {
        
        // READ_TYPE: "O" -> read each notification , READ_TYPE: "A" read all n otification
        self.notificationVM.fetchNotification_0007_U001(reqBody: WABOOKS_MREC_BLTB_0007_U001.REQUEST(READ_TYPE: "O", SEQ_NO: Int(Shared.actionData?.SEQ_NO ?? ""))) { (result) in
        }
    }
    
    func fetchR010(isClickReadAll: Bool = false) {
        
        self.isFetching = true
        self.notificationVM.fetching(isShowLoading: isClickReadAll ? true : false, body: WABOOKS_MREC_R010.REQUEST(PAGE_NO: self.page, PAGE_PER_CNT: self.PAGE_PER_CNT, NOTI_TYPE: isClickReadAll ? "A" : Shared.share.isTapUnread ? "U" : "A")) { (error) in
            
            DispatchQueue.main.async {
                guard error == nil else {
                    
                    if error?.code == 1004 {//No Internet Connection
                        self.noInternetConnectionView.isHidden = false
                    } else {
                        self.noInternetConnectionView.isHidden = true
                        self.alert(message: error?.localizedDescription ?? "")
                        self.setIndicator(isSpin: false) // set spinner to false after fetching failure
                        self.disableRefreshing()
                    }
                    
                    self.isFetching = false
                    
                    return
                }
                
                //Success
                
                self.noInternetConnectionView.isHidden = true
                
                self.setIndicator(isSpin: false) // set spinner to false after fetching success
                
                (self.isRefresh || self.isReload) ? self.clearDataResponse() : () //empty nofication when pullToRefresh or reload
                
                self.notificationVM.notificationList?.REC?.forEach {
                    if self.isDuplicateData(data: $0) {
                        return
                    }
                    self.notificationList.append($0)
                    self.urlStrRec.append(self.notificationVM.mapFullUrl(notification: $0))
                }
                
                self.isLastRecord = self.notificationVM.notificationList?.NEXT_PAGE_YN == "N"
                
                self.page += 1
                self.isFetching = false
                
                self.finalizeNotiTransaction()
            }
        }
    }
    
    
    //    private func mapFullUrl(notification: WABOOKS_MREC_R010.RESPONSE.REC) -> String {
    //        let BIZ_KEY     = Shared.R002_DATA?.BIZ_KEY ?? ""
    //        let DV_CD       = notification.DV_CD ?? ""
    //        let SEQ_NO      = notification.SEQ_NO ?? ""
    //        let REG_DT      = notification.REG_DT ?? ""
    //        let REG_SEQ_NO  = notification.REG_SEQ_NO ?? ""
    //        let CD_VD       = mapDVCD(DV_CD: notification.DV_CD ?? "").1
    //
    //
    //        // old : "\(StrWebBaseURL)\(CD_VD)?TITLE=%22%22&SEQ_NO=%22\(SEQ_NO)%22&BIZ_KEY=%22\(BIZ_KEY)%22&REG_DT=%22\(REG_DT)%22&REG_SEQ_NO=%22\(REG_SEQ_NO)%22"
    //        var urlStr = "\(StrWebBaseURL)\(CD_VD)?TITLE=&SEQ_NO=\(SEQ_NO)&BIZ_KEY=\(BIZ_KEY)&REG_DT=\(REG_DT)&REG_SEQ_NO=\(REG_SEQ_NO)"
    //
    //        switch notification.DV_CD ?? "0" {
    //        case "1":
    //
    //            let userID = Shared.R002_DATA?.USER_ID ?? ""
    //            // old : "\(StrWebBaseURL)\(CD_VD)?TITLE=%22%22&SEQ_NO=%22\(SEQ_NO)%22&BIZ_KEY=%22\(BIZ_KEY)%22&USER_ID=%22\(userID)%22"
    //            urlStr = "\(StrWebBaseURL)\(CD_VD)?TITLE=&SEQ_NO=\(SEQ_NO)&BIZ_KEY=\(BIZ_KEY)&USER_ID=\(userID)"
    //
    //        case "3", "4", "5":
    //            // old : "\(StrWebBaseURL)\(CD_VD)?TITLE=%22%22&SEQ_NO=%22\(SEQ_NO)%22&BIZ_KEY=%22\(BIZ_KEY)%22&REG_DT=%22\(REG_DT)%22&REG_SEQ_NO=%22\(REG_SEQ_NO)%22"
    //            urlStr = "\(StrWebBaseURL)\(CD_VD)?TITLE=&SEQ_NO=\(SEQ_NO)&BIZ_KEY=\(BIZ_KEY)&REG_DT=\(REG_DT)&REG_SEQ_NO=\(REG_SEQ_NO)"
    //        default:
    //            urlStr = ""
    //        }
    //
    //        return urlStr
    //    }
    
    private func checkingDuplicateData(notification: WABOOKS_MREC_R010.RESPONSE.REC) -> Bool {
        return self.notificationList.contains(notification)
    }
    
    private func isDuplicateData(data: WABOOKS_MREC_R010.RESPONSE.REC) -> Bool {
        return self.notificationList.contains(where: {$0 == data})
    }
    
    private func clearDataResponse() {
        
        /// noted next time
        self.isReload           = false
        self.notificationList   = []
        self.urlStrRec          = []
    }
    
    private func finalizeNotiTransaction(shouldReloadData: Bool = true) {
        if shouldReloadData {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        self.checkHasNotification()
        self.disableRefreshing()
    }
    
    private func checkHasNotification() {
        
        if self.notificationList.count < 1 {
            self.emptyView.isHidden             = false//self.notificationList.count != 0
            self.notificationVM.isShowLoading   = false //true
        } else {
            self.emptyView.isHidden             = true
            self.notificationVM.isShowLoading   = false
        }
        
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension NotificationListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return self.notificationList.count
        
        
        return self.notificationList.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as? NotificationCell else {
            return UITableViewCell()
        }
        
        if notificationList.count > indexPath.row {
            cell.configCell(item: self.notificationList[indexPath.row], unReadNoti: self.notificationList[indexPath.row].NOTI_CNFM_YN == "N")
        }
        
        
        //        cell.configCell(item: self.notificationList[indexPath.row], unReadNoti: self.notificationList[indexPath.row].NOTI_CNFM_YN == "N")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! NotificationCell
        
        
        //change to read notification after clicking
//        cell.isRead(item: self.notificationList[indexPath.row])
//        cell.bgView.backgroundColor         = .white
        cell.contentView.backgroundColor    = .white
        cell.pointView.backgroundColor      = UIColor.white
        
        let notification    = self.notificationList[indexPath.row]
        
        //update obj at indexPath
        notificationList[indexPath.row].NOTI_CNFM_YN = "Y"
        
        //        let CD_VD           = self.notificationVM.mapDVCD(DV_CD: notification.DV_CD ?? "").1
        let SEQ_NO          = notification.SEQ_NO ?? ""
        
        //        let BIZ_KEY         = Shared.R002_DATA?.BIZ_KEY ?? ""
        //        let REG_DT          = notification.REG_DT ?? ""
        //        let REG_SEQ_NO      = notification.REG_SEQ_NO ?? ""
        
#warning("This code below is not use so it should remove it.")
        //        var urlStr = "\(StrWebBaseURL)\(CD_VD)?TITLE=%22%22&SEQ_NO=%22\(SEQ_NO)%22&BIZ_KEY=%22\(BIZ_KEY)%22&REG_DT=%22\(REG_DT)%22&REG_SEQ_NO=%22\(REG_SEQ_NO)%22"
        //
        //        switch notification.DV_CD ?? "0" {
        //        case "1":
        //
        //            let userID = Shared.R002_DATA?.USER_ID ?? ""
        //            urlStr = "\(StrWebBaseURL)\(CD_VD)?TITLE=%22%22&SEQ_NO=%22\(SEQ_NO)%22&BIZ_KEY=%22\(BIZ_KEY)%22&USER_ID=%22\(userID)%22"
        //
        //        case "3", "4", "5":
        //            urlStr = "\(StrWebBaseURL)\(CD_VD)?TITLE=%22%22&SEQ_NO=%22\(SEQ_NO)%22&BIZ_KEY=%22\(BIZ_KEY)%22&REG_DT=%22\(REG_DT)%22&REG_SEQ_NO=%22\(REG_SEQ_NO)%22"
        //        default:
        //            urlStr = ""
        //        }
        
        
        
        
        // old api
        //        if notification.NOTI_CNFM_YN == "N" { //unread notification
        //            self.notificationVM.fetchNotification_U001(reqBody: WABOOKS_MREC_U001.REQUEST(SEQ_NO: Int(SEQ_NO) ?? 0, NOTI_CNFM_YN: "Y")) { (result) in
        //
        //                self.notificationList[indexPath.row].NOTI_CNFM_YN = "Y"
        //                let currentBadge = self.notificationVM.u001_data?.PUSH_BADGE_COUNT ?? 0
        //                UIApplication.shared.applicationIconBadgeNumber = currentBadge
        ////                Shared.badgeCount = currentBadge
        ////                MyNotify.send(name: .checkingBadgeCount)
        //            }
        //        }
        
        
        
        //        let BIZ_KEY         = Shared.R002_DATA?.BIZ_KEY ?? ""
        //        let REG_DT          = notification.REG_DT ?? ""
        //        let REG_SEQ_NO      = notification.REG_SEQ_NO ?? ""
        //        var urlStr = "\(StrWebBaseURL)\(CD_VD)?TITLE=&SEQ_NO=\(SEQ_NO)&BIZ_KEY=\(BIZ_KEY)&REG_DT=\(REG_DT)&REG_SEQ_NO=\(REG_SEQ_NO)"
        //
        //        switch notification.DV_CD ?? "0" {
        //        case "1":
        //
        //            let userID = Shared.R002_DATA?.USER_ID ?? ""
        //            urlStr = "\(StrWebBaseURL)\(CD_VD)?TITLE=&SEQ_NO=\(SEQ_NO)&BIZ_KEY=\(BIZ_KEY)&USER_ID=\(userID)"
        //
        //        case "3", "4", "5":
        //            urlStr = "\(StrWebBaseURL)\(CD_VD)?TITLE=&SEQ_NO=\(SEQ_NO)&BIZ_KEY=\(BIZ_KEY)&REG_DT=\(REG_DT)&REG_SEQ_NO=\(REG_SEQ_NO)"
        //        default:
        //            urlStr = ""
        //        }
        
        
        //  New api
        if notification.NOTI_CNFM_YN == "N" {  //unread notification
            self.notificationVM.fetchNotification_0007_U001(reqBody: WABOOKS_MREC_BLTB_0007_U001.REQUEST(READ_TYPE: "O", SEQ_NO: Int(SEQ_NO))) { (result) in
                self.notificationList[indexPath.row].NOTI_CNFM_YN = "Y"
                let currentBadge = self.notificationVM.u001_data?.PUSH_BADGE_COUNT ?? 0
                // UIApplication.shared.applicationIconBadgeNumber = currentBadge
                
                
                if Shared.badgeCount > 0 {
                    Shared.badgeCount = Shared.badgeCount - 1
                } else {
                    Shared.badgeCount = 0
                }
                
                UIApplication.shared.applicationIconBadgeNumber = Shared.badgeCount
                MyNotify.send(name: .checkingBadgeCount) // notification button style has new notification

            }
        }
        if notification.DV_CD == "1" || notification.DV_CD == "2" || notification.DV_CD == "3" || notification.DV_CD == "4" || notification.DV_CD == "5" {
            let selectedNotification = notificationList[indexPath.row]
            let urlStr = notificationVM.mapFullUrl(notification: selectedNotification)
            let vc        = self.VC(sbName: "NotificationSB", identifier: "NotificationCollectionView") as! NotificationCollectionView
            vc.notificationtListVM  = self.notificationVM
            vc.urlStrRec            = self.urlStrRec
            vc.notificationRec      = self.notificationList
            vc.delegate             = self
            vc.urlStr               = urlStr
            vc.currentRowAt         = indexPath.row
            vc.currentPage          = self.page
            if Shared.share.isTapUnread {
                vc.NOTI_TYPE        = "U"
            }else{
                vc.NOTI_TYPE        = "A"
            }
            self.pushVC(viewController: vc)
        }else {
            /*
             BB006_Notification
             Current Notification process : link -> http://surl.li/qmwss
             */
            
            let vc = self.VC(sbName: "ExpenseApprovalWeCMSSB", identifier: "ExpenseApprovalWeCMSVC") as! ExpenseApprovalWeCMSVC
            vc.DV_CD   = self.notificationList[indexPath.row].DV_CD ?? ""

            vc.expenseApprovalVM.POST_APPR_DV  = self.notificationList[indexPath.row].POST_APPR_DV ?? ""
            vc.COMNT_SEQ_NO  = self.notificationList[indexPath.row].COMNT_SEQ_NO ?? ""
            vc.editing_COMNT_SEQ_NO  = self.notificationList[indexPath.row].COMNT_SEQ_NO ?? ""

            // Check Later
            if notification.DV_CD == "12" {
                /// Article
                vc.expenseApprovalVM.POST_TYPE_CD = "01"
            }else if notification.DV_CD == "15" {
                // This condion follow from AOS
                if notification.POST_APPR_DV == nil {
                    vc.expenseApprovalVM.POST_TYPE_CD = "01"
                }else{
                    vc.expenseApprovalVM.POST_TYPE_CD = "02"
                }
            }
            else{
                ///  Approval
                vc.expenseApprovalVM.POST_TYPE_CD = "02"
            }
            vc.isNotification = true
            vc.isShouldReload = true
            self.pushVC(viewController: vc)


        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? NotificationCell {
            cell.bgView.backgroundColor         = UIColor(hexString: "F5F9FC")
            
            // Transform when touch
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseOut, animations: {
                cell.transform = CGAffineTransform.identity.scaledBy(x: 0.97, y: 0.97)
            }) { (_) in
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? NotificationCell {
            
            if self.notificationList[indexPath.row].NOTI_CNFM_YN == "Y" { //Read notificaiton
                cell.bgView.backgroundColor         = .white
                cell.pointView.backgroundColor      = UIColor.white
            }
            
            //            if !self.isTapUnread {
            //                if self.notificationList[indexPath.row].NOTI_CNFM_YN == "Y" { //Read notificaiton
            //                    cell.bgView.backgroundColor         = .white
            //                    cell.pointView.backgroundColor      = UIColor.white
            //                }
            //            }
            // Transform when release touch
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
                cell.transform = CGAffineTransform.identity.scaledBy(x: 1.01, y: 1.01)
            }) { (_) in
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    cell.transform = CGAffineTransform.identity
                }) { (_) in
                    /// ************** do action here **************
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //        let data  =  self.notificationList.count - 1
        //        if self.tableView.indexPathsForVisibleRows?.last?.row == data
        
        if self.tableView.indexPathsForVisibleRows?.last?.row == self.notificationList.count - 1
            && !self.isLastRecord
            && !(self.isRefresh || self.isReload) && !self.isFetching {
            //&& !self.isFetching && (self.notificationVM.notificationList?.REC?.count ?? 0 != 0) {
            
            self.setIndicator(isSpin: true)
            self.fetchR010()    // fix duplicate loading data
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.isScrollEnabled = !self.isRefresh
    }
}

//MARK: - NotificationDelegate

extension NotificationListVC : NotificationDelegate {
    func passValueBack(notificationVM: NotificationtListVM, notificationRec: [WABOOKS_MREC_R010.RESPONSE.REC], urlStrRec: [String], currentRowAt: Int) {
        self.isLastRecord       = notificationVM.notificationList?.NEXT_PAGE_YN == "N"
        self.currentRowAt       = currentRowAt
        self.page               = notificationVM.page
        self.notificationVM     = notificationVM
        self.notificationList   = notificationRec
        self.urlStrRec          = urlStrRec
        
        #warning("Sothea check this")
        DispatchQueue.main.async {
            self.tableView.reloadData()
//            self.tableView.scrollToRow(at: IndexPath(row: currentRowAt, section: 0), at: .none, animated: false)
        }
    }
}

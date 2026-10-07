//
//  NotificationCollectionView.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 3/9/21.
//


import UIKit

// Relocated from NotificationVC.swift (removed as dead code).
// Still adopted by NotificationListVC and used by NotificationCollectionView.
protocol NotificationDelegate {
    func passValueBack(notificationVM: NotificationtListVM, notificationRec: [MREC_R010.RESPONSE.REC], urlStrRec: [String], currentRowAt: Int)
}

class NotificationCollectionView: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate : NotificationDelegate?
    var urlStrRec : [String] = []
    var notificationRec : [MREC_R010.RESPONSE.REC] = []
    var currentRowAt    = 0
    var currentPage     = 0
    var notificationtListVM = NotificationtListVM()
    var initailScroll   = true
    var NOTI_TYPE = ""
    var urlStr = ""
    var isFirstLoaded = true
    
    private var startingScrollingOffset             = CGPoint.zero
    private var indexOfCellBeforeDragging   : Int   = 0
    private var indexOfMajorCell            : Int   = 0
    
    var didBeginScrollCollectionView : (() -> ())   = {}
    var didEndScrollCollectionView   : (() -> ())   = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate     = self
        collectionView.dataSource   = self
        collectionView.isPagingEnabled = true
        
        // set title to VC for First Init
        // self.title = mapTitleDVCD(DV_CD: notificationRec[self.currentRowAt].DV_CD ?? "")
        
        let DV_CD = notificationRec[self.currentRowAt].DV_CD ?? ""
        let SND_NM = notificationRec[self.currentRowAt].SND_NM ?? ""
        let CONT = notificationRec[self.currentRowAt].CONT ?? ""
        self.title = "\(mapDVCD(DV_CD:  DV_CD, SN_NM: SND_NM , CONT: CONT).0)"
        
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.shadowImage            = UIImage()
        self.navigationController?.navigationBar.barTintColor           = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes    = [.foregroundColor: UIColor.black]
        
        let backItem    = UIBarButtonItem()
        backItem.title  = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        self.navigationController?.navigationBar.backItem?.title = ""

        
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.delegate?.passValueBack(notificationVM: self.notificationtListVM, notificationRec: self.notificationRec, urlStrRec: urlStrRec, currentRowAt: currentRowAt)
    }
    
    func mapTitleDVCD(DV_CD: String) -> String {
        switch DV_CD {
        case "1": return "contacts".localized//거래처
        case "2": return "급여명세" //not used
        case "3": return "credit".localized//입금
        case "4": return "debit".localized//Expense
        case "5": return "daily_cash".localized //보고서
        default : return ""
        }
    }
    
    func formatCurrencyFromJSON(jsonString: String) -> String? {
        // Extracting the JSON string from the given input
        guard let jsonSubstringRange = jsonString.range(of: "\\[{.*?}\\]", options: .regularExpression) else {
            #if DEBUG
            print("Invalid JSON format")
            #endif
            return nil
        }

        let jsonSubstring = jsonString[jsonSubstringRange]

        // Convert the substring to a String
        let extractedJSON = String(jsonSubstring)

        // Decoding the JSON data
        if let jsonData = extractedJSON.data(using: .utf8),
           let jsonArray = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: String]],
           let firstItem = jsonArray.first,
           let amountString = firstItem["AMT"],
           let currencyCode = firstItem["CCY_CD"],
           let amount = Double(amountString) {

            // Formatting the values
            let formattedString = "\(currencyCode) \(String(format: "%.2f", amount))"
            return formattedString
        } else {
            print("Invalid JSON format")
            return nil
        }
    }
    
    // a @[Hello 2024](06auguset@testing.com) @[Sokny Ran (Yakuza)](soknyran.dev@gmail.com) b @[E-Youvita](vita@gmail.com)
    func extractNames(inputString: String) -> String {
        var modifiedString = inputString

        // Remove occurrences of (email)
        modifiedString = modifiedString.replacingOccurrences(of: "\\([^\\)]+\\)", with: "", options: .regularExpression)

        // Remove occurrences of @[...] and extract names
        let regexPattern = "\\@\\[([^\\]]*)\\]"

        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: [])
            let range = NSRange(location: 0, length: modifiedString.utf16.count)

            var extractedNames = [String]()

            regex.enumerateMatches(in: modifiedString, options: [], range: range) { (match, _, _) in
                if let matchRange = match?.range(at: 1) {
                    if let range = Range(matchRange, in: modifiedString) {
                        extractedNames.append(String(modifiedString[range]))
                    }
                }
            }

            // Replace occurrences of @[...] with extracted names
            for name in extractedNames {
                modifiedString = modifiedString.replacingOccurrences(of: "@[\(name)]", with: name)
            }

            return modifiedString.trimmingCharacters(in: .whitespaces)
        } catch {
            print("Error creating regex: \(error)")
            return modifiedString
        }
    }
    
    
    func mapDVCD(DV_CD: String, SN_NM: String, CONT: String) -> (String, String, String) {
        switch DV_CD {
        case "1":
            // CONT arrives as "KM|EN"; WeCMS has no Khmer, so always use the EN half.
            let cont        = CONT.components(separatedBy: "|")
            let contactNo   = cont.count == 1 ? "" : cont.last ?? ""
            let titleStr    = "status_of_000".localized
            return ("contact".localized, "mobl_0010_002.act", String(format: titleStr, contactNo)) //거래처
        case "2":
            let date        = formatteDate(dateStr: CONT)
            let titleStr    = "status_of_000".localized
            //return ("급여명세", "", "") //not used
            return ("Payroll", "szon_0004_008.act", String(format: titleStr, date))
        case "3":
            let date        = formatteDate(dateStr: CONT)
            let titleStr    = "status_of_000".localized
            //let titleStr = "there_are_new_deposit_transactions".localized
            return ("deposit".localized + " ", "szon_0004_008.act", String(format: titleStr, date)) //입금
        case "4":
            let date        = formatteDate(dateStr: CONT)
            let titleStr    = "status_of_000".localized
            //let titleStr = "there_are_new_withdrawal_transactions".localized
            return ("withdrawal".localized + " ", "szon_0004_009.act", String(format: titleStr, date)) //Expense
        case "5":
            let date        = formatteDate(dateStr: CONT)//CONT.formatDate(format: toFormatStr, fromFormat: "yyyyMMdd")//CONT
            let titleStr    = "status_of_000".localized
            return ("report".localized + " ", "szon_0004_010.act", String(format: titleStr, date)) //보고서
        case "6":
            let titleStr    = "request_an_expense_approval_000".localized
            
//            [{\"AMT\":\"1.000000\",\"CCY_CD\":\"KHR\"}]
             let formattedCurrency = formatCurrencyFromJSON(jsonString: CONT) ?? ""
            
            return (SN_NM, "", String(format: titleStr, formattedCurrency))
        case "7":
            let titleStr    = "approved_your_expense_approval_request_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "8":
            let titleStr    = "approved_your_expense_approval_request_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "9":
            let titleStr    = "reject_your_expense_approval_request_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "10":
            let titleStr    = "reject_your_expense_approval_request_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "11":
            let titleStr    = "request_an_approval_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "12":
            let titleStr    = "posted_an_article_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "13":
            let titleStr    = "approved_your_approval_request_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "14":
            let titleStr    = "approved_your_approval_request_000".localized
            return (SN_NM, "", String(format: titleStr, CONT))
        case "15":
            // Remove "@[" and "]"
            let modifiedString = CONT.replacingOccurrences(of: "\\@\\[|\\]", with: "", options: .regularExpression)
            let lastModifiedString = extractNames(inputString: modifiedString)
            let titleStr    = "commented_on_your_post_000".localized
            let titleString    = "commented on your post with attachment.".localized
            if CONT == "" {
                return (SN_NM, "", String(format: titleString, lastModifiedString))
            }else{
                return (SN_NM, "", String(format: titleStr, lastModifiedString))
            }
//        case "16":
//            let titleStr    = "commented_on_your_post_000".localized
//            // Remove "@[" and "]"
//            let modifiedString = CONT.replacingOccurrences(of: "\\@\\[|\\]", with: "", options: .regularExpression)
//            return (SN_NM, "", String(format: titleStr, modifiedString))
        default : return ("", "", "")
        }
    }
    
}

extension NotificationCollectionView : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notificationRec.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellForRowAt \(indexPath.row)")
        
        guard let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationWebViewCell", for: indexPath) as? NotificationWebViewCell else { return UICollectionViewCell() }
        
        cell.baseWebview?.delegate = self
        
        //  old flow
        //  cell.loadWebView(urlStr: urlStrRec[indexPath.row])
        
        if isFirstLoaded {
            cell.loadWebView(urlStr: urlStr)
        } else {
            let selectedNotification = notificationRec[indexPath.row]
            let urlStr = notificationtListVM.mapFullUrl(notification: selectedNotification)
            cell.loadWebView(urlStr: urlStr)
        }
        
        // disable loading webview index 0 when initial VC, util selectRowAt == 0
//        if !initailScroll || currentRowAt == indexPath.row {
//            cell.baseWebview?.delegate = self
//            cell.loadWebView(urlStr: urlStrRec[indexPath.row])
//        }
        
        return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(" ========= willDisplay  ========= \(indexPath)")
        
        // Setup scrollToItem and Title when first initial
        if initailScroll {
            
            // need Dispatch to work well as hell #lol
            DispatchQueue.main.async {
               
                //if not relaod data first index of collectionview not show
                self.collectionView?.reloadData()
                self.collectionView.scrollToItem(at: IndexPath(item: self.currentRowAt, section: 0), at: .left, animated: false)
                
                self.updateNotiCNFM_YN(index: self.currentRowAt)
            }
        }else{
            // To get right IndexPath.Row
            currentRowAt = indexPath.row
        }
        
        initailScroll = false
        
        if indexPath.row == self.notificationRec.count - 2 { /// Need to fetch new page
            self.notificationtListVM.page = self.currentPage
            if (self.notificationtListVM.notificationList?.NEXT_PAGE_YN ?? "N") == "Y" {
                self.notificationtListVM.fetchR010(NOTI_TYPE: NOTI_TYPE) {_ in
                    self.currentPage += 1
                    self.urlStrRec.append(contentsOf: self.notificationtListVM.urlStrRec)

                    DispatchQueue.main.async {
//                        var indexPaths : [IndexPath] = []
//                        ((self.urlStrRec.count - 10)..<self.urlStrRec.count).forEach({
//                            print($0)
//                            indexPaths.append(IndexPath(row: $0, section: 0))
//                        })
//                        print(self.notificationtListVM.notificationRec, "notitfication rec")
                        
                        self.notificationRec.append(contentsOf: self.notificationtListVM.notificationRec)

//                       self.collectionView.insertItems(at: indexPaths)
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print("-------- didEndDisplayCell \(indexPath.row) ")
        
        // To reload the end display URL by indexPath
//        let cell    = cell as! NotificationWebViewCell
//        cell.baseWebview?.delegate = self
//        cell.loadWebView(urlStr: urlStrRec[indexPath.row])
        
        cell.prepareForReuse()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.isEqual(collectionView) {
       
            print("--->> scrollViewDidEndDragging : ",currentRowAt)
            
            self.title = mapTitleDVCD(DV_CD: notificationRec[currentRowAt].DV_CD ?? "")
     
            self.updateNotiCNFM_YN(index: currentRowAt)
            
        }
    }
    func updateNotiCNFM_YN(index : Int){
        // Update Read Notification based on Index
        if self.notificationRec[index].NOTI_CNFM_YN == "N" {
            self.notificationtListVM.fetchNotification_U001(reqBody: MREC_U001.REQUEST(SEQ_NO: Int(notificationRec[index].SEQ_NO ?? "0") ?? 0, NOTI_CNFM_YN: "Y")) { (result) in
                self.notificationRec[index].NOTI_CNFM_YN = "Y"
                let currentBadge    = self.notificationtListVM.u001_data?.PUSH_BADGE_COUNT ?? 0
                UIApplication.shared.applicationIconBadgeNumber = currentBadge
            }
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        // change title while collection cell being transmitted from one cell to another
//        if scrollView.isEqual(collectionView) {
//            let offSet = scrollView.contentOffset.x
//            let width  = scrollView.frame.width
//            let index  = Int(round(offSet/width))
//
//            // Update Read Notification based on Index
//            if self.notificationRec[index].NOTI_CNFM_YN == "N" {
//                self.notificationtListVM.fetchNotification_U001(reqBody: MREC_U001.REQUEST(SEQ_NO: Int(notificationRec[index].SEQ_NO ?? "0") ?? 0, NOTI_CNFM_YN: "Y")) { (result) in
//                    self.notificationRec[index].NOTI_CNFM_YN = "Y"
//                    let currentBadge    = self.notificationtListVM.u001_data?.PUSH_BADGE_COUNT ?? 0
//                    UIApplication.shared.applicationIconBadgeNumber = currentBadge
//                }
//            }
//        }
//    }
    
}

//MARK: - BaseWebViewDelegate
extension NotificationCollectionView: BaseWebViewDelegate {
    func baseWebViewResponseCode(actionCode: ActionCode, actionData: [String : Any]?) {
        // Pending Action code
    }
    
    func baseWebViewDidFinishLoad(webView: WKWebView, title: String) {
        isFirstLoaded = false
//        let finishUrl = webView.url?.absoluteString
//        titleLbel.text = webView.title ?? ""
//        print("Row at \(self.rowAt) current Row \(self.currentRowAt)")
//        if self.notificationRec[self.rowAt].NOTI_CNFM_YN == "N" {
//            self.notificationtListVM.fetchNotification_U001(reqBody: MREC_U001.REQUEST(SEQ_NO: Int(notificationRec[self.rowAt].SEQ_NO ?? "0") ?? 0, NOTI_CNFM_YN: "Y")) { (result) in
//                self.notificationRec[self.rowAt].NOTI_CNFM_YN = "Y"
//                let currentBadge    = self.notificationtListVM.u001_data?.PUSH_BADGE_COUNT ?? 0
//                UIApplication.shared.applicationIconBadgeNumber = currentBadge
//            }
//        }

    }
    
    func showAlertMessage(message: String, handler: (() -> Void)?) {
        LoadingView.delayBeforeHide(seconds: 0.3) { (status) in
            self.alert(title: "", message: message, okbtn: "comfirm".localized) {
                handler?()
            }
        }
    }
    
    func showAlertMessageError(messageError: String) {
//        LoadingView.delayBeforeHide(seconds:  0.3) { (_) in
//            self.alert(title: "", message: messageError, okbtn: "comfirm".localized) {
//                // pending -> Go Back
//            }
//        }
        LoadingView.delayBeforeHide(seconds:  0.3) { (_) in
            if messageError.isEmpty {
                
            }
            else {
                
                self.showCustomAlert(titlte: "notice".localized, message: messageError,greyBtn: "try_again".localized) {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func showAlertPromptMessage(message: String) {
        self.alert(message: message)
    }
    
    func showAlertConfirmMessage(message: String, handler: ((Bool) -> Void)?) {
        self.alertYesNo(title: "", message: message, nobtn: "cancel".localized, yesbtn: "comfirm".localized) { (status) in
            handler?(status)
        }
    }
    
    func navigationAction(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            
            let urlScheme = navigationAction.request.url?.scheme ?? ""
            
            if(isItunesURL(url.absoluteString)) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
                decisionHandler(.cancel)
            }
            else if urlScheme != "http" && urlScheme != "https" {
                if urlScheme.contains("about") {
                    decisionHandler(.allow)
                }
                else {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    decisionHandler(.cancel)
                }
            }
            else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}

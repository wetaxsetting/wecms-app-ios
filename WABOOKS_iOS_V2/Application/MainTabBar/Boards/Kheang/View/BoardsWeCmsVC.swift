//
//  BoardsWeCmsVC.swift
//  WABOOKS_iOS_V2
//
//  Created by lymanny on 9/1/25.
//
//  Note: This class was adapted from BoardsVC
//  Some conditions and methods have been modified to fit the requirements of the BoardsWeCms feature.

import UIKit

import IQKeyboardManagerSwift

class BoardsWeCmsVC: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var tableView                : UITableView!
    @IBOutlet weak var collectionView           : UICollectionView!
    
    @IBOutlet weak var filterButton             : UIButton!
    @IBOutlet weak var searchButton             : UIButton!
    
    @IBOutlet weak var titleBoardLabel          : UILabel!
    @IBOutlet weak var descriptionBoardLabel    : UILabel!

    //MARK: - Propertiees & Variable
    private lazy var refreshControl : UIRefreshControl = {
        var animateImages = [UIImage]()
        for index in 1...12 {
            if let image = UIImage(named:"img_loading\(index < 10 ? "0\(index)" : "\(index)")") {
                animateImages.append(image)
            }
        }
        
        let refreshImage               = UIImageView(frame: CGRect(x: (UIScreen.main.bounds.width / 2)-(38 / 2), y: 10, width: 38, height: 38))
        refreshImage.animationImages   = animateImages
        refreshImage.animationDuration = 0.5
        refreshImage.startAnimating()
        
        var _refreshControl = UIRefreshControl()
        _refreshControl.addSubview(refreshImage)
        _refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return _refreshControl
    }()
    
    var indicator           = UIActivityIndicatorView()
    var isPullToRefresh     : Bool = false
    var boardsVM            = BoardsVM()
    var BLTB_CD             : String?
    var isRefresh           = false
    var selectedDate        : DateFilterModel?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isRefresh = false
        self.titleBoardLabel.getlocalizedFont()
        displayAddFloatButton(true)
        displayTabBar(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.addSubview(refreshControl)
        self.refreshControl.layer.zPosition = -1
        self.refreshControl.superview?.sendSubviewToBack(self.refreshControl)
        tableView.reloadData()
    }
    
    //MARK: - @IBAction
    @IBAction func filterButtonPressed(_ sender: Any) {
        self.tableView.tableHeaderView = nil
        self.tableView.tableFooterView = nil
        
        let vc = self.VC(sbName: "SelectOptionWithTitleSB", identifier: "SelectOptionWithTitleVC") as! SelectOptionWithTitleVC
        /*
         60      => top & bottom spaces
         58 * 4  => 58 is height of one cell, and 4 multiples with item count to get all cells height
         51      => is height header view

         These three numbers must stay in step with the ones SelectOptionWithTitleVC reports
         through `heightCompletion` (`spaces = 60`, `cellHeight = 58`, `headerViewSize = 51`),
         otherwise the sheet changes size the first time a row is tapped even when the row
         count has not changed. The old value here was 85 rather than 60.
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
            self.boardsVM.PAGE_NO  = 1
            switch selectData.rowType {
            case . LastOneMonth, .LastThreeMonth, .LastSixMonth, .FilterMaually:
                self.selectedDate = selectData
                self.boardsVM.fetchBoardWeCMS(FROM_DT: selectData.value.fromDate ?? "", TO_DT: selectData.value.toDate ?? "") { result in
                    switch result {
                    case .success(_):
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.boardsVM.initDataWeCMSApproval(location: self.boardsVM.get_location())
                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                self.dismiss(animated: true)
                
            default: break
            }
        }
        // Resize the sheet to whatever it actually contains. `totalHeight` above is only the
        // opening estimate; from here on the sheet measures itself. This used to switch to
        // `.large` instead, which made the sheet full-screen however little content it held.
        let fitSheet: () -> Void = {
            guard let sheet = vc.sheetPresentationController else { return }
            totalHeight = vc.fittedSheetHeight
            if #available(iOS 16.0, *) {
                sheet.animateChanges {
                    sheet.detents = [.custom { context in min(totalHeight, context.maximumDetentValue) }, .large()]
                }
            } else {
                // iOS 15 has no custom detents; `.large` is the only way to grow.
                sheet.animateChanges { sheet.selectedDetentIdentifier = .large }
            }
        }
        vc.heightCompletion = { _ in
            // The sheet rebuilds its rows right after calling this, so measure on the next
            // run-loop turn — otherwise we would fit to the layout it is about to replace.
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
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        let vc = VC(sbName: "BoardsWeCmsSB", identifier: "SearchBoardWeCMSVC") as! SearchBoardWeCMSVC
        vc.BLTB_CD = self.BLTB_CD ?? ""
        displayAddFloatButton(false)
        displayTabBar(false)
        //        vc.tabBarController?.tabBar.isHidden = true
        self.pushVC(viewController: vc)
    }
    
    //MARK: - Function
    private func checkingNotify() {
        MyNotify.listen(self, selector: #selector(reloadAfterPostToBoardSubmit), name: .GotoBoard)
        MyNotify.listen(self, selector: #selector(reloadAfterCreateArticle), name: .reloadAfterCreateArticle)
        MyNotify.listen(self, selector: #selector(reloadAfterComment), name: .reloadAfterComment)
        MyNotify.listen(self, selector: #selector(reloadAfterChangeLocalize), name: .reloadBoardVC)
        MyNotify.listen(self, selector: #selector(reloadBoardVCAfterDetail), name: .reloadBoardVCAfterDetail)
    }
    
    private func disableRefreshing() {
        if isRefresh {
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.isRefresh ? 0.3 : 0)) {
                self.isRefresh                  = false
                self.boardsVM.isShowLoading     = true
                self.collectionView.isUserInteractionEnabled = true
                self.tableView.isScrollEnabled  = !self.isRefresh
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func stopIndicator() {
        self.indicator.stopAnimating()
        self.indicator.hidesWhenStopped = true
    }
    
    private func showIndicator() {
        self.indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        self.indicator.style = UIActivityIndicatorView.Style.large
        self.indicator.center = self.view.center
        self.indicator.startAnimating()
        self.indicator.backgroundColor = .clear
        self.view.addSubview(indicator)
    }
    
    func registerCell() {
        collectionView.register(UINib(nibName: "SectionTypeCell", bundle: nil), forCellWithReuseIdentifier: "SectionTypeCell")
        tableView.register(UINib(nibName: "FullContentWeCMSCell", bundle: nil), forCellReuseIdentifier: "FullContentWeCMSCell")
        tableView.register(UINib(nibName: "DescriptionBoardCell", bundle: nil), forCellReuseIdentifier: "DescriptionBoardCell")
        tableView.register(UINib(nibName: "CommentBoardCell", bundle: nil), forCellReuseIdentifier: "CommentBoardCell")
        tableView.register(UINib(nibName: "LineFooterCell", bundle: nil), forCellReuseIdentifier: "LineFooterCell")
    }
    
    func setupUI() {
        boardsVM.initSectionData()
        self.boardsVM.boardType    = .Approval
        self.boardsVM.selectedData = self.boardsVM.sectionData.first
        fetchBoard(location: self.boardsVM.get_location())
        self.titleBoardLabel.text = "approvals".localized
        self.checkingNotify() //note: don't move checkingNotify to viewWillAppear, it will call the number of notify has been listen.
        
    }
    
    func fetchBoard(location: Int, completion: @escaping () -> Void = {}) {
        collectionView.isUserInteractionEnabled = false
        
        if self.isPullToRefresh {
            self.isPullToRefresh = true
            self.stopIndicator()
        } else {
            self.stopIndicator() // prevent ចុចញាប់ពេក បិទអត់ទាន់
            self.isPullToRefresh = false
            self.showIndicator()
        }
        
        self.boardsVM.fetchBoardWeCMS() { result in
            switch result {
            case .success(_):
                self.boardsVM.initDataWeCMSApproval(location: location)
                self.descriptionBoardLabel.text = ""
                self.disableRefreshing()
            case .failure(let error):
                self.alert(message: error.localizedDescription) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            DispatchQueue.main.async {
                if self.boardsVM.sectionData.contains(where: {$0.sectionType == self.boardsVM.selectedData.sectionType}) {
                    self.boardsVM.sectionData[location].isSelected = true
                } else {
                    self.boardsVM.sectionData[location].isSelected = false
                }
                self.collectionView.reloadData()
                self.tableView.reloadData()
                self.collectionView.isUserInteractionEnabled = true
                self.boardsVM.isShowLoading = true
                self.boardsVM.isFetching = false
                self.stopIndicator()
                completion()
            }
        }
    }
    
    func reSetuphomeMenu() {
        boardsVM.sectionData[boardsVM.get_location()].isSelected = false
        boardsVM.sectionData[0].isSelected = true
        collectionView.reloadData()
        self.descriptionBoardLabel.text = ""
        self.descriptionBoardLabel.getlocalizedFont()
        
        boardsVM.LAST_PAGE_NO = 1
        boardsVM.PAGE_NO = 1
        boardsVM.showMore = false
        
        self.filterButton.isHidden = false
        self.fetchBoard(location: 0)
    }
    
    func commentPopup(indexPath: IndexPath, completion: @escaping Completion_String = {_ in}) {
        
        let vc = self.VC(sbName: "BoardsWeCmsSB", identifier: "CommentVC") as! CommentVC
        
        vc.POST_SEQ_NO   = self.boardsVM.content[indexPath.section].content[indexPath.row].REC.POST_SEQ_NO ?? ""
        vc.POST_TYPE_CD  = self.boardsVM.content[indexPath.section].content[indexPath.row].REC.POST_TYPE_CD ?? ""
        vc.BLTB_CD       = self.boardsVM.content[indexPath.section].content[indexPath.row].REC.BLTB_CD ?? ""
        vc.TOT_CMT       = self.boardsVM.content[indexPath.section].content[indexPath.row].REC.TOT_CMT ?? ""
        vc.APPR_SEQ_NO   =  self.boardsVM.content[indexPath.section].content[indexPath.row].REC.APPR_SEQ_NO ?? ""
        vc.isShowKeyboard = true
        
        let topPadding = UIApplication.shared.keyWindowInConnectedScenes?.safeAreaInsets.top
        
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    private func getFullscreenHeight() -> CGFloat {
        let statusBarManager = UIApplication.shared.statusBarManagerInConnectedScenes
        let statusBarHeight = statusBarManager?.statusBarFrame.height ?? 0
        let fullscreenHeight = UIScreen.main.bounds.height - statusBarHeight
        return fullscreenHeight
    }
    
    deinit {
        if UIDevice.current.userInterfaceIdiom == .pad {
            NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }
    
    //MARK: - OBJC
    @objc func reloadAfterChangeLocalize() {
        //notify when come to borad 1st
        self.reSetuphomeMenu()
    }
    
    @objc func reloadBoardVCAfterDetail() {
        boardsVM.isShowLoading = false
        self.boardsVM.fetchBoardWeCMS() { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
            self.boardsVM.isShowLoading = true
            self.boardsVM.isFetching = false
        }
    }
    
    @objc func reloadAfterComment() {
        boardsVM.isShowLoading = false
        self.boardsVM.fetchBoardWeCMS() { result in
            switch result {
            case .success(let data):
                self.boardsVM.replaceData(data: data)
                if let indexPath = self.tableView.indexPathsForVisibleRows {
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: indexPath, with: .none)
                    }
                }
            case .failure(let error):
                print(error)
            }
            self.boardsVM.isShowLoading = true
            self.boardsVM.isFetching = false
        }
    }
    
    @objc func pullToRefresh() {
        self.isPullToRefresh        = true
        self.isRefresh              = true
        self.boardsVM.PAGE_NO       = 1
        self.boardsVM.LAST_PAGE_NO  = 1
        self.boardsVM.isShowLoading = false
        self.collectionView.isUserInteractionEnabled = false
        self.fetchBoard(location: self.boardsVM.get_location())
    }
    
    @objc func reloadAfterPostToBoardSubmit(notification: Notification) {
        
        self.isPullToRefresh = true
        
        let noti = notification.object as? [String: String]
        switch noti?["DOTPOST_TYPE"] {
        case "create" :
            self.fetchBoard(location: self.boardsVM.get_location())
        case "edit":
            self.fetchBoard(location: self.boardsVM.get_location())
        case "delete" :
            self.fetchBoard(location: self.boardsVM.get_location())
        case "leave":
            self.reSetuphomeMenu()
        default:
            break
        }
    }
    
    @objc func reloadAfterCreateArticle(notification: Notification) {
        let noti = notification.object as? [String: String]
        switch noti?["ARTICLE_TYPE"] {
        case "C":
            self.boardsVM.PAGE_NO = 1
            boardsVM.isShowLoading = false
            self.fetchBoard(location: self.boardsVM.get_location())
        default:
            break
        }
    }
    
    @objc func dotPostAction(sender: UIButton) {
        //This function call for Article only
        let point           = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath       = self.tableView.indexPathForRow(at: point)!
        
        let boardREC = boardsVM.content[indexPath.section].content[indexPath.row].REC
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
                        
                        
                        self.boardsVM.requestDeletePost(body: WABOOKS_MREC_BLTB_0002_D001.REQUEST(POST_SEQ_NO: boardREC.POST_SEQ_NO, BLTB_CD: boardREC.BLTB_CD )){ erorr in
                            if erorr != nil {
                                // erorr
                                self.customAlert(message: erorr?.localizedDescription ?? "")
                            } else {
                                // success stay current
                                self.popOrDismissVC(animated: true,completion: {
                                    let count = Int(self.boardsVM.sectionData[self.boardsVM.get_location()].count ?? "1")
                                    self.boardsVM.sectionData[self.boardsVM.get_location()].count = String((count ?? 1) - 1)
                                    self.boardsVM.content.remove(at: indexPath.section)
                                    let indexPath = IndexPath(item: self.boardsVM.get_location(), section: 0)
                                    self.collectionView.reloadItems(at: [indexPath])
                                    if self.boardsVM.content.count > 1 {
                                        self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                                    } else {
                                        self.tableView.reloadData()
                                    }
                                })
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
                        
                        self.boardsVM.requestDeleteDraftPost(body: WABOOKS_MREC_BLTB_0002_D003.REQUEST(BLTB_CD: boardREC.BLTB_CD, DRAFT_POST_SEQ_NO: boardREC.DRAFT_POST_SEQ_NO)){ erorr in
                            
                            if erorr != nil {
                                self.customAlert(message: erorr?.localizedDescription ?? "")
                            } else {
                                self.popOrDismissVC(animated: true,completion: {
                                    let count = Int(self.boardsVM.sectionData[self.boardsVM.get_location()].count ?? "1")
                                    self.boardsVM.sectionData[self.boardsVM.get_location()].count = String((count ?? 1) - 1)
                                    self.boardsVM.content.remove(at: indexPath.section)
                                    let indexPath = IndexPath(item: self.boardsVM.get_location(), section: 0)
                                    self.collectionView.reloadItems(at: [indexPath])
                                    if self.boardsVM.content.count > 1 {
                                        self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                                    } else {
                                        self.tableView.reloadData()
                                    }
                                })
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
extension BoardsWeCmsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return boardsVM.content.count > 0 ? boardsVM.content.count : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if boardsVM.content.count == 0 {
            return 1
        }
        
        switch boardsVM.content[section].sectionType {
            
        case .TITLE, .SHOWMORE, .SHOWLESS, .PINLINE:
            return 1
        case .CONTENT:
            return boardsVM.content[section].content.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if boardsVM.content.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataBoardsCell", for: indexPath)  as! NoDataBoardsCell
            cell.tapLabel.text                   = "Click_+_button_to_create_new_one".localized
            cell.noPostLabel.text                = "No_post_yet".localized
            return cell
        }
        
        switch boardsVM.content[indexPath.section].sectionType {
            
        case .TITLE:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
            cell.config(data: boardsVM.content[indexPath.section])
            return cell
            
        case .SHOWMORE:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FooterCell", for: indexPath) as! FooterCell
            cell.configShowMore()
            return cell
            
        case .SHOWLESS:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FooterCell", for: indexPath) as! FooterCell
            cell.configShowLess()
            return cell
            
        case .PINLINE:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PinLineCell", for: indexPath)
            return cell
            
        case .CONTENT:
            let data = boardsVM.content[indexPath.section].content[indexPath.row]
            
            switch data.rowType {
                
            case .STATUS:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FullContentWeCMSCell", for: indexPath) as! FullContentWeCMSCell
                
                cell.dotPostBtn.addTarget(self, action: #selector(dotPostAction), for: .touchUpInside)
                cell.config(data: data.REC)
                return cell
                
            case .DESCRIPTION:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionBoardCell", for: indexPath) as! DescriptionBoardCell
                cell.config(data: data.REC)
                return cell
                
            case .COMMENT:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommentBoardCell", for: indexPath) as! CommentBoardCell
                cell.config(data: data.REC)
                return cell
                
            case .LINEFOOTER:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LineFooterCell", for: indexPath)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if boardsVM.content.count == 0 {return}
        
        switch boardsVM.content[indexPath.section].sectionType {
        case .SHOWMORE:
            boardsVM.initShowMoreData()
            tableView.reloadData()
            
        case .SHOWLESS:
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.boardsVM.initShowLessData()
                self.tableView.reloadData()
            })
            
        case .CONTENT:
            let data = boardsVM.content[indexPath.section].content[indexPath.row]
            switch data.rowType {
            case .COMMENT:
                commentPopup(indexPath: indexPath)
                
            case .STATUS, .DESCRIPTION:
                self.boardsVM.PAGE_NO = self.boardsVM.content[indexPath.section].page
                guard let POST_SEQ_NO = self.boardsVM.content[indexPath.section].content[indexPath.row].REC.POST_SEQ_NO else {return}
                displayAddFloatButton(false)
                displayTabBar(false)
                let vc = self.VC(sbName: "ExpenseApprovalWeCMSSB", identifier: "ExpenseApprovalWeCMSVC") as! ExpenseApprovalWeCMSVC
                vc.expenseApprovalVM.POST_TYPE_CD  = self.boardsVM.content[indexPath.section].content[indexPath.row].REC.POST_TYPE_CD ?? ""
//                vc.POST_SEQ_NO   = POST_SEQ_NO
//                vc.BLTB_CD       = self.boardsVM.content[indexPath.section].content[indexPath.row].REC.BLTB_CD ?? ""
                vc.expenseApprovalVM.POST_APPR_DV  = self.boardsVM.content[indexPath.section].content[indexPath.row].REC.POST_APPR_DV ?? ""
//                vc.APPR_SEQ_NO   = self.boardsVM.content[indexPath.section].content[indexPath.row].REC.APPR_SEQ_NO ?? ""
//                vc.POST_STTS   = self.boardsVM.content[indexPath.section].content[indexPath.row].REC.POST_STTS ?? ""
                
                vc.boardRec      = self.boardsVM.content[indexPath.section].content[indexPath.row].REC
                
                vc.isShouldReload = true
                
                pushVC(viewController: vc)
            default: return
            }
        default: return
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if boardsVM.content.count == 0 {
            self.tableView.tableFooterView = nil
        } else {
            let nextPage = self.boardsVM.response?.NEXT_PAGE_YN
            if indexPath.section == self.boardsVM.content.count - 1 && nextPage == "Y" && !self.boardsVM.isFetching && (self.boardsVM.response?.REC?.count ?? 0) > 0 {
                self.boardsVM.LAST_PAGE_NO += 1
                self.boardsVM.PAGE_NO = self.boardsVM.LAST_PAGE_NO
                self.boardsVM.isShowLoading = false
                self.boardsVM.fetchBoardWeCMS() { result in
                    switch result {
                    case .success(let data):
                        self.boardsVM.appendData(data: data)
                        self.tableView.reloadData()
                    case .failure(let error):
                        print(error)
                    }
                    self.boardsVM.isShowLoading = true
                    self.boardsVM.isFetching = false
                }
            } else {
                self.tableView.tableFooterView = self.boardsVM.isFetching ? self.view.createSpinnerFooter() : nil
            }
        }
        stopIndicator()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if boardsVM.content.count == 0 {
            self.tableView.isScrollEnabled = false
            self.tableView.backgroundColor = UIColor(hexString: "ECEFF1")
            let height = self.tableView.frame.height - 60
            return height > 0 ? height : UIScreen.main.bounds.height - 60
        } else {
            self.tableView.isScrollEnabled = true
            self.tableView.backgroundColor = .systemBackground
            return UITableView.automaticDimension
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension BoardsWeCmsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return boardsVM.sectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SectionTypeCell", for: indexPath) as! SectionTypeCell
        cell.config(data: boardsVM.sectionData[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        boardsVM.PAGE_NO = 1
        boardsVM.LAST_PAGE_NO = 1
        self.isPullToRefresh = false
        self.boardsVM.selectedData = self.boardsVM.sectionData[indexPath.row]
        for (n, _) in boardsVM.sectionData.enumerated() {
            boardsVM.sectionData[n].isSelected = false
        }
        boardsVM.sectionData[indexPath.row].isSelected = true
        fetchBoard(location: self.boardsVM.get_location())
        collectionView.reloadData()
    }

}

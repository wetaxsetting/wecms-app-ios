//
//  EditArticleWeCMSVC.swift
//  WeCMS_iOS
//
//  Created by lymanny on 16/1/25.
//
//  Note: This class was adapted from EditArticleVC
//  Some conditions and methods have been modified to fit the requirements of the EditArticleWeCMS feature.

import UIKit
import IQKeyboardManagerSwift


class EditArticleWeCMSVC: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var closeBtn             : UIButton!
    @IBOutlet weak var postBtn              : UIButton!
    @IBOutlet weak var backgroundViewButton : UIView!
    @IBOutlet weak var tableView            : UITableView!
    @IBOutlet weak var titleLabel           : UILabel!
    @IBOutlet weak var navView              : UIView!
    @IBOutlet weak var mentionTableView     : UITableView!
    @IBOutlet weak var mentionTableViewHC   : NSLayoutConstraint!
    
    //MARK: - Properties & Variable
    var editArticleVM           = EditArticleVM()
    var boardImage              : [WeCMSStruct.REC_Protocol] = []
    var boardImageApproval      : [WeCMSStruct.REC_Protocol] = []
    var boardREC                : WeCMSStruct.BoardDetail_Protocol?
    var requestApprovers        : [MREC_BLTB_0004_C002.REQUEST.REC6] = []
    var getApprovers            : [MREC_BLTB_0004_C002.REQUEST.REC6] = []
    var responseBoardDetail     : MREC_BLTB_0005_R002.RESPONSE?
    var responseArticle         : MREC_BLTB_0005_R001.RESPONSE?
    var isNotification          : Bool = false
    var POST_TYPE_CD            : String  = "" // "01"-> Article, "02" -> Approval
    var POST_STTS               = ""
    var PIN_POST_TYPE           = ""
    var POST_TITLE              = ""
    var POST_CONT               = ""
    var POST_APPR_DV            = ""
    var PIN_POST_DUE_DT         = ""
    var selectDateType          = "save_permanently".localized
    var mentionedMembers        : [MentionMemberUIModel] = []
    var mentionedMemberNames    : [String] = []
    let mentionMemberVM         = MentionMemberVM()
    var cursorPosition          = 0
    var stringToSearch          = ""
    var isFirstLoaded           = true
    var POST_CONT_Syntax        = ""
    var textCount               = 0
    var imagePreviewArr         : [PreviewModel] = []
    var Spacing                 :CGFloat = 300 // spacing between Content and Item
    var spceAfterText           :CGFloat = 300
    
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    lazy var TopBarKeyboardView : TopBarKeyboardView = {
        return Bundle.main.loadNibNamed("TopBarKeyboardView", owner: self, options: nil)?.first as! TopBarKeyboardView
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mentionTableViewHC.constant = 0
        self.backgroundViewButton.isHidden = false
        self.POST_STTS = self.boardREC?.POST_STTS ?? ""
        enableSaveButton()
        self.registerCell()
        self.initNavigationData()
        editArticleVM.POST_APPR_DV = boardREC?.POST_APPR_DV ?? ""
        if self.boardREC?.POST_TYPE_CD == "01"{
            self.titleLabel.text = "Edit_Article".localized
            self.fetchDetailEditBoardArticle()
            
        }else if isNotification && self.POST_TYPE_CD == "01" { //check from notification
            self.titleLabel.text = "Edit_Article".localized
            self.fetchDetailEditBoardArticle()
        }else {
            if isNotification {// check if data from notification
                self.editArticleVM.POST_APPR_DV = self.POST_APPR_DV
            }
            self.titleLabel.text = "Edit Request Approval"
            self.fetchDetailEditBoardApproval()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.TopBarKeyboardView.delegate = self
    }
    
    //MARK: - Function
    func initNavigationData(){
        self.titleLabel.text = "Edit_Article".localized
        self.closeBtn.setImage(UIImage(named: "ico_close"), for: .normal)
        self.postBtn.setTitle("save".localized, for: .normal)
        postBtn.getlocalizedFont()
        titleLabel.getlocalizedFont()
        self.postBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        self.closeBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
    }
    
    func registerCell() {
        self.tableView.register(UINib(nibName: "ApprovalFormHeaderCell", bundle: nil), forCellReuseIdentifier: "ApprovalFormHeaderCell")
        self.tableView.register(UINib(nibName: "ApprovalInfoWeCMSCell", bundle: nil), forCellReuseIdentifier: "ApprovalInfoWeCMSCell")
        self.tableView.register(UINib(nibName: "ApprovalDateInfoWeCMSCell", bundle: nil), forCellReuseIdentifier: "ApprovalDateInfoWeCMSCell")
        self.tableView.register(UINib(nibName: "ApprovalSelectInfoWeCMSCell", bundle: nil), forCellReuseIdentifier: "ApprovalSelectInfoWeCMSCell")
        self.tableView.register(UINib(nibName: "ApprovalLineCell", bundle: nil), forCellReuseIdentifier: "ApprovalLineCell")
        self.tableView.register(UINib(nibName: "ImageViewWeCMSCell", bundle: nil), forCellReuseIdentifier: "ImageViewWeCMSCell")
        self.tableView.register(UINib(nibName: "AttactMentsWeCMSCell", bundle: nil), forCellReuseIdentifier: "AttactMentsWeCMSCell")
        self.tableView.register(UINib(nibName: "ArticleToggleCell", bundle: nil), forCellReuseIdentifier: "ArticleToggleCell")
        self.tableView.register(UINib(nibName: "ExpenseItemCell", bundle: nil), forCellReuseIdentifier: "ExpenseItemCell")
        self.tableView.register(UINib(nibName: "SeeMoreCell", bundle: nil), forCellReuseIdentifier: "SeeMoreCell")
        self.mentionTableView.register(UINib(nibName: "MentionMemberCell", bundle: nil), forCellReuseIdentifier: "MentionMemberCell")
        self.tableView.register(UINib(nibName: "DocumentNoCell", bundle: nil), forCellReuseIdentifier: "DocumentNoCell")
        self.tableView.register(UINib(nibName: "DocumentNoWeCMSCell", bundle: nil), forCellReuseIdentifier: "DocumentNoWeCMSCell")
        self.tableView.register(UINib(nibName: "ApprovalSelectExpenseCell", bundle: nil), forCellReuseIdentifier: "ApprovalSelectExpenseCell")
    }
    
    func requestEditArticle(){
        if !POST_CONT.contains("@[") && mentionedMembers.count > 0 {
            POST_CONT_Syntax = self.formatMentionFromReadableToAPISyntax(originalText: POST_CONT, mentionedMembers: mentionedMembers)
        } else {
            POST_CONT_Syntax = POST_CONT
        }
        
        var POST_SEQ_NO = ""
        var BLTB_CD     = ""
        if isNotification && POST_TYPE_CD  == "01" {
            POST_SEQ_NO = responseArticle?.POST_SEQ_NO ?? ""
            BLTB_CD     = responseArticle?.BLTB_CD ?? ""
        }else {
            POST_SEQ_NO = boardREC?.POST_SEQ_NO ?? ""
            BLTB_CD = boardREC?.BLTB_CD ?? ""
        }
        if self.PIN_POST_DUE_DT.contains(" ") {
            self.PIN_POST_DUE_DT = changeFormatDate(self.PIN_POST_DUE_DT, fromFormat: "dd MMM yyyy", toFormat: "yyyyMMdd")
        }
        
        let REC2 = editArticleVM.REC2
        let REC = editArticleVM.REC
        editArticleVM.request_0004_U001(BLTB_CD: BLTB_CD, POST_SEQ_NO: POST_SEQ_NO, POST_TITLE: self.POST_TITLE, POST_CONT: POST_CONT_Syntax, POST_TYPE_CD: "01", POST_STTS: self.POST_STTS, PIN_POST_TYPE: self.PIN_POST_TYPE == "" ? nil : self.PIN_POST_TYPE, PIN_POST_DUE_DT: self.PIN_POST_DUE_DT == "permanently".localized ? "" : self.PIN_POST_DUE_DT, REC: REC, REC2: REC2) { result in
            switch result {
            case .success(_):
                //post success
                self.popOrDismissVC(animated: true,completion: {
                    MyNotify.send(name: .GotoBoard, object: ["DOTPOST_TYPE": "edit"] as AnyObject)
                    MyNotify.send(name: .GotoExpenseApproval, object: ["DOTPOST_TYPE": "edit"] as AnyObject)
                    MyNotify.send(name: .GotoSearch, object: ["SEARCH_BOARD": "Edit"] as AnyObject)
                })
                
            case .failure(let error):
                self.alertError(message: error.localizedDescription )
            }
        }
    }
    
    func requestEditApproval() {
        let REC3    = self.editArticleVM.REC3
        let REC4    = self.editArticleVM.REC4
        var temp    : [MREC_BLTB_0004_C002.REQUEST.REC6] = []
        var temp2   : [MREC_BLTB_0004_C002.REQUEST.REC6] = []
        var temp3   : [MREC_BLTB_0004_C002.REQUEST.REC6] = []
        
        editArticleVM.rec005_R002!.REC3?.forEach { data in
            temp.append(MREC_BLTB_0004_C002.REQUEST.REC6(APPRVR_ID: data.APPRVR_ID, APPRVR_NM: data.APPRVR_NM))
        }
        
        temp2 = Array(Set(requestApprovers).subtracting(temp)) // Compare approver from new select with old approver
        if getApprovers.count > 0 {
            temp3 = Array(Set(temp).subtracting(getApprovers)) // Compare old approver with new select approver
        }
        
        for rec1 in temp2 {
            self.editArticleVM.REC1.append(MREC_BLTB_0004_U002.REQUEST.REC1(APPRVR_ID: rec1.APPRVR_ID, APPRVR_NM: rec1.APPRVR_NM)) // Add Delete Approver
        }
        for rec2 in temp3 {
            self.editArticleVM.REC2APPR.append(MREC_BLTB_0004_U002.REQUEST.REC2(APPRVR_NM: rec2.APPRVR_NM, APPRVR_ID: rec2.APPRVR_ID)) // Add New Approver
        }

        if !POST_CONT.contains("@[") && mentionedMembers.count > 0 {
            POST_CONT_Syntax = self.formatMentionFromReadableToAPISyntax(originalText: POST_CONT, mentionedMembers: mentionedMembers)
        } else {
            POST_CONT_Syntax = POST_CONT
        }
        
        var POST_SEQ_NO = ""
        var BLTB_CD     = ""
        if isNotification && POST_TYPE_CD  == "02" {
            POST_SEQ_NO = responseBoardDetail?.POST_SEQ_NO ?? ""
            BLTB_CD     = responseBoardDetail?.BLTB_CD ?? ""
            // POST_APPR_DV == 00 -> Simple approval , POST_APPR_DV == 10 -> Exspense approval
            //            if POST_APPR_DV == "00" {
            //                self.editArticleVM.rec005_R002?.REC3?.forEach { i in
            //                    self.editArticleVM.REC3.append(MREC_BLTB_0004_U002.REQUEST.REC3(
            //                }
            //            }else if POST_APPR_DV == "10" {
            //
            //            }
        }else {
            POST_SEQ_NO = boardREC?.POST_SEQ_NO ?? ""
            BLTB_CD = boardREC?.BLTB_CD ?? ""
        }
        
        editArticleVM.request_0004_U002(BLTB_CD: BLTB_CD, POST_SEQ_NO: POST_SEQ_NO, POST_TITLE:  self.POST_TITLE, POST_CONT: POST_CONT_Syntax.convertStringToHTML, REC1: self.editArticleVM.REC1.uniqued(), REC2: self.editArticleVM.REC2APPR, REC3: REC3, REC4: REC4) { result in
            switch result {
            case .success(_):
                //post success
                self.popOrDismissVC(animated: true,completion: {
                    MyNotify.send(name: .GotoBoard, object: ["DOTPOST_TYPE": "edit"] as AnyObject)
                    MyNotify.send(name: .GotoExpenseApproval, object: ["DOTPOST_TYPE": "edit"] as AnyObject)
                    MyNotify.send(name: .GotoSearch, object: ["SEARCH_BOARD": "Edit"] as AnyObject)
                })
                
            case .failure(let error):
                self.alertError(message: error.localizedDescription )
            }
        }
    }
    
    func fetchDetailEditBoardApproval() {
        
        var POST_SEQ_NO = ""
        var BLTB_CD     = ""
        if isNotification && POST_TYPE_CD  == "02" {
            POST_SEQ_NO = responseBoardDetail?.POST_SEQ_NO ?? ""
            BLTB_CD     = responseBoardDetail?.BLTB_CD ?? ""
        }else {
            POST_SEQ_NO = boardREC?.POST_SEQ_NO ?? ""
            BLTB_CD = boardREC?.BLTB_CD ?? ""
        }
        
        editArticleVM.fetchEditBoardDetailApprovalWeCMS(POST_SEQ_NO: POST_SEQ_NO, BLTB_CD: BLTB_CD) { result in
            switch result {
            case .success(let data):
                self.boardImageApproval = data.REC2 ?? []
                self.POST_CONT = data.POST_CONT ?? ""
                self.POST_TITLE = data.POST_TITLE ?? ""
                for item in data.REC3 ?? [] {
                    self.requestApprovers.append(MREC_BLTB_0004_C002.REQUEST.REC6(APPRVR_ID: item.APPRVR_ID, APPRVR_NM: item.APPRVR_NM, APPRVR_IMG_URL: item.APPRVR_IMG_URL))
                }
                
                let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
                
                for imgUrl in self.boardImageApproval {
                    let fileName = imgUrl.ORG_FILE_NM ?? ""
                    if fileName.contains(".jpg") || fileName.contains(".png")  {
                        
                        let split_url       = imgUrl.FILE_URL?.components(separatedBy: "?")
                        let img_url         = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")"
                        self.imagePreviewArr.append(PreviewModel(fileName: fileName, image: img_url))
                    }
                }
                self.tableView.reloadData()
                
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func fetchDetailEditBoardArticle() {
        
        var POST_SEQ_NO = ""
        var BLTB_CD     = ""
        if isNotification && POST_TYPE_CD  == "01" {
            POST_SEQ_NO = responseArticle?.POST_SEQ_NO ?? ""
            BLTB_CD     = responseArticle?.BLTB_CD ?? ""
        }else {
            POST_SEQ_NO = boardREC?.POST_SEQ_NO ?? ""
            BLTB_CD = boardREC?.BLTB_CD ?? ""
        }
        
        editArticleVM.fetchEditBoardDetailArticle(POST_SEQ_NO: POST_SEQ_NO, BLTB_CD: BLTB_CD) { result in
            switch result {
            case .success(let data):
                self.boardImage             = data.REC ?? []
                self.POST_CONT              = data.POST_CONT ?? ""
                self.POST_TITLE             = data.POST_TITLE ?? ""
                self.boardREC?.POST_STTS    = data.POST_STTS ?? ""
                self.PIN_POST_TYPE          = data.PIN_POST_TYPE ?? ""
                self.PIN_POST_DUE_DT        = data.PIN_POST_TYPE == "UD" ? "permanently".localized : data.PIN_POST_DUE_DT ?? ""
                
                //get image from response for show in preview image
                let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
                for imgUrl in self.boardImage {
                    let fileName = imgUrl.ORG_FILE_NM ?? ""
                    if fileName.contains(".jpg") || fileName.contains(".png")  {
                        let split_url       = imgUrl.FILE_URL?.components(separatedBy: "?")
                        let img_url         = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")"
                        self.imagePreviewArr.append(PreviewModel(fileName: fileName, image: img_url)) //file url
                    }
                }
                self.tableView.reloadData()
                
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func showPopupDeleteImage(completion: @escaping Completion) {
        customAlert(type        : .YES_OR_NO_ALERT,
                    image       : "badge_warning",
                    title       : "delete".localized,
                    message     : "are_you_sure_want_to_delete_the_attached_image".localized,
                    redTitle    : "delete".localized,
                    greyTitle   : "cancel".localized) { (isDelete) in
            if isDelete {
                completion()
            }
        }
    }
    
    func enableSaveButton(){
        self.postBtn.backgroundColor = UIColor(hexString: "#0069B9")
        self.postBtn.isUserInteractionEnabled = true
        self.postBtn.setTitleColor(.white, for: .normal)
    }
    
    func getExistedMentionedMember(content: String) {
        let formatedComponent   = self.formatMentionFromAPISyntaxToReadable(originalText: content)
        let mentionedMemberFullInfo = formatedComponent.2
        for obj in mentionedMemberFullInfo {
            let split = obj.components(separatedBy: "](")
            
            if split.count == 2 {
                let name = split.first?.replace(of: "@[", with: "") ?? ""
                //                let email = split.last?.replace(of: ")", with: "") ?? ""
                let user = MentionMemberUIModel(name: name, email: obj, photo: "", USER_IMG: "")
                
            
                var isAlreadyExisted = false
                for obj in mentionedMembers {
                    if obj.email == user.email {
                        isAlreadyExisted = true
                        break
                    }
                }
                
                if !isAlreadyExisted {
                    mentionedMemberNames.append(name)
                    mentionedMembers.append(user)
                }
            
            }
        }
    }
    
    func removeImageLocal(isArtcle: Bool = false, fileName: String ){
        if isArtcle {
            for ( index, data) in editArticleVM.REC2.enumerated() {
                if  data.FILE_NM == fileName {
                    editArticleVM.REC2.remove(at: index)
                    break
                }
            }
        }else{
            for ( index, data) in editArticleVM.REC3.enumerated() {
                if  data.FILE_NM == fileName {
                    editArticleVM.REC3.remove(at: index)
                    break
                }
            }
        }
        
        //remove preview local
        for ( index, data) in imagePreviewArr.enumerated() {
            if  data.fileName == fileName {
                imagePreviewArr.remove(at: index)
                break
            }
        }
    }
    
    private func goToPurpose( _ userListKey: String) {
        let vc                      = self.VC(sbName: "SelectPurposeSB", identifier: "SelectPurposeVC" ) as! SelectPurposeVC
        vc.delegate                 = self
        vc.selectUserListKey        = userListKey
        vc.isShowPlanned_money      = true
        vc.isShowOnlyPlanned_money  = false
        vc.headerTitle              = "select_a_purpose".localized
        self.presetVC(vc:vc)
    }
    
    //MARK: - OBJC
    @objc func backAction(send: UIButton){
        popOrDismissVC()
    }
    
    @objc func saveAction (send: UIButton){
        if  (self.boardREC?.POST_TYPE_CD == "01") || (isNotification && self.POST_TYPE_CD == "01") {
            self.requestEditArticle()
            
        }else if isNotification && self.POST_TYPE_CD == "02" || self.editArticleVM.POST_APPR_DV == "00" || self.editArticleVM.POST_APPR_DV == "10" {
            self.requestEditApproval()
        }
    }
    
    @objc func switchChanged(itemSwitch: UISwitch) {
        
        //        if itemSwitch.isVisible == true {
        //            self.enableSaveButton()
        //        }else{
        //            disableSaveButton()
        //        }
        let switchOn = itemSwitch.isOn
        self.POST_STTS = switchOn ? "PL" : "PV"
    }
    
    @objc func switchChangeMark(itemSwitch: UISwitch) {
        //        if itemSwitch.isVisible == true {
        //            self.enableSaveButton()
        //        }else{
        //            disableSaveButton()
        //        }
        
        let switchOn = itemSwitch.isOn
        self.PIN_POST_TYPE = switchOn ? "UD" : ""
        self.tableView.reloadData()
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension EditArticleWeCMSVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
            // Main TableView
        case self.tableView:
            return  editArticleVM.cells.count
            // Mention TableView
        case self.mentionTableView:
            return mentionMemberVM.filteredList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case self.tableView :
            let rowType = editArticleVM.cells[indexPath.row].rowType
            let data = self.editArticleVM.cells[indexPath.row]
            
            switch rowType {
            case .NEW_ARTICLE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalFormHeaderCell", for: indexPath) as! ApprovalFormHeaderCell
                cell.configEditArticle(data: data, description: self.editArticleVM.tempDescription, isFirstLoaded: self.isFirstLoaded, isArticle: true, isHideTextCount: self.boardREC?.POST_TYPE_CD ?? "")
                cell.titleTextView.tag = 1010
                cell.descriptionTextView.tag = 1011
                self.textCount = data.decription?.count ?? 0
                cell.textCountLabel.text = "\(self.textCount)/200"
                cell.textCountLabel.textColor = .gray
                cell.descriptionTextView.inputAccessoryView = TopBarKeyboardView
                cell.titleTextView.delegate         = self
                cell.descriptionTextView.delegate   = self
                //calulate space
                if boardREC?.POST_TYPE_CD == "01"{
                    cell.textCountBottomConstraint.constant = editArticleVM.REC2.count > 0 ?  20 :  (tableView.frame.size.height - self.Spacing)
                }else{
                    self.Spacing = 530
                    cell.textCountBottomConstraint.constant = editArticleVM.REC3.count > 0 ?  20 :  (tableView.frame.size.height - self.Spacing)
                }
                
                if isFirstLoaded {
                    getExistedMentionedMember(content: data.decription ?? "")
                }
                if isFirstLoaded {
                    isFirstLoaded = false
                }
                return cell
                
            case .ATTACHMENT:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AttactMentsWeCMSCell", for: indexPath) as! AttactMentsWeCMSCell
                cell.configFileEditArticle(data: data)
                cell.deleteButton.didTap {
                    if self.boardREC?.POST_TYPE_CD == "01"{ // For Article
                        let removeItem = self.editArticleVM.cells.remove(at: indexPath.row)
                        if let FILE_ID = removeItem.IMAGE_REC?.FILE_ID {
                            //remove file get from response
                            self.editArticleVM.REC.append(MREC_BLTB_0004_U001.REQUEST.REC(FILE_ID: FILE_ID))
                        }
                        //remove file upload from local
                        self.removeImageLocal(isArtcle: true, fileName: removeItem.fileName ?? "" )
                        self.Spacing = self.tableView.frame.size.height - self.Spacing
                        
                        for imgUr in self.editArticleVM.REC2.filter( {($0.FILE_NM ?? "").contains(".jpg")}) {
                            self.Spacing = self.tableView.frame.size.height - CGFloat((imgUr.FILE_NM ?? "").count)*350 //> Seanghay <\\ height of Image
                        }
                        
                        if self.editArticleVM.REC2.count > 0 {
                            self.Spacing = self.tableView.frame.size.height - CGFloat(self.editArticleVM.REC2.count*46)
                        }else if self.editArticleVM.REC2.count == 0{
                            self.Spacing = self.spceAfterText
                        }
                        
                    }else { // For Approval
                        let removeItem = self.editArticleVM.cells.remove(at: indexPath.row)
                        if let FILE_ID = removeItem.IMAGE_REC?.FILE_ID {
                            //remove file get from response
                            self.editArticleVM.REC4.append(MREC_BLTB_0004_U002.REQUEST.REC4(FILE_ID: FILE_ID))
                        }
                        //remove file upload from local
                        self.removeImageLocal(isArtcle: false, fileName: removeItem.fileName ?? "" )
                        self.Spacing = self.tableView.frame.size.height - self.Spacing
                        
                        for imgUr in self.editArticleVM.REC3.filter( {($0.FILE_NM ?? "").contains(".jpg")}) {
                            self.Spacing = self.tableView.frame.size.height - CGFloat((imgUr.FILE_NM ?? "").count)*350 //> Seanghay <\\ height of Image
                        }
                        
                        if self.editArticleVM.REC3.count > 0 {
                            self.Spacing = self.tableView.frame.size.height - CGFloat(self.editArticleVM.REC3.count*46)
                        }else if self.editArticleVM.REC3.count == 0{
                            self.Spacing = self.spceAfterText
                        }
                    }
                    self.tableView.reloadData()
                    //  self.enableSaveButton()
                }
                return cell
                
            case .IMAGE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageViewWeCMSCell", for: indexPath) as! ImageViewWeCMSCell
                cell.configImageEditArticle(data: data)
                cell.deleteButton.didTap {
                    if self.boardREC?.POST_TYPE_CD == "01"{
                        let removeItem = self.editArticleVM.cells.remove(at: indexPath.row)
                        if let FILE_ID = removeItem.IMAGE_REC?.FILE_ID {
                            //remove image get from response
                            self.editArticleVM.REC.append(MREC_BLTB_0004_U001.REQUEST.REC(FILE_ID: FILE_ID))
                            self.editArticleVM.REC2.removeAll(where: {$0.FILE_NM == removeItem.IMAGE_REC?.ORG_FILE_NM ?? ""})
                            
                            //remove image from respone for preview
                            self.imagePreviewArr.removeAll(where: {$0.fileName == removeItem.IMAGE_REC?.ORG_FILE_NM})
                        }
                        
                        //remove image upload from local and preview
                        self.removeImageLocal(isArtcle: true, fileName: removeItem.fileName ?? "" )
                        self.Spacing = self.tableView.frame.size.height - self.Spacing
                        
                        for imgUr in self.editArticleVM.REC2.filter( {($0.FILE_NM ?? "").contains(".jpg")}) {
                            self.Spacing = self.tableView.frame.size.height - CGFloat((imgUr.FILE_NM ?? "").count)*CGFloat(cell.imageContainView.frame.height)
                        }
                        if self.editArticleVM.REC2.count > 0 {
                            self.Spacing = self.tableView.frame.size.height - CGFloat(self.editArticleVM.REC2.count*46) //> Seanghay <\\ 46 height of Attachment
                        }else if self.editArticleVM.REC2.count == 0{
                            self.Spacing = self.spceAfterText
                        }
                        
                    }else{
                        //For Approval
                        let removeItem = self.editArticleVM.cells.remove(at: indexPath.row)
                        if let FILE_ID = removeItem.IMAGE_REC?.FILE_ID {
                            //remove file get from response
                            self.editArticleVM.REC4.append(MREC_BLTB_0004_U002.REQUEST.REC4(FILE_ID: FILE_ID))
                            self.editArticleVM.REC3.removeAll(where: {$0.FILE_NM == removeItem.IMAGE_REC?.ORG_FILE_NM ?? ""})
                            
                            //remove image upload from respone and local for preview
                            self.imagePreviewArr.removeAll(where: {$0.fileName == removeItem.IMAGE_REC?.ORG_FILE_NM})
                        }
                        //remove file upload from local and preview
                        self.removeImageLocal(isArtcle: false, fileName: removeItem.fileName ?? "" )
                        self.Spacing = self.tableView.frame.size.height - self.Spacing
                        
                        for imgUr in self.editArticleVM.attacmentREC3.filter( {($0.FILE_NM ?? "").contains(".jpg")}) {
                            self.Spacing = self.tableView.frame.size.height - CGFloat((imgUr.FILE_NM ?? "").count)*CGFloat(cell.imageContainView.frame.height)
                        }
                        if self.editArticleVM.attacmentREC3.count > 0 {
                            self.Spacing = self.tableView.frame.size.height - CGFloat(self.editArticleVM.attacmentREC3.count*46) //> Seanghay <\\ 46 height of Attachment
                        }else if self.editArticleVM.attacmentREC3.count == 0{
                            self.Spacing = self.spceAfterText
                        }
                    }
                
                    //    self.enableSaveButton()
                    self.tableView.reloadData()
                }
                return cell
                
            case .POST_PUBLIC:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleToggleCell", for: indexPath) as! ArticleToggleCell
                cell.itemSwitch.isOn = self.POST_STTS != "PV"
                cell.specificDateButton.isHidden    = true
                cell.configEditAricle(data: data)
                cell.itemSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
                return cell
                
            case .MAKE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleToggleCell", for: indexPath) as! ArticleToggleCell
                cell.configMarkEditAricle(data: data, PIN_POST_TYPE: self.PIN_POST_TYPE, PIN_POST_DUE_DT: self.PIN_POST_DUE_DT)
                if #available(iOS 14.0, *) {
                    cell.itemSwitch.setOnValueChangeListener {
                        let switchOn = cell.itemSwitch.isOn
                        if self.PIN_POST_DUE_DT == "permanently".localized || self.PIN_POST_DUE_DT == "" {
                            self.PIN_POST_TYPE = switchOn ? "UD" : ""  // => if on toggle = "UD" & off toggle = ""
                        }else{
                            self.PIN_POST_TYPE = switchOn ? "LD" : ""  // => if on toggle = "LD" & off toggle = ""
                        }
                        self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .none)
                    }
                } else {
                    cell.itemSwitch.addTarget(self, action: #selector(switchChangeMark), for: UIControl.Event.valueChanged)
                }
                
                cell.specificDateButton.didTap {
                    self.selectDateType = self.PIN_POST_TYPE == "LD" ? "until_specific_date".localized : "save_permanently".localized
                    self.selectOptionWithChekSpecificDate(optionData: self.PIN_POST_DUE_DT, defaultApproval: self.selectDateType ){ option,value,duration   in
                        cell.specificDateButton.setTitle(value, for: .normal)
                        self.PIN_POST_TYPE      = duration
                        self.PIN_POST_DUE_DT    = duration == "UD" ? value : changeFormatDate(value, fromFormat: "dd MMM yyyy", toFormat: "yyyyMMdd")
                        self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .none)
                    }
                }
                return cell
                
                //Simple approval
            case .LINE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalLineCell", for: indexPath) as! ApprovalLineCell
                return cell
                
            case .REQUESTOR:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentNoWeCMSCell", for: indexPath) as! DocumentNoWeCMSCell
                cell.configDocNoCell(data: data)
                return cell
            case .APPROVERS:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalSelectInfoWeCMSCell", for: indexPath) as! ApprovalSelectInfoWeCMSCell
                cell.configEditCell(data: data, imageSet: self.requestApprovers)
                return cell

            case .DOCUMENTNO:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentNoCell", for: indexPath) as! DocumentNoCell
                cell.configDocNoCell(data: data)
                return cell
                
            case .REQUESTSCHEDULED:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalDateInfoWeCMSCell", for: indexPath) as! ApprovalDateInfoWeCMSCell
                cell.configEditCell(data: data)
                let language = "dd MMM yyyy"
//                let today = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
//                let formattedDate = dateFormatter.string(from: today)
                cell.selectDateButton.setTitle(changeFormatDate(data.endDate ?? "", fromFormat: "yyyyMMddHHmmss", toFormat: language), for: .normal)
                /*
                // Cannot edit REQUEST SCHEDULED
                cell.startDateButton.didTap {
                    self.dropDownStartDate(date: cell.startDateButton.titleLabel?.text ?? "") { option in
                        cell.startDateButton.setTitle(option == "" ? cell.startDateButton.titleLabel?.text ?? "" : option, for: .normal)
                        self.PAY_REQ_DATE = changeFormatDate(option == "" ? cell.startDateButton.titleLabel?.text ?? "" : option, fromFormat: "dd-MM-yyyy", toFormat: "yyyyMMdd")
                    }
                }
                
                cell.selectDateButton.didTap {
                    self.dropDownSelectDate(date: cell.selectDateButton.titleLabel?.text ?? "") { option in
                        cell.selectDateButton.setTitle(option ==  data.endDate ? today.toString(format: "dd-MM-yyyy") : option, for: .normal)
                        self.PAY_REQ_DATE = changeFormatDate(option == "" ? today.toString(format: "dd-MM-yyyy") : option, fromFormat: "dd-MM-yyyy", toFormat: "yyyyMMdd")
                    }
                }
                 */
                cell.dataImageView.image = UIImage(named: data.icon ?? "")
                return cell
                
            case .TOTALAMOUNT:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalInfoWeCMSCell", for: indexPath) as! ApprovalInfoWeCMSCell
                cell.amountStackView.isHidden = false
                cell.configEditCell(data: data)
                return cell
                
            case .EXPENSES:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalSelectExpenseCell", for: indexPath) as! ApprovalSelectExpenseCell
                cell.configEditCell(data: data)
                return cell
            case .EXPENSESITEM:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseItemCell", for: indexPath) as! ExpenseItemCell
                cell.configEditCell(data: data)
//                cell.purposeButton.didTap {
//                    self.goToPurpose(self.editArticleVM.cells[indexPath.row].BUSA_USAG_CD ?? "")
//                }
//
//                cell.purposeDropButton.didTap {
//                    self.goToPurpose(self.editArticleVM.cells[indexPath.row].BUSA_USAG_CD ?? "")
//                }
                
//                cell.deleteButton.didTap {
//                    self.editArticleVM.cells.remove(at: indexPath.row)
//                    self.requestExpense.remove(at: indexPath.row - 3)
//                    self.editArticleVM.selectExpenseCount = "\(self.simpleApprovalVM.requestExpense.count)"
//                    self.calculateTotalAmount(data: self.simpleApprovalVM.requestExpense)
//                    self.simpleApprovalVM.initData()
//                    self.tableView.reloadData()
//                }
                return cell
            case .SEEMORE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreCell", for: indexPath) as! SeeMoreCell
                return cell
            default:
                return UITableViewCell()
            }
            
        case self.mentionTableView:
            let data = mentionMemberVM.filteredList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "MentionMemberCell", for: indexPath) as! MentionMemberCell
            cell.configCell(data: data, index: indexPath.row)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case self.tableView :
            let rowType = editArticleVM.cells[indexPath.row].rowType
            switch rowType {
            case .TOTALAMOUNT:
                return UITableView.automaticDimension
            default :
                return UITableView.automaticDimension
            }
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch tableView {
        case self.tableView :
            let rowType = editArticleVM.cells[indexPath.row].rowType
            
            switch rowType {
            case .APPROVERS:
                
                if self.requestApprovers.count == 0 {
                    for data in self.editArticleVM.rec005_R002?.REC3 ?? [] {
                        self.requestApprovers.append(MREC_BLTB_0004_C002.REQUEST.REC6(APPRVR_ID: data.APPRVR_ID, APPRVR_NM: data.APPRVR_NM))
                    }
                }
                self.popSelectApprovalItem(selectCount: "\(self.requestApprovers.count)/4",  selectData: self.requestApprovers, BLTB_CD: self.editArticleVM.rec005_R002?.BLTB_CD ?? "", optionType: .APPROVERS) { option,data  in
                    if tableView.dequeueReusableCell(withIdentifier: "ApprovalSelectInfoWeCMSCell") is ApprovalSelectInfoWeCMSCell {
                        self.editArticleVM.updateApprovalWeCMS(selectApprover: option, index: indexPath.row)
                        self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .none)
                    }
                    self.requestApprovers = data
                    self.getApprovers = data
                }
                
                /*
                let vc = UIStoryboard(name: "ViewApproverSB", bundle: nil).instantiateViewController(withIdentifier: "ViewApproverVC") as! ViewApproverVC
                vc.APPROVER_REC    = self.editArticleVM.rec005_R002?.REC3 ?? []
                vc.requestorName   = self.boardREC?.REG_NM ?? ""
                vc.requetorProfile = self.boardREC?.REG_IMG_URL ?? ""
                let options = SheetOptions(
                    pullBarHeight: 25,  // Height of pullbar that contains the pull grip
                    useFullScreenMode: false,
                    shrinkPresentingViewController: false,   // Present smaller VC to FittedSheet
                    useInlineMode: false,
                    maxWidth: nil // doesn't limit the width
                )
                var approverSize = 0
                if let REC = self.editArticleVM.rec005_R002?.REC3 {
                    for (_, c) in REC.enumerated() {
                        if c.APPR_DTM != nil {
                            approverSize += 65 + 30
                        } else {
                            approverSize += 42 + 30
                        }
                    }
                }
                let size = CGFloat(approverSize + 25 + 40 + 82) + bottomSafeAreaInset
                let sheetController = SheetViewController(controller: vc, sizes: [.fixed(size)], options: options)
                sheetController.gripSize        = CGSize(width: 40, height: 5) // Size of pull grip
                sheetController.dismissOnPull   = true  // Enable pull down to dismiss
                sheetController.cornerRadius    = 20
                sheetController.allowPullingPastMaxHeight = true
                self.present(sheetController, animated: true)
                 */
                 
                /*
                 case .EXPENSES:
                 
                 if self.requestExpense.count == 0{
                 for data in self.editArticleVM.rec005_R002?.REC ?? [] {
                 self.requestExpense.append(MREC_BLTB_0004_C002.REQUEST.REC1(TRCO_KEY: data.TRCO_KEY, TRCO_CMNM: data.TRCO_CMNM, TRCO_CMENM: data.TRCO_CMENM, CCY_CD: data.CCY_CD, AMT: data.AMT, BUSA_USAG_CD: data.BUSA_USAG_CD, MEMO: data.MEMO, DOC_ID: data.DOC_ID, DOC_TYPE: data.DOC_TYPE))
                 }
                 }
                 self.popSelectApprovalItemExpense(selectData: [], optionType: .EXPENSES) { option,data  in
                 for (_, item) in data.enumerated() {
                 if (item.CCY_CD ?? "").contains("KHR") {
                 let intAMT = Double(item.AMT?.replace(of: "KHR", with: "") ?? "") ?? 0
                 self.TOTL_AMTKHR += intAMT
                 }else{
                 let intAMT = Double(item.AMT?.replace(of: "USD", with: "") ?? "") ?? 0
                 self.TOTL_AMTUSD += intAMT
                 }
                 }
                 print("KHR USD", self.TOTL_AMTKHR, self.TOTL_AMTUSD)
                 if tableView.dequeueReusableCell(withIdentifier: "ApprovalSelectInfoWeCMSCell") is ApprovalSelectInfoWeCMSCell {
                 self.editArticleVM.getDataApproval(selectApprover: option)
                 let lastRowIndex = tableView.numberOfRows(inSection: indexPath.section) - 3
                 self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section),IndexPath(row: lastRowIndex, section: indexPath.section)], with: .none)
                 }
                 self.requestExpense = data
                 }
                 */
                
            case .IMAGE:
                
                let vc = VC(sbName: "PhotoPreviewSB", identifier: "PhotoPreviewsVC") as! PhotoPreviewsVC
                vc.modalPresentationStyle = .fullScreen
                vc.isBtnDeleteDisable = true
                
                 // indexPath.row - 1 becuase index 0 is title and decription row
                vc.currentIndexImage  = indexPath.row - 1
                
                vc.imageUrlArray    = [["RCPT_IMG_URL" : imagePreviewArr]] as Array<AnyObject>
                vc.isFromEditPostArticle = true
                let img = tableView.cellForRow(at: indexPath) as! ImageViewWeCMSCell
                vc.cc_setZoomTransition(originalView: img.imageContainView) // Zoom trasition
                self.present(vc, animated: true)
                
            case .EXPENSESITEM:
                let data = self.editArticleVM.cells[indexPath.row]
                if data.DOC_TYPE == "E"{ // DOC_TYPE
                    let vc = UIStoryboard(name: "ReceiptDetailsSB", bundle: nil).instantiateViewController(withIdentifier: "ReceiptDetailsVC") as! ReceiptDetailsVC
                    vc.doc_id = data.DOC_ID ?? "" //DOC_ID
                    vc.usag_nm = data.decription ?? ""
                    vc.isRequestApproval = true
                    vc.isFromExpenseApproval = true
                    
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .custom
                    self.present(nav, animated: true)
                     
                }else if data.DOC_TYPE == "" || data.DOC_TYPE == nil{ //DOC_ID
                    self.popAddOtherManual(dataEditExpense: data, isEditManual: "VIEW_DETAIL")
                }
                
            case .SEEMORE:
                var data : [MREC_BLTB_0004_C002.REQUEST.REC1] = []
                for item in self.editArticleVM.rec005_R002?.REC ?? [] {
                    data.append(MREC_BLTB_0004_C002.REQUEST.REC1(TRCO_KEY: item.TRCO_KEY, TRCO_CMNM: item.TRCO_CMNM, TRCO_CMENM: item.TRCO_CMENM, CCY_CD: item.CCY_CD, AMT: item.AMT, BUSA_USAG_CD: item.BUSA_USAG_CD, MEMO: item.MEMO, DOC_ID: item.DOC_ID, DOC_TYPE: item.DOC_TYPE, USAG_NM: item.USAG_NM))
                }
                self.expenseListPop(optionData: data, isCreate: false)
            default:
                break
            }
            
        case self.mentionTableView:
            let data = mentionMemberVM.filteredList[indexPath.row]
            if data.email.contains(".org") || data.email.contains(".cc") || data.email.contains(".net") || data.email.contains(".com") || data.email.contains(".kr") || data.email.contains(".kh") {
                
                let name = data.name.trimmingCharacters(in: .whitespaces)
                let userInfo = MentionMemberUIModel(name: name, email: "@[\(name)](\(data.email))", photo: data.photo, USER_IMG: data.USER_IMG)
                
                var isAlreadyExisted = false
                for obj in mentionedMembers {
                    if obj.email == userInfo.email {
                        isAlreadyExisted = true
                        break
                    }
                }
                
                if !isAlreadyExisted {
                    mentionedMembers.append(userInfo)
                    mentionedMemberNames.append(name)
                }
                
                
                // Fucking important algorithm, without this mention could not be complete
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ApprovalFormHeaderCell {
                    
                    let existedText =  cell.descriptionTextView.text ?? ""
                    var newText = ""
                    
                    if cursorPosition == existedText.utf16.count || existedText.utf16.count == (cursorPosition + 1) {
                        let split = existedText.components(separatedBy: " ")
                        let old = split.dropLast()
                        let last = split.last?.removing(charactersOf: "@")
                        
                        if last == self.stringToSearch {
                            newText = "\(old.joined(separator: " ")) \(data.name) "
                        } else {
                            newText = existedText.replace(of: "@\(stringToSearch)", with: "\(data.name) ")
                        }
                    } else {
                        
                        if stringToSearch == "@" {
                            var temptText = existedText
                            
                            if cursorPosition < temptText.utf16.count {
                                temptText.remove(at: temptText.utf16.index(temptText.utf16.startIndex, offsetBy: cursorPosition))
                                temptText.insert(contentsOf: "\(data.name) ", at: temptText.utf16.index(temptText.utf16.startIndex, offsetBy: cursorPosition))
                            }
                            
                            newText = temptText
                        } else {
                            newText = existedText.replace(of: "@\(stringToSearch)", with: "\(data.name) ")
                        }
                        
                    }
                    
                    let tempSyntaxText = formatMentionFromReadableToAPISyntax(originalText: newText, mentionedMembers: mentionedMembers)
                    self.editArticleVM.tempDescription = tempSyntaxText
                    
                    cell.descriptionTextView.text = newText
                    
                    if mentionedMemberNames.count > 0 {
                        let originalFont =  UIFont(name: "Inter-Medium", size: 15.0)
                        setAttributeTextView(textView: cell.descriptionTextView , textsTobeAttributed: mentionedMemberNames, defaultFont: originalFont, defaultColor: .black, attributedFont: originalFont, atrributedColor: UIColor(resource: .mainTextBulletin))
                    }
                    
                    mentionTableViewHC.constant = 0
                    self.backgroundViewButton.isHidden = false
                    UIView.animate(withDuration: 0.1) {
                        self.view.layoutIfNeeded()
                    }
                }
            } else {
                self.customAlert(type: .CONFIRM_ALERT, image: "", title: "notice".localized, message: "incorrect_email_address_format".localized, redTitle: "close".localized, greyTitle: "close".localized)
            }
            
        default: break
        }
    }
}

//MARK: - UITextViewDelegate
extension EditArticleWeCMSVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let point           = textView.convert(CGPoint.zero, to: self.tableView)
        let indexPath       = self.tableView.indexPathForRow(at: point)!
        if let cell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell {
            cell.titleTextView.placeholderText = "title".localized
            cell.descriptionTextView.placeholderText = "description".localized + " " + "max_200_characters".localized
        }
        //if get file or image more than 5 hide add file and image
        if boardREC?.POST_TYPE_CD == "01"{
            TopBarKeyboardView.setCountImageFile(editArticleVM.REC2.count)
        }else{
            TopBarKeyboardView.setCountImageFile(editArticleVM.REC3.count)
        }
    }
    
//    func textViewDidChangeSelection(_ textView: UITextView) {
        //        var tempDataInfo = (OT_request_vm.contentData[indexPath.row].value as? OT_request_content_body.ContentBody)
        //
        //        tempDataInfo?.reason?.value = textView.text
        //
        //        OT_request_vm.contentData[indexPath.row].value = tempDataInfo
//    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //        let tempDataInfo = (OT_request_vm.contentData[indexPath.row].value as? OT_request_content_body.ContentBody)
        let point           = textView.convert(CGPoint.zero, to: self.tableView)
        let indexPath       = self.tableView.indexPathForRow(at: point)!
        if let cell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell {
            self.POST_TITLE = cell.titleTextView.text ?? ""
            self.POST_CONT  = cell.descriptionTextView.text ?? ""
            
            if textView.text.isEmpty {
                cell.titleTextView.placeholderText = "title".localized
                cell.descriptionTextView.placeholderText = "description".localized + " " + "max_200_characters".localized
            }
        }
        let tempSyntaxText = formatMentionFromReadableToAPISyntax(originalText: textView.text, mentionedMembers: mentionedMembers)
        self.editArticleVM.tempDescription = tempSyntaxText
        
        IQKeyboardManager.shared.resignOnTouchOutside = true
        mentionTableViewHC.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //make textview size automatic
        UIView.setAnimationsEnabled(false)
        textView.sizeToFit()
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        let point           = textView.convert(CGPoint.zero, to: self.tableView)
        let indexPath       = self.tableView.indexPathForRow(at: point)!
        if let cell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell {
            self.POST_TITLE = cell.titleTextView.text ?? ""
            self.POST_CONT  = cell.descriptionTextView.text ?? ""
            self.editArticleVM.setContent(rowType: .NEW_ARTICLE, desc: self.POST_CONT, title: self.POST_TITLE)
        }
        let tempSyntaxText = formatMentionFromReadableToAPISyntax(originalText: textView.text, mentionedMembers: mentionedMembers)
        self.editArticleVM.tempDescription = tempSyntaxText
        //validate Button
        
        //        if textView.tag == 1010 {
        //            self.POST_TITLE = textView.text
        //        }
        //
        //        if textView.tag == 1011 {
        //            self.POST_CONT = textView.text
        //        }
        
        //        let isIntact = self.POST_CONT == self.descriptionAPI && self.POST_TITLE == self.titleFromAPI
        //        if self.POST_TITLE.isNotEmpty && self.POST_CONT.isNotEmpty && !isIntact {
        //            self.enableSaveButton()
        //        }else{
        //            self.disableSaveButton()
        //        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let point           = textView.convert(CGPoint.zero, to: self.tableView)
        let indexPath       = self.tableView.indexPathForRow(at: point)!
        let currentText = textView.text as NSString
        let newText = currentText.replacingCharacters(in: range, with: text)
        let cell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell
        self.textCount = textView.text.count
        if textView == cell?.titleTextView {
            if text == "\n"{
                self.Spacing = Spacing + 30 // spacing for Title
                self.spceAfterText = self.Spacing
                cell?.textCountBottomConstraint.constant = cell?.textCountBottomConstraint.constant ?? 0 <= 20 ? 20 : tableView.frame.size.height - self.Spacing
            }
        }else if textView == cell?.descriptionTextView {
            if text == "\n"{
                self.Spacing = Spacing + 15 // spacing for Description
                self.spceAfterText = self.Spacing
                cell?.textCountBottomConstraint.constant = cell?.textCountBottomConstraint.constant ?? 0 <= 20 ? 20 : tableView.frame.size.height - self.Spacing
            }
            cell?.textCountLabel.text        = "\(self.textCount)/200"
            cell?.textCountLabel.textColor   = .gray
        }else{
            //Todo
        }
        
        // ============================================== Start Mention Part ==============================================
        if textView.tag == 1011 {
            
            if textView.text.utf16.count < 2 {
                mentionedMembers = []
                mentionedMemberNames = []
            }
            
            // Navy: Mention Part
            // Typing text for search in mention
            var typingWord = ""
            let point           = textView.convert(CGPoint.zero, to: self.tableView)
            let indexPath       = self.tableView.indexPathForRow(at: point)!
            
            // new updated text
            let nsString = textView.text as NSString?
            let updatedString = nsString?.replacingCharacters(in: range, with: text)
            let headerCell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell
            
            // Get location of cursor
            if let selectedRange = textView.selectedTextRange {
                cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            }
            
            // ================== Fucking important note !!!!!!! =====================
            // CASE A : Incase user alway typing forward and the cursor is always at last, we easy to get tying text to search by splitting it with space
            // CASE B : Incase toxic user move cursor to the middel of middle of text, we need to get typing in few fucking steps:
            // Step 1: get location of cursor
            // Step 2: get text behind cursor by loop backward from cursor location till space then stop, then collection character one by one and make it as string
            // Step 3: The string was combinded behind the cursor are new typing text
            
            if cursorPosition == textView.text.utf16.count {
                
                let newString = updatedString ?? ""
                if newString.contains("\n")  {
                    let split = updatedString?.components(separatedBy: "\n")
                    let lastSplit = split?.last
                    
                    
                    let split2 = lastSplit?.components(separatedBy: " ")
                    typingWord = split2?.last ?? ""
                    
                } else {
                    let split = updatedString?.components(separatedBy: " ")
                    typingWord = split?.last ?? ""
                }
                
                
                if mentionedMemberNames.count > 0 {
                    let originalFont =  UIFont(name: "Inter-Medium", size: 15.0)
                    self.setAttributeTextView(textView: textView, textsTobeAttributed: mentionedMemberNames, defaultFont: originalFont, defaultColor: .black, attributedFont:originalFont , atrributedColor: UIColor(resource: .mainTextBulletin))
                }
                
            } else {
                
                var newStringArray = [""]
                
                for index in (0...cursorPosition).reversed() {
                    
                    let str = "\(updatedString ?? "")"
                    let stringArray = Array(str)
                    
                    // check prevent crash when user hold backspace button
                    if text != "" {
                        if stringArray.count > index {
                            if stringArray[index] == " " || stringArray[index] == "\n" {
                                break
                            } else {
                                newStringArray.insert(String(stringArray[index]), at: 0)
                            }
                        }
                    }
                }
                
                typingWord = newStringArray.joined(separator: "")
                
                if typingWord.contains("\n") {
                    typingWord = typingWord.removing(charactersOf: "\n")
                }
            }
            
            
            
            let numberOfAddress = typingWord.numberOfOccurrencesOf(string: "@")
            if  numberOfAddress == 1 {
                
                if typingWord == "@" /*|| typingWord.last == "@"*/ {
                    stringToSearch = ""
                } else if typingWord.first == ("@") || typingWord.getLast2Characters() == "\n@" {
                    stringToSearch = typingWord.removing(charactersOf: "@").replace(of: "\n", with: "")
                } else {
                    mentionMemberVM.filteredList = []
                }
                let BLTB_CD  =  Shared.BLTB_CD  == "" ? "999999999999999" : Shared.BLTB_CD
                let body =  MREC_BLTB_0004_R001.REQUEST(BLTB_CD: BLTB_CD , USER_NM: stringToSearch.removing(charactersOf: "@"))
                self.mentionMemberVM.requestMentionMembers(body: body) { result in
                    switch result {
                    case .success(_):
                        
                        self.mentionTableView.reloadData()
                        
                        // Show or Hide tableView
                        if self.mentionMemberVM.filteredList.count != 0 {
                            let divided = self.screenHeight / 3
                            self.mentionTableViewHC.constant = self.screenHeight - divided + 10
                            IQKeyboardManager.shared.resignOnTouchOutside = false
                            self.backgroundViewButton.isHidden = true
                            
                        } else {
                            IQKeyboardManager.shared.resignOnTouchOutside = true
                            self.mentionTableViewHC.constant = 0
                            self.backgroundViewButton.isHidden = false
                        }

                    case .failure(let error):
                        print(error)
                    }
                }
                
            } else {
                IQKeyboardManager.shared.resignOnTouchOutside = true
                mentionTableViewHC.constant = 0
                self.backgroundViewButton.isHidden = false
            }
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            
            let tempSyntaxText = formatMentionFromReadableToAPISyntax(originalText: textView.text, mentionedMembers: mentionedMembers)
            self.editArticleVM.tempDescription = tempSyntaxText
            // ============================================== End Mention Part ==============================================
            
            if self.editArticleVM.POST_APPR_DV == "00" || self.editArticleVM.POST_APPR_DV == "10" {
                return textView == headerCell?.descriptionTextView ? updatedString?.count ?? 0 <= 200 : true
            }
        }
        return true
    }
}

//MARK: - TopBarKeyboardDelegate
extension EditArticleWeCMSVC: TopBarKeyboardDelegate {
    
    func addFile(_ files: [FileModel]) {
        for file in files {
            let fileName = file.fileName.removingPercentEncoding
            let fileData = file.fileData.base64EncodedString()
            
            if self.boardREC?.POST_TYPE_CD == "01" { //append file for Edit Article
                self.editArticleVM.REC2.append(MREC_BLTB_0004_U001.REQUEST.REC2(FILE_NM: fileName, FILE_DATA: fileData))
                var index = 1
                var checkIndex = false
                for (n, c) in self.editArticleVM.cells.enumerated() {
                    if c.rowType == .ATTACHMENT{
                        index = n
                        checkIndex = true
                    }else {
                        for (n, c) in self.editArticleVM.cells.enumerated() {
                            if c.rowType == .IMAGE{
                                index = n
                                checkIndex = true
                            }
                        }
                    }
                }
                index = checkIndex ? index : 0
                self.editArticleVM.cells.insert(EditArticleData(rowType: .ATTACHMENT, fileName: fileName, fileData: "\(file.fileData)"), at: index + 1)
                self.Spacing = self.tableView.frame.size.height - CGFloat(self.editArticleVM.attacmentREC2.count*46)
                
                for _ in self.editArticleVM.attacmentREC2.filter( {($0.FILE_NM ?? "").contains(".jpg")}) {
                    self.Spacing = self.tableView.frame.size.height - 20
                }
                
            }else{ //append file for Edit Approval
                self.editArticleVM.REC3.append(MREC_BLTB_0004_U002.REQUEST.REC3(FILE_NM: fileName, FILE_DATA: fileData))
                var index = 1
                var checkIndex = false
                for (n, c) in self.editArticleVM.cells.enumerated() {
                    if c.rowType == .ATTACHMENT{
                        index = n
                        checkIndex = true
                    }else {
                        for (n, c) in self.editArticleVM.cells.enumerated() {
                            if c.rowType == .IMAGE{
                                index = n
                                checkIndex = true
                            }
                        }
                    }
                }
                index = checkIndex ? index : 0
                self.editArticleVM.cells.insert(EditArticleData(rowType: .ATTACHMENT, fileName: fileName, fileData: "\(file.fileData)"), at: index + 1)
                self.tableView.insertRows(at: [IndexPath(row:  index + 1, section: 0)], with: .automatic)
                self.Spacing = self.tableView.frame.size.height - CGFloat(self.editArticleVM.attacmentREC3.count*46)
                
                for _ in self.editArticleVM.attacmentREC3.filter( {($0.FILE_NM ?? "").contains(".jpg")}) {
                    self.Spacing = self.tableView.frame.size.height - 20
                }
            }
        }
        if boardREC?.POST_TYPE_CD == "01"{
            TopBarKeyboardView.setCountFile(editArticleVM.REC2.count)
        }else{
            TopBarKeyboardView.setCountFile(editArticleVM.REC3.count)
        }
        self.tableView.reloadData()
    }
    
    func addImage(_ images: [UIImage]) {
        if images.count != 0 {
            for (i, image) in images.enumerated() {
                if let base64 = convertToBase64(image) {
                    let formatter           = DateFormatter()
                    formatter.dateFormat    = "yyyMMddHHmm"
                    let fileName = "\(formatter.string(from: Date()))\(i).jpg"
                    
                    if self.boardREC?.POST_TYPE_CD == "01"{ //append images for Edit Article
                       
                        self.editArticleVM.REC2.append(MREC_BLTB_0004_U001.REQUEST.REC2(FILE_NM: fileName, FILE_DATA: base64))
                        var i = 0
                        for (n, c) in self.editArticleVM.cells.enumerated() {
                            if c.rowType == .IMAGE {
                                i = n
                            }
                        }
                        self.editArticleVM.cells.insert(EditArticleData(rowType: .IMAGE, insertImage: base64, fileName: fileName), at: i + 1)
                        
                    }else{
                        self.editArticleVM.REC3.append(MREC_BLTB_0004_U002.REQUEST.REC3(FILE_NM: fileName, FILE_DATA: base64))
                        var i = 0
                        for (n, c) in self.editArticleVM.cells.enumerated() {
                            if c.rowType == .IMAGE {
                                i = n
                            }
                        }
                        self.editArticleVM.cells.insert(EditArticleData(rowType: .IMAGE, insertImage: base64, fileName: fileName), at: i + 1)
                    }
                    //append to preview image from local
                    self.imagePreviewArr.append(PreviewModel(fileName: fileName, image: image))
                }
            }
        }
        if boardREC?.POST_TYPE_CD == "01"{
            TopBarKeyboardView.setCountImageFile(editArticleVM.REC2.count)
        }else{
            TopBarKeyboardView.setCountImageFile(editArticleVM.REC3.count)
        }
       
        self.Spacing = self.tableView.frame.size.height - 20
        self.tableView.reloadData()
        //  enableSaveButton()
    }
    
    func dismissKeyboard() {
        let point           = tableView.convert(CGPoint.zero, to: self.tableView)
        let indexPath       = self.tableView.indexPathForRow(at: point)!
        if let cell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell {
            cell.descriptionTextView.resignFirstResponder()
        }
    }
}

//MARK: - SelectPurposeDelegate
extension EditArticleWeCMSVC: SelectPurposeDelegate {
    
    func sendProjectREC(rec: LIST_POP_UP_RESPONSE.PROJECT_SITE_LIST) {
        self.tableView.reloadData()
    }
    
    // PURPOSE
    func sendRECItem(rec: LIST_POP_UP_RESPONSE.REC , type: POPUP_TYPE) {
        self.tableView.reloadData()
    }
    
    // Advance Legder
    func sendREC2Item(rec2: LIST_POP_UP_RESPONSE.REC2) {
    }
    
    // PURPOSE
    func sendUserListItem(userList: LIST_POP_UP_RESPONSE.USE_LIST) {
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
}

//
//  ExpenseApprovalWeCMSVC.swift
//  WABOOKS_iOS_V2
//
//  Created by lymanny on 15/1/25.
//
//  Note: This class was adapted from ExpenseApprovalVC
//  Some conditions and methods have been modified to fit the requirements of the ExpenseApprovalWeCMS feature.

import UIKit
import IQKeyboardManagerSwift

import SDWebImage
import Photos

class ExpenseApprovalWeCMSVC: UIViewController, UIDocumentInteractionControllerDelegate {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var collectionView                : UICollectionView!
    @IBOutlet weak var navigationBar                 : NavigationBar!
    @IBOutlet weak var commentView                   : CommentView!
    @IBOutlet weak var commentViewHeightConstraint   : NSLayoutConstraint!
    @IBOutlet weak var mentionTableViewHC            : NSLayoutConstraint!
    @IBOutlet weak var mentionTableViewTopContraint  : NSLayoutConstraint!
    @IBOutlet weak var mentionTableView              : UITableView!
    @IBOutlet weak var navigationBarHeightConstraint : NSLayoutConstraint!
    
    //MARK: - Properties & Variable
    var expenseApprovalVM = ExpenseApprovalVM()
    
    var DV_CD          = ""
    var COMNT_SEQ_NO   = ""
    var FileType       = ""
    var FileId         = ""
    var APPRVR_STTS    = ""
    var COMNT_CONT     = ""
    var REC_IN         = ""
    var stringToSearch = ""
    
    var isNotification: Bool = false
    var isShouldReload: Bool = false
    var isHightLight         = false
    
    var mentionMemberVM      = MentionMemberVM()
    var boardsVM             = BoardsVM()
    var commentVM            = CommentVM()
    var bottomBlockHeight    : CGFloat = 0
    var mentionedMembers     : [MentionMemberUIModel] = []
    var mentionedMemberNames : [String] = []
    var indexPathUpdate      = IndexPath()
    var receiptList          : [[WABOOKS_MREC_R006.RESPONSE.REC]]    = [[]]
    var selectedDocuments    : [FileModel] = []
    var selectedImages       : [String] = []
    var imageSave            : UIImage?
    var boardRec             : WABOOKSStruct.BoardDetail_Protocol?
    var indexSection         : Int = 0
    var indexPath            : Int = 0
    var isEditComment        = false
    var editing_COMNT_SEQ_NO = ""
    
    var indexPathEditComment = IndexPath(row: 0, section: 0)
    var fileIndexPath        = IndexPath(row: 0, section: 0)
    var imageIndexPath       = IndexPath(row: 0, section: 0)
    
    var File_ID              = ""
    
    private var assetCollection: PHAssetCollection!
    
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mentionTableViewHC.constant = 0
        self.mentionMemberVM.initCellData(data: [])
        
        // Do any additional setup after loading the view.
        mentionTableView.register(UINib(nibName: "MentionMemberCell", bundle: nil), forCellReuseIdentifier: "MentionMemberCell")
        collectionView.register(UINib(nibName: "MultiImageCell", bundle: nil), forCellWithReuseIdentifier: "MultiImageCell")
        
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil )
        self.navigationBar.rightButton.addTarget(self, action:#selector(popup(_:)) , for: .touchUpInside)
        
        setupCollectionView()
//        expenseApprovalVM.POST_APPR_DV = POST_APPR_DV
//        expenseApprovalVM.POST_TYPE_CD = POST_TYPE_CD
        
        navigationBar.title = "expense_approval".localized
        navigationBarHeightConstraint.constant = expenseApprovalVM.POST_TYPE_CD == "01" || self.expenseApprovalVM.POST_APPR_DV == "00" ? 52 : 67
        self.navigationBar.layoutIfNeeded()
        self.navigationBar.view.layoutIfNeeded()
        
        commentView.isHidden = true
        setupCommentView()
        
        commentView.delegate = self
        commentView.dataSource = self
        
        if isShouldReload {
            getAllData(showLoading: true)
        }
        self.checkingNotify()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        swipeNavigationBack()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        MyNotify.send(name: .reloadBoardVCAfterDetail)
    }
    
    //MARK: - Function
    private func checkingNotify() {
        self.isShouldReload = false
        MyNotify.listen(self, selector: #selector(reloadAfterPostToBoardSubmit), name: .GotoExpenseApproval)
    }
    
    func getAllData(showLoading: Bool = false, completionArticle: ((Swift.Result<WABOOKS_MREC_BLTB_0005_R001.RESPONSE, NSError>) -> Void)? = nil, completionExpense: ((Swift.Result<WABOOKS_MREC_BLTB_0005_R002.RESPONSE, NSError>) -> Void)? = nil) {
        if self.expenseApprovalVM.POST_TYPE_CD == "01" {
            expenseApprovalVM.fetchArticle(showLoading: showLoading, POST_SEQ_NO: self.boardRec?.POST_SEQ_NO ?? "", BLTB_CD: self.boardRec?.BLTB_CD ?? "") { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.commentView.setUserProfileImage(url: self.expenseApprovalVM.responseListComment?.USER_IMG_URL)
                        self.commentVM.REC2 = []
                        self.commentView.commentViewVM.REC = []
                        self.commentView.textView.resignFirstResponder()
                        self.commentView.isHidden = false
                        self.commentViewHeightConstraint.constant = 54
                        self.commentView.layoutIfNeeded()
                        self.commentView.commentViewVM.content = [CommentViewModel(rowType: .TextView)]
                        self.commentView.collectionView.reloadData()
                        self.collectionView.reloadData()
                        completionArticle?(result)
                        if self.DV_CD == "8" || self.DV_CD == "10" || self.DV_CD == "14" || self.DV_CD == "15" {
                            self.scrollToComment()
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        completionArticle?(result)
                        if error.code == 1146 {
                            self.deletedPostSheet()
                        } else if error.code == 1147 {
                            let leftTitle = "Permissopn_has_been_denied".localized
                            let message = "You_do_not_have_the_permission_to_view_this_post".localized
                            self.infoMessagePopup(iconName: "", title: leftTitle, message: message, dismissOnPull: false, confirmTitle: "okay".localized) { isOkay in
                                if isOkay {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        } else {
                            self.alert(message: error.localizedDescription) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            }
        } else {
            expenseApprovalVM.fetchBoardDetailWeCMS(showLoading: showLoading, POST_SEQ_NO: self.boardRec?.POST_SEQ_NO ?? "", BLTB_CD: self.boardRec?.BLTB_CD ?? "") { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
//                        self.APPR_SEQ_NO = data.APPR_SEQ_NO ?? "" // Why Set again
                        self.commentView.setUserProfileImage(url: self.expenseApprovalVM.responseListComment?.USER_IMG_URL)
                        self.commentVM.REC2 = []
                        self.commentView.commentViewVM.REC = []
                        self.commentView.textView.resignFirstResponder()
                        if let DOC_NO = self.expenseApprovalVM.responseBoardDetail?.DOC_NO {
                            if self.expenseApprovalVM.POST_APPR_DV == "10" {
                                self.navigationBar.subTitle = "document_no.".localized + " \(DOC_NO)"
                            }
                        }
                        self.commentView.isHidden = false
                        self.commentViewHeightConstraint.constant = self.expenseApprovalVM.isApprover ? 140 : 54
                        self.commentView.isApprover = self.expenseApprovalVM.isApprover
                        self.commentView.layoutIfNeeded()
                        self.commentView.commentViewVM.content = [CommentViewModel(rowType: .TextView)]
                        self.commentView.collectionView.reloadData()
                        self.collectionView.reloadData()
                        completionExpense?(result)
                        if self.DV_CD == "8" || self.DV_CD == "10" || self.DV_CD == "14" || self.DV_CD == "15" {
                            self.scrollToComment()
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        completionExpense?(result)
                        if self.isNotification {
                            // This post has been deleted
#warning("Need to confirm with AOS")
                            if error.code == 1000 {
                                self.deletedPostSheet()
                            } else if error.code == 1146 {
                                self.deletedPostSheet()
                            }
                        } else {
                            self.alert(message: error.localizedDescription) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func deletedPostSheet() {
        let leftTitle   = "This_post_has_been_deleted".localized
        let message     = "The_owner_of_this_post_has_removed_or_edited_the_post".localized
        self.infoMessagePopup(iconName: "", title: leftTitle, message: message,dismissOnPull: false, confirmTitle: "okay".localized) { isOkay in
            if isOkay {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func scrollToComment() {
        for (n, c) in expenseApprovalVM.content.enumerated() {
            if c.rowType == .COMMENT_USER {
                if c.Comment_REC?.COMNT_SEQ_NO == self.COMNT_SEQ_NO {
                    let indexPath = IndexPath(row: 0, section: n)
                    collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
                    DispatchQueue.main.async {
                        self.checkHighlightUpdateComment()
                    }
                }
            }
        }
    }
    
    private func setupCommentView() {
        
        commentView.completionKeyboard = { [weak self] in
            guard let self else { return }
            if self.commentView.collectionView.contentSize.height <= 200 {
                self.commentViewHeightConstraint.constant = self.commentView.collectionView.contentSize.height + 1 + 10 + 10 + (self.expenseApprovalVM.isApprover ? 86 : 0)
                self.commentView.layoutIfNeeded()
            } else {
                self.commentViewHeightConstraint.constant = 200 + 10 + 10 + (self.expenseApprovalVM.isApprover ? 86 : 0)
                self.commentView.layoutIfNeeded()
            }
            IQKeyboardManager.shared.resignOnTouchOutside = true
            self.mentionTableViewHC.constant = 0
        }
        
        commentView.newCompletion = { [weak self] height, keyboardAppearance in
            guard let self else { return }
            let heightCollection = self.commentView.collectionView.contentSize.height
            if heightCollection <= 200 {
                self.commentViewHeightConstraint.constant  = heightCollection + 10 + 10 + 1 - 28 + (self.expenseApprovalVM.isApprover ? 86 : 0)
                self.commentViewHeightConstraint.constant += keyboardAppearance ? height : 0
                if self.commentViewHeightConstraint.constant < 54 + (self.expenseApprovalVM.isApprover ? 86 : 0) {
                    self.commentViewHeightConstraint.constant = 54 + (self.expenseApprovalVM.isApprover ? 86 : 0)
                }
                self.commentView.layoutIfNeeded()
            } else {
                self.commentViewHeightConstraint.constant = 200 + 10 + 10 + (self.expenseApprovalVM.isApprover ? 86 : 0)
                self.commentViewHeightConstraint.constant += keyboardAppearance ? height : 0
                self.commentView.layoutIfNeeded()
            }
        }
        
        commentView.removeFileCompletion = { [weak self] height, keyboardAppearance in
            guard let self else { return }
            let heightCollection = self.commentView.collectionView.contentSize.height
            if heightCollection <= 200 {
                self.commentViewHeightConstraint.constant  = heightCollection + 10 + 10 + 1 + (self.expenseApprovalVM.isApprover ? 86 : 0)
                self.commentViewHeightConstraint.constant -= 28
                self.commentViewHeightConstraint.constant += keyboardAppearance ? height : 0
                if self.commentViewHeightConstraint.constant < 54 + (self.expenseApprovalVM.isApprover ? 86 : 0) {
                    self.commentViewHeightConstraint.constant = 54 + (self.expenseApprovalVM.isApprover ? 86 : 0)
                }
                self.commentView.layoutIfNeeded()
            } else {
                self.commentViewHeightConstraint.constant = 200 + 10 + 10 + 1 + (self.expenseApprovalVM.isApprover ? 86 : 0)
                self.commentViewHeightConstraint.constant += keyboardAppearance ? height : 0
                self.commentView.layoutIfNeeded()
            }
        }
        
        commentView.completionSelectDocument = { [weak self] file in
            self?.selectedDocuments = file
        }

        commentView.completionImageUrls = { [weak self] imageStrings in
            self?.selectedImages = imageStrings
        }
        
        commentView.completionPostComment = { [weak self] commentString in
            guard let self else { return }
            // *** NOTE ***
            // 👉 no need to formatted POST_CONT into user info form, if no member has been mentioned
            // 👉 when one or more member has been mentioned in the POST_CONT, must format it into user info form => "@[Sokny Ran (Yakuza)](soknyran.dev@gmail.com)"
            var POST_CONT_Formatted = commentString
            if self.mentionedMembers.count != 0 {
                POST_CONT_Formatted = self.formatMentionFromReadableToAPISyntax(originalText: commentString, mentionedMembers: self.mentionedMembers)
            }
            
            if !self.isEditComment {
                
                var REC : [WABOOKS_MREC_BLTB_0002_C001.REQUEST.REC] = []
                
                for (commentIndex, commentObj) in self.commentView.commentViewVM.content.enumerated() {
                    if commentObj.rowType == .FileType {
                        for (_, c) in self.commentView.commentViewVM.content[commentIndex].file.enumerated() {
                            let fileName = c.fileName.removingPercentEncoding
                            let fileData = c.fileData.base64EncodedString()
                            let eachDoc  = WABOOKS_MREC_BLTB_0002_C001.REQUEST.REC(FILE_NM: fileName, FILE_DATA: fileData)
                            REC.append(eachDoc)
                        }
                    } else if commentObj.rowType == .ImageType {
                        for (n, c) in self.commentView.commentViewVM.content[commentIndex].image.enumerated() {
                            if let base64 = convertToBase64(c.image) {
                                let formatter           = DateFormatter()
                                formatter.dateFormat    = "yyyMMddHHmm"
                                let fileName = "\(formatter.string(from: Date()))\(n).jpg"
                                let eachDoc  = WABOOKS_MREC_BLTB_0002_C001.REQUEST.REC(FILE_NM: fileName, FILE_DATA: base64)
                                REC.append(eachDoc)
                            }
                        }
                    }
                }
                
                
                // * COMNT_DV_CD = "C" => COMNT_TASK_CD =  C001 (Comment)
                // * COMNT_DV_CD = "R" => R001 ('Pin
                //                        R002 ('Approval' -> 'Rejected')
                //                        R003 ('Approval' → ‘Complete’)
                //                        R004 ('Approval' -> 'Approved')
                //
                let COMNT_DV_CD   = "C"
                let COMNT_TASK_CD = "C001"
                
                let body = WABOOKS_MREC_BLTB_0002_C001.REQUEST(BLTB_CD: self.boardRec?.BLTB_CD ?? "", POST_SEQ_NO: self.boardRec?.POST_SEQ_NO ?? "", COMNT_DV_CD: COMNT_DV_CD, COMNT_TASK_CD: COMNT_TASK_CD, COMNT_CONT: POST_CONT_Formatted.convertStringToHTML, REC: REC)
                
                self.commentVM.requestAddComment(body: body) { result in
                    switch result {
                        
                    case .success(_):
                        self.commentView.TopBarKeyboardView.resetCount()
                        self.commentView.addedCommentCompletion()
                        
                        self.getAllData(completionArticle: { result in
                            switch result {
                            case .success(_):
                                self.checkHighlightAddComment()
                            case .failure(_):
                                break
                            }
                        }, completionExpense:  { result in
                            switch result {
                            case .success(_):
                                self.checkHighlightAddComment()
                            case .failure(_):
                                break
                            }
                        })
                        
                    case .failure(let error):
                        self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: error.localizedDescription, greyTitle: "ok".localized)
                    }
                }
            } else {
                
                let REC2    = self.commentVM.REC2
                let REC     = self.commentView.commentViewVM.REC
                
                let body = WABOOKS_MREC_BLTB_0002_U001.REQUEST(BLTB_CD: self.boardRec?.BLTB_CD ?? "", POST_SEQ_NO: self.boardRec?.POST_SEQ_NO ?? "", COMNT_SEQ_NO: self.editing_COMNT_SEQ_NO, COMNT_CONT: POST_CONT_Formatted.convertStringToHTML, REC2: REC2, REC: REC) // heremen data or image
                
                self.commentVM.requestUpdateComment(body: body) { result in
                    switch result {
                        
                    case .success(_):
                        self.commentView.TopBarKeyboardView.resetCount()
                        self.isEditComment = false
                        //                        self.editing_COMNT_SEQ_NO = ""
                        
                        
                        self.commentView.addedCommentCompletion()
                        
                        //                        self.expenseApprovalVM.showLoading = false
                        self.getAllData(completionArticle: { result in
                            switch result {
                            case .success(_):
                                self.checkHighlightUpdateComment()
                            case .failure(_):
                                break
                            }
                        }, completionExpense:  { result in
                            switch result {
                            case .success(_):
                                self.checkHighlightUpdateComment()
                            case .failure(_):
                                break
                            }
                        })
                        
                    case .failure(let error):
                        self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: error.localizedDescription, greyTitle: "ok".localized)
                        
                    }
                }
            }
            
        }
        
        
        commentView.completionTypingWord = { [weak self] typingWord in
            guard let self else { return }
            let numberOfAddress = typingWord.numberOfOccurrencesOf(string: "@")
            if  numberOfAddress == 1 {
                // When text containt "@"
                //                print("Front typing word: ", typingWord)
                
                if typingWord == "@" || typingWord.getLast2Characters() == "\n@"/*|| typingWord.last == "@"*/ {
                    self.stringToSearch = typingWord
                } else if typingWord.first == ("@")  {
                    self.stringToSearch = typingWord.removing(charactersOf: "@")
                } else {
                    self.mentionMemberVM.filteredList = []
                }
                let BLTB_CD  =  Shared.BLTB_CD  == "" ? "999999999999999" : Shared.BLTB_CD
                let body =  WABOOKS_MREC_BLTB_0004_R001.REQUEST(BLTB_CD: BLTB_CD, USER_NM: self.stringToSearch.removing(charactersOf: "@"))
                self.mentionMemberVM.requestMentionMembers(body: body) { result in
                    switch result {
                    case .success(_):
                        
                        self.mentionTableView.reloadData()
                        // Show or Hide tableView
                        if self.mentionMemberVM.filteredList.count != 0 {
                            
                            if self.mentionMemberVM.filteredList.count >= 4 {
                                self.mentionTableViewHC.constant = 220
                                if self.expenseApprovalVM.isApprover == true {
                                    self.mentionTableViewTopContraint.constant = self.screenHeight - self.bottomBlockHeight - 148
                                }else{
                                    self.mentionTableViewTopContraint.constant = self.screenHeight - self.bottomBlockHeight - 60
                                }
                            } else {
                                self.mentionTableViewHC.constant = CGFloat(self.mentionMemberVM.filteredList.count * 60)
                                let remainingValue = 4 - self.mentionMemberVM.filteredList.count
                                let sizeToIncrease = CGFloat(remainingValue * 50)
                                if self.expenseApprovalVM.isApprover == true {
                                    self.mentionTableViewTopContraint.constant = self.screenHeight - self.bottomBlockHeight - 140 + sizeToIncrease
                                } else {
                                    self.mentionTableViewTopContraint.constant = self.screenHeight - self.bottomBlockHeight - 64 + sizeToIncrease
                                }
                            }
                            IQKeyboardManager.shared.resignOnTouchOutside = false
                            
                        } else {
                            IQKeyboardManager.shared.resignOnTouchOutside = true
                            self.mentionTableViewHC.constant = 0
                        }
                        
                        
                    case .failure(let error):
                        self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: error.localizedDescription, greyTitle: "ok".localized)
                    }
                }
                
            } else {
                
                // When text not contain "@"
                IQKeyboardManager.shared.resignOnTouchOutside = true
                self.mentionTableViewHC.constant = 0
            }
        }
    }
    
    func requestApprovalComment(commentString: String, approvalStatus: ApprovalStatus) {
        
        // *** NOTE ***
        // 👉 no need to formatted POST_CONT into user info form, if no member has been mentioned
        // 👉 when one or more member has been mentioned in the POST_CONT, must format it into user info form => "@[Sokny Ran (Yakuza)](soknyran.dev@gmail.com)"
        var POST_CONT_Formatted = commentString
        if self.mentionedMembers.count != 0 {
            POST_CONT_Formatted = self.formatMentionFromReadableToAPISyntax(originalText: commentString, mentionedMembers: self.mentionedMembers)
        }
        
        var REC_IN : [WABOOKS_MREC_BLTB_0005_U001.REQUEST.REC_IN] = []
        
        for (commentIndex, commentObj) in self.commentView.commentViewVM.content.enumerated() {
            if commentObj.rowType == .FileType {
                for (_, c) in self.commentView.commentViewVM.content[commentIndex].file.enumerated() {
                    let fileName = c.fileName.removingPercentEncoding
                    let fileData = c.fileData.base64EncodedString()
                    let eachDoc  = WABOOKS_MREC_BLTB_0005_U001.REQUEST.REC_IN(FILE_NM: fileName, FILE_DATA: fileData)
                    REC_IN.append(eachDoc)
                }
            } else if commentObj.rowType == .ImageType {
                for (n, c) in self.commentView.commentViewVM.content[commentIndex].image.enumerated() {
                    if let base64 = convertToBase64(c.image) {
                        let formatter           = DateFormatter()
                        formatter.dateFormat    = "yyyMMddHHmm"
                        let fileName = "\(formatter.string(from: Date()))\(n).jpg"
                        let eachDoc  = WABOOKS_MREC_BLTB_0005_U001.REQUEST.REC_IN(FILE_NM: fileName, FILE_DATA: base64)
                        REC_IN.append(eachDoc)
                    }
                }
            }
        }
        
        self.expenseApprovalVM.requestApproveOrReject(APPR_SEQ_NO: self.boardRec?.APPR_SEQ_NO ?? "" , APPRVR_STTS: approvalStatus.rawValue, BLTB_CD: self.boardRec?.BLTB_CD ?? "", COMNT_CONT: POST_CONT_Formatted.trim.convertStringToHTML, REC_IN: REC_IN) { result in
            switch result {
            case .success(_):
                self.commentView.TopBarKeyboardView.resetCount()
                self.expenseApprovalVM.isApprover = false
                self.commentView.addedCommentCompletion()
                self.mentionedMembers = []
                self.commentView.mentionedMembers = []
                
                // update by Kheng
                if approvalStatus == .Approve  {
                    self.boardRec?.APPR_TYPE_CD = "01"
                } else {
                    self.boardRec?.APPR_TYPE_CD = "02"
                }
                
                // heremen; clean from comment box too
                self.getAllData()
                
            case .failure(let error):
                self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: error.localizedDescription, greyTitle: "ok".localized)
            }
        }
    }
    
    private func checkHighlightAddComment() {
        guard !expenseApprovalVM.content.isEmpty else { return }
        let lastIndex = expenseApprovalVM.content.count - 1
        let lastItem = expenseApprovalVM.content[lastIndex]
        let snapshotCount = expenseApprovalVM.content.count
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: lastIndex), at: .top, animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self,
                  self.expenseApprovalVM.content.count == snapshotCount,
                  lastIndex < self.expenseApprovalVM.content.count else { return }
            let count = self.expenseApprovalVM.content.count
            switch lastItem.rowType {

            case .COMMENT_TextView:
                guard let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex)) as? TextViewCell,
                      lastIndex >= 1,
                      let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex - 1)) as? UserCell else { return }
                textViewCell.isHighLight = true
                userCell.isHighLight = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak textViewCell, weak userCell] in
                    textViewCell?.isHighLight = false
                    userCell?.isHighLight = false
                }

            case .COMMENT_File:
                guard lastIndex >= 2,
                      let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex - 1)) as? TextViewCell,
                      let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex - 2)) as? UserCell else { return }
                self.isHightLight = true
                self.fileIndexPath = IndexPath(row: 0, section: lastIndex)
                guard lastIndex < count else { return }
                self.collectionView.reloadSections(IndexSet(integer: lastIndex))
                textViewCell.isHighLight = true
                userCell.isHighLight = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self, weak textViewCell, weak userCell] in
                    guard let self, lastIndex < self.expenseApprovalVM.content.count else { return }
                    textViewCell?.isHighLight = false
                    userCell?.isHighLight = false
                    self.isHightLight = false
                    self.fileIndexPath = IndexPath(row: 0, section: 0)
                    self.imageIndexPath = IndexPath(row: 0, section: 0)
                    self.collectionView.reloadSections(IndexSet(integer: lastIndex))
                }

            case .COMMENT_IMAGE:
                if lastIndex >= 1 && self.expenseApprovalVM.content[lastIndex - 1].rowType == .COMMENT_File {
                    guard lastIndex >= 3,
                          let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex - 2)) as? TextViewCell,
                          let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex - 3)) as? UserCell else { return }
                    let imageIndexSet = IndexSet(integer: lastIndex)
                    self.imageIndexPath = IndexPath(row: 0, section: lastIndex)
                    self.fileIndexPath = IndexPath(row: 0, section: lastIndex - 1)
                    textViewCell.isHighLight = true
                    userCell.isHighLight = true
                    self.isHightLight = true
                    guard lastIndex < count else { return }
                    self.collectionView.reloadSections(imageIndexSet)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self, weak textViewCell, weak userCell] in
                        guard let self, lastIndex < self.expenseApprovalVM.content.count else { return }
                        textViewCell?.isHighLight = false
                        userCell?.isHighLight = false
                        self.isHightLight = false
                        self.fileIndexPath = IndexPath(row: 0, section: 0)
                        self.imageIndexPath = IndexPath(row: 0, section: 0)
                        self.collectionView.reloadSections(imageIndexSet)
                    }
                } else {
                    guard lastIndex >= 2,
                          let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex - 1)) as? TextViewCell,
                          let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex - 2)) as? UserCell else { return }
                    let imageIndexSet = IndexSet(integer: lastIndex)
                    self.imageIndexPath = IndexPath(row: 0, section: lastIndex)
                    textViewCell.isHighLight = true
                    userCell.isHighLight = true
                    self.isHightLight = true
                    guard lastIndex < count else { return }
                    self.collectionView.reloadSections(imageIndexSet)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self, weak textViewCell, weak userCell] in
                        guard let self, lastIndex < self.expenseApprovalVM.content.count else { return }
                        textViewCell?.isHighLight = false
                        userCell?.isHighLight = false
                        self.isHightLight = false
                        self.fileIndexPath = IndexPath(row: 0, section: 0)
                        self.imageIndexPath = IndexPath(row: 0, section: 0)
                        self.collectionView.reloadSections(imageIndexSet)
                    }
                }
            default: return
            }
        }
    }
    
    private func checkHighlightUpdateComment() {
        guard let editIndex = self.expenseApprovalVM.content.firstIndex(where: { $0.Comment_REC?.COMNT_SEQ_NO == self.editing_COMNT_SEQ_NO }) else { return }
        let snapshotCount = expenseApprovalVM.content.count
        self.collectionView.scrollToItem(at: IndexPath(row: 0, section: editIndex), at: .top, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self,
                  self.expenseApprovalVM.content.count == snapshotCount,
                  editIndex < self.expenseApprovalVM.content.count else { return }
            let count = self.expenseApprovalVM.content.count

            if editIndex == count - 2 {
                guard let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex)) as? UserCell,
                      editIndex + 1 < count,
                      let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex + 1)) as? TextViewCell else { return }
                textViewCell.isHighLight = true
                userCell.isHighLight = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak textViewCell, weak userCell] in
                    textViewCell?.isHighLight = false
                    userCell?.isHighLight = false
                }

                if self.expenseApprovalVM.content.last?.rowType != .COMMENT_TextView {
                    if self.expenseApprovalVM.content.last?.rowType == .COMMENT_File {
                        guard editIndex + 2 < count else { return }
                        self.isHightLight = true
                        let fileIndexSet = IndexSet(integer: editIndex + 2)
                        self.fileIndexPath = IndexPath(row: 0, section: editIndex + 2)
                        self.collectionView.reloadSections(fileIndexSet)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                            guard let self, editIndex + 2 < self.expenseApprovalVM.content.count else { return }
                            self.isHightLight = false
                            self.fileIndexPath = IndexPath(row: 0, section: 0)
                            self.collectionView.reloadSections(fileIndexSet)
                        }
                    } else if self.expenseApprovalVM.content.last?.rowType == .COMMENT_IMAGE {
                        if count >= 2 && self.expenseApprovalVM.content[count - 2].rowType == .COMMENT_File {
                            guard editIndex + 3 < count else { return }
                            let imageIndexSet = IndexSet(integer: editIndex + 3)
                            self.fileIndexPath = IndexPath(row: 0, section: editIndex + 2)
                            self.imageIndexPath = IndexPath(row: 0, section: editIndex + 3)
                            self.isHightLight = true
                            self.collectionView.reloadSections(imageIndexSet)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                                guard let self, editIndex + 3 < self.expenseApprovalVM.content.count else { return }
                                self.isHightLight = false
                                self.fileIndexPath = IndexPath(row: 0, section: 0)
                                self.imageIndexPath = IndexPath(row: 0, section: 0)
                                self.collectionView.reloadSections(imageIndexSet)
                            }
                        } else {
                            guard editIndex + 2 < count else { return }
                            let imageIndexSet = IndexSet(integer: editIndex + 2)
                            self.imageIndexPath = IndexPath(row: 0, section: editIndex + 2)
                            self.isHightLight = true
                            self.collectionView.reloadSections(imageIndexSet)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                                guard let self, editIndex + 2 < self.expenseApprovalVM.content.count else { return }
                                self.isHightLight = false
                                self.imageIndexPath = IndexPath(row: 0, section: 0)
                                self.collectionView.reloadSections(imageIndexSet)
                            }
                        }
                    }
                }

            } else {
                guard editIndex + 2 < count else { return }
                let editItem = self.expenseApprovalVM.content[editIndex + 2]

                switch editItem.rowType {
                case .COMMENT_USER:
                    guard let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex)) as? UserCell,
                          editIndex + 1 < count,
                          let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex + 1)) as? TextViewCell else { return }
                    textViewCell.isHighLight = true
                    userCell.isHighLight = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak textViewCell, weak userCell] in
                        textViewCell?.isHighLight = false
                        userCell?.isHighLight = false
                    }

                case .COMMENT_File:
                    guard let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex)) as? UserCell,
                          editIndex + 1 < count,
                          let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex + 1)) as? TextViewCell else { return }
                    self.isHightLight = true
                    textViewCell.isHighLight = true
                    userCell.isHighLight = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak textViewCell, weak userCell] in
                        textViewCell?.isHighLight = false
                        userCell?.isHighLight = false
                    }
                    guard editIndex + 2 < count else { return }
                    let fileIndexSet = IndexSet(integer: editIndex + 2)
                    self.fileIndexPath = IndexPath(row: 0, section: editIndex + 2)
                    self.collectionView.reloadSections(fileIndexSet)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                        guard let self, editIndex + 2 < self.expenseApprovalVM.content.count else { return }
                        self.isHightLight = false
                        self.fileIndexPath = IndexPath(row: 0, section: 0)
                        self.collectionView.reloadSections(fileIndexSet)
                    }
                    if editIndex + 3 < count && self.expenseApprovalVM.content[editIndex + 3].rowType == .COMMENT_IMAGE {
                        let imageIndexSet = IndexSet(integer: editIndex + 3)
                        self.imageIndexPath = IndexPath(row: 0, section: editIndex + 3)
                        self.collectionView.reloadSections(imageIndexSet)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                            guard let self, editIndex + 3 < self.expenseApprovalVM.content.count else { return }
                            self.isHightLight = false
                            self.imageIndexPath = IndexPath(row: 0, section: 0)
                            self.collectionView.reloadSections(imageIndexSet)
                        }
                    }

                case .COMMENT_IMAGE:
                    guard let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex)) as? UserCell,
                          editIndex + 1 < count,
                          let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex + 1)) as? TextViewCell else { return }
                    textViewCell.isHighLight = true
                    userCell.isHighLight = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak textViewCell, weak userCell] in
                        textViewCell?.isHighLight = false
                        userCell?.isHighLight = false
                    }
                    self.isHightLight = true
                    guard editIndex + 2 < count else { return }
                    let imageIndexSet = IndexSet(integer: editIndex + 2)
                    self.imageIndexPath = IndexPath(row: 0, section: editIndex + 2)
                    self.collectionView.reloadSections(imageIndexSet)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                        guard let self, editIndex + 2 < self.expenseApprovalVM.content.count else { return }
                        self.isHightLight = false
                        self.imageIndexPath = IndexPath(row: 0, section: 0)
                        self.collectionView.reloadSections(imageIndexSet)
                    }

                default: return
                }
            }
        }
    }
    
    func getDocumentsDirectory() -> URL { // returns your application folder
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = makeLayout()
        setUpCell()
    }
    
    func getExistedMentionedMember(content: String) {
        let formatedComponent   = self.formatMentionFromAPISyntaxToReadable(originalText: content)
        let mentionedMemberFullInfo = formatedComponent.2
        for obj in mentionedMemberFullInfo {
            let split = obj.components(separatedBy: "](")
            
            if split.count == 2 {
                let name = split.first?.replace(of: "@[", with: "") ?? ""
                let user = MentionMemberUIModel(name: name, email: obj, photo: "", USER_IMG: "")
                
                var isAlreadyExisted = false
                for obj in mentionedMembers {
                    if obj.email == user.email {
                        isAlreadyExisted = true
                        break
                    }
                }
                if !isAlreadyExisted {
                    mentionedMembers.append(user)
                    mentionedMemberNames.append(name)
                }
            }
        }
    }
    
    private func confirmDelete(indexPath: IndexPath, isDeleteFile: Bool, isFromComment: Bool) {
        let leftTitle = "delete_attachment".localized
        let message = "This_action_can't_be_undone".localized
        self.yesNoPopup(title: leftTitle, message: message, confirmTitle: "delete".localized, cancelTitle: "Don't_delete".localized, isDeletePopup: true) { confirm in
            if confirm {
                var FILE_ID = ""
                var FILE_TYPE = ""
                
                if isDeleteFile { // delete file
                    if isFromComment {
                        FILE_ID = self.expenseApprovalVM.content[indexPath.section].FILE_COMMENT_REC[indexPath.row].FILE_ID ?? ""
                        FILE_TYPE = self.expenseApprovalVM.content[indexPath.section].FILE_COMMENT_REC[indexPath.row].FILE_TYPE ?? ""
                    } else {
                        FILE_ID = self.expenseApprovalVM.content[indexPath.section].FILE_REC?[indexPath.row].FILE_ID ?? ""
                        FILE_TYPE = self.expenseApprovalVM.content[indexPath.section].FILE_REC?[indexPath.row].FILE_TYPE ?? ""
                    }
                } else { // delete Image
                    FILE_ID = self.expenseApprovalVM.content[indexPath.section].IMAGE_REC?[indexPath.row].FILE_ID ?? ""
                    FILE_TYPE = self.expenseApprovalVM.content[indexPath.section].IMAGE_REC?[indexPath.row].FILE_TYPE ?? ""
                }
                
                if isFromComment {
                    if self.expenseApprovalVM.content[indexPath.section].FILE_COMMENT_REC.count == 1 && self.expenseApprovalVM.content[indexPath.section].IMAGE_COMMENT_REC.count == 0 && self.expenseApprovalVM.content[indexPath.section].Comment_REC?.COMNT_CONT == "" || self.expenseApprovalVM.content[indexPath.section].Comment_REC?.COMNT_CONT == nil {
                        let body = WABOOKS_MREC_BLTB_0002_D002.REQUEST(BLTB_CD: self.boardRec?.BLTB_CD ?? "", POST_SEQ_NO: self.boardRec?.POST_SEQ_NO ?? "", COMNT_SEQ_NO: self.expenseApprovalVM.content[indexPath.section].Comment_REC?.COMNT_SEQ_NO)
                        self.commentVM.requestDeleteComment(body: body) { result in
                            switch result {
                            case .success(_):
                                //                                self.expenseApprovalVM.showLoading = false
                                self.getAllData()
                            case .failure(let error):
                                self.customAlert(message: error.localizedDescription)
                            }
                        }
                    }
                    let COMNT_SEQ_NO = self.expenseApprovalVM.content[indexPath.section].Comment_REC?.COMNT_SEQ_NO
                    self.expenseApprovalVM.requestDeleteFileComment(body: WABOOKS_MREC_BLTB_0005_D002.REQUEST(POST_SEQ_NO: self.boardRec?.POST_SEQ_NO ?? "", BLTB_CD: self.boardRec?.BLTB_CD ?? "", COMNT_SEQ_NO: COMNT_SEQ_NO, FILE_ID: FILE_ID)) { erorr in
                        if erorr != nil {
                            // erorr
                            self.customAlert(message: erorr?.localizedDescription ?? "")
                            
                        } else {
                            // success
                            //                        self.titleBoardLabel.text   = Boards.BoardType.Home.rawValue
                            /// go home when delete success
                            //                        self.expenseApprovalVM.boardType     = .Approval
                            self.getAllData()
                            
                        }
                    }
                } else {
                    self.expenseApprovalVM.requestDeletePhoto(body: WABOOKS_MREC_BLTB_0005_D001.REQUEST(POST_SEQ_NO: self.boardRec?.POST_SEQ_NO ?? "", BLTB_CD: self.boardRec?.BLTB_CD ?? "", APPR_SEQ_NO: self.boardRec?.APPR_SEQ_NO, POST_TYPE_CD: self.expenseApprovalVM.POST_TYPE_CD, FILE_ID: FILE_ID, FILE_TYPE: FILE_TYPE, DRAFT_POST_SEQ_NO: "")) { erorr in
                        if erorr != nil {
                            // erorr
                            self.customAlert(message: erorr?.localizedDescription ?? "")
                            
                        } else {
                            // success
                            //                        self.titleBoardLabel.text   = Boards.BoardType.Home.rawValue
                            /// go home when delete success
                            //                        self.expenseApprovalVM.boardType     = .Approval
                            self.getAllData()
                            
                        }
                    }
                }
            } else {
                //                self.dismiss(animated: true)
                print("Don't delete")
            }
        }
    }
    
    func showDocumentSaveAndOpen(){
        let file = "\(UUID().uuidString).txt"
        let content = "asdf"
        let direct = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = direct.appendingPathComponent(file)
        
        do{
            try content.write(to: fileURL, atomically: false, encoding: .utf8)
            
            let documentInteractionController = UIDocumentInteractionController(url: fileURL)
            documentInteractionController.delegate = self
            documentInteractionController.presentPreview(animated: true)
            
        } catch {
            print("Error : \(error)")
        }
    }
    
    func dowloadImage(image: UIImage) {
        
        CustomPhotoAlbum.sharedInstance.save(image: image, completion: {status, error  in
            if status {
                self.customToast(image: "toast_success_ico", message: "photo_downloaded".localized)
                DispatchQueue.main.async {
                    self.customToast(image: "toast_success_ico", message: "photo_downloaded".localized)
                }
            }
            else {
                print("Error saving photo by: ", error.debugDescription)
            }
        })
    }
    
    //MARK: - OBJC
    @objc func reloadAfterPostToBoardSubmit(notification: Notification){
        let noti = notification.object as? [String: String]
        switch noti?["DOTPOST_TYPE"] {
            
        case "create" :
            
            self.getAllData()
            
        case "edit":
            self.getAllData()
            
        case "delete" :
            self.getAllData()
            
        default:
            break
        }
    }
    
    @objc func popup(_ sender : UIButton) {
        
        var moreBoardOption : [OptionPopupWithoutTitleModel] = []
        
        if isNotification { // check data from notification
            let approvalREG_ID = expenseApprovalVM.responseBoardDetail?.REG_ID
            let approvalPOST_TYPE_CD = expenseApprovalVM.responseBoardDetail?.POST_TYPE_CD
            let arapprovalDEL_YN = expenseApprovalVM.responseBoardDetail?.DEL_YN
            
            let articleREG_ID = expenseApprovalVM.responseArticle?.REG_ID
            let articlePOST_TYPE_CD = expenseApprovalVM.responseArticle?.POST_TYPE_CD
            let articleDEL_YN = expenseApprovalVM.responseArticle?.DEL_YN
            
            /// if  POST_TYPE_CD = 01 it is article
            /// if POST_TYPE_CD = 02 it is approval or exepense approval
            
            let tempREG_ID = self.expenseApprovalVM.POST_TYPE_CD == "01" ? articleREG_ID : approvalREG_ID
            let tempPOST_TYPE_CD = self.expenseApprovalVM.POST_TYPE_CD == "01" ? articlePOST_TYPE_CD : approvalPOST_TYPE_CD
            let tempDEL_YN = self.expenseApprovalVM.POST_TYPE_CD == "01" ? articleDEL_YN : arapprovalDEL_YN
            
            // expense approval
            if (Shared.R002_DATA?.USER_ID == tempREG_ID && tempPOST_TYPE_CD == "01") { // check edit article
                moreBoardOption.append(OptionPopupWithoutTitleModel(icon: "ico_pen", title: "Edit_post".localized))
            } else if (Shared.R002_DATA?.USER_ID == tempREG_ID && tempPOST_TYPE_CD == "02" && (expenseApprovalVM.responseBoardDetail?.APPR_TYPE_CD == "00")) {
                // check edit approval
                moreBoardOption.append(OptionPopupWithoutTitleModel(icon: "ico_pen", title: "Edit_post".localized))
            }
            if tempDEL_YN == "Y" {
                moreBoardOption.append(OptionPopupWithoutTitleModel(icon: "ico_bin", title: "Delete_post".localized, isRedOption: true))
            }
            
        } else {    //end
            if (Shared.R002_DATA?.USER_ID == boardRec?.REG_ID && expenseApprovalVM.POST_TYPE_CD == "01") { // check edit article
                moreBoardOption.append(OptionPopupWithoutTitleModel(icon: "ico_pen", title: "Edit_post".localized))
            } else if Shared.R002_DATA?.USER_ID == boardRec?.REG_ID && expenseApprovalVM.POST_TYPE_CD == "02" && (boardRec?.APPR_TYPE_CD == "00" || boardRec?.DRAFT_POST_SEQ_NO != nil) { // check edit approval
                moreBoardOption.append(OptionPopupWithoutTitleModel(icon: "ico_pen", title: "Edit_post".localized))
            }
            if boardRec?.DEL_YN == "Y" {
                moreBoardOption.append(OptionPopupWithoutTitleModel(icon: "ico_bin", title: "Delete_post".localized, isRedOption: true))
            }
        }
        
        
        optionPopupWithoutTitle(optionData: moreBoardOption) { [self] option, _ in
            
            switch option {
                
            case "Edit_post".localized :
                self.dismiss(animated: true)
                let vc = VC(sbName: "EditArticleWeCMSSB", identifier: "EditArticleWeCMSVC") as! EditArticleWeCMSVC
                //                vc.response = self.boardsVM.response
                if isNotification {
                    vc.responseArticle      = self.expenseApprovalVM.responseArticle
                    vc.responseBoardDetail  = self.expenseApprovalVM.responseBoardDetail
                    vc.POST_TYPE_CD         = self.expenseApprovalVM.POST_TYPE_CD ?? ""  // "01"-> Article, "02" -> Approval
                    vc.POST_APPR_DV         = self.expenseApprovalVM.POST_APPR_DV ?? "" // "10"-> Exspense approval, "00" -> Simple Approval
                    vc.isNotification       = true
                }else {
                    vc.boardREC = boardRec
                }
                
                self.presetVC(vc: vc, modalPresentStyle: .overFullScreen)
                
            case "Delete_post".localized:
                self.dismiss(animated: true)
                
                let leftTitle = "Delete_post".localized
                let message = "This_action_can’t_be_undone".localized
                self.yesNoPopup(title: leftTitle, message: message, confirmTitle: "delete".localized, cancelTitle: "Don't_delete".localized, isDeletePopup: true) { confirm in
                    if confirm {
                        self.dismiss(animated: true)
                        
                        var POST_SEQ_NO = ""
                        var BLTB_CD     = ""
                        
                        if self.isNotification {
                            POST_SEQ_NO = self.boardRec?.POST_SEQ_NO ?? ""
                            BLTB_CD     = self.boardRec?.BLTB_CD ?? ""
                        }else{
                            POST_SEQ_NO = self.boardRec?.POST_SEQ_NO ?? ""
                            BLTB_CD     = self.boardRec?.BLTB_CD ?? ""
                        }
                        
                        self.boardsVM.requestDeletePost(body: WABOOKS_MREC_BLTB_0002_D001.REQUEST(POST_SEQ_NO: POST_SEQ_NO , BLTB_CD: BLTB_CD )){ erorr in
                            if erorr != nil {
                                // erorr
                                self.customAlert(message: erorr?.localizedDescription ?? "")
                            } else {
                                // success stay current
                                self.popOrDismissVC(animated: true,completion: {
                                    MyNotify.send(name: .GotoBoard, object: ["DOTPOST_TYPE": "delete"] as AnyObject)
                                })
                                
                            }
                        }
                    } else {
                        self.dismiss(animated: true)
                        print("Don't delete")
                    }
                }
                
            default:
                break
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            print(keyboardHeight)
            bottomBlockHeight = keyboardHeight + 130 + 86 //heremen // 130 : height of view top of keybaord, 86 : height of accept/reject view //
        }
    }
    
    @objc private func actionCommentFileButtonPressed(sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: self.collectionView)
        guard let indexPath = self.collectionView.indexPathForItem(at: point),
              indexPath.section < expenseApprovalVM.content.count else { return }
        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
        let data = expenseApprovalVM.content[indexPath.section]
        
        var treeObjButtons : [OptionPopupWithoutTitleModel] = []
        
        let tempData1 = OptionPopupWithoutTitleModel(icon: "ico_downarrow",    title: "save_to_files".localized)
        treeObjButtons.append(tempData1)
        
        if Shared.R002_DATA?.USER_ID == data.Comment_REC?.REG_ID {
            let tempData2 = OptionPopupWithoutTitleModel(icon: "ico_bin",       title: "delete".localized)
            treeObjButtons.append(tempData2)
        }
        
        optionPopupWithoutTitle(optionData: treeObjButtons) { option,_ in
            switch option {
            case "save_to_files".localized :
                
                var file_url = ""
                if data.rowType == .FILE {
                    let file_name   = data.FILE_REC?[indexPath.row].ORG_FILE_NM ?? ""
                    let split_url   = data.FILE_REC?[indexPath.row].FILE_URL?.components(separatedBy: "?")
                    file_url    = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")" + "&\(file_name)"
                } else {
                    let file_name   = data.FILE_COMMENT_REC[indexPath.row].ORG_FILE_NM ?? ""
                    let split_url   = data.FILE_COMMENT_REC[indexPath.row].FILE_URL?.components(separatedBy: "?")
                    file_url    = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")" + "&\(file_name)"
                }
                print(file_url)
                
                DataAccess.shared.downloadTask(withURL: file_url, shouldShowLoading: true) { (data, error) in
                    if error == nil {
                        let fileREC = self.expenseApprovalVM.content[indexPath.section].rowType == .FILE ? self.expenseApprovalVM.content[indexPath.section].FILE_REC : self.expenseApprovalVM.content[indexPath.section].FILE_COMMENT_REC
                        let path = self.getDocumentsDirectory()
                        let fileUrl = path.appendingPathComponent(fileREC?[indexPath.row].ORG_FILE_NM ?? "")
                        do {
                            try data?.write(to: fileUrl)
                            print(fileUrl)
                            DispatchQueue.main.async {
                                let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
                                if let popoverPresentationController = activityViewController.popoverPresentationController {
                                    popoverPresentationController.sourceView = self.view
                                    popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                                    popoverPresentationController.permittedArrowDirections = []
                                }
                                self.present(activityViewController, animated: true, completion: nil)
                            }
                        } catch {
                            print(error)
                        }
                        
                        
                    }else {
                        self.customAlert(message: error?.localizedDescription ?? "")
                    }
                }
                
                
            case "delete".localized :
                self.dismiss(animated: true, completion: nil)
                self.confirmDelete(indexPath: indexPath, isDeleteFile: true, isFromComment: true)
            default :
                break
            }
        }
    }
    
    @objc private func actionFileButtonPressed(sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: self.collectionView)
        guard let indexPath = self.collectionView.indexPathForItem(at: point),
              indexPath.section < expenseApprovalVM.content.count else { return }
        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
        let data = expenseApprovalVM.content[indexPath.section]
        
        var treeObjButtons : [OptionPopupWithoutTitleModel] = []
        
        let tempData1 = OptionPopupWithoutTitleModel(icon: "ico_downarrow",    title: "save_to_files".localized)
        treeObjButtons.append(tempData1)
        if self.expenseApprovalVM.POST_TYPE_CD == "01" { //article
            if Shared.R002_DATA?.USER_ID == expenseApprovalVM.responseArticle?.REG_ID {
                let tempData2 = OptionPopupWithoutTitleModel(icon: "ico_bin",       title: "delete".localized)
                treeObjButtons.append(tempData2)
            }
        } else if self.expenseApprovalVM.POST_TYPE_CD == "02" { //approval
            if Shared.R002_DATA?.USER_ID == expenseApprovalVM.responseBoardDetail?.REG_ID && expenseApprovalVM.responseBoardDetail?.APPR_TYPE_CD == "00" {
                let tempData2 = OptionPopupWithoutTitleModel(icon: "ico_bin",       title: "delete".localized)
                treeObjButtons.append(tempData2)
            }
        }
        
        optionPopupWithoutTitle(optionData: treeObjButtons) { option,_ in
            switch option {
            case "save_to_files".localized :
                
                var file_url = ""
                if data.rowType == .FILE {
                    let file_name   = data.FILE_REC?[indexPath.row].ORG_FILE_NM ?? ""
                    let split_url   = data.FILE_REC?[indexPath.row].FILE_URL?.components(separatedBy: "?")
                    file_url    = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")" + "&\(file_name)"
                } else {
                    let file_name   = data.FILE_COMMENT_REC[indexPath.row].ORG_FILE_NM ?? ""
                    let split_url   = data.FILE_COMMENT_REC[indexPath.row].FILE_URL?.components(separatedBy: "?")
                    file_url    = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")" + "&\(file_name)"
                }
                
                DataAccess.shared.downloadTask(withURL: file_url, shouldShowLoading: true) { (data, error) in
                    if error == nil {
                        let fileREC = self.expenseApprovalVM.content[indexPath.section].rowType == .FILE ? self.expenseApprovalVM.content[indexPath.section].FILE_REC : self.expenseApprovalVM.content[indexPath.section].FILE_COMMENT_REC
                        let path = self.getDocumentsDirectory()
                        let fileUrl = path.appendingPathComponent(fileREC?[indexPath.row].ORG_FILE_NM ?? "")
                        do {
                            try data?.write(to: fileUrl)
                            DispatchQueue.main.async {
                                let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
                                if let popoverPresentationController = activityViewController.popoverPresentationController {
                                    popoverPresentationController.sourceView = self.view
                                    popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                                    popoverPresentationController.permittedArrowDirections = []
                                }
                                self.present(activityViewController, animated: true, completion: nil)
                            }
                        } catch {
                            print(error)
                        }
                        
                        
                    }else {
                        self.customAlert(message: error?.localizedDescription ?? "")
                    }
                }
                
                
            case "delete".localized :
                self.dismiss(animated: true, completion: nil)
                self.confirmDelete(indexPath: indexPath, isDeleteFile: true, isFromComment: false)
            default :
                break
            }
        }
    }
    
    @objc func actionImageButtonPressed(sender: UIView) {
        let point = sender.convert(CGPoint.zero, to: self.collectionView)
        guard let indexPath = self.collectionView.indexPathForItem(at: point),
              indexPath.section < expenseApprovalVM.content.count else { return }
        
        var treeObjButtons : [OptionPopupWithoutTitleModel] = []
        
        let tempData1 = OptionPopupWithoutTitleModel(icon: "ico_downarrow",    title: "save_to_gallery".localized)
        treeObjButtons.append(tempData1)
        if self.expenseApprovalVM.POST_TYPE_CD == "01" { //article
            if Shared.R002_DATA?.USER_ID == expenseApprovalVM.responseArticle?.REG_ID {
                let tempData2 = OptionPopupWithoutTitleModel(icon: "ico_bin",       title: "delete".localized)
                treeObjButtons.append(tempData2)
            }
        } else if self.expenseApprovalVM.POST_TYPE_CD == "02" { //approval
            if Shared.R002_DATA?.USER_ID == expenseApprovalVM.responseBoardDetail?.REG_ID && expenseApprovalVM.responseBoardDetail?.APPR_TYPE_CD == "00" {
                let tempData2 = OptionPopupWithoutTitleModel(icon: "ico_bin",       title: "delete".localized)
                treeObjButtons.append(tempData2)
            }
        }
        optionPopupWithoutTitle(optionData: treeObjButtons) { option, _ in
            switch option {
            case "save_to_gallery".localized:
                let cell = self.collectionView.cellForItem(at: indexPath) as! ExpenseImageWeCMSCell
                let image = cell.img.image
                if let img = image {
                    self.dowloadImage(image: img)
                }
                
            case "delete".localized :
                self.dismiss(animated: true, completion: nil)
                self.confirmDelete(indexPath: indexPath, isDeleteFile: false, isFromComment: false)
            default :
                break
            }
        }
    }
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ExpenseApprovalWeCMSVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return expenseApprovalVM.content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < expenseApprovalVM.content.count else { return 0 }
        let data = expenseApprovalVM.content[section]
        switch data.rowType {
        case .EXPENSE_LIST:
            return data.EXPENSE_REC?.count ?? 0
        case .FILE:
            return data.FILE_REC?.count ?? 0
        case .IMAGE:
            return data.IMAGE_REC?.count ?? 0
        case .COMMENT_IMAGE:
            return data.IMAGE_COMMENT_REC.count
        case .COMMENT_File:
            return data.FILE_COMMENT_REC.count
        default: return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.section < expenseApprovalVM.content.count else { return UICollectionViewCell() }
        let data = expenseApprovalVM.content[indexPath.section]
        
        switch data.rowType {
            
        case .STATUS:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpenseStatusWeCMSCell", for: indexPath) as! ExpenseStatusWeCMSCell
            if self.expenseApprovalVM.POST_TYPE_CD == "01" {
                if let data = data.ARTICLE_REC {
                    cell.WABOOKS_MREC_BLTB_0005_R001(data: data, POST_APPR_DV: self.expenseApprovalVM.POST_APPR_DV)
                }
            } else {
                if let data = data.REC {
                    cell.WABOOKS_MREC_BLTB_0005_R002(data: data, POST_APPR_DV: self.expenseApprovalVM.POST_APPR_DV)
                }
            }
            return cell
        case .AMOUNT:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaidAmountCell", for: indexPath) as! PaidAmountCell
            if let data = data.REC {
                cell.config(data: data)
            }
            return cell
        case .DESC:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DescriptionExpenseCell", for: indexPath) as! DescriptionExpenseCell
            
            
            if self.expenseApprovalVM.POST_TYPE_CD == "01" {
                if let data = data.ARTICLE_REC {
                    cell.POST_CONT = data.POST_CONT
                    cell.config01(data: data)
                }
            } else {
                if let data = data.REC {
                    cell.POST_CONT = data.POST_CONT
                    cell.config02(data: data)
                }
            }
            return cell
        case .FILE:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileTypeCell", for: indexPath) as! FileTypeCell
            if let data = data.FILE_REC?[indexPath.row] {
                cell.WABOOKS_MREC_BLTB_0005_R002_0005_R001_0002_R003(data: data)
            }
            cell.dotMoreAction.addTarget(self, action: #selector(actionFileButtonPressed), for: .touchUpInside)
            return cell
        case .IMAGE:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpenseImageWeCMSCell", for: indexPath) as! ExpenseImageWeCMSCell
            
            if let data = data.IMAGE_REC?[indexPath.row] {
                cell.config(data: data)
            }
            cell.dotActionSave.addTarget(self, action: #selector(actionImageButtonPressed), for: .touchUpInside)
            return cell
        case .EXPENSE_TITLE:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TitleExpenseCell", for: indexPath) as! TitleExpenseCell
            return cell
        case .EXPENSE_LIST:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpenseListCell", for: indexPath) as! ExpenseListCell
            if let data = data.EXPENSE_REC?[indexPath.row] {
                cell.config(data: data)
            }
            return cell
        case .APPROVER:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpenseApproverCell", for: indexPath) as! ExpenseApproverCell
            if let data = data.APPROVER_REC {
                cell.config(data: data)
            }
            return cell
        case .COMMENT_HEADER:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpenseCommentHeaderCell", for: indexPath) as! ExpenseCommentHeaderCell
            if self.expenseApprovalVM.POST_TYPE_CD == "01" {
                if let data = data.ARTICLE_REC {
                    cell.config(data: data)
                }
            } else {
                if let data = data.REC {
                    cell.config(data: data)
                }
            }
            return cell
        case .COMMENT_IMAGE:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageTypeCell", for: indexPath) as! ImageTypeCell
            cell.deleteUIView.isHidden = true
            cell.WABOOKS_MREC_BLTB_0002_R003(data: data.IMAGE_COMMENT_REC[indexPath.row])
            return cell
        case .COMMENT_USER:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCell
            if let data = data.Comment_REC {
                cell.WABOOKS_MREC_BLTB_0002_R003(data: data)
            }
            
            cell.optionButton.didTap {
                let option1 = OptionPopupWithoutTitleModel(icon: "ico_pen", title: "Edit_Comment".localized, isRedOption: false)
                let option2 = OptionPopupWithoutTitleModel(icon: "ico_bin", title: "Delete_Comment".localized, isRedOption: true)
                let options = [option1, option2]
                self.optionPopupWithoutTitle(optionData: options) { status, _ in
                    switch status {
                    case "Delete_Comment".localized :
                        let title = "Delete_Comment".localized
                        let description = "This_action_can’t_be_undone".localized
                        self.yesNoPopup(title: title, message: description, confirmTitle: "delete".localized, cancelTitle: "Don't_delete".localized, isDeletePopup: true) { isDelete in
                            if isDelete {
                                let body = WABOOKS_MREC_BLTB_0002_D002.REQUEST(BLTB_CD: self.boardRec?.BLTB_CD ?? "", POST_SEQ_NO: self.boardRec?.POST_SEQ_NO ?? "", COMNT_SEQ_NO: data.Comment_REC?.COMNT_SEQ_NO)
                                self.commentVM.requestDeleteComment(body: body) { result in
                                    switch result {
                                    case .success(_):
                                        self.getAllData()
                                        
                                    case .failure(let error):
                                        self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: error.localizedDescription, greyTitle: "ok".localized)
                                    }
                                }
                            }
                        }
                        
                    case "Edit_Comment".localized:
                        self.mentionedMembers = []
                        self.mentionedMemberNames = []
                        self.editing_COMNT_SEQ_NO = data.Comment_REC?.COMNT_SEQ_NO ?? ""
                        self.isEditComment = true
                        self.indexPathEditComment = indexPath
                        
                        let COMNT_CONT = data.Comment_REC?.COMNT_CONT?.replace(of: "<br>", with: "\n")
                        var commentREC = [CommentViewModel(text: COMNT_CONT, rowType: .TextView)]
                        var FILE_COMMENT_REC : [any WABOOKS_MREC_BLTB_0005_R002_0005_R001_0002_R003] = []
                        var IMAGE_COMMENT_REC : [any WABOOKS_MREC_BLTB_0005_R002_0005_R001_0002_R003] = []
                        if indexPath.section + 2 < self.expenseApprovalVM.content.count {
                            if self.expenseApprovalVM.content[indexPath.section + 2].rowType == .COMMENT_File {
                                FILE_COMMENT_REC = self.expenseApprovalVM.content[indexPath.section + 2].FILE_COMMENT_REC
                                if indexPath.section + 3 < self.expenseApprovalVM.content.count {
                                    if self.expenseApprovalVM.content[indexPath.section + 3].rowType == .COMMENT_IMAGE {
                                        IMAGE_COMMENT_REC = self.expenseApprovalVM.content[indexPath.section + 3].IMAGE_COMMENT_REC
                                    }
                                }
                            } else if self.expenseApprovalVM.content[indexPath.section + 2].rowType == .COMMENT_IMAGE {
                                IMAGE_COMMENT_REC = self.expenseApprovalVM.content[indexPath.section + 2].IMAGE_COMMENT_REC
                            }
                            if FILE_COMMENT_REC.count > 0 {
                                var fileREC : [FileModel] = []
                                for file in FILE_COMMENT_REC {
                                    fileREC.append(FileModel(fileName: file.ORG_FILE_NM ?? "", filePath: "", fileData: Data(), fileSize: file.FILE_SIZE ?? "0", fileURL: file.FILE_URL, isFromLocal: false))
                                }
                                commentREC.append(CommentViewModel(file: fileREC, rowType: .FileType))
                            }
                            
                            if IMAGE_COMMENT_REC.count > 0 {
                                var imgREC : [CommentViewModel.ImageModel] = []
                                let imageSection = FILE_COMMENT_REC.count > 0 ? (indexPath.section + 3) : (indexPath.section + 2)
                                for i in 0..<IMAGE_COMMENT_REC.count {
                                    guard let cell = collectionView.cellForItem(at: IndexPath(row: i, section: imageSection)) as? ImageTypeCell,
                                          let image = cell.img.image else { continue }
                                    imgREC.append(CommentViewModel.ImageModel(image: image, isFromLocal: false))
                                }
                                commentREC.append(CommentViewModel(image: imgREC, rowType: .ImageType))
                            }
                            
                        }
                        
                        self.commentView.commentViewVM.content = commentREC
                        self.getExistedMentionedMember(content: commentREC.description)
                        self.commentView.mentionedMembers = self.mentionedMemberNames
                        self.commentView.collectionView.reloadData()
                        self.commentView.placeholderLabel.isHidden = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.commentView.textView.becomeFirstResponder()
                        }
                    default:
                        break
                    }
                }
            }
            return cell
        case .COMMENT_TextView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
            cell.textView.isEditable = false
            if let data = data.Comment_REC {
                cell.WABOOKS_MREC_BLTB_0002_R003()
            }
            return cell
        case .COMMENT_File:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileTypeCell", for: indexPath) as! FileTypeCell
            cell.WABOOKS_MREC_BLTB_0005_R002_0005_R001_0002_R003(data: data.FILE_COMMENT_REC[indexPath.row])
            cell.dotMoreAction.addTarget(self, action: #selector(actionCommentFileButtonPressed), for: .touchUpInside)
            return cell
        case .UNDER_LINE:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpenseUnderLineCell", for: indexPath)
            return cell
        case .SPLIT_LINE:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpenseSplitLineCell", for: indexPath)
            return cell
        case .NoComment:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCmtCollectionViewCell", for: indexPath) as! EmptyCmtCollectionViewCell
            return cell
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section < expenseApprovalVM.content.count else { return }
        let data = expenseApprovalVM.content[indexPath.section]
        switch data.rowType {
        case .IMAGE, .COMMENT_IMAGE:
            
            let vc = VC(sbName: "PhotoPreviewSB", identifier: "PhotoPreviewsVC") as! PhotoPreviewsVC
            vc.isBtnDeleteDisable = true
            vc.currentIndexImage  = indexPath.row
            var imgRec : [Any]   = []
            let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
            
            if data.rowType == .IMAGE {
                for imgUrl in data.IMAGE_REC ?? [] {
                    let split_url       = imgUrl.FILE_URL?.components(separatedBy: "?")
                    File_ID             = imgUrl.FILE_ID ?? ""
                    let img_url         = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")"
                    imgRec.append(img_url) //file url
                }
            } else {
                for imgUrl in data.IMAGE_COMMENT_REC {
                    let split_url       = imgUrl.FILE_URL?.components(separatedBy: "?")
                    let img_url         = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")"
                    imgRec.append(img_url) //file url
                }
            }
            vc.imageUrlArray     = [["RCPT_IMG_URL" : imgRec]] as Array<AnyObject>
            if data.rowType == .IMAGE {
                let img = collectionView.cellForItem(at: indexPath) as! ExpenseImageWeCMSCell
                vc.cc_setZoomTransition(originalView: img.img) // Zoom trasition for receipt image
            } else {
                let img = collectionView.cellForItem(at: indexPath) as! ImageTypeCell
                vc.cc_setZoomTransition(originalView: img.img) // Zoom trasition for receipt image
            }
            self.present(vc, animated: true)
        case .FILE, .COMMENT_File:
            
            let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
            var file_url = ""
            if data.rowType == .FILE {
                let file_name   = data.FILE_REC?[indexPath.row].ORG_FILE_NM ?? ""
                let split_url   = data.FILE_REC?[indexPath.row].FILE_URL?.components(separatedBy: "?")
                file_url    = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")" + "&\(file_name)"
            } else {
                let file_name   = data.FILE_COMMENT_REC[indexPath.row].ORG_FILE_NM ?? ""
                let split_url   = data.FILE_COMMENT_REC[indexPath.row].FILE_URL?.components(separatedBy: "?")
                file_url    = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")" + "&\(file_name)"
            }
            
            
            DataAccess.shared.downloadTask(withURL: file_url, shouldShowLoading: true) { (data, error) in
                if error == nil {
                    let fileREC = self.expenseApprovalVM.content[indexPath.section].rowType == .FILE ? self.expenseApprovalVM.content[indexPath.section].FILE_REC : self.expenseApprovalVM.content[indexPath.section].FILE_COMMENT_REC
                    let path = self.getDocumentsDirectory()
                    let fileUrl = path.appendingPathComponent(fileREC?[indexPath.row].ORG_FILE_NM ?? "")
                    do {
                        try data?.write(to: fileUrl)
                        
                        DispatchQueue.main.async {
                            
                            let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
                            //                            self.present(activityViewController, animated: true, completion: nil)
                            if let popoverPresentationController = activityViewController.popoverPresentationController {
                                popoverPresentationController.sourceView = self.view
                                popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                                popoverPresentationController.permittedArrowDirections = []
                            }
                            
                            self.present(activityViewController, animated: true, completion: nil)
                        }
                    } catch {
                        print(error)
                    }
                    
                    
                }else {
                    self.customAlert(message: error?.localizedDescription ?? "")
                }
            }
        case .EXPENSE_LIST:
            let docType = data.EXPENSE_REC?[indexPath.row].DOC_TYPE
            if docType == "E" {
                let vc = UIStoryboard(name: "ReceiptDetailsSB", bundle: nil).instantiateViewController(withIdentifier: "ReceiptDetailsVC") as! ReceiptDetailsVC
                
                vc.doc_id = expenseApprovalVM.content[indexPath.section].EXPENSE_REC?[indexPath.row].DOC_ID ?? ""
                vc.isRequestApproval = true
                // need to request with key for request DocId
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated:true, completion:nil)
                
            } else if docType == "" || docType == nil{
                self.popAddOtherManual(dataR002: data.EXPENSE_REC?[indexPath.row], isEditManual: "EXPENSE_APPROVAL_VC")
            }
            
        case .APPROVER:
            let vc = UIStoryboard(name: "ViewApproverSB", bundle: nil).instantiateViewController(withIdentifier: "ViewApproverVC") as! ViewApproverVC
            vc.APPROVER_REC = data.APPROVER_REC
            vc.requestorName = self.expenseApprovalVM.responseBoardDetail?.REG_NM ?? ""
            vc.requetorProfile = self.expenseApprovalVM.responseBoardDetail?.REG_IMG_URL ?? ""
            var approverSize = 0
            if let REC = data.APPROVER_REC {
                for (_, c) in REC.enumerated() {
                    if c.APPR_DTM != nil {
                        approverSize += 65 + 30
                    } else {
                        approverSize += 42 + 30
                    }
                }
            }
            let size = CGFloat(approverSize + 25 + 40 + 82) + bottomSafeAreaInset
            vc.modalPresentationStyle = .pageSheet
            if let sheet = vc.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom { _ in size }, .large()]
                } else {
                    sheet.detents = [.medium(), .large()]
                }
                sheet.prefersGrabberVisible = true
            }
            self.present(vc, animated: true)
        default:
            print("f")
        }
    }
    
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ExpenseApprovalWeCMSVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionMemberVM.filteredList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = mentionMemberVM.filteredList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MentionMemberCell", for: indexPath) as! MentionMemberCell
        cell.configCell(data: data, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
            }
            
            commentView.addNewMentionedMember(newMember: name)
            
            mentionTableViewHC.constant = 0
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.customAlert(type: .CONFIRM_ALERT, image: "", title: "notice".localized, message: "incorrect_email_address_format".localized, redTitle: "close".localized, greyTitle: "close".localized)
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension ExpenseApprovalWeCMSVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CommentFooterCell", for: indexPath) as! CommentFooterCell
            // Customize your footer view here if needed
            return footerView
        default:
            assertionFailure("Unexpected supplementary element kind: \(kind)")
            return UICollectionReusableView()
        }
    }
}

//MARK: - CommentViewDelegate, CommentViewDataSource
extension ExpenseApprovalWeCMSVC: CommentViewDelegate, CommentViewDataSource {
    func approve(commentString: String) {
        self.requestApprovalComment(commentString: commentString, approvalStatus: .Approve)
    }
    
    func reject(commentString: String) {
        self.requestApprovalComment(commentString: commentString, approvalStatus: .Reject)
    }
    
    func removeItemAtIndexPath(indexPath: IndexPath, rowType: CommentViewModel.RowType, isFromLocal: Bool) {
        switch rowType {
        case .TextView:
            break
        case .FileType:
            if !isFromLocal {
                var temp = expenseApprovalVM.content
                let FILE_ID = temp[indexPathEditComment.section + 1 + indexPath.section].FILE_COMMENT_REC.remove(at: indexPath.row).FILE_ID
                commentVM.REC2.append(WABOOKS_MREC_BLTB_0002_U001.REQUEST.REC2(FILE_ID: FILE_ID))
            }
        case .ImageType:
            if !isFromLocal {
                var temp = expenseApprovalVM.content
                var section = 0
                switch expenseApprovalVM.content[indexPathEditComment.section + 1 + 1].rowType {
                case .COMMENT_File:
                    if expenseApprovalVM.content[indexPathEditComment.section + 1 + 1].FILE_COMMENT_REC.count > 0 {
                        section = commentView.commentViewVM.fileCount() > 0 ? indexPathEditComment.section : indexPathEditComment.section + 1
                    } else {
                        section = indexPathEditComment.section - 1
                    }
                case .COMMENT_IMAGE:
                    section = indexPathEditComment.section
                default: return
                }
                let FILE_ID = temp[section + 1 + indexPath.section].IMAGE_COMMENT_REC.remove(at: indexPath.row).FILE_ID
                commentVM.REC2.append(WABOOKS_MREC_BLTB_0002_U001.REQUEST.REC2(FILE_ID: FILE_ID))
            }
        }
    }
}

//MARK: - Set up CollectionView
extension ExpenseApprovalWeCMSVC {
    private func setUpCell() {
        collectionView.register(UINib(nibName: "ExpenseStatusWeCMSCell", bundle: nil), forCellWithReuseIdentifier: "ExpenseStatusWeCMSCell")
        collectionView.register(UINib(nibName: "PaidAmountCell", bundle: nil), forCellWithReuseIdentifier: "PaidAmountCell")
        collectionView.register(UINib(nibName: "DescriptionExpenseCell", bundle: nil), forCellWithReuseIdentifier: "DescriptionExpenseCell")
        collectionView.register(UINib(nibName: "ExpenseImageWeCMSCell", bundle: nil), forCellWithReuseIdentifier: "ExpenseImageWeCMSCell")
        collectionView.register(UINib(nibName: "TitleExpenseCell", bundle: nil), forCellWithReuseIdentifier: "TitleExpenseCell")
        collectionView.register(UINib(nibName: "ExpenseListCell", bundle: nil), forCellWithReuseIdentifier: "ExpenseListCell")
        collectionView.register(UINib(nibName: "ExpenseApproverCell", bundle: nil), forCellWithReuseIdentifier: "ExpenseApproverCell")
        collectionView.register(UINib(nibName: "ExpenseUnderLineCell", bundle: nil), forCellWithReuseIdentifier: "ExpenseUnderLineCell")
        collectionView.register(UINib(nibName: "ExpenseSplitLineCell", bundle: nil), forCellWithReuseIdentifier: "ExpenseSplitLineCell")
        collectionView.register(UINib(nibName: "ExpenseCommentHeaderCell", bundle: nil), forCellWithReuseIdentifier: "ExpenseCommentHeaderCell")
        collectionView.register(UINib(nibName: "UserCell", bundle: nil), forCellWithReuseIdentifier: "UserCell")
        collectionView.register(UINib(nibName: "ImageTypeCell", bundle: nil), forCellWithReuseIdentifier: "ImageTypeCell")
        collectionView.register(UINib(nibName: "FileTypeCell", bundle: nil), forCellWithReuseIdentifier: "FileTypeCell")
        collectionView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellWithReuseIdentifier: "TextViewCell")
        collectionView.register(UINib(nibName: "EmptyCmtCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EmptyCmtCollectionViewCell")
        collectionView.register(CommentFooterCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "CommentFooterCell")
    }
    
    private func makeLayout() -> UICollectionViewLayout! {
        if #available(iOS 13.0, *) {
            let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                guard let self, section < self.expenseApprovalVM.content.count else {
                    return ExpenseApprovalLayout.expenseSplitLineLayout()
                }
                let data = self.expenseApprovalVM.content[section]
                let rowType = data.rowType
                let indexPath = IndexPath(row: 0, section: section)

                switch rowType {

                case .STATUS:
                    return ExpenseApprovalLayout.statusLayout()
                case .AMOUNT:
                    return ExpenseApprovalLayout.amountLayout()
                case .DESC:
                    return ExpenseApprovalLayout.descLayout()
                case .FILE:
                    return ExpenseApprovalLayout.expenseFileLayout(itemCount: data.FILE_REC?.count ?? 0)
                case .IMAGE:
                    return ExpenseApprovalLayout.expenseImageLayout(itemCount: data.IMAGE_REC?.count ?? 0)
                case .EXPENSE_TITLE:
                    return ExpenseApprovalLayout.titleExpenseLayout()
                case .EXPENSE_LIST:
                    let itemCount = data.EXPENSE_REC?.count ?? 0
                    guard itemCount > 0 else {
                        return ExpenseApprovalLayout.expenseSplitLineLayout()
                    }
                    return ExpenseApprovalLayout.expenseListLayout(itemCount: itemCount)
                case .APPROVER:
                    return ExpenseApprovalLayout.expenseApproverLayout()
                case .UNDER_LINE:
                    return ExpenseApprovalLayout.expenseUnderLineLayout()
                case .SPLIT_LINE:
                    return ExpenseApprovalLayout.expenseSplitLineLayout()
                case .COMMENT_HEADER:
                    return ExpenseApprovalLayout.commentHeaderLayout()
                case .COMMENT_IMAGE:
                    return ExpenseApprovalLayout.imageTypeLayout(itemCount: data.IMAGE_COMMENT_REC.count, isHighlight: self.isHightLight, indexPath: indexPath, imageIndexPath: self.imageIndexPath)
                case .COMMENT_USER:
                    return ExpenseApprovalLayout.userLayout()
                case .COMMENT_TextView:
                    return ExpenseApprovalLayout.textViewLayout()
                case .COMMENT_File:
                    return ExpenseApprovalLayout.fileTypeLayout(itemCount: data.FILE_COMMENT_REC.count, isHighlight: self.isHightLight, indexPath: indexPath, fileIndexPath: self.fileIndexPath)
                case .NoComment:
                    return ExpenseApprovalLayout.NoCmtLayout()
                }
            }
            layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: "background-element-kind")
            return layout
        }
        return nil
    }
}



//
//  ArticleVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 11/1/24.
//

import UIKit
import UniformTypeIdentifiers
import Photos
import IQKeyboardManagerSwift


class CommentVC: UIViewController {
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var commentView: CommentView!
    @IBOutlet weak var mentionTableView: UITableView!
    @IBOutlet weak var commentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstaint: NSLayoutConstraint!
    @IBOutlet weak var mentionTableViewHC: NSLayoutConstraint!
    @IBOutlet weak var mentionTableViewTopContraint: NSLayoutConstraint!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    // MARK: - Variables
    
    var bottomBlockHeight : CGFloat = 0
    var mentionedMembers  : [MentionMemberUIModel] = []
    let commentVM         = CommentVM()
    let expenseApprovalVM = ExpenseApprovalVM()
    var selectedDocuments : [FileModel] = []
    var selectedImages    : [String] = []
    
    let commentViewVM           = CommentViewVM()
    let mentionMemberVM         = MentionMemberVM()
    //    var expenseApprovalVM = ExpenseApprovalVM()
    var attributedStringArray   : [String] = []
    var stringToSearch          = ""
    var cursorPosition          = 0
    var newText                 = ""
    var  isReloadComment        = true
    var existedText             = ""
    var isEditComment           = false
    var isAddComment            = false
    var isHightLight            = false
    
    
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    var POST_SEQ_NO             = ""
    var POST_TYPE_CD            = ""
    var BLTB_CD                 = ""
    var TOT_CMT                 = ""
    var isShowKeyboard          = false
    var APPR_SEQ_NO             = ""
    var editing_COMNT_SEQ_NO    = ""
    var indexPathEditComment    = IndexPath(row: 0, section: 0)
    var fileIndexPath           = IndexPath(row: 0, section: 0)
    var imageIndexPath          = IndexPath(row: 0, section: 0)
    let commentIndexPath        = IndexPath(row: 0, section: 0)
    var mentionedMemberNames    : [String] = []

    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.mentionMemberVM.initCellData(data: [])
        self.setupView()
        self.commentCountLabel.getlocalizedFont()
        
        self.collectionView.collectionViewLayout = self.makeLayout()
        collectionView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellWithReuseIdentifier: "TextViewCell")
        collectionView.register(UINib(nibName: "FileTypeCell", bundle: nil), forCellWithReuseIdentifier: "FileTypeCell")
        collectionView.register(UINib(nibName: "ImageTypeCell", bundle: nil), forCellWithReuseIdentifier: "ImageTypeCell")
        collectionView.register(UINib(nibName: "UserCell", bundle: nil), forCellWithReuseIdentifier: "UserCell")
        collectionView.register(UINib(nibName: "EmptyCmtCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EmptyCmtCollectionViewCell")
        collectionView.register(UINib(nibName: "CommentFooterCell", bundle: nil), forCellWithReuseIdentifier: "CommentFooterCell")
        mentionTableView.register(UINib(nibName: "MentionMemberCell", bundle: nil), forCellReuseIdentifier: "MentionMemberCell")
        
        showKeyboard()
        
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        self.fetchCommentList()
        
        commentView.dataSource = self
        commentView.TopBarKeyboardView.dataSource = self
        
        // MARK: - CommentView -
        commentView.completionKeyboard = {
            if self.commentView.collectionView.contentSize.height <= 200 {
                self.commentViewHeightConstraint.constant = self.commentView.collectionView.contentSize.height + 10 + 10 + 1
                self.commentView.layoutIfNeeded()
            } else {
                self.commentViewHeightConstraint.constant = 200 + 10 + 10 + 1
                self.commentView.layoutIfNeeded()
            }
            
            IQKeyboardManager.shared.resignOnTouchOutside = true
            self.mentionTableViewHC.constant = 0
        }
        
        commentView.newCompletion = { height, keyboardAppearance in
            let heightCollection = self.commentView.collectionView.contentSize.height
            if heightCollection <= 200 {
                self.commentViewHeightConstraint.constant  = heightCollection + 10 + 10 + 1 - 28
                self.commentViewHeightConstraint.constant += keyboardAppearance ? height : 0
                if self.commentViewHeightConstraint.constant < 54 {
                    self.commentViewHeightConstraint.constant = 54
                }
                self.commentView.layoutIfNeeded()
            } else {
                self.commentViewHeightConstraint.constant =  200 + 10 + 10 + 1
                self.commentViewHeightConstraint.constant += keyboardAppearance ? height : 0
                self.commentView.layoutIfNeeded()
            }
        }
        
        commentView.removeFileCompletion = { height, keyboardAppearance in
            let heightCollection = self.commentView.collectionView.contentSize.height
            if heightCollection <= 200 {
                self.commentViewHeightConstraint.constant  = heightCollection + 10 + 10 + 1
                self.commentViewHeightConstraint.constant += keyboardAppearance ? height : 0
                if self.commentViewHeightConstraint.constant < 54 {
                    self.commentViewHeightConstraint.constant = 54
                }
                self.commentView.layoutIfNeeded()
            } else {
                self.commentViewHeightConstraint.constant =  200 + 10 + 10 + 1
                self.commentViewHeightConstraint.constant += keyboardAppearance ? height : 0
                self.commentView.layoutIfNeeded()
            }
        }
        
        commentView.completionPostComment = { commentString in
            
            self.commentView.submitButton.isUserInteractionEnabled = false
            
            if !self.isEditComment {
                
                
                
                // *** NOTE ***
                // 👉 no need to formatted POST_CONT into user info form, if no member has been mentioned
                // 👉 when one or more member has been mentioned in the POST_CONT, must format it into user info form => "@[Sokny Ran (Yakuza)](soknyran.dev@gmail.com)"
                var POST_CONT_Formatted = commentString
                if self.mentionedMembers.count != 0 {
                    POST_CONT_Formatted = self.formatMentionFromReadableToAPISyntax(originalText: commentString, mentionedMembers: self.mentionedMembers)
                }
                
                //                var rec_in : [WABOOKS_MREC_BLTB_0002_C001.REQUEST.REC] = []
                //                for obj in self.selectedDocuments {
                //                    let fileName = obj.fileName
                //                    let fileData = obj.fileData.base64EncodedString(options: .endLineWithLineFeed)
                //                    let eachDoc  = WABOOKS_MREC_BLTB_0002_C001.REQUEST.REC(FILE_NM: fileName, FILE_DATA: fileData)
                //                    rec_in.append(eachDoc)
                //                }
                
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
                
                let COMNT_DV_CD   = "C"
                let COMNT_TASK_CD = "C001"
                
                
                let body = WABOOKS_MREC_BLTB_0002_C001.REQUEST(BLTB_CD: self.BLTB_CD, POST_SEQ_NO: self.POST_SEQ_NO, COMNT_DV_CD: COMNT_DV_CD, COMNT_TASK_CD: COMNT_TASK_CD, COMNT_CONT: POST_CONT_Formatted.convertStringToHTML, REC: REC)
                
                // addcmt
                self.commentVM.requestAddComment(body: body) { result in
                    switch result {
                        
                    case .success(_):
                        // yes sir
                        self.isAddComment = true
                        self.TOT_CMT = String((Int(self.TOT_CMT) ?? 0) + 1) // comment count + 1
                        self.commentView.addedCommentCompletion()
                        self.mentionedMembers = []
                        self.commentView.mentionedMembers = []
                    
                        self.fetchCommentList() { result in
                            // Highlight add comment
                            switch result {
                            case .success(_):
                                self.commentView.TopBarKeyboardView.resetCount()
                                let lastIndex = self.commentVM.content.count - 1
                                let lastItem = self.commentVM.content[lastIndex]
                                DispatchQueue.main.async {
                                    self.collectionView.scrollToItem(at: IndexPath(row: 0, section: lastIndex), at: .top, animated: true)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

                                    switch lastItem.rowType {
                                        
                                    case .TextView:
                                        let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex)) as! TextViewCell
                                        let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex - 1)) as! UserCell
                                        textViewCell.isHighLight    = true
                                        userCell.isHighLight        = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            textViewCell.isHighLight    = false
                                            userCell.isHighLight        = false
                                        }
                                    case .FileType:
                                        let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex - 1)) as! TextViewCell
                                        let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex - 2)) as! UserCell
                                        self.isHightLight = true
                                        self.fileIndexPath = IndexPath(row: 0, section: lastIndex)
                                        self.collectionView.reloadSections(IndexSet(integer: lastIndex))
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            textViewCell.isHighLight    = true
                                            userCell.isHighLight        = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            textViewCell.isHighLight    = false
                                            userCell.isHighLight        = false
                                            self.isHightLight           = false
                                            self.fileIndexPath          = IndexPath(row: 0, section: 0)
                                            self.imageIndexPath         = IndexPath(row: 0, section: 0)
                                            self.collectionView.reloadSections(IndexSet(integer: lastIndex))
                                        }
                                    case .ImageType:
                                        if self.commentVM.content[lastIndex - 1].rowType == .FileType {
                                            let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex - 2)) as! TextViewCell
                                            let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex - 3)) as! UserCell
                                            self.imageIndexPath = IndexPath(row: 0, section: lastIndex)
                                            self.fileIndexPath  = IndexPath(row: 0, section: lastIndex - 1)
                                            self.isHightLight           = true
                                            self.collectionView.reloadSections(IndexSet(integer: lastIndex))
                                            DispatchQueue.main.async {
                                                textViewCell.isHighLight    = true
                                                userCell.isHighLight        = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                textViewCell.isHighLight    = false
                                                userCell.isHighLight        = false
                                                self.isHightLight           = false
                                                self.fileIndexPath          = IndexPath(row: 0, section: 0)
                                                self.imageIndexPath         = IndexPath(row: 0, section: 0)
                                                self.collectionView.reloadSections(IndexSet(integer: lastIndex))
                                            }
                                        } else {
                                            let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex - 2)) as! UserCell
                                            let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: lastIndex - 1)) as! TextViewCell
                                            self.imageIndexPath = IndexPath(row: 0, section: lastIndex)
                                            self.isHightLight           = true
                                            self.collectionView.reloadSections(IndexSet(integer: lastIndex))
                                            DispatchQueue.main.async {
                                                textViewCell.isHighLight    = true
                                                userCell.isHighLight        = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                textViewCell.isHighLight    = false
                                                userCell.isHighLight        = false
                                                self.isHightLight           = false
                                                self.fileIndexPath          = IndexPath(row: 0, section: 0)
                                                self.imageIndexPath         = IndexPath(row: 0, section: 0)
                                                self.collectionView.reloadSections(IndexSet(integer: lastIndex))
                                            }
                                        }
                                    default: return
                                    }
                                }
                            case .failure(_):
                                break
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                    self.commentView.submitButton.isUserInteractionEnabled = true
                }
            } else {
                
                // *** NOTE ***
                // 👉 no need to formatted POST_CONT into user info form, if no member has been mentioned
                // 👉 when one or more member has been mentioned in the POST_CONT, must format it into user info form => "@[Sokny Ran (Yakuza)](soknyran.dev@gmail.com)"
                var POST_CONT_Formatted = commentString
                if self.mentionedMembers.count != 0 {
                    POST_CONT_Formatted = self.formatMentionFromReadableToAPISyntax(originalText: commentString, mentionedMembers: self.mentionedMembers)
                }
                POST_CONT_Formatted = POST_CONT_Formatted.replace(of: "\n", with: "<br>")
                
                let REC2    = self.commentVM.REC2
                let REC     = self.commentView.commentViewVM.REC
                
                let body = WABOOKS_MREC_BLTB_0002_U001.REQUEST(BLTB_CD: self.BLTB_CD, POST_SEQ_NO: self.POST_SEQ_NO, COMNT_SEQ_NO: self.editing_COMNT_SEQ_NO, COMNT_CONT: POST_CONT_Formatted.convertStringToHTML, REC2: REC2, REC: REC)
                
                // updatecmt
                self.commentVM.requestUpdateComment(body: body) { result in
                    switch result {
                        
                    case .success(_):
                        self.isEditComment = false
                        //                        self.editing_COMNT_SEQ_NO = ""
                        self.commentView.addedCommentCompletion()
                        self.mentionedMembers = []
                        self.commentView.mentionedMembers = []
                        self.fetchCommentList() { result in
                            switch result {
                            case .success(_):
                                self.commentView.TopBarKeyboardView.resetCount()
                                guard let editIndex = self.commentVM.content.firstIndex(where: {$0.REC?.COMNT_SEQ_NO == self.editing_COMNT_SEQ_NO}) else {return}
                                DispatchQueue.main.async {
                                    self.collectionView.scrollToItem(at: IndexPath(row: 0, section: editIndex), at: .top, animated: true)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    if editIndex == self.commentVM.content.count - 2 {
                                        
                                        let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex)) as! UserCell
                                        let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex + 1)) as! TextViewCell

                                        textViewCell.isHighLight    = true
                                        userCell.isHighLight        = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            textViewCell.isHighLight    = false
                                            userCell.isHighLight        = false
                                        }
                                        
                                        if self.commentViewVM.content.last?.rowType != .TextView {
                                            if self.commentViewVM.content.last?.rowType == .FileType {
                                                self.isHightLight = true
                                                let fileIndexSet = IndexSet(integer: editIndex + 2)
                                                self.fileIndexPath = IndexPath(row: 0, section: editIndex)

                                                self.collectionView.reloadSections(fileIndexSet)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                    self.isHightLight = false
                                                    self.fileIndexPath = IndexPath(row: 0, section: 0)
                                                    self.collectionView.reloadSections(fileIndexSet)
                                                }
                                                
                                            } else if self.commentVM.content.last?.rowType == .ImageType {
                                                if self.commentViewVM.content[self.commentVM.content.count - 2].rowType == .FileType {
//                                                    let fileIndexSet    = IndexSet(integer: editIndex + 2)
                                                    let imageIndexSet   = IndexSet(integer: editIndex + 3)
                                                    self.fileIndexPath = IndexPath(row: 0, section: editIndex + 2)
                                                    self.imageIndexPath = IndexPath(row: 0, section: editIndex + 3)
                                                    
                                                    self.isHightLight = true
//                                                    self.collectionView.reloadSections(fileIndexSet)
                                                    self.collectionView.reloadSections(imageIndexSet)
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                        self.isHightLight = false
                                                        self.fileIndexPath = IndexPath(row: 0, section: 0)
                                                        self.imageIndexPath = IndexPath(row: 0, section: 0)
//                                                        self.collectionView.reloadSections(fileIndexSet)
                                                        self.collectionView.reloadSections(imageIndexSet)
                                                    }
                                                } else {
                                                    let imageIndexSet   = IndexSet(integer: editIndex + 2)
                                                    self.imageIndexPath = IndexPath(row: 0, section: editIndex + 3)
                                                    self.isHightLight = true
                                                    self.collectionView.reloadSections(imageIndexSet)
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                        self.isHightLight = false
                                                        self.imageIndexPath = IndexPath(row: 0, section: 0)
                                                        self.collectionView.reloadSections(imageIndexSet)
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        
                                        let editItem = self.commentVM.content[editIndex + 2]
                                        
                                        switch editItem.rowType {
                                        case .User:
                                            let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex)) as! UserCell
                                            let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex + 1)) as! TextViewCell
                                            
                                            textViewCell.isHighLight    = true
                                            userCell.isHighLight        = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                textViewCell.isHighLight    = false
                                                userCell.isHighLight        = false
                                            }
                                        case .FileType:
                                            let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex)) as! UserCell
                                            let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex + 1)) as! TextViewCell
                                            
                                            self.isHightLight = true
                                            
                                            textViewCell.isHighLight    = true
                                            userCell.isHighLight        = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                textViewCell.isHighLight    = false
                                                userCell.isHighLight        = false
                                            }
                                            
                                            let fileIndexSet = IndexSet(integer: editIndex + 2)
                                            self.fileIndexPath = IndexPath(row: 0, section: editIndex + 2)
                                            
                                            self.collectionView.reloadSections(fileIndexSet)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                self.isHightLight = false
                                                self.fileIndexPath = IndexPath(row: 0, section: 0)
                                                self.collectionView.reloadSections(fileIndexSet)
                                            }
                                            
                                            if (editIndex + 3) <= (self.commentVM.content.count - 1) {
                                                
                                                if self.commentVM.content[editIndex + 3].rowType == .ImageType {
                                                    let imageIndexSet = IndexSet(integer: editIndex + 3)
                                                    self.imageIndexPath = IndexPath(row: 0, section: editIndex + 3)
                                                    
                                                    self.collectionView.reloadSections(imageIndexSet)
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                        self.isHightLight = false
                                                        self.imageIndexPath = IndexPath(row: 0, section: 0)
                                                        self.collectionView.reloadSections(imageIndexSet)
                                                    }
                                                }
                                            }
                                            
                                        case .ImageType:
                                            let userCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex)) as! UserCell
                                            let textViewCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: editIndex + 1)) as! TextViewCell
                                            
                                            textViewCell.isHighLight    = true
                                            userCell.isHighLight        = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                textViewCell.isHighLight    = false
                                                userCell.isHighLight        = false
                                            }
                                            
                                            self.isHightLight = true
                                            
                                            let imageIndexSet = IndexSet(integer: editIndex + 2)
                                            self.imageIndexPath = IndexPath(row: 0, section: editIndex + 2)
                                            
                                            self.collectionView.reloadSections(imageIndexSet)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                self.isHightLight = false
                                                self.imageIndexPath = IndexPath(row: 0, section: 0)
                                                self.collectionView.reloadSections(imageIndexSet)
                                            }
                                        default: return
                                        }
                                    }
                                }
                            case .failure(_):
                                break
                            }
                        }
                    case .failure(let error):
                        self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: error.localizedDescription, greyTitle: "ok".localized)
                    }
                    self.commentView.submitButton.isUserInteractionEnabled = true
                }
            }
        }
        
        commentView.completionTypingWord = { typingWord in
            let numberOfAddress = typingWord.numberOfOccurrencesOf(string: "@")
            if  numberOfAddress == 1 {
                // When text containt "@"
                print("Front typing word: ", typingWord)
                
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
                                self.mentionTableViewTopContraint.constant = self.screenHeight - self.bottomBlockHeight - 220
                            } else {
                                self.mentionTableViewHC.constant = CGFloat(self.mentionMemberVM.filteredList.count * 60)
                                
                                let remainingValue = 4 - self.mentionMemberVM.filteredList.count
                                let sizeToIncrease = CGFloat(remainingValue * 50)
                                self.mentionTableViewTopContraint.constant = self.screenHeight - self.bottomBlockHeight - 220 + sizeToIncrease
                            }
                            
                            IQKeyboardManager.shared.resignOnTouchOutside = false
                            
                        } else {
                            IQKeyboardManager.shared.resignOnTouchOutside = true
                            self.mentionTableViewHC.constant = 0
                        }
                        
                        
                    case .failure(let error):
                        print(error)
                    }
                }
                
            } else {
                
                // When text not contain "@"
                IQKeyboardManager.shared.resignOnTouchOutside = true
                self.mentionTableViewHC.constant = 0
            }
        }
    }
    
    private func makeLayout() -> UICollectionViewLayout! {
        if #available(iOS 13.0, *) {
            let layout = UICollectionViewCompositionalLayout { (section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                
                let data = self.commentVM.content[section]
                let rowType = data.rowType
                let indexPath = IndexPath(row: 0, section: section)
                
                switch rowType {
                    
                case .TextView:
                    return CommentLayout.textViewLayout()
                case .FileType:
                    return CommentLayout.fileTypeLayout(itemCount: data.FILE_COMMENT_REC.count, isHighlight: self.isHightLight, indexPath: indexPath, fileIndexPath: self.fileIndexPath)
                case .ImageType:
                    return CommentLayout.imageTypeLayout(itemCount: data.IMAGE_COMMENT_REC.count, isHighlight: self.isHightLight, indexPath: indexPath, imageIndexPath: self.imageIndexPath)
                case .User:
                    return CommentLayout.userLayout()
                case .NoComment:
                    return CommentLayout.NoCmtLayout()
                case .Footer:
                    return CommentLayout.footerLayout()
                }
            }
            layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: "background-element-kind")
            return layout
        }
        return nil
    }
    
    // MARK: - call this Function to refresh
    func fetchCommentList(completion: ((Swift.Result<WABOOKS_MREC_BLTB_0002_R003.RESPONES, NSError>) -> Void)? = nil) {
        commentVM.fetchComment(POST_SEQ_NO: POST_SEQ_NO, BLTB_CD: BLTB_CD) { result in
            self.commentCountLabel.isHidden = false
            switch result {
            case .success(_):
                self.commentView.setUserProfileImage(url: self.commentVM.response?.USER_IMG_URL)
                self.commentVM.REC2 = []
                self.commentView.commentViewVM.REC = []
                self.commentVM.initData()
                self.commentView.commentViewVM.content = [CommentViewModel(rowType: .TextView)]
                if self.TOT_CMT != "0" && self.TOT_CMT != "1"{
                    self.commentCountLabel.text = "\(self.TOT_CMT)" + " " + "comments".localized
                }else{

                    self.commentCountLabel.text = "\(self.TOT_CMT) \("comment".localized)"

                    self.commentCountLabel.text = "\(self.TOT_CMT)" + " " + "comment".localized
                }
                self.commentCountLabel.getlocalizedFont()
                self.commentViewHeightConstraint.constant = 54
                self.commentView.layoutIfNeeded()
                self.commentView.collectionView.reloadData()
                self.collectionView.reloadData()
                
                completion?(result)
                
            case .failure(let error):
                print(error)
                completion?(result)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        MyNotify.send(name: .reloadAfterComment)
    }
    
    func getDocumentsDirectory() -> URL { // returns your application folder
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func requestApprovalComment(commentString: String, approvalStatus: ApprovalStatus) {
        
        // *** NOTE ***
        // 👉 no need to formatted POST_CONT into user info form, if no member has been mentioned
        // 👉 when one or more member has been mentioned in the POST_CONT, must format it into user info form => "@[Sokny Ran (Yakuza)](soknyran.dev@gmail.com)"
        var POST_CONT_Formatted = commentString
        if self.mentionedMembers.count != 0 {
            POST_CONT_Formatted = self.formatMentionFromReadableToAPISyntax(originalText: commentString, mentionedMembers: self.mentionedMembers)
        }
        
        var rec_in : [WABOOKS_MREC_BLTB_0005_U001.REQUEST.REC_IN] = []
        for obj in self.selectedDocuments {
            let fileName = obj.fileName
            let fileData = obj.fileData.base64EncodedString(options: .endLineWithLineFeed)
            let eachDoc  = WABOOKS_MREC_BLTB_0005_U001.REQUEST.REC_IN(FILE_NM: fileName, FILE_DATA: fileData)
            rec_in.append(eachDoc)
            self.selectedDocuments.removeAll()
        }
        
        for obj in self.selectedImages {
            let fileName = self.getRandomImageName()
            let fileData = obj
            let eachDoc  = WABOOKS_MREC_BLTB_0005_U001.REQUEST.REC_IN(FILE_NM: fileName, FILE_DATA: fileData)
            rec_in.append(eachDoc)
            self.selectedImages.removeAll()
        }
        
        
        
        self.expenseApprovalVM.requestApproveOrReject(APPR_SEQ_NO: self.APPR_SEQ_NO , APPRVR_STTS: approvalStatus.rawValue, BLTB_CD: self.BLTB_CD, COMNT_CONT: POST_CONT_Formatted, REC_IN: rec_in) { result in
            switch result {
            case .success(_):
                self.commentView.addedCommentCompletion()
                self.mentionedMembers = []
                self.commentView.mentionedMembers = []
                
                // heremen; clean from comment box too
                self.commentView.textView.resignFirstResponder()
                self.fetchCommentList()
                
                
            case .failure(let error):
                self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: error.localizedDescription, greyTitle: "ok".localized)
            }
        }
    }
    
    
    
    // MARK: - Ojective-C Functions
    // get keyboard height
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            print(keyboardHeight)
            
            bottomBlockHeight = keyboardHeight + 130  // 130 : height of view top of keybaord
            //            mentionTableViewTopContraint.constant = screenHeight - bottomBlockHeight - 220 //
        }
    }
    
    func showKeyboard() {
        if isShowKeyboard {
            if let commentView = commentView {
                commentView.checkShowKeyboard(isShowKeyboard: self.isShowKeyboard)
            }
        }
    }
    
    func setupView() {
        commentCountLabel.isHidden = true
        mentionTableViewHC.constant = 0
        IQKeyboardManager.shared.resignOnTouchOutside = true
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
    
    
    @objc func actionFileButtonPressed(sender: UIButton) {
        let point           = sender.convert(CGPoint.zero, to: self.collectionView)
        let indexPath       = self.collectionView.indexPathForItem(at: point)!
        let data = self.commentVM.content[indexPath.section]
        
        var treeObjButtons : [OptionPopupWithoutTitleModel] = []
        
        let tempData1 = OptionPopupWithoutTitleModel(icon: "ico_downarrow",    title: "save_to_files".localized)
        treeObjButtons.append(tempData1)
        
        if Shared.R002_DATA?.USER_ID == data.REC?.REG_ID {
            let tempData2 = OptionPopupWithoutTitleModel(icon: "ico_bin",       title: "Delete".localized)
            treeObjButtons.append(tempData2)
        }
        
        optionPopupWithoutTitle(optionData: treeObjButtons) { option, owner in
            switch option {
            case "Save to files".localized :
//                self.showDocumentSaveAndOpen()
                let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
                let file_name   = data.FILE_COMMENT_REC[indexPath.row].ORG_FILE_NM ?? ""
                let split_url   = data.FILE_COMMENT_REC[indexPath.row].FILE_URL?.components(separatedBy: "?")
                let file_url    = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")" + "&\(file_name)"
                print("This is linked file \(file_url)")
                DataAccess.shared.downloadTask(withURL: file_url, shouldShowLoading: true) { (data, error) in
                    if error == nil {
                        //                    let fileREC = self.commentVM.content[indexPath.section].rowType == .FileType ? self.commentVM.content[indexPath.section].FILE_REC : self.commentVM.content[indexPath.section].FILE_COMMENT_REC
                        let path = self.getDocumentsDirectory()
                        let fileUrl = path.appendingPathComponent(file_name)
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
                
            case "Delete".localized :
                owner.dismiss(animated: true, completion: nil)
                let leftTitle = "Delete attachment".localized
                let message = "This action can’t be undone.".localized
                self.yesNoPopup(title: leftTitle, message: message, confirmTitle: "Delete".localized, cancelTitle: "Don't delete".localized, isDeletePopup: true) { confirm in
                    if confirm {
                        if self.commentVM.content[indexPath.section].FILE_COMMENT_REC.count == 1 && self.commentVM.content[indexPath.section].IMAGE_COMMENT_REC.count == 0 && self.commentVM.content[indexPath.section].REC?.COMNT_CONT == "" || self.commentVM.content[indexPath.section].REC?.COMNT_CONT == nil {
                            let body = WABOOKS_MREC_BLTB_0002_D002.REQUEST(BLTB_CD: self.BLTB_CD, POST_SEQ_NO: self.POST_SEQ_NO, COMNT_SEQ_NO: self.commentVM.content[indexPath.section].REC?.COMNT_SEQ_NO)
                            self.commentVM.requestDeleteComment(body: body) { result in
                                switch result {
                                case .success(_):
                                    self.fetchCommentList()
                                    self.TOT_CMT = String((Int(self.TOT_CMT) ?? 0) - 1) // comment count - 1
                                case .failure(let error):
                                    self.customAlert(message: error.localizedDescription)
                                }
                            }
                        } else {
                            self.expenseApprovalVM.requestDeleteFileComment(body: WABOOKS_MREC_BLTB_0005_D002.REQUEST(POST_SEQ_NO: data.REC?.POST_SEQ_NO, BLTB_CD: data.REC?.BLTB_CD, COMNT_SEQ_NO: data.REC?.COMNT_SEQ_NO, FILE_ID: data.FILE_COMMENT_REC[indexPath.row].FILE_ID)) { erorr in
                                if erorr != nil {
                                    // erorr
                                    self.customAlert(message: erorr?.localizedDescription ?? "")
                                    
                                } else {
                                    // success
                                    //                        self.titleBoardLabel.text   = Boards.BoardType.Home.rawValue
                                    /// go home when delete success
                                    //                        self.expenseApprovalVM.boardType     = .Approval
                                    //                                self.getAllData()
                                    self.fetchCommentList()
                                }
                            }
                        }
                    } else {
                        //                self.dismiss(animated: true)
                        print("Don't delete")
                    }
                }
//                self.confirmDelete()
            default :
                break
            }
        }
    }
    
}

extension CommentVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return commentVM.content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let data = commentVM.content[section]
        switch data.rowType {
            
        case .TextView, .User, .NoComment, .Footer:
            return 1
        case .ImageType:
            return data.IMAGE_COMMENT_REC.count
        case .FileType:
            return data.FILE_COMMENT_REC.count
        }
    }
    
    // MARK: -  UICollectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = commentVM.content[indexPath.section]
        
        switch data.rowType {
            
        case .TextView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
            cell.recData = data.REC
            cell.WABOOKS_MREC_BLTB_0002_R003()
            cell.isUserInteractionEnabled = false
            return cell
        case .FileType:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileTypeCell", for: indexPath) as! FileTypeCell
            cell.WABOOKS_MREC_BLTB_0005_R002_0005_R001_0002_R003(data: data.FILE_COMMENT_REC[indexPath.row])
            cell.dotMoreAction.addTarget(self, action: #selector(actionFileButtonPressed), for: .touchUpInside)
            return cell
        case .ImageType:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageTypeCell", for: indexPath) as! ImageTypeCell
            cell.deleteUIView.isHidden = true
            cell.WABOOKS_MREC_BLTB_0002_R003(data: data.IMAGE_COMMENT_REC[indexPath.row])
            return cell
        case .User:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCell
            if let REC = data.REC {
                cell.WABOOKS_MREC_BLTB_0002_R003(data: REC)
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
                                let body = WABOOKS_MREC_BLTB_0002_D002.REQUEST(BLTB_CD: self.BLTB_CD, POST_SEQ_NO: self.POST_SEQ_NO, COMNT_SEQ_NO: data.REC?.COMNT_SEQ_NO)
                                self.commentVM.requestDeleteComment(body: body) { result in
                                    switch result {
                                    case .success(_):
                                        self.TOT_CMT = String((Int(self.TOT_CMT) ?? 0) - 1) // comment count - 1
                                        self.fetchCommentList()
                                    case .failure(let error):
                                        self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: error.localizedDescription, greyTitle: "ok".localized)
                                    }
                                }
                            }
                        }
                        
                    case "Edit_Comment".localized:
                        //                        self.editing_COMNT_SEQ_NO = data.REC?.COMNT_SEQ_NO ?? ""
                        //                        self.isEditComment = true
                        //                        self.commentView.textView.text = data.REC?.COMNT_CONT
                        //                        self.commentView.placeholderLabel.isHidden = self.commentView.textView.text == "" ? false : true
                        //                        self.commentView.textView.becomeFirstResponder()
                   
                        
                        self.editing_COMNT_SEQ_NO = data.REC?.COMNT_SEQ_NO ?? ""
                        self.isEditComment = true
                        self.indexPathEditComment = indexPath
                        let COMNT_CONT = data.REC?.COMNT_CONT?.replace(of: "<br>", with: "\n")
                        var commentREC = [CommentViewModel(text: COMNT_CONT, rowType: .TextView)]
                        var FILE_COMMENT_REC : [WABOOKSStruct.REC_Protocol] = []
                        var IMAGE_COMMENT_REC : [WABOOKSStruct.REC_Protocol] = []
                        if indexPath.section + 2 < self.commentVM.content.count {
                            if self.commentVM.content[indexPath.section + 2].rowType == .FileType {
                                FILE_COMMENT_REC = self.commentVM.content[indexPath.section + 2].FILE_COMMENT_REC
                                if indexPath.section + 3 < self.commentVM.content.count {
                                    if self.commentVM.content[indexPath.section + 3].rowType == .ImageType {
                                        IMAGE_COMMENT_REC = self.commentVM.content[indexPath.section + 3].IMAGE_COMMENT_REC
                                    }
                                }
                            } else if self.commentVM.content[indexPath.section + 2].rowType == .ImageType {
                                IMAGE_COMMENT_REC = self.commentVM.content[indexPath.section + 2].IMAGE_COMMENT_REC
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
                                for i in 0..<IMAGE_COMMENT_REC.count {
                                    let cell = collectionView.cellForItem(at: IndexPath(row: i, section: FILE_COMMENT_REC.count > 0 ? (indexPath.section + 3) : (indexPath.section + 2) )) as! ImageTypeCell
                                    //                                    imgREC.append(cell.img.image!)
                                    imgREC.append(CommentViewModel.ImageModel(image: cell.img.image!, isFromLocal: false))
                                }
                                commentREC.append(CommentViewModel(image: imgREC, rowType: .ImageType))
                            }
                            
                        }
                        
                        self.commentView.TopBarKeyboardView.setCountFile(FILE_COMMENT_REC.count)
                        self.commentView.TopBarKeyboardView.setCountImage(IMAGE_COMMENT_REC.count)
                        
                        self.commentView.commentViewVM.content = commentREC
                        self.commentView.collectionView.reloadData()
                        self.commentView.placeholderLabel.isHidden = true
                        
                        
                        self.getExistedMentionedMember(content: commentREC[self.indexPathEditComment.item].text ?? "")
                        self.commentView.mentionedMembers = self.mentionedMemberNames
                        self.commentView.setAttributedStringWhenEdit()
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.commentView.placeholderLabel.isHidden = commentREC[self.indexPathEditComment.item].text != ""
                            self.commentView.textView.becomeFirstResponder()
                        }
                        
                        //                        self.commentView.commentViewVM.content =
                        //                        self.commentView.textView.text = data.Comment_REC?.COMNT_CONT
                        //                        self.commentView.placeholderLabel.isHidden = self.commentView.textView.text == "" ? false : true
                        //                        self.commentView.textView.becomeFirstResponder()
                    default:
                        break
                    }
                }
            }
            return cell
        case .NoComment:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCmtCollectionViewCell", for: indexPath)
            return cell
        case .Footer:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentFooterCell", for: indexPath)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = commentVM.content[indexPath.section]
        
        switch data.rowType {
        case .ImageType:
            let vc = VC(sbName: "PhotoPreviewSB", identifier: "PhotoPreviewsVC") as! PhotoPreviewsVC
            var imgRec : [Any]   = []
            let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
            vc.isBtnDeleteDisable = true
            vc.currentIndexImage  = indexPath.row
            for imgUrl in data.IMAGE_COMMENT_REC {
                let split_url       = imgUrl.FILE_URL?.components(separatedBy: "?")
                let img_url         = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")"
                imgRec.append(img_url) //file url
            }
            vc.imageUrlArray     = [["RCPT_IMG_URL" : imgRec]] as Array<AnyObject>
            let img = collectionView.cellForItem(at: indexPath) as! ImageTypeCell
            vc.cc_setZoomTransition(originalView: img.img) // Zoom trasition for receipt image
            self.present(vc, animated: true)
            
        case .FileType :
            //            var file_url    =  ""
            let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
            let file_name   = data.FILE_COMMENT_REC[indexPath.row].ORG_FILE_NM ?? ""
            let split_url   = data.FILE_COMMENT_REC[indexPath.row].FILE_URL?.components(separatedBy: "?")
            let file_url    = "\(split_url?.first ?? "")?token=\(authorization)&\(split_url?.last ?? "")" + "&\(file_name)"

            DataAccess.shared.downloadTask(withURL: file_url, shouldShowLoading: true) { (data, error) in
                if error == nil {
                    //                    let fileREC = self.commentVM.content[indexPath.section].rowType == .FileType ? self.commentVM.content[indexPath.section].FILE_REC : self.commentVM.content[indexPath.section].FILE_COMMENT_REC
                    let path = self.getDocumentsDirectory()
                    let fileUrl = path.appendingPathComponent(file_name)
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
        default :
            print("Hello world")
            
        }
    }
}

extension CommentVC: UITableViewDelegate, UITableViewDataSource {
    
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
        
        if data.email.contains(".org") || data.email.contains(".cc") || data.email.contains(".net") || data.email.contains(".com") || data.email.contains(".kr") || data.email.contains(".kh"){
            
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
extension CommentVC: TopBarKeyboardDataSource {
    func setResponsibleVC() -> UIViewController {
        return self
    }
}


extension CommentVC: CommentViewDataSource {
    func removeItemAtIndexPath(indexPath: IndexPath, rowType: CommentViewModel.RowType, isFromLocal: Bool) {
        switch rowType {
        case .TextView:
            break
        case .FileType:
            if !isFromLocal {
                var temp = commentVM.content
                let FILE_ID = temp[indexPathEditComment.section + 1 + indexPath.section].FILE_COMMENT_REC.remove(at: indexPath.row).FILE_ID
                commentVM.REC2.append(WABOOKS_MREC_BLTB_0002_U001.REQUEST.REC2(FILE_ID: FILE_ID))
            }
        case .ImageType:
            if !isFromLocal {
                var temp = commentVM.content
                var section = 0
                switch commentVM.content[indexPathEditComment.section + 1 + 1].rowType {
                case .FileType:
                    if commentVM.content[indexPathEditComment.section + 1 + 1].FILE_COMMENT_REC.count > 0 {
                        section = commentView.commentViewVM.fileCount() > 0 ? indexPathEditComment.section : indexPathEditComment.section + 1
                    } else {
                        section = indexPathEditComment.section - 1
                    }
                case .ImageType:
                    section = indexPathEditComment.section
                default: return
                }
                let FILE_ID = temp[section + 1 + indexPath.section].IMAGE_COMMENT_REC.remove(at: indexPath.row).FILE_ID
                commentVM.REC2.append(WABOOKS_MREC_BLTB_0002_U001.REQUEST.REC2(FILE_ID: FILE_ID))
            }
        }
    }
}

class SectionBackgroundDecorationView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(hexString: "EDF7FF")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//
//  View.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 17/1/24.
//

import UIKit
import IQKeyboardManagerSwift


class CommentView: UIView {
    
    private static let NIB_NAME = "CommentView"
    
    @IBOutlet weak var collectionView   : UICollectionView!
    @IBOutlet var view                  : UIView!
    @IBOutlet weak var approveTitle     : UIButton!
    @IBOutlet weak var rejectTitle      : UIButton!
    @IBOutlet weak var approvalView     : UIView!
    @IBOutlet weak var submitButton     : UIButton!
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    var textView: UITextView!
    
    var placeholderLabel: UILabel!
    
    var commentViewVM = CommentViewVM()
    
    var mentionedMembers : [String] = []
    
    var completion: (_ height: CGFloat) -> Void = {_ in }
    
    @IBOutlet weak var bottomConstain: NSLayoutConstraint!
    
    var completionKeyboard: () -> Void = {}
    
    @IBOutlet weak var bottomCollectionViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomConstraintToApprovalView: NSLayoutConstraint!
    
    @IBOutlet weak var heightApproveViewConstraint: NSLayoutConstraint!
    
    var newCompletion: (_ height: CGFloat, _ keyboardAppearance: Bool) -> Void = { _, _ in }
    
    var removeFileCompletion: (_ height: CGFloat, _ keyboardAppearance: Bool) -> Void = { _, _ in }
    
    var completionFile: () -> Void = {}
    
    var previousRect = CGRect.zero
    
    var height : CGFloat = 0
    
    var heightTextview : CGFloat = 17
    
    var keyboardHeight: CGFloat = 0
    
    var completionTypingWord : Completion_String = {_ in }
    
    var completionPostComment : Completion_String = {_ in }
    
    var completionSelectDocument : Completion_SelectDocument = {_ in }
    
    var completionImageUrls : Completion_ArrayOfString = {_ in }
    
    var selectedFileArr   : [FileModel] = []
    var cursorPosition = 0
    
    var stringToSearch = ""
    var keyboardAppearance = false
    
    // MARK: delegate variable
    var delegate    : CommentViewDelegate?
    var dataSource  : CommentViewDataSource?
    
    // this variable for hide and show Approver and Reject button action
    var isApprover: Bool = false {
        didSet {
            if isApprover {
                commentViewHeight = 140
                approvalView.isHidden = false
                heightApproveViewConstraint.constant = 86
            } else {
                commentViewHeight = 54
                approvalView.isHidden = true
                heightApproveViewConstraint.constant = 0
            }
            view.layoutIfNeeded()
        }
    }
    
    var commentViewHeight: CGFloat = 54
    
    lazy var TopBarKeyboardView : TopBarKeyboardView = {
        return Bundle.main.loadNibNamed("TopBarKeyboardView", owner: self, options: nil)?.first as! TopBarKeyboardView
    }()
    
    override func awakeFromNib() {
        commentViewVM.initData()
        initWithNib()
        TopBarKeyboardView.delegate = self
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(CommentVC.self)
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ExpenseApprovalWeCMSVC.self)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.placeholderLabel.getlocalizedFont()
        self.textView.getlocalizedFont()
        approveTitle.setTitle("Approve".localized, for: .normal)
        rejectTitle.setTitle("reject".localized, for: .normal)
        rejectTitle.getlocalizedFont()
        approveTitle.getlocalizedFont()
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        self.keyboardAppearance = true
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.keyboardHeight = keyboardHeight
            height = keyboardHeight + commentViewHeight
            bottomConstain.constant = keyboardHeight - 48 + 10 + 10
            newCompletion(keyboardHeight, keyboardAppearance)
        }
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification) {
        self.keyboardAppearance = false
        if self.frame.height != commentViewHeight {
            bottomConstain.constant = 0
            completionKeyboard()
        }
    }
    
    @IBAction func approveButtonPressed(_ sender: Any) {
        delegate?.approve?(commentString: textView.text)
    }
    
    @IBAction func rejectButtonPressed(_ sender: Any) {
        delegate?.reject?(commentString: textView.text)
    }
    
    private func initWithNib() {
        Bundle.main.loadNibNamed(CommentView.NIB_NAME, owner: self, options: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        setupLayout()
        setupCollection()
        isApprover = false // Noted: we set default commentView approver is false
        enableSubmitButton(false)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(
            [
                view.topAnchor.constraint(equalTo: topAnchor),
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
            ]
        )
    }
    
    func addedCommentCompletion() {
        textView.text = ""
//        textView.textColor = .lightGray
        let _ = textViewShouldEndEditing(textView)
    }
    
    private func setupCollection() {
        collectionView.collectionViewLayout = self.makeLayout()
        collectionView.register(UINib(nibName: "TextViewCommentCell", bundle: nil), forCellWithReuseIdentifier: "TextViewCommentCell")
        collectionView.register(UINib(nibName: "FileTypeCell", bundle: nil), forCellWithReuseIdentifier: "FileTypeCell")
        collectionView.register(UINib(nibName: "ImageTypeCell", bundle: nil), forCellWithReuseIdentifier: "ImageTypeCell")
    }
    
    private func enableSubmitButton(_ enable: Bool) {
        if enable {
            submitButton.isUserInteractionEnabled = true
            submitButton.setImage(UIImage(named: "Button_submit"), for: .normal)
        } else {
            submitButton.isUserInteractionEnabled = false
            submitButton.setImage(UIImage(named: "button"), for: .normal)
        }
    }
    
    func setUserProfileImage(url: String?) {
        self.userProfileImageView.sd_setImage(with: url?.formatFileURL,  completed: { (image, error, SDImageCacheType , url) in
            if error == nil {
                self.userProfileImageView.image  = image
            } else {
                self.userProfileImageView.image  = UIImage(named: "ico_user")
            }
        })
    }
    
    func setAttributedStringWhenEdit() {
        let originalFont =  UIFont(name: "Inter-Medium", size: 14.0)
        
        if mentionedMembers.count > 0 {
            
            setAttributeTextView(textView: self.textView, textsTobeAttributed: mentionedMembers, defaultFont: originalFont, defaultColor: .black, attributedFont: originalFont, atrributedColor: UIColor(resource: .mainTextBulletin))
            textViewDidChange(textView)
        } else {
            textView.font = originalFont
        }
    }
    
    
    
    
    @IBAction func postCommentButtonDidTap(_ sender: UIButton) {
        dismissKeyboard()
        completionPostComment(textView.text)
    }
    
    func addNewMentionedMember(newMember: String) {
        
        var isAlreadyExisted = false
        for obj in mentionedMembers {
            
            if obj == newMember {
                isAlreadyExisted = true
                break
            }
        }
        
        if !isAlreadyExisted {
            mentionedMembers.append(newMember)
        }
        
        let existedText = textView.text ?? ""
        var newText = ""
        
        if cursorPosition == existedText.utf16.count || existedText.utf16.count == (cursorPosition + 1) {
            let split = existedText.components(separatedBy: " ")
            let old = split.dropLast()
            let last = split.last?.removing(charactersOf: "@")
            
            if last == stringToSearch {
                newText = "\(old.joined(separator: " ")) \(newMember) "
            } else {
                newText = existedText.replace(of: "@\(stringToSearch)", with: "\(newMember) ")
            }
        } else {
            
            if stringToSearch == "@" || stringToSearch.isContainsEmoji(){
                var temptText = existedText
                
                if cursorPosition < temptText.utf16.count {
                    temptText.remove(at: temptText.utf16.index(temptText.utf16.startIndex, offsetBy: cursorPosition))
                    temptText.insert(contentsOf: "\(newMember) ", at: temptText.utf16.index(temptText.utf16.startIndex, offsetBy: cursorPosition))
                }
                
                newText = temptText
            } else {
                newText = existedText.replace(of: "@\(stringToSearch)", with: "\(newMember) ")
            }
            
        }
        
        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        let final = trimmed + " "
        
        textView.text = final
        commentViewVM.content[0].text = final
        
        
        if mentionedMembers.count > 0 {
            let originalFont =  UIFont(name: "Inter-Medium", size: 14.0)
            setAttributeTextView(textView: self.textView, textsTobeAttributed: mentionedMembers, defaultFont: originalFont, defaultColor: .black, attributedFont: originalFont, atrributedColor: UIColor(resource: .mainTextBulletin))
            textViewDidChange(textView)
        }
        
    }
    
    func makeLayout() -> UICollectionViewLayout! {
        if #available(iOS 13.0, *) {
            let layout = UICollectionViewCompositionalLayout { (section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                let data = self.commentViewVM.content[section]
                let rowType = data.rowType
                
                switch rowType {
                    
                case .TextView:
                    return CommentViewLayout.textViewLayout()
                case .FileType:
                    return CommentViewLayout.fileTypeLayout(countItem: data.file.count)
                case .ImageType:
                    return CommentViewLayout.imageTypeLayout(countItem: data.image.count)
                }
            }
            return layout
        }
        return nil
    }
}

extension CommentView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return commentViewVM.content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let data = commentViewVM.content[section]
        
        switch data.rowType {
            
        case .TextView:
            return 1
        case .ImageType:
            return data.image.count
        case .FileType:
            return data.file.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = commentViewVM.content[indexPath.section]
        
        if commentViewVM.content.first(where: {$0.rowType == .ImageType})?.image.count ?? 0 > 0 || commentViewVM.content.first(where: {$0.rowType == .FileType})?.file.count ?? 0 > 0 {
            enableSubmitButton(true)
        } else {
            enableSubmitButton(false)
        }
        
        switch data.rowType {
            
        case .TextView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextViewCommentCell", for: indexPath) as! TextViewCommentCell
            cell.config(data: data, mentionMembers: self.mentionedMembers)
            cell.isUserInteractionEnabled = true
            self.textView = cell.textView
            self.placeholderLabel = cell.placeholder
            cell.textView.delegate = self
            cell.textView.tag = 1001
            cell.textView.inputAccessoryView = TopBarKeyboardView
            return cell
        case .FileType:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileTypeCell", for: indexPath) as! FileTypeCell
            cell.config(data: data.file[indexPath.row])
            cell.dotMoreAction.didTap {
                
                let location = IndexPath(row: indexPath.row, section: 1)
                
                self.dataSource?.removeItemAtIndexPath(indexPath: location, rowType: self.commentViewVM.content[location.section].rowType, isFromLocal: self.commentViewVM.content[location.section].file[location.row].isFromLocal)
                self.commentViewVM.content[location.section].file.remove(at: location.row)
                self.TopBarKeyboardView.setCountFile(self.commentViewVM.fileCount())
                if self.commentViewVM.content[location.section].file.count == 0 {
                    self.commentViewVM.content.remove(at: location.section)
                    self.collectionView.performBatchUpdates({
                        self.collectionView.deleteSections(IndexSet(integer: 1))
                    }, completion: { _ in
                        self.removeFileCompletion(self.keyboardHeight, self.keyboardAppearance)
                    })
                } else {
                    self.collectionView.performBatchUpdates({
                        self.collectionView.deleteItems(at: [location])
                    }, completion: { _ in
                        self.collectionView.reloadSections(IndexSet(integer: 1))
                        self.removeFileCompletion(self.keyboardHeight, self.keyboardAppearance)
                    })
                }
            }
            return cell
        case .ImageType:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageTypeCell", for: indexPath) as! ImageTypeCell
            cell.config(data: data.image[indexPath.row].image)
            cell.deleteUIView.didTap {
                
                let location = IndexPath(row: indexPath.row, section: self.commentViewVM.fileCount() > 0 ? 2 : 1)
                
                self.dataSource?.removeItemAtIndexPath(indexPath: location, rowType: self.commentViewVM.content[location.section].rowType, isFromLocal: self.commentViewVM.content[location.section].image[location.row].isFromLocal)
                self.commentViewVM.content[location.section].image.remove(at: location.row)
                self.TopBarKeyboardView.setCountImage(self.commentViewVM.imageCount())

                if self.commentViewVM.content[location.section].image.count == 0 {
                    self.commentViewVM.content.remove(at: location.section)
                    self.collectionView.performBatchUpdates({
                        self.collectionView.deleteSections(IndexSet(integer: self.commentViewVM.fileCount() > 0 ? 2 : 1))
                    }, completion: { _ in
                        self.removeFileCompletion(self.keyboardHeight, self.keyboardAppearance)
                    })
                } else {
                    self.collectionView.performBatchUpdates({
                        self.collectionView.deleteItems(at: [location])
                    }, completion: { _  in
                        self.collectionView.reloadSections(IndexSet(integer: self.commentViewVM.fileCount() > 0 ? 2 : 1))
                        self.removeFileCompletion(self.keyboardHeight, self.keyboardAppearance)
                    })
                }
            }
            return cell
        }
    }
}

extension CommentView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        //call this function for live update textview resize in colllectionview
        self.collectionView.performBatchUpdates({})
        
        if textView.text != nil && textView.text != "" {
            placeholderLabel.isHidden = true
        } else {
            placeholderLabel.isHidden = false
        }
        if (textView.text != nil && textView.text.trim != "") || commentViewVM.content.first(where: {$0.rowType == .ImageType})?.image.count ?? 0 > 0 || commentViewVM.content.first(where: {$0.rowType == .FileType})?.file.count ?? 0 > 0 {
            enableSubmitButton(true)
        } else {
            enableSubmitButton(false)
        }
        self.newCompletion(self.keyboardHeight, self.keyboardAppearance)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        
        if textView.text.utf16.count < 2 {
            mentionedMembers = []
        }
        
        
        // Check not allow emoji
//        let isContainEmoji = text.isContainsEmoji()
//        if isContainEmoji {
//            return false
//        }
        
        // Typing text for search in mention
        var typingWord = ""
        
        // new updated text
        let nsString = textView.text as NSString?
        let updatedString = nsString?.replacingCharacters(in: range, with: text)
        
        commentViewVM.content[0].text = updatedString
        
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
        
        
        // When cursor is at last string
        if cursorPosition == textView.text.utf16.count {
            
            let newString = updatedString ?? ""
            if newString.contains("\n")  {
                let split = updatedString?.components(separatedBy: "\n")
                let lastSplit = split?.last
                
                
                let split2 = lastSplit?.components(separatedBy: " ")
                typingWord = split2?.last ?? ""
                print("Typing Word Last: ", typingWord)
                
                
            } else {
                let split = updatedString?.components(separatedBy: " ")
                typingWord = split?.last ?? ""
                print("Typing Word Last: ", typingWord)
            }
            
            if mentionedMembers.count > 0 {
                let originalFont =  UIFont(name: "Inter-Medium", size: 14.0)
                self.setAttributeTextView(textView: textView, textsTobeAttributed: mentionedMembers, defaultFont: originalFont, defaultColor: .black, attributedFont:originalFont , atrributedColor: UIColor(resource: .mainTextBulletin))
                
            }
       
            
        } else {
            // When cursor is not at last
            
            var newStringArray = [""]
    
            for index in (0...cursorPosition).reversed() {
                
                let str = "\(updatedString ?? "")"
                let stringArray = Array(str)
                
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
            print("Middle typing String; ", typingWord)
            
        }

        if typingWord == "@" /*|| typingWord.last == "@"*/ {
            stringToSearch = ""
        } else if typingWord.first == ("@") || typingWord.getLast2Characters() == "\n@" {
            stringToSearch = typingWord.removing(charactersOf: "@").replace(of: "\n", with: "")
        } else {
            stringToSearch = ""
        }
        completionTypingWord(typingWord)
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" || textView.text == "Add_a_comment".localized {
            textView.text = ""
        }
        if textView.text != nil && textView.text != "" {
        }
        
        let originalFont =  UIFont(name: "Inter-Medium", size: 14.0)
        textView.font = originalFont
       
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            placeholderLabel.isHidden = false
        }
        return true
    }
}

// MARK: TopBarKeyboardDelegate -
extension CommentView: TopBarKeyboardDelegate {
    
    func addFile(_ files: [FileModel]) {
        
        files.forEach { file in
            let fileName = file.fileName.removingPercentEncoding
            let fileData = file.fileData.base64EncodedString()
            self.commentViewVM.REC.append(WABOOKS_MREC_BLTB_0002_U001.REQUEST.REC(FILE_NM: fileName, FILE_DATA: fileData))
        }
        if let index = self.commentViewVM.content.firstIndex(where: {$0.rowType == .FileType}) {
            var indexPath : [IndexPath] = []
            var fileCount = self.commentViewVM.fileCount()
            for _ in 0..<files.count {
                indexPath.append(IndexPath(row: fileCount - 1, section: index))
                fileCount+=1
            }
            self.commentViewVM.content[index].file.append(contentsOf: files)
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: indexPath)
                self.collectionView.insertItems(at: indexPath)
            }, completion: { _ in
                self.collectionView.scrollToItem(at: indexPath.last!, at: .top, animated: true)
            })
        } else {
            self.collectionView.performBatchUpdates({
                self.commentViewVM.content.insert(CommentViewModel(file: files, rowType: .FileType), at: 1)
                self.collectionView.performBatchUpdates({
                    self.collectionView.insertSections(IndexSet(integer: 1))
                }, completion: { _ in
                    let indexPath = IndexPath(row: self.commentViewVM.fileCount() - 1, section: 1)
                    self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
                })
            })
        }
        let fileCount = commentViewVM.fileCount()
        TopBarKeyboardView.setCountFile(fileCount)
        DispatchQueue.main.async {
            self.newCompletion(self.keyboardHeight, self.keyboardAppearance)
        }
    }
    
    func addImage(_ images: [UIImage]) {
        for (i, image) in images.enumerated() {
            if let base64 = convertToBase64(image) {
                let formatter           = DateFormatter()
                formatter.dateFormat    = "yyyMMddHHmm"
                let fileName = "\(formatter.string(from: Date()))\(i).jpg"
                let fileData = base64
                self.commentViewVM.REC.append(WABOOKS_MREC_BLTB_0002_U001.REQUEST.REC(FILE_NM: fileName, FILE_DATA: fileData))
            }
        }
        var imageREC : [CommentViewModel.ImageModel] = []
        images.forEach { img in
            imageREC.append(CommentViewModel.ImageModel(image: img))
        }
        if let index = self.commentViewVM.content.firstIndex(where: {$0.rowType == .ImageType}) {
            var indexPath : [IndexPath] = []
            var imgCount = self.commentViewVM.imageCount()
            for _ in 0..<images.count {
                indexPath.append(IndexPath(row: imgCount - 1, section: index))
                imgCount+=1
            }
            self.commentViewVM.content[index].image.append(contentsOf: imageREC)
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: indexPath)
            }, completion: {_ in 
                self.collectionView.scrollToItem(at: indexPath.last!, at: .top, animated: true)
            })
        } else {
            self.commentViewVM.content.append(CommentViewModel(image: imageREC, rowType: .ImageType))
            self.collectionView.performBatchUpdates({
                self.collectionView.insertSections(IndexSet(integer: commentViewVM.fileCount() > 0 ? 2 : 1))
            }, completion: { _ in
                let indexPath = IndexPath(row: self.commentViewVM.imageCount() - 1, section: self.commentViewVM.fileCount() > 0 ? 2 : 1)
                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            })
        }
        let imageCount = commentViewVM.imageCount()
        TopBarKeyboardView.setCountImage(imageCount)
        DispatchQueue.main.async {
            self.newCompletion(self.keyboardHeight, self.keyboardAppearance)
        }
    }
    
    func dismissKeyboard() {
        self.textView.resignFirstResponder()
    }
    
    func checkShowKeyboard(isShowKeyboard: Bool) {
        if isShowKeyboard {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let _ = self.textView {
//                    self.textView.becomeFirstResponder()
                }
            }
        }
    }
}

// MARK: CommentViewDelegate -
@objc protocol CommentViewDelegate {
    @objc optional func approve(commentString: String)
    @objc optional func reject(commentString: String)
    @objc optional func commentDidChange()
    @objc optional func keyboardDidPopup()
    @objc optional func attachmentHandler()
}

// MARK: CommentViewDataSource -
protocol CommentViewDataSource {
    func removeItemAtIndexPath(indexPath: IndexPath, rowType: CommentViewModel.RowType, isFromLocal: Bool)
}

// MARK: - Custom text can iput Emoji in TextView
extension String {
    
    func isContainsEmoji() -> Bool {
        for character in self {
            var shouldCheckNextScalar = false
            for scalar in character.unicodeScalars {
                if shouldCheckNextScalar {
                    if scalar == "\u{FE0F}" { // scalar that indicates that character should be displayed as emoji
                        return true
                    }
                    shouldCheckNextScalar = false
                }
                if scalar.properties.isEmoji {
                    if scalar.properties.isEmojiPresentation {
                        return true
                    }
                    shouldCheckNextScalar = true
                }
            }
        }
        return false
    }
}


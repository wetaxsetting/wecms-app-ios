//
//  MainTabBarVC.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 8/1/21.
//

import UIKit
import SDWebImage

import Photos
import PhotosUI

class MainTabBarVC: UIViewController {
    
    //MARK: - @IBOutlet
    // Receipt
    @IBOutlet weak var viewReceiptDetail        : UIView!
    @IBOutlet weak var labelReceipt             : UILabel!
    @IBOutlet weak var imageViewReceipt         : UIImageView!
    @IBOutlet weak var notificationBadgeCountBtn: UIButton!
    @IBOutlet weak var cstWBtnNotificationBadge : NSLayoutConstraint!
    
    // Board
    @IBOutlet weak var viewBoards: UIView!
    @IBOutlet weak var boardImageView: UIImageView!
    @IBOutlet weak var boardLabel: UILabel!
    
    // Notification
    @IBOutlet weak var viewNotification         : UIView!
    @IBOutlet weak var labelNotification        : UILabel!
    @IBOutlet weak var imageViewNotification    : UIImageView!
    
    // Create New Receipt
    @IBOutlet weak var buttonCreateNewReceipt   : UIButton!
    
    // Container View
    @IBOutlet weak var viewTab                  : UIView!
    @IBOutlet weak var viewTapHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewReceiptList : UIView!
    @IBOutlet weak var containerViewNotification: UIView!
    @IBOutlet weak var containerViewBoards      : UIView!
    @IBOutlet weak var viewLine                 : UIView!
    
    @IBOutlet weak var trickView: UIView!
    
    // Top Main tab bar
    @IBOutlet weak var labelMenu                : UILabel!
    @IBOutlet weak var headerButton             : UIButton!
    @IBOutlet weak var headerPersonImage        : UIImageView!
    @IBOutlet weak var topMenuView: UIView!
    @IBOutlet weak var heightTopMenuViewConstaint: NSLayoutConstraint!
    
    //MARK: - Variable
    var maintabVM                  = MainTabBarVM()
    private var responseImage      : MREC_C002.RESPONSE?
    private let maxImages          : Int = 100 // For select image max (select one image)
    private var isOnReceipt        : Bool = false
    private var isOnNotification   : Bool = false
    private(set) var isOnBoards    : Bool = false
    private var documentManager    : DocumentsManager!
    private var isNotificationTap  : Bool = false
    private let imagePicker        = ImagePicker()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkNotify()
        self.setupVC()
        gotoReceipt()
        self.labelMenu.getlocalizedFont()
        
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = UIColor(hexString: "#666666")
     
        MyNotify.send(name: .reloadNotificationVC)
        MyNotify.send(name: .reloadReceiptListVC)
        
        embedBoardsView()
        maintabVM.requestDocNoWithOperationQueue { }
        
        self.imagePicker.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(NotifyKey.SuccessTakePhoto.rawValue),object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isNotificationTap {
            self.buttonCreateNewReceipt.isHidden = true
            self.buttonCreateNewReceipt.setImage(nil, for: .normal)
            isNotificationTap = true
        }else {
            self.buttonCreateNewReceipt.isHidden = false
            self.buttonCreateNewReceipt.setImage(UIImage(named:"tab_create_btn"), for: .normal)
        }
        
        //protection when choose from gallery
        MyNotify.listen(self, selector: #selector(successTakenPhoto(_:)), name: .SuccessTakePhoto)
    }
    
    //MARK: - @IBAction
    @IBAction func didTapOnNotificationGuesture(_ sender: UITapGestureRecognizer) {
        MyDefaults.set(key: .hasReceivedNotification, value: false)
        checkBadgeNotification()
        showAnimation(sender.view!, finished: {
            self.gotoNotification()
        })
    }
    
    
    @IBAction func didTapOnBoardsGesture(_ sender: UITapGestureRecognizer) {
        showAnimation(sender.view!, finished: {
            self.gotoBoards()
        })
        
    }
    
    @IBAction func didTapOnReceiptGuesture(_ sender: UITapGestureRecognizer) {
        showAnimation(sender.view!, finished: {
            self.gotoReceipt()
        })
    }
    
    @IBAction func touchDownAddNewButtonAction(_ sender: UIButton) {
        sender.animateButtonDown()
    }
    
    @IBAction func touchUpOutSideAddNewButtonAction(_ sender: UIButton) {
        sender.animateButtonUp()
    }
    
    @IBAction func didTapAddNewReceiptButtonAction(_ sender: UIButton) {
        sender.animateButtonUp()
        
        if isOnReceipt {
            customOption(type       : .MultipleChoice,
                         image      : "",
                         title      : "register_invoice".localized,
                         message    : "take_a_photo_or_choose_from_gallery".localized,
                         data       : ["take_a_photo".localized, "choose_from_gallery".localized, "attachment_file".localized],
                         selectRowAt: -1,
                         imgStrRec  : ["camera_ico", "gallery_ico", "tap_attachment"]) { [unowned self](index) in
                switch index {
                case 0:
                    self.view.endEditing(true)
                    self.checkCameraPermission()
                    
                case 1  :
                    if #available(iOS 14.0, *) {
                        self.openGallery()
                    } else {
                        // Fallback on earlier versions
                    }
                    
                case 2  : self.openAttachFile()
                default : break
                }
            }
        } else {
            checkType()
        }
    }
    
    @IBAction func didTapProfileButtonAction(_ sender: UIButton) {
        let vc = VC(sbName: "ProfileSB", identifier: "ProfileVC") as! ProfileVC
        presetVC(vc: vc, modalPresentStyle: .overCurrentContext)
    }
    
    
    //MARK: - Private func
    private func tapOnReceipt(_ tap: Bool) {
        containerViewReceiptList.isHidden   = !tap
        
        heightTopMenuViewConstaint.constant = tap ? 65 : 0
        
        buttonCreateNewReceipt.isHidden = isNotificationTap
        
        self.buttonCreateNewReceipt.setImage(UIImage(named:"tab_create_btn"), for: .normal)
        
        imageViewReceipt.image              = UIImage(named: tap ? "ico_stack" : "ico_stack-2")
        labelReceipt.textColor              = tap ? UIColor(hexString: "#0069B9") : UIColor.black
        
        if tap {
            labelMenu.text                      = "receipt".localized
            if isOnReceipt {
                MyNotify.send(name: .reloadReceiptListVC)
            }
            isOnNotification = false
            isOnBoards = false
            isOnReceipt = true
        }

    }
    
    private func tapOnBoards(_ tap: Bool)  {
        containerViewBoards.isHidden   = !tap
        topMenuView.isHidden = tap
        heightTopMenuViewConstaint.constant = tap ? 0 : 65
        
        buttonCreateNewReceipt.isHidden = isNotificationTap
        self.buttonCreateNewReceipt.setImage(UIImage(named:"tab_create_btn"), for: .normal)
        
        if tap {
            boardLabel.text                      = getSecondTabName()
            if isOnBoards {
                MyNotify.send(name: .reloadBoardVC) // reload when click on BoardTab
            }
            isOnNotification = false
            isOnBoards = true
            isOnReceipt = false
        }
        boardImageView.image         = UIImage(named: tap ? "tab_board_focus" : "tab_board_normal")
        boardLabel.textColor         = tap ? UIColor(hexString: "#0069B9") : UIColor.black
    }
    
    private func tapOnNotification(_ tap: Bool) {
        containerViewNotification.isHidden  = !tap
        buttonCreateNewReceipt.isHidden     = tap
        
        isNotificationTap                   = tap
        
        topMenuView.isHidden                = tap
        heightTopMenuViewConstaint.constant = tap ? 0 : 65
        
        imageViewNotification.image         = UIImage(named: tap ? "ico_bell-1" : "ico_bell")
        labelNotification.textColor         = tap ? UIColor(hexString: "#0069B9") : UIColor.black
        
        if tap {
            if isOnNotification {
                MyNotify.send(name: .reloadNotificationVC)
            }
            isOnNotification = true
            isOnBoards = false
            isOnReceipt = false
        }
        
    }
    
    
    private func checkNotify() {
        
        MyNotify.listen(self, selector: #selector(reloadLocalize), name: .reloadLocalize)
        MyNotify.listen(self, selector: #selector(gotoNotification), name: .gotoNotification)
        MyNotify.listen(self, selector: #selector(checkingBadgeCount), name: .checkingBadgeCount)
        
    }
    
    
    @objc func successTakenPhoto(_ notification:Notification) {
        if let img = notification.object as? UIImage {
            self.uploadImageAfterCaptureSucess(normalizeImage: img)
        }
    }
    
    private func setupVC() {
        // Shared.R002_DATA?.USER_NM
        self.headerPersonImage.sd_setImage(with: Shared.R002_DATA?.USER_IMG_URL?.formatFileURL,  completed: { (image, error, SDImageCacheType , url) in
            if error == nil {
                self.headerPersonImage.image  = image
            } else {
                self.headerPersonImage.image  = UIImage(named: "head_employee_ico")
            }
        })
        self.labelReceipt.text      = "receipt".localized
        self.labelReceipt.getlocalizedFont()
        self.labelNotification.text = "notification".localized
        self.labelNotification.getlocalizedFont()
        self.labelMenu.text         = getSecondTabName()
        self.labelMenu.getlocalizedFont()
        self.boardLabel.text        = getSecondTabName()
        self.boardLabel.getlocalizedFont()
        
        self.checkBadgeNotification()
    }
    
    func openAttachFile() {
        
        self.documentManager = DocumentsManager(self)
        self.documentManager.openDocument()
        self.documentManager.isNotFromSubmit = true
        self.documentManager.completionError = { error in
            self.alert(message: error.localizedDescription)
        }
        self.documentManager.completionFileInfo = { files in
            print(files)
        }
        
    }
    
    private func embedBoardsView() {
        let storyboardName = "BoardsWeCmsSB"
        let identifier     = "BoardsWeCmsVC"

        // Instantiate the view controller
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)

        // Embed the view controller into the containerViewBoardsv
        addChild(viewController)
        viewController.view.frame = containerViewBoards.bounds
        containerViewBoards.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
    }
    
    func getSecondTabName() -> String {
        return "approvals".localized
    }

    private func checkType() {
        presentViewController(storyboardName: "RequestApprovalSB", viewControllerIdentifier: "RequestApprovalVC")
    }
    
    // TODO: - Upload Image from gallery
    func didFinishPickImages(images: [UIImage]) {
        
        if images.count != 0 {
            var REC_IN : [MREC_C002.REQUEST.REC] = []
            
            for (i, image) in images.enumerated() {
                if let base64 = convertToBase64(image) {
                    let formatter           = DateFormatter()
                    formatter.dateFormat    = "yyyMMddHHmm"
                    // REC_IN.append(MREC_C002.REQUEST.REC(FILE_NM: "\(formatter.string(from: Date())).jpg", FILE_DATA: base64))
                    
                    REC_IN.append(MREC_C002.REQUEST.REC(FILE_NM: "\(formatter.string(from: Date()))\(i).jpg", FILE_DATA: base64))
                }
            }
            
            // Upload image
            self.uploadImage(body: MREC_C002.REQUEST(REC_IN: REC_IN)) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        MyNotify.send(name:.reloadAfterUploadImage)
                    }
                }
            }
        }
    }
    
    func showPermissionAlert() {
        self.alertYesNo(
            title   : #""WeCMS" Would Like to Access the Camera"#,
            message : "메모 등록시 사진첨부를 위해서 카메라 접근을 승인해야 합니다.",
            nobtn   : "Don't Allow",
            yesbtn  : "ok".localized,
            completion: { (ok) in
                if ok {
                    self.gotoAppSettings()
                }
            })
    }
    //TODO: -Upload image form camera
    func uploadImageAfterCaptureSucess(normalizeImage : UIImage?) {
        
        
        var REC_IN : [MREC_C002.REQUEST.REC] = []
        
        if let base64 = convertToBase64(normalizeImage ?? UIImage()) {
            let formatter           = DateFormatter()
            formatter.dateFormat    = "yyyMMddHHmmssA"
            REC_IN.append(MREC_C002.REQUEST.REC(FILE_NM: "\(formatter.string(from: Date())).jpg", FILE_DATA: base64))
            
            // Upload Image after taking a photo
            self.uploadImage(body: MREC_C002.REQUEST(REC_IN: REC_IN)) {
                // Reload Receipt List After Upload Image Success
                MyNotify.send(name: .reloadAfterUploadImage)
            }
        }
    }
    
    // Fetching API
    private func uploadImage(body: MREC_C002.REQUEST, _ completion: @escaping () -> () = {}) {
        self.maintabVM.uploadImage(body: body) { (error) in
            if error != nil {
                self.customAlert(type       : .CONFIRM_ALERT,
                                 image      : "badge_failed",
                                 title      : "uploaded_fail".localized,
                                 message    : error?.localizedDescription ?? "uploaded_fail_descr".localized,
                                 redTitle   : "",
                                 greyTitle  : "ok".localized) { (_) in
                }
                return
            }
            
            self.responseImage = self.maintabVM.reponseImage
            completion()
        }
    }
    
    //MARK: - @objc func
    @objc func reloadLocalize() {
        self.setupVC()
        gotoReceipt()
    }
    
    @objc func gotoReceipt() {
        self.tapOnReceipt(true)
        self.tapOnNotification(false)
        self.tapOnBoards(false)
    }

    @objc func gotoNotification() {
        self.tapOnReceipt(false)
        self.tapOnBoards(false)
        self.tapOnNotification(true)
    }

    @objc func gotoBoards() {
        self.tapOnReceipt(false)
        self.tapOnNotification(false)
        self.tapOnBoards(true)
    }
    
    @objc func checkingBadgeCount() {
        
        // notificationBadgeCountBtn.isHidden  = !Shared.hasReceivedNewNotification || Shared.badgeCount < 1
        notificationBadgeCountBtn.isHidden  = Shared.badgeCount < 1
        cstWBtnNotificationBadge.constant   = "\(Shared.badgeCount)".count > 2 ? 26 : 18
        notificationBadgeCountBtn.setTitle("\(Shared.badgeCount > 99 ? "99+" : "\(Shared.badgeCount)")", for: .normal)

    }
    func checkBadgeNotification() {
        // notificationBadgeCountBtn.isHidden  = !Shared.hasReceivedNewNotification || Shared.badgeCount < 1
        notificationBadgeCountBtn.isHidden  = Shared.badgeCount < 1

        cstWBtnNotificationBadge.constant   = "\(Shared.badgeCount)".count > 2 ? 26 : 18
        notificationBadgeCountBtn.setTitle("\(Shared.badgeCount > 99 ? "99+" : "\(Shared.badgeCount)")", for: .normal)
    }
    
}

extension MainTabBarVC: ImagePickerSelectDelegate {
    
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage) {
        self.uploadImageAfterCaptureSucess(normalizeImage: image)
        imagePicker.dismiss()
    }
       
    func cancelButtonDidClick(on imagePicker: ImagePicker) {
        imagePicker.dismiss()
    }
    
    private func checkCameraPermission( ) {
        self.checkAllowCameraPermission(completion: { (allow) in
            if allow {
                self.openCameraVC()
            }
            else {
                self.showPermissionAlert()
            }
        })
    }
    
    func openCameraVC(){
        self.imagePicker.showImagePicker(from: self, sourceType: .camera, allowsEditing: false)
    }
}

@available(iOS 14.0, *)
extension MainTabBarVC: PHPickerViewControllerDelegate{
    func openGallery() {

        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5 // 0 means no limit, set to a number for a specific limit
        configuration.filter = .images   // Only select images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        var selectedImages: [UIImage] = []
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter() // Start a task
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let uiImage = image as? UIImage {
                        selectedImages.append(uiImage)
                    }
                    dispatchGroup.leave() // End the task
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if selectedImages.count > 0 {
                self.didFinishPickImages(images: selectedImages)
            }
        }
    }
}


//
//  CommentView.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 16/1/24.
//

import UIKit
import PhotosUI

class TopBarKeyboardView: UIView {
    
    @IBOutlet weak private var addFileButton: UIButton!
    @IBOutlet weak private var addImageButton: UIButton!
    private var responsibleVC       : UIViewController!
    private var documentManager     : DocumentsManager!
    private var fileLimit           : Int = 5
    var delegate                    : TopBarKeyboardDelegate? = nil
    var actionDelegate              : TopBarKeyboardActionDelegate? = nil
    var dataSource                  : TopBarKeyboardDataSource? = nil
    var commentDelegate             : CommentViewDelegate? = nil
    private var imageCount                  = 0
    private var fileCount                   = 0
    private var imageFileCount              = 0
    var isFromEditOrPostArticle     :Bool = false
    
    //MARK: Hide action button preventing for limit user adding media type file
    private var hideActionButton : Bool = false {
        didSet {
            addFileButton.isHidden = hideActionButton
            addImageButton.isHidden = hideActionButton
        }
    }
    
    override func awakeFromNib() {
        /* 
            set ViewController to responsobleVC when it needs to present or PopSheet
            findViewController() is a function to get ViewController UIApplication Window
         */
        responsibleVC = findViewController()
    }
    
    /**
        * use this function to set count image
        * limit adding media type under 5
     **/
    func setCountImage(_ count: Int) {
        self.imageCount = count
        hideActionButton = fileCount + imageCount >= 5
    }
    
    /**
        * use this function to set count file
        * limit adding media type under 5
     **/
    func setCountFile(_ count: Int) {
        self.fileCount = count
        hideActionButton = fileCount + imageCount >= 5
    }
    
    /**
        * use this function to set count file and image
        * limit adding media type under 5
     **/
    func setCountImageFile(_ count: Int) {
        isFromEditOrPostArticle = true
        self.imageFileCount = count
        hideActionButton = count >= 5
    }
    
    func resetCount() {
        self.fileCount = 0
        self.imageCount = 0
        self.hideActionButton = false
    }
    
    //MARK: - Adding file
    @IBAction func addFilePressed(_ sender: UIButton) {
        openAttachFile() { files in
            self.delegate?.addFile(files)
        }
    }

    //MARK: - Adding image
    @IBAction func addImagePressed(_ sender: Any) {
        self.actionDelegate?.didBeginAddImage?()
        if #available(iOS 14.0, *) {
            openGallery()
        } else {
            // Fallback on earlier versions
        }
    }

    //MARK: - Dismiss keyboard
    @IBAction func dismissKeyboardPressed(_ sender: Any) {
        delegate?.dismissKeyboard()
    }
    
    //MARK: - Approve function
    @IBAction func approveButtonPressed(_ sender: Any) {
        commentDelegate?.approve!(commentString: "")
    }
    
    //MARK: - Reject function
    @IBAction func rejectButtonPressed(_ sender: Any) {
        commentDelegate?.reject!(commentString: "")
    }
    
    //MARK: - Open File function
    func openAttachFile(completion: @escaping ([FileModel]) -> ()) {
        let responseVC = dataSource?.setResponsibleVC()
        if let vc = responseVC {
            self.responsibleVC = vc
        }
        actionDelegate?.didBeginAddFile?()
        self.documentManager = DocumentsManager(responsibleVC)
        self.documentManager.openDocument()
        self.documentManager.isNotFromSubmit = false
        self.documentManager.completionError = { error in
            self.responsibleVC.alert(message: error.localizedDescription)
        }
        
        self.documentManager.completionFilesModel = { files in
            self.actionDelegate?.didEndAddFile?()
            completion(files)
        }
    }
}

@available(iOS 14.0, *)
extension TopBarKeyboardView: PHPickerViewControllerDelegate{
    
    //MARK: - Open Gallery function
    func openGallery() {
        var limitImage = fileLimit - imageCount - fileCount   // Check limit file
        if isFromEditOrPostArticle {
            limitImage = fileLimit - imageFileCount
        }
        
        // Get the responsible view controller
        let responseVC = dataSource?.setResponsibleVC()
        if let vc = responseVC {
            self.responsibleVC = vc
        }
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = limitImage
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        // Use a UIViewController reference to present
        responsibleVC?.present(picker, animated: true, completion: nil)
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
                self.actionDelegate?.didEndAddImage?()
                self.delegate?.addImage(selectedImages)
            }
        }
    }
}

// MARK: - TopBarKeyboardDelegate
protocol TopBarKeyboardDelegate {
    func addFile(_ files: [FileModel])
    func addImage(_ images: [UIImage])
    func dismissKeyboard()
}

// MARK: - TopBarKeyboardActionDelegate
@objc protocol TopBarKeyboardActionDelegate {
    @objc optional func didBeginAddFile()
    @objc optional func didEndAddFile()
    @objc optional func didBeginAddImage()
    @objc optional func didEndAddImage()
}

// MARK: - TopBarKeyboardDataSource
protocol TopBarKeyboardDataSource {
    // Get ViewController from any Owner or Screen
    func setResponsibleVC() -> UIViewController
}

//
//  NativeGalleryCamera.swift
//  WABOOKS_iOS_V2
//
//  Created by SteveChea  on 20/1/25.
//

import UIKit
import Photos

// MARK: - ImagePickerDelegate Protocol
protocol ImagePickerSelectDelegate: AnyObject {
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage)
    func cancelButtonDidClick(on imagePicker: ImagePicker)
}

// MARK: - ImagePicker Class
class ImagePicker: NSObject {
    
    // MARK: - Properties
    private weak var controller: UIImagePickerController?
    weak var delegate: ImagePickerSelectDelegate?
    
    // MARK: - Function
    
    // Dismiss the image picker
    func dismiss() {
        controller?.dismiss(animated: true, completion: nil)
    }
    
    // Present the image picker with source type and editing option
    func present(from viewController: UIViewController, sourceType: UIImagePickerController.SourceType, allowsEditing: Bool = false) {
        
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = allowsEditing
        self.controller = imagePickerController
        
        DispatchQueue.main.async {
            viewController.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    
    // Display an alert to choose between camera and photo library
    func showImagePicker(from viewController: UIViewController, sourceType: UIImagePickerController.SourceType, allowsEditing: Bool) {
        if sourceType == .camera{
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.present(from: viewController, sourceType: .camera, allowsEditing: allowsEditing)
            }
        }else{
            self.present(from: viewController, sourceType: .photoLibrary, allowsEditing: allowsEditing)
        }
    }

}

// MARK: - UINavigationControllerDelegate
extension ImagePicker: UINavigationControllerDelegate { }

// MARK: - UIImagePickerControllerDelegate
extension ImagePicker: UIImagePickerControllerDelegate {
    
    // Called when an image is selected or captured
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            delegate?.imagePicker(self, didSelect: editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            delegate?.imagePicker(self, didSelect: originalImage)
        } else {
            print("Image source not recognized")
        }
    }

    // Called when the user cancels the image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.cancelButtonDidClick(on: self)
    }
}

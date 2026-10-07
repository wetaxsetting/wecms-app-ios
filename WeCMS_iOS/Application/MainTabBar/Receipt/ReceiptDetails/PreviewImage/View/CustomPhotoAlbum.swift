//
//  CustomPhotoAlbum.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 19/1/21.
//

import UIKit
import Photos

class CustomPhotoAlbum: NSObject {
    
    private static let albumName        = "WeCMS"
    public  static let sharedInstance   = CustomPhotoAlbum()
    
    private var assetCollection: PHAssetCollection!
    
    override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.createAlbum()
        }
        else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
}

extension CustomPhotoAlbum {
    
    private func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("trying again to create the album")
            self.createAlbum()
        }
        else {
            print("should really prompt the user to let them know it's failed")
        }
    }
    
    private func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)   // create an asset collection with the album name
        }) { success, error in
            if success {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            } else {
                print("error \(String(describing: error))")
            }
        }
    }
    
    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions        = PHFetchOptions()
        fetchOptions.predicate  = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        
        let collection          = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _ : AnyObject = collection.firstObject {
            return collection.firstObject
        }
        
        return nil
    }
    
    public func save(image: UIImage, completion: @escaping (Bool, Error?)->Void) {
        if assetCollection == nil {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest      = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder        = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest      = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray    = [assetPlaceHolder!]
            
            albumChangeRequest!.addAssets(enumeration)
        }) { (status, error) in
            DispatchQueue.main.async {
                completion(status, error)
            }
        }
    }
}
 

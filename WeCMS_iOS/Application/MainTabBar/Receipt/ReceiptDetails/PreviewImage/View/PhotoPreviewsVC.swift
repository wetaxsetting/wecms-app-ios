//
//  PhotoPreviewsVC.swift
//  WeCMS_iOS
//
//  Created by Nheng Vanchhay on 30/8/21.
//

import UIKit

import SDWebImage


protocol IndexImageDelete {
    func getIndexImage(index: [Int], typeOfImage: [Bool])
}

class PhotoPreviewsVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var btnDownload      : UIButton!
    @IBOutlet weak var btnClose         : UIButton!
    @IBOutlet weak var collectionView   : UICollectionView!
    @IBOutlet weak var chiPage          : UIPageControl!
    
    public  var imageUrlArray           : Array<AnyObject>!
    public  var currentIndexImage       : Int? = 0
    private var initialTouchPoint       : CGPoint = CGPoint(x: 0,y: 0)
    
    var panGestureRecognizer            : UIPanGestureRecognizer!
    var imgUrlArr                       = [Any]() //should be img or img url str
    var fistLoadScreen                  = true
    var imageSave                       : UIImage?
    var delegate                        : IndexImageDelete?
    
    var arrIndexImageDelete: [Int]      = []
    var typeOfImageDelete:   [Bool]     = []
    var isBtnDeleteDisable              : Bool = false // for disable btn delete in CustomOptionMultipleChoiceCell
    var imageViewer                     : GSImageViewerController?
    var isFromEditPostArticle           : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fistLoadScreen = true
        if let imageUrlArray = imageUrlArray {
            imgUrlArr = isFromEditPostArticle ? imageUrlArray[0]["RCPT_IMG_URL"] as? [PreviewModel] ?? [] : imageUrlArray[0]["RCPT_IMG_URL"] as? [Any] ?? []
            
        }
        setUpPageControll()
        
        //create animation to collection when dismiss
        panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                      action: #selector(panGestureRecognizerHandler(_:)))
       panGestureRecognizer.delegate = self
       collectionView.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Perform the scroll only after cells are rendered
        if self.fistLoadScreen, let currentIndexImage = self.currentIndexImage {
            DispatchQueue.main.async {
                self.collectionView.performBatchUpdates({
                    // Trigger layout updates
                    self.collectionView.layoutIfNeeded()
                }) { _ in
                    // Now perform the scrolling
                    if currentIndexImage >= 0 && currentIndexImage < self.imgUrlArr.count {
                        self.collectionView.scrollToItem(at: IndexPath(row: currentIndexImage, section: 0), at: .centeredHorizontally, animated: false)
                        print("Scrolled to index \(currentIndexImage) after rendering cells.")
                    } else {
                        print("Error: currentIndexImage (\(currentIndexImage)) is out of bounds!")
                    }
                    self.fistLoadScreen = false
                }
            }
        }
    }


    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith
                        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //loading
    private lazy var activity : UIActivityIndicatorView! = {
        var _activity       = UIActivityIndicatorView.init(style: .medium)
        _activity.color     = .white
        _activity.startAnimating()
        
        let frame           = self.collectionView.frame
        _activity.frame     = CGRect(x: (frame.size.width / 2) - 12.5 , y: (frame.size.height / 2) - 12.5 , width: 25, height: 25)
        
        return _activity
    }()
    
    @IBAction func moreAction(_ sender: Any) {
        
        customOption(type       : .MultipleChoice,
                     data       : ["download".localized, "delete".localized],
                     selectRowAt: -1,
                     imgStrRec  : ["file_download_black_24dp", "head_del_white_ico_2"],
                     isShowHeaderView: false,
                     isBtnDeleteDisable: isBtnDeleteDisable) { (index) in
            switch index {
            case 0  : self.dowloadImage()
            case 1  : if !self.isBtnDeleteDisable {
                self.showPopupDeleteImage {
                    
                    let indexRow  = self.indexOfCell() //current index row before dalete
                    //typeOfImageDelete = true type url = false type UIimage
                    if let _ = self.imgUrlArr[indexRow] as? String {
                        self.arrIndexImageDelete.append(indexRow)
                        self.typeOfImageDelete.append(true)
                    }else {
                        self.typeOfImageDelete.append(false)
                        self.arrIndexImageDelete.append(indexRow)
                    }
                    
                    self.imgUrlArr.remove(at: indexRow)
                    
                    self.collectionView.deleteItems(at: [IndexPath(item: indexRow, section: 0)])
                    self.collectionView.reloadItems(at: [IndexPath(item: indexRow, section: 0)])
                    // Clear cache
                    SDImageCache.shared.clearMemory()
                    SDImageCache.shared.clearDisk()
                    
                    DispatchQueue.main.async {
                        let indexRow  = self.indexOfCell() //current index row after dalete
                        self.chiPage.numberOfPages = self.imgUrlArr.count
                        self.chiPage.currentPage = indexRow
                        self.customToast(image: "toast_success_ico", message: "photo_deleted".localized)
                    }
                    
                    if self.imgUrlArr.count < 1 {
                        self.dimissVC()
                    }
                    
                }
            }

            default : break
            }
        }
    }
    
    func dowloadImage() {
        
        guard let image = self.imageSave else {
            print("Error saving photo... ")
            return
        }
        
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
    
    @IBAction func closeAction(_ sender: Any) {
        dimissVC()
    }
    
    func dimissVC() {
        dismiss(animated: true, completion: {
            print("nottt")
            print(self.arrIndexImageDelete.count)
            print(self.arrIndexImageDelete)
            self.delegate?.getIndexImage(index: self.arrIndexImageDelete, typeOfImage: self.typeOfImageDelete)
        })
    }
    
    func setUpPageControll() {
        chiPage.numberOfPages                   = imgUrlArr.count
        chiPage.pageIndicatorTintColor          = UIColor.white.withAlphaComponent(0.5)
        chiPage.currentPageIndicatorTintColor   = .white
        chiPage.currentPage                     = currentIndexImage ?? 0
    }
    
    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        
        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
            
        case .changed:
            initialTouchPoint = sender.translation(in: collectionView)
                    UICollectionView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        self.collectionView.transform = CGAffineTransform(translationX: 0, y: self.initialTouchPoint.y)
                    })
            btnClose.alpha      = 0.4
            btnDownload.alpha   = 0.4
            
        case .ended, .cancelled:
            if initialTouchPoint.y < 200 {
                UICollectionView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                            self.collectionView.transform = .identity
                        })
                btnClose.alpha      = 1
                btnDownload.alpha   = 1
                    } else {
                        dimissVC()
                    }
            
        default: break
        }
    }
}

extension PhotoPreviewsVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //get current index
    private func indexOfCell() -> Int {
        let itemWidth           = self.collectionView.bounds.width
        let proportionalOffset  = self.collectionView.contentOffset.x / itemWidth
        let index               = Int(round(proportionalOffset))
        let safeIndex           = max(0, min(imgUrlArr.count, index))
        return safeIndex
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexRow            = indexOfCell()
        chiPage.currentPage = indexRow
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //because collection scroll horizontal
        collectionView.removeGestureRecognizer(panGestureRecognizer)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let indexRow            = indexOfCell()
        let cell = collectionView.cellForItem(at: IndexPath(item: indexRow, section: 0)) as! PhotoPreviewsCellCollection
        self.imageSave = cell.imageView.image //get image to save to gallery
        currentIndexImage       = indexRow

    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        collectionView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgUrlArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoPreviewsCellCollection", for: indexPath) as! PhotoPreviewsCellCollection
        var  data = imgUrlArr[indexPath.row]
        
        if isFromEditPostArticle {
            let predata = self.imgUrlArr[indexPath.row] as? PreviewModel
            data = predata?.image ?? ""
        }
        
        if let urlStr = data as? String {
            cell.imageView.addSubview(activity)
            cell.imageView.sd_setImage(with: URL(string: "\(urlStr)")) { image, error, SDImageCacheType, url in
                if error == nil {
                    self.activity.removeFromSuperview()
                    cell.imageView.image = image
                    

                    
                    // scroll to item when first laod screen
                    if self.fistLoadScreen {
                        collectionView.selectItem(at: IndexPath(row: self.currentIndexImage ?? 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
                        self.imageSave = image //pass image to save to gallery
                        self.fistLoadScreen = false
                    }
                }
            }
        }else {
            cell.imageView.image = data as? UIImage
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoPreviewsCellCollection else {
//            return
//        }
//        let imageInfo = GSImageInfo(image: cell.imageView.image!, imageMode: .aspectFit)
//        let tranitionInfo = GSTransitionInfo(fromView: collectionView)
//        imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: tranitionInfo)
//        present(imageViewer!, animated: true, completion: nil)
    }

}

class PhotoPreviewsCellCollection: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView! 
    
    override func awakeFromNib() {
    }
}



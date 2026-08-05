//
//  CarbonNewNotificationVC.swift
//  Bizcard4.0
//
//  Created by kimlang on 8/28/23.
//  Copyright © 2023 KOSIGN. All rights reserved.
//

import UIKit

class CarbonNewNotificationVC: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var contentView      : UIView!
    @IBOutlet weak var collectionView   : UICollectionView!
    @IBOutlet weak var readAllButton    : UIButton!
    @IBOutlet weak var menuLabel        : UILabel!
    
    //MARK: - Properties & Variable
    private var arrViewController   = [[String]]()
    weak var owner                  : NotificationListVC?
    var isSelectedAtIndex           = 0
    var carbonVM                    = CarbonNewNotificationVM()
    private var notificationVM      = NotificationtListVM()
    
    private var pageViewController  : UIPageViewController!
    private var pageVCs             : [UIViewController] = []

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate        = self
        self.collectionView.dataSource      = self
        self.collectionView.indicatorStyle  = .default
        
        self.setUpVC()
        self.setupPageViewController()
        self.setupTabAppearance()
        self.carbonVM.getData()
        self.checkNotify()
    }
    
    //MARK: - Function
    private func setupTabAppearance() {
        self.menuLabel.text = "notification".localized
        self.readAllButton.setTitle("Read_all".localized, for: .normal)
        self.menuLabel.getlocalizedFont()
        self.readAllButton.getlocalizedFont()
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.delegate   = self
        pageViewController.dataSource = self
        
        if let firstVC = pageVCs.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: false)
            owner = firstVC as? NotificationListVC
            owner?.carbonNotiVC = self
        }
        
        addChild(pageViewController)
        contentView.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        pageViewController.didMove(toParent: self)
    }
    
    private func switchToTab(at index: Int, animated: Bool = true) {
        guard index >= 0 && index < pageVCs.count else { return }
        let direction: UIPageViewController.NavigationDirection = index >= isSelectedAtIndex ? .forward : .reverse
        let targetVC = pageVCs[index]
        pageViewController.setViewControllers([targetVC], direction: direction, animated: animated)
        
        let previousIndex = isSelectedAtIndex
        isSelectedAtIndex = index
        owner = targetVC as? NotificationListVC
        owner?.carbonNotiVC = self
        collectionView.reloadData()
        
        if index != previousIndex {
            handleTabChange(index: index)
        }
    }
    
    private func handleTabChange(index: Int) {
        if index == 0 {
            Shared.share.isTapUnread = true
            Shared.share.isClickedReadAll = false
        } else {
            Shared.share.isTapUnread = false
            Shared.share.isClickedReadAll = false
        }
        MyNotify.send(name: .reloadNotificationVC)
        
        if let ownerVC = self.owner {
            ownerVC.page = 1
            ownerVC.isRefresh = true
            ownerVC.isLastRecord = false
            ownerVC.notificationList.removeAll()
            DispatchQueue.global(qos: .userInitiated).async {
                ownerVC.fetchR010(isClickReadAll: false)
            }
        }
    }
    
    @objc func reloadNotification() {
        setupLocalize()
    }
    
    private func setupLocalize() {
        self.menuLabel.text = "notification".localized
        self.readAllButton.setTitle("Read_all".localized, for: .normal)
        self.menuLabel.getlocalizedFont()
        self.readAllButton.getlocalizedFont()
        self.carbonVM.getData()
        self.collectionView.reloadData()
    }
    
    private func checkNotify() {
        MyNotify.listen(self, selector: #selector(reloadNotification), name: .reloadNotificationVC)
    }
    
    private func setUpVC() {
        arrViewController.append(["NotificationSB", "NotificationListVC"]) // unread
        arrViewController.append(["NotificationSB", "NotificationListVC"]) // read
        
        for (index, item) in arrViewController.enumerated() {
            let notiVC = VC(sbName: item[0], identifier: item[1]) as! NotificationListVC
            notiVC.isSelectedAtIndex = index == 0 ? "0" : "1"
            pageVCs.append(notiVC)
        }
    }
    
    @IBAction func readAllNotificationAction(_ sender: UIButton) {
        self.isSelectedAtIndex = 1
        Shared.shouldReload = true
        Shared.share.isClickedReadAll = true
        self.switchToTab(at: 1)
        
        let notificationVM = NotificationtListVM()
        notificationVM.fetchNotification_0007_U001(reqBody: WABOOKS_MREC_BLTB_0007_U001.REQUEST(READ_TYPE: "A", SEQ_NO: nil)) { _ in
            UIApplication.shared.applicationIconBadgeNumber = 0
            Shared.badgeCount = 0
            MyNotify.send(name: .checkingBadgeCount)
            
            if let currentVC = self.pageVCs[self.isSelectedAtIndex] as? NotificationListVC {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    currentVC.notificationList.removeAll()
                    currentVC.page = 1
                    currentVC.isRefresh = true
                    currentVC.isLastRecord = false
                    currentVC.fetchR010(isClickReadAll: true)
                }
            }
        }
    }
}

//MARK: - UIPageViewControllerDataSource
extension CarbonNewNotificationVC: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pageVCs.firstIndex(of: viewController), index > 0 else { return nil }
        return pageVCs[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pageVCs.firstIndex(of: viewController), index < pageVCs.count - 1 else { return nil }
        return pageVCs[index + 1]
    }
}

//MARK: - UIPageViewControllerDelegate
extension CarbonNewNotificationVC: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first,
              let index = pageVCs.firstIndex(of: currentVC) else { return }
        
        let previousIndex = isSelectedAtIndex
        isSelectedAtIndex = index
        owner = currentVC as? NotificationListVC
        owner?.carbonNotiVC = self
        collectionView.reloadData()
        
        if index != previousIndex {
            handleTabChange(index: index)
        }
    }
}

//MARK: Extension CollectionView UICollectionViewDataSource
extension CarbonNewNotificationVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carbonVM.carbonData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonNotiCell", for: indexPath) as! ButtonNotiCell
        
        if isSelectedAtIndex == indexPath.item {
            self.carbonVM.carbonData[indexPath.item].isSelected = true
        } else {
            self.carbonVM.carbonData[indexPath.item].isSelected = false
        }
        cell.configCell(data: self.carbonVM.carbonData[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switchToTab(at: indexPath.item)
    }
}

//MARK: Extension CollectionView UICollectionViewDelegateFlowLayout
extension CarbonNewNotificationVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let labelDesc   = UILabel(frame: CGRect.zero)
        labelDesc.text  = self.carbonVM.carbonData[indexPath.item].titleButton
        labelDesc.sizeToFit()
        return CGSize(width: labelDesc.frame.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let numberOfItems = CGFloat(collectionView.numberOfItems(inSection: section))
        let combinedItemWidth = (numberOfItems * flowLayout.itemSize.width) + ((numberOfItems - 1) * flowLayout.minimumInteritemSpacing)
        let padding = (collectionView.frame.width - combinedItemWidth) / 2
        
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        return UIEdgeInsets(top: 0, left: isIPad ? padding : 0, bottom: 0, right: isIPad ? padding : 0)
    }
}

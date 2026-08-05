//
//  UIViewController.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 5/1/21.
//

import UIKit
import Photos


extension UIViewController {
    
    // Kheang: 17/07/24
    var safeAreaInsets: UIEdgeInsets {
        let window = UIApplication.shared.keyWindowInConnectedScenes
        return window?.safeAreaInsets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    var bottomSafeAreaInset: CGFloat {
        return safeAreaInsets.bottom
    }
      
    func gotoAppSettings() {
        if #available(iOS 10.0, *) {
            DispatchQueue.main.async {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    func gotoPasscodeSettings() {
        if #available(iOS 10.0, *) {
            DispatchQueue.main.async {
                UIApplication.shared.open(URL(string: "App-Prefs:root=TOUCHID_PASSCODE" + Bundle.main.bundleIdentifier!)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    func checkAllowNotificationPermission(completion: @escaping Completion_Bool) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus != .authorized {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
            }
        }
    }
    
    func popOrDismissVC(animated: Bool = true, completion: @escaping Completion = { }) {
        if let nav = self.navigationController {
            nav.popViewController(animated: animated)
            completion()
        }
        else {
            self.dismiss(animated: animated) {
                completion()
            }
        }
    }
    
    func findsViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.keyWindowInConnectedScenes
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    func pushVC(viewController: UIViewController, animated: Bool = true) {
        self.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func navController(sbName: String, identifier: String) -> UINavigationController {
        return UIStoryboard(name: sbName, bundle: nil).instantiateViewController(withIdentifier: identifier) as! UINavigationController
    }
    
    // Important
    func setRootViewController(sbName: String, identifier: String, direction: UIWindow.TransitionOptions.Direction = .fade, duration: TimeInterval = 0.3) {
        let window              = UIApplication.shared.keyWindowInConnectedScenes
        var animateOption       = UIWindow.TransitionOptions()
        animateOption.direction = direction
        animateOption.duration  = duration
        window?.setRootViewController(VC(sbName: sbName, identifier: identifier), options: animateOption)
    }
    
    // Important
    func setRootViewController(viewController: UIViewController, direction: UIWindow.TransitionOptions.Direction = .fade, duration: TimeInterval = 0.3) {
        let window              = UIApplication.shared.keyWindow
        var animateOption       = UIWindow.TransitionOptions()
        animateOption.direction = direction
        animateOption.duration  = duration
        window?.setRootViewController(viewController, options: animateOption)
    }
    
    // Important
    func setRootNavViewController(sbName: String, identifier: String, direction: UIWindow.TransitionOptions.Direction = .fade, duration: TimeInterval = 0.3) {
        let window              = UIApplication.shared.keyWindow
        var animateOption       = UIWindow.TransitionOptions()
        animateOption.direction = direction
        animateOption.duration  = duration
        window?.setRootViewController(navController(sbName: sbName, identifier: identifier), options: animateOption)
    }
    
    // Important
    func setRootNavViewController(navigation: UINavigationController, direction: UIWindow.TransitionOptions.Direction = .fade, duration: TimeInterval = 0.3) {
        let window              = UIApplication.shared.keyWindow
        var animateOption       = UIWindow.TransitionOptions()
        animateOption.direction = direction
        animateOption.duration  = duration
        window?.setRootViewController(navigation, options: animateOption)
    }
    
    func getCGSizeText(st: String, fontSize: CGFloat) -> CGSize {
        let font = UIFont.systemFont(ofSize: fontSize)
        let fontAtrr = [NSAttributedString.Key.font: font]
        let size = (st as NSString).size(withAttributes: fontAtrr)
        return size
    }
    
    /*
     + TODO: Set Left Navigation Item
     - param image : Your image name
     - param action: Selector handle selection when click on left navigation
     - param title : Your title when navigation title is not available
     */
    func setLeftNavigationItem(_ image:String, action:Selector, title:String, width: CGFloat) -> Void {
        guard let image_nav = UIImage(named: image) else { return }

        var config = UIButton.Configuration.plain()
        config.image = image_nav
        config.title = title
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.contentInsets = .zero
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17)
            return outgoing
        }

        let leftNavBtn = UIButton(configuration: config)
        let autoWidth = getCGSizeText(st: title, fontSize: 17).width
        leftNavBtn.frame = CGRect(x: -16, y: 0, width: image_nav.size.width + autoWidth, height: image_nav.size.height)
        leftNavBtn.contentHorizontalAlignment = .leading
        leftNavBtn.addTarget(self, action: action, for: .touchUpInside)

        // leftBarButtonItem
        let leftBarButtonItem = UIBarButtonItem(customView: leftNavBtn)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func VC(sbName: String, identifier: String) -> UIViewController {
        return UIStoryboard(name: sbName, bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    func PopupVC(storyboard: String, identifier: String) -> UIViewController {
        let vc = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: identifier)
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.providesPresentationContextTransitionStyle = true
        vc.definesPresentationContext = true
        
        return vc
    }
    
    @objc public func popVC() {
        self.navigationController?.popViewController(animated: true)
    }
  
    func pushViewController(sbName: String, identifier: String, animated: Bool = true)  {
        let vc = UIStoryboard(name: sbName, bundle: nil).instantiateViewController(withIdentifier: identifier)
        self.navigationController?.pushViewController(vc, animated: animated)
    }
     
    func presetVCWithNavigation(vc: UIViewController, modalPresentStyle: UIModalPresentationStyle = .fullScreen) {
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = modalPresentStyle
        self.present(nav, animated: true, completion: nil)
    }
    
    func presetVC(vc: UIViewController, modalPresentStyle: UIModalPresentationStyle = .fullScreen) {
        vc.modalPresentationStyle = modalPresentStyle
        self.present(vc, animated: true, completion: nil)
    }
    
    func setNavigationBarStyle(isHidden: Bool,
                               animated: Bool,
                               title: String?,
                               leftBarButtonImage: String = "",
                               titleColor: UIColor = UIColor(hexString: "494949"),
                               barTintColor: UIColor = .white,
                               tintColor: String = "#494949",
                               leftSelector: Selector? = nil
    ) {
        
        if #available(iOS 13.0, *) {
            
//            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
            
            self.navigationController?.navigationBar.standardAppearance.shadowColor = .clear
            self.navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor, NSAttributedString.Key.font : UIFont(descriptor: UIFontDescriptor(name: "Inter-Bold", size: 15), size: 15)]
            
            // For custom TextAttributes
            // When tableview scroll to the top, it change from custom font to default sytem Font.
            // Use this line to prevent this problem from getting default system font.
            self.navigationController?.navigationBar.standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor, NSAttributedString.Key.font : UIFont(descriptor: UIFontDescriptor(name: "Inter-Bold", size: 15), size: 15)]
            
            self.navigationController?.navigationBar.standardAppearance.backgroundColor = barTintColor
            
//            let backItem = UIBarButtonItem()
//            backItem.image = UIImage(named: leftBarButtonImage)
//            navigationItem.leftBarButtonItem = backItem

            let leftButton = UIButton(type: .custom)
            leftButton.contentHorizontalAlignment = .left
            leftButton.frame = CGRect(x: 0, y: 0, width: 50, height: 33)
            leftButton.setImage(UIImage(named: leftBarButtonImage), for: .normal)
            leftButton.setTitleColor(UIColor.black, for: .normal)
            
            // Use back system as default if leftSelector not set
            if let selector = leftSelector {
                leftButton.addTarget(self, action: selector, for: .touchUpInside)
                
                let leftBarButton = UIBarButtonItem(customView: leftButton)
                self.navigationItem.leftBarButtonItem = leftBarButton
                
            }
            
            // Set background color of ScrollEdgebackground
            self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = barTintColor
            self.navigationController?.navigationBar.standardAppearance.shadowImage = UIImage()
        } else {
            // Fallback on earlier versions
        }
        
        // Navigation bar title
        self.navigationItem.title = title
        
        // Navigation bar style
        self.navigationController?.navigationBar.isHidden = isHidden
        
        // Default navigation bar is White
        self.navigationController?.navigationBar.barTintColor = barTintColor

        // Default navigation bar title color is "747474" and Font AppleSDGothicNeo-Medium
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor, NSAttributedString.Key.font : UIFont(descriptor: UIFontDescriptor(name: "Inter-Bold", size: 15), size: 15)]
        
        // Default navigation back button is empty
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        // Default navigation back button color is "747474"
        self.navigationController?.navigationBar.tintColor = UIColor(hexString: tintColor)
        
    }
     
    func alert(title: String, message: String, completion: @escaping Completion = { }) {
        if let jsonData = message.data(using: String.Encoding.utf8) {
            do {
                try JSONSerialization.jsonObject(with: jsonData)
                alertJsonError(title: title, message: message)
            }
            catch {
                let alert   = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let ok      = UIAlertAction(title: "OK".capitalized, style: .cancel) { (_) in
                    completion()
                }
                alert.addAction(ok)
                
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
//    func alertError(message: String) {
//        self.customAlert(type       : .CONFIRM_ALERT,
//                         image      : "badge_failed",
//                         title      : "notice".localized,
//                         message    : message,
//                         redTitle   : "",
//                         greyTitle  : "close".localized) { (_) in
//        }
//    }
    
    private func alertJsonError(title: String, message: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        
        let messageText = NSMutableAttributedString(
            string: message,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),
                NSAttributedString.Key.foregroundColor : UIColor.black
            ]
        )
        
        let alert   = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok      = UIAlertAction(title: "OK".capitalized, style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.setValue(messageText, forKey: "attributedMessage")
        
        present(alert, animated: true, completion: nil)
    }
    
    func alertYesNo(title: String, message: String, nobtn: String = "NO".capitalized, yesbtn: String = "YES".capitalized
                    , completion: @escaping Completion_Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: yesbtn, style: .default, handler: { (action) -> Void in
                completion(true)
            })
        )
        alert.addAction(
            UIAlertAction(title: nobtn, style: .cancel)
        )
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertError(message: String) {
        self.customAlert(type       : .CONFIRM_ALERT,
                         image      : "badge_failed",
                         title      : "notice".localized,
                         message    : message,
                         redTitle   : "",
                         greyTitle  : "close".localized) { (_) in
        }
    }
      
    func alert(title: String = "notice".localized, message: String, okbtn: String = "comfirm".localized, completion: @escaping Completion = { }) {
        if let jsonData = message.data(using: String.Encoding.utf8) {
            do {
                try JSONSerialization.jsonObject(with: jsonData)
                alertJsonError(title: title, message: message)
            }
            catch {
                let alert   = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let ok      = UIAlertAction(title: okbtn, style: .cancel) { (_) in
                    completion()
                }
                alert.addAction(ok)
                
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    /**
     Authorize status only
     Attachment
     */

    func checkAllowPhotoPermission(completion: @escaping Completion_Bool) {
        if (PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized) {
            DispatchQueue.main.async {
                completion(true)
            }
        }
        else if (PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.notDetermined) {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            })
        }
        else {
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
    
    func checkAllowCameraPermission(completion: @escaping Completion_Bool) {
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) -> Void in
                DispatchQueue.main.async {
                    completion(granted)
                }
            })
        }
        else {
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    func openCamera(cameraBlock:(()->Void)?) {
       // let MESSAGE_CAMERA      = "unable_to_take_a_photo".localized
        
        if(UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            self.checkAllowCameraPermission { (status) in
                if status {
                    cameraBlock?()
                }
                else {
//                    self.alertYesNo(title: "", message: "MESSAGE_CAMERA", nobtn: "close".localized, yesbtn: "confirm".localized) { (yes) in
//                        if yes {
//                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//                        }
//                    }
                }
            }
            
        }
    }
    
    func openAlbum(albumBlock:(()->Void)?) {
        self.checkAllowPhotoPermission { (status) in
            if status {
                albumBlock?()
            }
            else {
//                self.alertYesNo(title: "", message: "MESSAGE_PHOTO_ALBUM", nobtn: "close".localized, yesbtn: "confirm".localized) { (yes) in
//                    if yes {
//                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//                    }
//                }
            }
        }
    }
    
    func checkDeniedCameraPermission(completion: @escaping Completion_Bool) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            DispatchQueue.main.async {
                completion(true)
            }
        }
        else {
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
     
    func checkDeniedPhotoPermission(completion: @escaping Completion_Bool) {
        if (PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.denied) {
            DispatchQueue.main.async {
                completion(true)
            }
        }
        else {
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
    
    func presentViewController<T: UIViewController>(storyboardName: String, viewControllerIdentifier: String, configure: ((T) -> Void)? = nil) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? T else {
            print("Failed to instantiate view controller with identifier: \(viewControllerIdentifier)")
            return
        }
        
        configure?(vc)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
       
}

extension UIViewController {
    func callCommonPopup(withStorybordName storyboard: String, identifier: String) -> UIViewController {
        let vc = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: identifier)
        vc.modalPresentationStyle                       = .overFullScreen
        vc.modalTransitionStyle                         = .crossDissolve
        vc.providesPresentationContextTransitionStyle   = true
        vc.definesPresentationContext                   = true
        return vc
    }
    
    func showToast(image: String, message: String) {
        //create view
        let myView = UIView()
        myView.frame = CGRect(x: 20,
                              y: -65 ,
                              width: self.view.bounds.width - 40, height: 54)
        myView.cornerRadius = 5
        myView.backgroundColor = UIColor(hexString: "49535B")
        
        //create image
        let imageView = UIImageView(frame: CGRect(x: 15, y: myView.bounds.midY - (24 / 2), width: 24, height: 24))
        imageView.image = UIImage(named: image)
        myView.addSubview(imageView)
        
        //create label
        let toastLabel = UILabel(frame: CGRect(x: 49, y: myView.bounds.midY - (myView.bounds.height / 2), width: myView.bounds.width, height: myView.bounds.height))
        toastLabel.textColor = .white
        toastLabel.textAlignment = .left
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        
        myView.addSubview(toastLabel)
        self.view.addSubview(myView)
        
        // Finally the animation!
        let offset = CGPoint(x: 0, y: -self.view.frame.maxY)
        let x: CGFloat = 0, y: CGFloat = 0
        myView.transform = CGAffineTransform(translationX: offset.x + x, y: offset.y + y + 500)
        myView.isHidden = false
        
        //view come in
        UIView.animate(
            withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.80, initialSpringVelocity: 3,
            options: .curveEaseOut, animations: {
                myView.transform = .identity
                myView.alpha = 1
            })
        
        //view come out
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(
                withDuration: 5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 3,
                options: .curveEaseIn, animations: {
                    myView.center.y -= myView.bounds.height + 100
                },  completion: {(_ completed: Bool) -> Void in
                    myView.removeFromSuperview()
                })
        }
    }
    
    func showCustomAlert(imgStr: String = "badge_failed", titlte: String, message: String, greyBtn: String = "comfirm".localized, completion: @escaping Completion) {
        self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: title ?? "", message: message, redTitle: "", greyTitle: greyBtn) { (isRedPress) in
            completion()
        }
    }
    
    func sheetController( _ StoryBoard: String, identifier: String, Size: Int) {
        let vc = self.callCommonPopup(withStorybordName: StoryBoard, identifier: identifier)
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.medium(), .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = false
        }
        self.present(vc, animated: true, completion: nil)
    }
}

extension UINavigationController {
    func hairLine(hide: Bool) {
        //hides hairline at the bottom of the navigationbar
        
        for subview in self.navigationBar.subviews {
            if subview.isKind(of: UIImageView.self) {
                for hairline in subview.subviews {
                    if hairline.isKind(of: UIImageView.self) && hairline.bounds.height <= 1.0 {
                        hairline.isHidden = hide
                    }
                }
            }
        }
    }
}

extension UIViewController {
    func getRandomImageName() -> String {
        
        // get the current date and time
        let currentDateTime = Date()

        // get the user's calendar
        let userCalendar = Calendar.current

        // choose which date and time components are needed
        let requestedComponents: Set<Calendar.Component> = [
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second
        ]

        // get the components
        let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: currentDateTime)
        // now the components are available
        let year = dateTimeComponents.year  // 2016
        let month = dateTimeComponents.month  // 10
        let day = dateTimeComponents.day    // 8
        let hour = dateTimeComponents.hour   // 22
        let minute = dateTimeComponents.minute // 42
        let second = dateTimeComponents.second // 17
        
        return "IMG\(day ?? 01)\(month ?? 01)\(year ?? 2024)\(hour ?? 00)\(minute ?? 00)\(second ?? 00).JPG"
    }
}


// Navy : 24 Jan 2024, Custom Attributed String to TextView
extension UIViewController {
    
    
    // MARK: - REGEX AS STRING
    func regexMatchesToString(_ pattern: String, string: String) throws -> [String]? {
        
        // ============= ⚠️ DON'T TOUCH THIS ⚠️ ===============
        
        var formattedPattern = pattern
        if pattern.contains("(") || pattern.contains(")") {
            // if the pattern contains parenthese "(" or ")", the regex will skip this special character and cannot find the match word
            // the pattern to detect the word that contain parenthese is "\\( \(YOUR PATTERN) \\)" ->
            // Example: to match "Asnavy (C++)" you need to format it to "Asnavy \\(C++)\\"
            formattedPattern = pattern.replacingOccurrences(of: "(", with: "\\(").replacingOccurrences(of: ")", with: "\\)")
        }
        
        let regex = try NSRegularExpression(pattern: formattedPattern)
        let range = NSRange(string.startIndex..<string.endIndex, in: string)
        let results = regex.matches(in: string, options: [], range: range)
        
        let allMatches =  results.map {
            String(string[Range($0.range, in: string)!])
        }
        
        // reduce loop of reduntdancy pattern, we need to remove redundancy
        let uniquedArray = Array(Set(allMatches))
        return uniquedArray
    }
    

    // MARK: - REGEX AS NSTextCheckingResult AND LOCATION
    func regexMatches(_ pattern: String, string: String) throws -> [NSTextCheckingResult]? {
        
        // ============= ⚠️ DON'T TOUCH THIS ⚠️ ===============
        
        var formattedPattern = pattern
        if pattern.contains("(") || pattern.contains(")") {
            
            // ***************** SPECIAL CASE *****************
            // if the pattern contains parenthese "(" or ")", the regex will skip this special character and cannot find the match word
            // the pattern to detect the word that contain parenthese is "\\( \(YOUR PATTERN) \\)" -> Example: to match "Asnavy (C++)" you need to format it to "Asnavy \\(C++)\\"
            
            formattedPattern = pattern.replacingOccurrences(of: "(", with: "\\(").replacingOccurrences(of: ")", with: "\\)")
        }
        let regex = try NSRegularExpression(pattern: formattedPattern)
        let range = NSRange(string.startIndex..<string.endIndex, in: string)
        let regexResult = regex.matches(in: string, options: [], range: range)
        return regexResult
    }
    
    
    
    func setAttributeTextView(textView: UITextView, textsTobeAttributed: [String], defaultFont: UIFont?, defaultColor: UIColor, attributedFont: UIFont?, atrributedColor: UIColor) {
        
        textView.textColor   = defaultColor
        
        let fullContent      = textView.text ?? ""
        let attributedString = NSMutableAttributedString(string: fullContent)
        
        for txt in textsTobeAttributed {
            
            if let stringMatches1 = try? regexMatchesToString(txt, string: fullContent) {
                
                for triggerString in stringMatches1 {
                    
                    if triggerString == (txt) {
                        
                        let matches2 = try? regexMatches(txt, string: fullContent)
                        
                        if let matches = matches2 {
                            
                            for match in matches {
                                attributedString.addAttribute(NSAttributedString.Key.font, value: defaultFont as Any, range: match.range)
                                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: atrributedColor, range: match.range)
                                textView.attributedText = attributedString
                                textView.font = defaultFont
                            }
                        }
                    }
                }
            }
        }
        
    }
    

}

// Kheang : 03 Feb 2024, Display or Hide Add Float Button and TabBar
extension UIViewController {

    private func findMainTabBarVC() -> MainTabBarVC? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let nav = window.rootViewController as? UINavigationController else {
            return nil
        }
        return nav.viewControllers.first as? MainTabBarVC
    }

    func displayAddFloatButton(_ display: Bool) {
        guard let mainTabBarVC = findMainTabBarVC() else { return }
        mainTabBarVC.buttonCreateNewReceipt.isHidden = !display
    }

    func displayTabBar(_ display: Bool) {
        guard let mainTabBarVC = findMainTabBarVC() else { return }
        mainTabBarVC.viewTab.isHidden = !display
        mainTabBarVC.trickView.isHidden = !display
        mainTabBarVC.viewTapHeightConstraint.constant = display ? 60 : 0
        mainTabBarVC.viewTab.layoutIfNeeded()
    }

    func getVC() -> UIViewController? {
        guard let mainTabBarVC = findMainTabBarVC() else { return nil }
        return mainTabBarVC.children.last
    }

}



// Navy: 29 Jan 2024 -> Formatted mentioned member for display - For Use in VC
extension UIViewController {
    func formatMentionFromAPISyntaxToReadable(originalText: String) -> (String, [String], [String]) {
    
        var fullUserInfoArr     : [String] = [] // @[Asnavy Husein](asnavy619@gmail.com)
        var usernameArr         : [String] = [] // Asnavy Husein
        var formattedString     = originalText  // string to be replaced from "@[Asnavy Husein](asnavy619@gmail)" by "Asnavy Husein"
        let allUserArraySplit   = originalText.components(separatedBy: "@[") // Split to get each member that has been mentioned

        for user in allUserArraySplit {
            
            // usr : each user has been mentioned
            if user != "" && user.contains("]("){
                
                // get username
                var newStringComponentArray = [""]
                for index in (0...(user.count)) {
                    let str = "\(user)"
                    let stringArray = Array(str)
                    if stringArray.count > index {
                        if stringArray[index] == "]" {
                            break
                        } else {
                            newStringComponentArray.append(String(stringArray[index]))
                        }
                    }
                }
                
                let username = newStringComponentArray.joined(separator: "")
                print("username: ", username)
                usernameArr.append(username)
                
                
                // get full user info
                var newStringComponentArray2 = [""]
                for index in (0...(user.count )) {
                    
                    let str = "\(user)"
                    let stringArray = Array(str)
                    
                    if stringArray.count > index {
                        if (stringArray[index] == ")" && stringArray[index - 1] == "m") ||
                            (stringArray[index] == ")" && stringArray[index - 1] == "h") ||
                            (stringArray[index] == ")" && stringArray[index - 1] == "g") ||
                            (stringArray[index] == ")" && stringArray[index - 1] == "c") ||
                            (stringArray[index] == ")" && stringArray[index - 1] == "t") {
                            break
                        } else {
                            newStringComponentArray2.append(String(stringArray[index]))
                        }
                    }
                }
                let fullUserInfo =  "@[" + "\(newStringComponentArray2.joined(separator: ""))" + ")"
                #if DEBUG
                print("full user info: ", fullUserInfo)
                #endif
                fullUserInfoArr.append(fullUserInfo)
                formattedString = formattedString.replace(of: fullUserInfo, with: username)
            }
        }
        
        let cleanFullUserInfo = Array(Set(fullUserInfoArr))
        
        return (formattedString, usernameArr, cleanFullUserInfo)
    }
    
    
    // Navy: 29 Jan 2024 -> Formatted mentioned member for display - For Use in VC
    func formatMentionFromReadableToAPISyntax(originalText: String, mentionedMembers: [MentionMemberUIModel]) -> String {
        
        // ****************************** NOTE *************************************
        // if we have 2 user in one string exampel : "I would like to inform that Sokny Ran & Sokny Ran (Yakuza) are not the same"
        // if we replace directly of username by email, it would be => "I would like to inform that (soknyran@gmail.com) & (soknyran@gmail.com) (Yakuza) are not the same"
        // so, there is no place to replace sokyranyakuza@gmail.com,
        // now, we need to replace the spaces of each username by a unique keyword for their own, I choose "#QCHLXP#" for 2 phrase username, and "$XC1C3F$" for 3 Digit username
        
        
        
        
        let sortedMembers = mentionedMembers.sorted {$0.name.count > $1.name.count}
        
        
        // ➡️ add unique key into spaces
        var modifiedMembers : [MentionMemberUIModel] = []
        for obj in sortedMembers {
            
            let split = obj.name.components(separatedBy: " ")
            if split.count == 1 {
                let  modified = MentionMemberUIModel(name: obj.name + "#AFCHLZA#", email: obj.email, photo: obj.photo, USER_IMG: obj.USER_IMG)
                modifiedMembers.append(modified)
            } else if split.count == 2 {
                let  modified = MentionMemberUIModel(name: obj.name.replace(of: " ", with: "#QCHLXP#"), email: obj.email, photo: obj.photo, USER_IMG: obj.USER_IMG)
                modifiedMembers.append(modified)
            } else {
                let  modified = MentionMemberUIModel(name: obj.name.replace(of: " ", with: "$XC1C3F$"), email: obj.email, photo: obj.photo, USER_IMG: obj.USER_IMG)
                modifiedMembers.append(modified)
            }
        }
        
        // ➡️ replace confused username with it's own unique key
        var modifiedString = originalText
        for obj in sortedMembers {
            for modified in modifiedMembers {
                if obj.email == modified.email {
                    modifiedString = modifiedString.replace(of: obj.name, with: modified.name)
                }
            }
        }
        
        // ➡️ replace the unique key by original text
        var formattedString = modifiedString
        for (i, obj) in modifiedMembers.enumerated() {
            formattedString = formattedString.replace(of: obj.name, with: sortedMembers[i].email)
        }
#if DEBUG
        print("Formatted String : ", formattedString)
#endif
        return formattedString
    }
    
}

//Kheang: 12 Mar 2024
extension UIViewController {
    func swipeNavigationBack() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate  = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension UIViewController {
    func isValidFileExtension(_ fileExtension: String) -> Bool {
        let validFileExtensions = ["pdf", "ppt", "pptx", "xls", "xlsx", "doc", "docx", "key"]
        return validFileExtensions.contains(fileExtension.lowercased())
    }
    
    func alertPromptMessage(
        title: String?,
        message: String?,
        topButtonTitle: String?,
        centerButtonTitle: String?,
        bottomButtonTitle: String?,

        topButtonCompletion: (() -> Void)? = nil,
        centerButtonCompletion: (() -> Void)? = nil,
        bottomButtonCompletion: (() -> Void)? = nil
    ) {
        let alertServerPopup = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let topButtonAction = UIAlertAction(title: topButtonTitle, style: .default) { _ in
            topButtonCompletion?()
        }
        alertServerPopup.addAction(topButtonAction)
        
        let centerButtonAction = UIAlertAction(title: centerButtonTitle, style: .default) { _ in
            centerButtonCompletion?()
        }
        alertServerPopup.addAction(centerButtonAction)
        
        let bottomButtonAction = UIAlertAction(title: bottomButtonTitle, style: .default) { _ in
            bottomButtonCompletion?()
        }
        alertServerPopup.addAction(bottomButtonAction)
        
        present(alertServerPopup, animated: true, completion: nil)
    }
}


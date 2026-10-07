//
//  UIView.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 5/1/21.
//

import UIKit

@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class DesignableButton: UIButton {
}

@IBDesignable
class DesignableLabel: UILabel {
}

@IBDesignable
class DesignableImageView: UIImageView {
}

enum ViewBorder: String {
    case left, right, top, bottom
}

extension UIView {
    
    func add(border: ViewBorder, color: UIColor, width: CGFloat) {
        let borderLayer = CALayer()
        borderLayer.backgroundColor = color.cgColor
        borderLayer.name = border.rawValue
        switch border {
        case .left:
            borderLayer.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        case .right:
            borderLayer.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        case .top:
            borderLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        case .bottom:
            borderLayer.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        }
        self.layer.addSublayer(borderLayer)
    }
    
    func remove(border: ViewBorder) {
        guard let sublayers = self.layer.sublayers else { return }
        var layerForRemove: CALayer?
        for layer in sublayers {
            if layer.name == border.rawValue {
                layerForRemove = layer
            }
        }
        if let layer = layerForRemove {
            layer.removeFromSuperlayer()
        }
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
}

extension UIView {
    
    func bound() {
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 0.1,
            options: UIView.AnimationOptions.beginFromCurrentState,
            animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
    }
    
    func gone() {
        self.isHidden = true
    }
    
    func visible() {
        self.isHidden = false
    }
    
    var isGone: Bool {
        return self.isHidden == true
    }
    
    var isVisible: Bool {
        return self.isHidden == false
    }
    
    @IBInspectable
    var circular: Bool {
        get {
            return false
        }
        set {
            layer.cornerRadius = min(bounds.width, bounds.height) / 2
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var cornerAllRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            if #available(iOS 11.0, *) {
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBInspectable
    var cornerTopRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            if #available(iOS 11.0, *) {
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBInspectable
    var cornerBottomRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            if #available(iOS 11.0, *) {
                layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBInspectable
    var cornerLeftRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            if #available(iOS 11.0, *) {
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBInspectable
    var cornerRightRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            if #available(iOS 11.0, *) {
                layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    @IBInspectable
    /// Corner radius of view; also inspectable from Storyboard.
    public var maskToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
}


// HRToast
let HRToastDefaultDuration  =   3.0
let HRToastFadeDuration     =   0.3
let HRToastHorizontalMargin : CGFloat  =   17.0
let HRToastVerticalMargin   : CGFloat  =   17.0

let HRToastPositionDefault  =   "bottom"
let HRToastPositionTop      =   "top"
let HRToastPositionCenter   =   "center"

// activity
let HRToastActivityPositionDefault    = "center"

// image size
let HRToastImageViewWidth :  CGFloat  = 80.0
let HRToastImageViewHeight:  CGFloat  = 80.0

// label setting
let HRToastMaxWidth       :  CGFloat  = 1.0       // 80% of parent view width
let HRToastMaxHeight      :  CGFloat  = 0.8
let HRToastFontSize       :  CGFloat  = 16.0
let HRToastMaxTitleLines              = 0
let HRToastMaxMessageLines            = 0

// shadow appearance
let HRToastShadowOpacity  : CGFloat   = 0.8
let HRToastShadowRadius   : CGFloat   = 0.0
let HRToastShadowOffset   : CGSize    = CGSize(width: CGFloat(4.0), height: CGFloat(4.0))

let HRToastOpacity        : CGFloat   = 0.9
let HRToastCornerRadius   : CGFloat   = 0.0

var HRToastActivityView: UnsafePointer<UIView>?  =   nil
var HRToastTimer: UnsafePointer<Timer>?          =   nil
var HRToastView : UnsafePointer<UIView>?         =   nil


// Color Scheme
let HRAppColor:UIColor = UIColor.init(hexString: "2f3030")

let HRToastHidesOnTap       =   true
let HRToastDisplayShadow    =   false

extension UIView {
    
    /** Gets the height constraint if found.
     
    Example Usage for changing height property of a label :
     
    ```
    label.heightConstraint?.constant = 10
     
    // Animate if needed
    UIView.animateWithDuration(0.3, animations:layoutIfNeeded)
    ```
    - Returns: The height NSLayoutConstraint if found.
    */
    var heightConstraint: NSLayoutConstraint? {
        return constraintForView(self, attribute: .height)
    }
    
    func constraintForView(_ v: UIView, attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        
        func lookForConstraint(in view: UIView?) -> NSLayoutConstraint? {
            guard let constraints = view?.constraints else {
                return nil
            }
            for c in constraints {
                if let fi = c.firstItem as? NSObject, fi == v && c.firstAttribute == attribute {
                    return c
                } else if let si = c.secondItem as? NSObject, si == v && c.secondAttribute == attribute {
                    return c
                }
            }
            return nil
        }
        
        // Width and height constraints added via widthAnchor/heightAnchors are
        // added on the view itself.
        if (attribute == .width || attribute == .height) {
            return lookForConstraint(in: v.superview) ?? lookForConstraint(in: v)
        }
        
        // Look for constraint on superview.
        return lookForConstraint(in: v.superview)
    }
    
    public func dashStyle() {
        self.layer.layoutIfNeeded()
        let shapeLayer = CAShapeLayer()
        let selfBounds = self.frame.size
        
        let newBounds = CGRect(x: 0, y: 0, width: selfBounds.width, height: selfBounds.height)
        
        
        shapeLayer.name = "dash"
        shapeLayer.position = CGPoint(x: selfBounds.width / 2, y: selfBounds.height / 2)
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor =  UIColor.gray.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [4, 2]
        self.layer.addSublayer(shapeLayer)
        shapeLayer.bounds = newBounds
        shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: newBounds.width, height: newBounds.height), cornerRadius: self.cornerRadius).cgPath
    }
    
    public func underline(forColor: UIColor) {
        let border = CALayer()
        let underlineHeight: CGFloat = 1.0
        
        border.borderColor = forColor.cgColor
        let selfSize = self.frame.size
        border.frame = CGRect(x: 0, y: selfSize.height - underlineHeight, width: selfSize.width, height: selfSize.height)
        
        border.borderWidth = underlineHeight
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func makeToast(message msg: String, duration: Double, position: AnyObject) {
        let toast = self.viewForMessage(msg, title: nil, image: nil)
        self.showToast(toast: toast!, duration: duration, position: position)
    }
    
    func showToast(toast: UIView, duration: Double, position: AnyObject) {
        let existToast = objc_getAssociatedObject(self, &HRToastView) as! UIView?
        if existToast != nil {
            if let timer: Timer = objc_getAssociatedObject(existToast!, &HRToastTimer) as? Timer {
                timer.invalidate()
            }
            self.hideToast(toast: existToast!, force: false);
        }
        
        toast.center = self.centerPointForPosition(position, toast: toast)
        toast.alpha  = 0.0
        
        if HRToastHidesOnTap {
            let tapRecognizer = UITapGestureRecognizer(target: toast, action: #selector(UIView.handleToastTapped(_:)))
            toast.addGestureRecognizer(tapRecognizer)
            toast.isUserInteractionEnabled  = true
            toast.isExclusiveTouch          = true
        }
        
        self.addSubview(toast)
        objc_setAssociatedObject(self, &HRToastView, toast, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        
        UIView.animate(withDuration : HRToastFadeDuration,
                       delay        : 0.0,
                       options      : ([.curveEaseOut, .allowUserInteraction]),
                       animations   : {
            toast.alpha = 1.0
        },
                       completion   : { (finished: Bool) in
            let timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(UIView.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
            objc_setAssociatedObject(toast, &HRToastTimer, timer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        })
    }
    
    @objc func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
        self.hideToast(toast: recognizer.view!)
    }
    
    @objc func toastTimerDidFinish(_ timer: Timer) {
        self.hideToast(toast: timer.userInfo as! UIView)
    }
    
    func hideToast(toast: UIView) {
        self.isUserInteractionEnabled = true
        self.hideToast(toast: toast, force: false);
    }
    
    func centerPointForPosition(_ position: AnyObject, toast: UIView) -> CGPoint {
        if position is String {
            let toastSize = toast.bounds.size
            let viewSize  = self.bounds.size
            if position.lowercased == HRToastPositionTop {
                return CGPoint(x: viewSize.width/2, y: toastSize.height/2 + HRToastVerticalMargin)
            } else if position.lowercased == HRToastPositionDefault {
                return CGPoint(x: viewSize.width/2, y: viewSize.height - toastSize.height/2)
            } else if position.lowercased == HRToastPositionCenter {
                return CGPoint(x: viewSize.width/2, y: viewSize.height/2)
            }
        } else if position is NSValue {
            return position.cgPointValue
        }
#if DEBUG
        print("Warning: Invalid position for toast.")
#endif
        return self.centerPointForPosition(HRToastPositionDefault as AnyObject, toast: toast)
    }
    
    func hideToast(toast: UIView, force: Bool) {
        let completeClosure = { (finish: Bool) -> () in
            toast.removeFromSuperview()
            objc_setAssociatedObject(self, &HRToastTimer, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        if force {
            completeClosure(true)
        } else {
            UIView.animate(withDuration: HRToastFadeDuration,
                           delay: 0.0,
                           options: ([.curveEaseIn, .beginFromCurrentState]),
                           animations: {
                toast.alpha = 0.0
            },
                           completion:completeClosure)
        }
    }
    
    func viewForMessage(_ msg: String?, title: String?, image: UIImage?) -> UIView? {
        if msg == nil && title == nil && image == nil { return nil }
        
        var msgLabel: UILabel?
        var titleLabel: UILabel?
        var imageView: UIImageView?
        
        let wrapperView = UIView()
        wrapperView.autoresizingMask = ([.flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin])
        wrapperView.layer.cornerRadius = HRToastCornerRadius
        wrapperView.backgroundColor = UIColor.black.withAlphaComponent(HRToastOpacity)
        
        if HRToastDisplayShadow {
            wrapperView.layer.shadowColor = UIColor.black.cgColor
            wrapperView.layer.shadowOpacity = Float(HRToastShadowOpacity)
            wrapperView.layer.shadowRadius = HRToastShadowRadius
            wrapperView.layer.shadowOffset = HRToastShadowOffset
        }
        
        if image != nil {
            imageView = UIImageView(image: image)
            imageView!.contentMode = .scaleAspectFit
            imageView!.frame = CGRect(x: 18.0, y: HRToastVerticalMargin, width: CGFloat(HRToastImageViewWidth), height: CGFloat(HRToastImageViewHeight))
        }
        
        var imageWidth: CGFloat, imageHeight: CGFloat, _ : CGFloat
        if imageView != nil {
            imageWidth = imageView!.bounds.size.width
            imageHeight = imageView!.bounds.size.height
            //      imageLeft = HRToastHorizontalMargin
        } else {
            imageWidth  = 18.0; imageHeight = 0.0
        }
        
        if title != nil {
            titleLabel = UILabel()
            titleLabel!.numberOfLines = HRToastMaxTitleLines
            titleLabel!.font = UIFont.boldSystemFont(ofSize: HRToastFontSize)
            titleLabel!.textAlignment = .center
            titleLabel!.lineBreakMode = .byWordWrapping
            titleLabel!.textColor = UIColor.white
            titleLabel!.backgroundColor = UIColor.clear
            titleLabel!.alpha = 1.0
            titleLabel!.text = title
            
            // size the title label according to the length of the text
            let maxSizeTitle = CGSize(width: (self.bounds.size.width * HRToastMaxWidth) - imageWidth, height: self.bounds.size.height * HRToastMaxHeight);
            let expectedHeight = title!.stringHeightWithFontSize(HRToastFontSize, width: maxSizeTitle.width)
            titleLabel!.frame = CGRect(x: 18.0, y: 0.0, width: maxSizeTitle.width, height: expectedHeight)
        }
        
        if msg != nil {
            msgLabel = UILabel();
            msgLabel!.numberOfLines = HRToastMaxMessageLines
            msgLabel!.font = UIFont.systemFont(ofSize: HRToastFontSize)
            msgLabel!.lineBreakMode = .byWordWrapping
            msgLabel!.textAlignment = .left
            msgLabel!.textColor = UIColor.white
            msgLabel!.backgroundColor = UIColor.clear
            msgLabel!.alpha = 1.0
            msgLabel!.text = msg
            
            let maxSizeMessage = CGSize(width: (self.bounds.size.width * HRToastMaxWidth) - imageWidth, height: self.bounds.size.height * HRToastMaxHeight)
            let expectedHeight = msg!.stringHeightWithFontSize(HRToastFontSize, width: maxSizeMessage.width)
            msgLabel!.frame = CGRect(x: 15.0, y: 0.0, width: maxSizeMessage.width, height: expectedHeight)
        }
        
        var titleWidth: CGFloat, titleHeight: CGFloat, titleTop: CGFloat, titleLeft: CGFloat
        if titleLabel != nil {
            titleWidth = titleLabel!.bounds.size.width
            titleHeight = titleLabel!.bounds.size.height
            titleTop = HRToastVerticalMargin
            titleLeft = 18.0
        } else {
            titleWidth = 0.0; titleHeight = 0.0; titleTop = 0.0; titleLeft = 0.0
        }
        
        var msgWidth: CGFloat, msgHeight: CGFloat, msgTop: CGFloat, msgLeft: CGFloat
        if msgLabel != nil {
            msgWidth = msgLabel!.bounds.size.width
            msgHeight = msgLabel!.bounds.size.height
            msgTop = titleTop + titleHeight + HRToastVerticalMargin
            msgLeft = 18.0
        } else {
            msgWidth = 0.0; msgHeight = 0.0; msgTop = 0.0; msgLeft = 0.0
        }
        
        let largerWidth = max(titleWidth, msgWidth)
        let largerLeft  = max(titleLeft, msgLeft)
        
        // set wrapper view's frame
        let wrapperWidth  = max(imageWidth + HRToastHorizontalMargin * 2, largerLeft + largerWidth + HRToastHorizontalMargin)
        let wrapperHeight = max(msgTop + msgHeight + HRToastVerticalMargin, imageHeight + HRToastVerticalMargin * 2)
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        
        // add subviews
        if titleLabel != nil {
            titleLabel!.frame = CGRect(x: titleLeft, y: titleTop, width: titleWidth, height: titleHeight)
            wrapperView.addSubview(titleLabel!)
        }
        if msgLabel != nil {
            msgLabel!.frame = CGRect(x: msgLeft, y: msgTop, width: msgWidth, height: msgHeight)
            wrapperView.addSubview(msgLabel!)
        }
        if imageView != nil {
            wrapperView.addSubview(imageView!)
        }
        
        return wrapperView
    }
}

extension UIView {
    func animateButtonDown() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    func animateButtonUp() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

func showAnimation(_ view: UIView, finished:  @escaping () -> ()) {
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
        view.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
    }) { (_) in
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
            view.transform = CGAffineTransform.identity
        }) { (_) in
            finished()
        }
    }
}

func buttonAnimation(btn: UIButton, _ completion: @escaping () -> () = {} ) {
    btn.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    UIView.animate(withDuration             : 0.3,
                   delay                    : 0,
                   usingSpringWithDamping   : CGFloat(0.2),
                   initialSpringVelocity    : CGFloat(2.0),
                   options                  : UIView.AnimationOptions.allowUserInteraction,
                   animations               : {
        btn.transform = CGAffineTransform.identity
    },
                   completion               : { _ in
        completion()
    })
    

}
public extension UIView {
    func showAnimation(_ completionBlock: @escaping () -> Void) {
      isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear,
                       animations: { [weak self] in
                            self?.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
        }) {  (done) in
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: .curveLinear,
                           animations: { [weak self] in
                                self?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { [weak self] (_) in
                self?.isUserInteractionEnabled = true
                completionBlock()
            }
        }
    }
}

extension UIView {
    
    func toast(image: String, message: String) {
        
        //create view
        let myView = UIView()
        myView.frame = CGRect(x: 20,
                              y: -65 ,
                              width: self.bounds.width - 40, height: 54)
        myView.cornerRadius = 5
        myView.backgroundColor = UIColor(hexString: "49535B")
        
        //create image
        let imageView   = UIImageView(frame: CGRect(x: 15, y: myView.bounds.midY - (24 / 2), width: 24, height: 24))
        imageView.image = UIImage(named: image)
        myView.addSubview(imageView)
        
        //create label
        let toastLabel = UILabel(frame: CGRect(x: 49, y: myView.bounds.midY - (myView.bounds.height / 2), width: myView.bounds.width, height: myView.bounds.height))
        toastLabel.textColor        = .white
        toastLabel.textAlignment    = .left
        toastLabel.text             = message
        toastLabel.alpha            = 1.0
        toastLabel.clipsToBounds    =  true
        toastLabel.numberOfLines    = 0
        
        myView.addSubview(toastLabel)
        self.addSubview(myView)
        
        // Finally the animation!
        let offset = CGPoint(x: 0, y: -self.frame.maxY)
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
    
    
}

extension UIView {
    
    var parentViewController: UIViewController? {
        sequence(first: self) { $0.next }
            .first(where: { $0 is UIViewController })
            .flatMap { $0 as? UIViewController }
    }
    
    func findViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.keyWindowInConnectedScenes
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}


// Navy : Start on : 24 Jan 2024 - Found Best Solution : 08 Feb 2024
extension UIView {
    
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
    
    func setAttributeLabel(label: UILabel, textsTobeAttributed: [String], defaultFont: UIFont?, defaultColor: UIColor, attributedFont: UIFont?, atrributedColor: UIColor) {
        
        label.textColor   = defaultColor
        
        let fullContent      = label.text ?? ""
        let attributedString = NSMutableAttributedString(string: fullContent)
        
        for txt in textsTobeAttributed {
            if let stringMatches1 = try? regexMatchesToString(txt, string: fullContent) {
                for triggerString in stringMatches1 {
                    if triggerString == (txt) {
                        let matches1 = try? regexMatches(txt, string: fullContent)
                        if let matches = matches1 {
                            for match in matches {
                                attributedString.addAttribute(NSAttributedString.Key.font, value: defaultFont as Any, range: match.range)
                                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: atrributedColor, range: match.range)
                                label.attributedText = attributedString
                                label.font = defaultFont
                            }
                        }
                      
                    }
                }
            }
        }
        
    }
}

// Navy: 29 Jan 2024 -> Formatted mentioned member for display - For Used in Cell
extension UIView {
    func formatMentionFromAPISyntaxToReadable(originalText: String) -> (String, [String], [String])  {
        
        var fullUserInfoArr     : [String] = [] // @[Asnavy Husein](asnavy619@gmail.com)
        var usernameArr         : [String] = [] // Asnavy Husein
        var formattedString     = originalText.convertHTMLToString  // string to be replaced from "@[Asnavy Husein](asnavy619@gmail)" by "Asnavy Husein"
        let allUserArraySplit   = originalText.convertHTMLToString.components(separatedBy: "@[") // Split to get each member that has been mentioned

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
                        if (stringArray[index] == ")" && stringArray[index - 1] == "m") || /*.com*/
                            (stringArray[index] == ")" && stringArray[index - 1] == "h") || /*.kh*/
                            (stringArray[index] == ")" && stringArray[index - 1] == "g") || /*.org*/
                            (stringArray[index] == ")" && stringArray[index - 1] == "c") || /**/
                            (stringArray[index] == ")" && stringArray[index - 1] == "t") || /*.net*/
                            (stringArray[index] == ")" && stringArray[index - 1] == "n") || /*.vn*/
                            (stringArray[index] == ")" && stringArray[index - 1] == "o") || /*.co*/
                            (stringArray[index] == ")" && stringArray[index - 1] == "r") /*.kr*/
                        {
                            break
                        } else {
                            newStringComponentArray2.append(String(stringArray[index]))
                        }
                    }
                }
                var fullUserInfo =  "@[" + "\(newStringComponentArray2.joined(separator: ""))" + ")"
                #if DEBUG
                print("full user info: ", fullUserInfo)
                #endif
                
                // Navy : 14 Jan 2024
                // prevent error in case "@[kim](coral2036@webcash.co.kr)"
                fullUserInfo = fullUserInfo.replace(of: "))", with: ")")
                fullUserInfoArr.append(fullUserInfo)
                formattedString = formattedString.replace(of: fullUserInfo, with: username)
            }
        }
        
        let cleanFullUserInfo = Array(Set(fullUserInfoArr))
        let cleanuserNameArr = Array(Set(usernameArr))
        
        return (formattedString, cleanuserNameArr, cleanFullUserInfo)
    }
    
    
    
    
    // Navy: 29 Jan 2024 -> Formatted mentioned member for display - For Used in Cell
    func formatMentionFromReadableToAPISyntax(originalText: String, mentionedMembers: [MentionMemberUIModel]) -> String {
        
        // ****************************** NOTE *************************************
        // if we have 2 user in one string exampel : "I would like to inform that Sokny Ran & Sokny Ran (Yakuza) are not the same"
        // if we replace directly of username by email, it would be => "I would like to inform that (soknyran@gmail.com) & (soknyran@gmail.com) (Yakuza) are not the same"
        // so, there is no place to replace sokyranyakuza@gmail.com,
        // now, we need to replace the spaces of each username by a unique keyword for their own, I choose "#QCHLXP#" for 2 phrase username, and "$XC1C3F$" for 3 Digit username
        
        // ➡️ add unique key into spaces
        var modifiedMembers : [MentionMemberUIModel] = []
        for obj in mentionedMembers {
            
            let split = obj.name.components(separatedBy: " ")
            if split.count == 2 {
                let  modified = MentionMemberUIModel(name: obj.name.replace(of: " ", with: "#QCHLXP#"), email: obj.email, photo: obj.photo, USER_IMG: obj.USER_IMG)
                modifiedMembers.append(modified)
            } else {
                let  modified = MentionMemberUIModel(name: obj.name.replace(of: " ", with: "$XC1C3F$"), email: obj.email, photo: obj.photo, USER_IMG: obj.USER_IMG)
                modifiedMembers.append(modified)
            }
        }
        
        // ➡️ replace confused username with it's own unique key
        var modifiedString = originalText
        for (i, obj) in mentionedMembers.enumerated() {
            modifiedString = modifiedString.replace(of: obj.name, with: modifiedMembers[i].name)
        }
        
        // ➡️ replace the unique key by original text
        var formattedString = modifiedString
        for (i, obj) in modifiedMembers.enumerated() {
            formattedString = formattedString.replace(of: obj.name, with: mentionedMembers[i].email)
        }
        #if DEBUG
        print("Formatted String : ", formattedString)
        #endif
        return formattedString
    
    }
    
    
}



// Kheang: 2 Feb 2024 ->  // create bottom Loading view
extension UIView {
    func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
}




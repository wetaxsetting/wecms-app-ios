//
//  CustomToastViewController.swift
//  WABOOKS_iOS_V2
//
//  Created by Nheng Vanchhay on 3/6/21.
//

import UIKit

class CustomToastVC: UIViewController {

    @IBOutlet weak var viewContainer    : UIView!
    @IBOutlet weak var lblMessage       : UILabel!
    @IBOutlet weak var imgImage         : UIImageView!
    
    var image       : String?
    var message     : String?
    var imageColor  : UIColor?
    var color       : UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Finally the animation!
        let offset = CGPoint(x: 0, y: -self.view.frame.maxY)
        let x: CGFloat = 0, y: CGFloat = 0
        viewContainer.transform = CGAffineTransform(translationX: offset.x + x, y: offset.y + y + 500)
        viewContainer.isHidden = false
        UIView.animate(
            withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.80, initialSpringVelocity: 3,
            options: .curveEaseOut, animations: {
                self.viewContainer.transform = .identity
                self.viewContainer.alpha = 1
             
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // your code here
            // Finally the animation!
            self.dismiss(animated: false, completion: nil)
            let offset = CGPoint(x: 0, y: self.view.frame.maxY)
            let x: CGFloat = 0, y: CGFloat = 0
            self.viewContainer.transform = CGAffineTransform(translationX: offset.x + x, y: -(offset.y + y))
            self.viewContainer.isHidden = false
            UIView.animate(
                withDuration: 3, delay: 1, usingSpringWithDamping: 0.67, initialSpringVelocity: 3,
                options: .curveEaseIn, animations: {
                    self.viewContainer.transform = .identity
                    self.viewContainer.alpha = 1
                    
            })
        }
       
    }
    func initialize(){
        self.lblMessage.text    = message
        self.imgImage.image     = UIImage(named: image ?? "")
        self.viewContainer.backgroundColor = color
        
        self.lblMessage.getlocalizedFont()
        
        let slideDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissView(gesture:)))
        slideDown.direction = .up
        viewContainer.addGestureRecognizer(slideDown)
        
    }
    
    @objc func dismissView(gesture: UISwipeGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
        let offset = CGPoint(x: 0, y: self.view.frame.maxY)
        let x: CGFloat = 0, y: CGFloat = 0
        self.viewContainer.transform    = CGAffineTransform(translationX: offset.x + x, y: -(offset.y + y))
        self.viewContainer.isHidden     = false
        UIView.animate(
            withDuration: 5, delay: 0.8, usingSpringWithDamping: 0.4, initialSpringVelocity: 1,
            options: .curveEaseIn, animations: {
                self.viewContainer.transform    = .identity
                self.viewContainer.alpha        = 1
                
        })
    }
    
}

extension UIViewController {
    func customToast(image: String, message: String) {
        let vc = self.callCommonPopup(withStorybordName: "CustomAlertSB", identifier: "CustomToastVC") as! CustomToastVC
        vc.image    = image
        vc.message  = message
        
        self.present(vc, animated: true, completion: {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
//                // your code here
//                self.dismiss(animated: true, completion: nil)
//            }
        })
    }
    
    func customToastwithColor(image: String, message: String, backgroundColor: UIColor) {
        let vc = self.callCommonPopup(withStorybordName: "CustomAlertSB", identifier: "CustomToastVC") as! CustomToastVC
        vc.image    = image
        vc.message  = message
        vc.color    = backgroundColor
        
        self.present(vc, animated: true, completion: {
            
        })
    }
}

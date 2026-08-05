//
//  CustomAlertVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 5/1/21.
//

import UIKit

enum CustomAlertType : String, CaseIterable {
    case CONFIRM_ALERT      = "CONFIRM_ALERT"
    case SUCCESS_ALERT      = "SUCCESS_ALERT"
    case YES_OR_NO_ALERT    = "YES_OR_NO_ALERT"
}

///CustomAlertVC
class CustomAlertVC: UIViewController {
    // MARK: - IBOutlets -
    @IBOutlet weak var vContainer               : UIView!
    @IBOutlet weak var logoImageView            : UIImageView!
    @IBOutlet weak var labelTitle               : UILabel!
    @IBOutlet weak var labelMessage             : UILabel!
    @IBOutlet weak var btnRed                   : UIButton!
    @IBOutlet weak var btnGrey                  : UIButton!
    @IBOutlet weak var stackViewContainer       : UIStackView!
    @IBOutlet weak var constraintWidthBtnCancel : NSLayoutConstraint!
    @IBOutlet weak var backgroundButton         : UIButton!
    
    // MARK: - Public -
    var alertType       : CustomAlertType = .CONFIRM_ALERT
    var imageString     : String = ""
    var titleString     : String = ""
    var messageString   : String = ""
    var redTitle        : String = ""
    var greyTitle       : String = ""
    
    var redAction       : Completion = {}
    var greyAction      : Completion = {}
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        vContainer.alpha        = 0
        vContainer.transform    = CGAffineTransform(scaleX: 0.5, y: 0.5)

        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 3,
                options: .curveEaseOut, animations: {
                    self.view.backgroundColor = UIColor(hexString: "06141F").withAlphaComponent(0.4)
                    self.vContainer.transform   = .identity
                    self.vContainer.alpha       = 1
            }, completion: nil)
        }
        
    }
    
    private
    func initialize() {
//        logoImageView.image          = UIImage(named: imageString)
        labelTitle.textAlignment = .center
        
        labelTitle.text              = titleString
        labelMessage.text            = messageString
        btnRed.setTitle(redTitle.capitalized, for: .normal)
        btnGrey.setTitle(greyTitle.capitalized, for: .normal)
        
        labelTitle.getlocalizedFont()
        labelMessage.getlocalizedFont()
        btnRed.getlocalizedFont()
        btnGrey.getlocalizedFont()
        
        if alertType == .CONFIRM_ALERT {
            constraintWidthBtnCancel.constant   = 0 //hide grey btn
            stackViewContainer.spacing          = 0
            btnRed.isUserInteractionEnabled     = false
        } else if alertType == .YES_OR_NO_ALERT {
            constraintWidthBtnCancel.constant   = 119
            stackViewContainer.spacing          = 10
            btnRed.isUserInteractionEnabled     = true
        }
    }
    
    // MARK: - IBAction -
    @IBAction func didTapBtnRed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.redAction()
        }
    }
    
    @IBAction func didTapBtnGrey(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.greyAction()
        }
    }
    
    @IBAction func didTapBackgroundButton(_ sender: Any) {
        self.popOrDismissVC()
    }
    
}

extension UIViewController {
    func customAlert(type       : CustomAlertType = .CONFIRM_ALERT,
                     image      : String = "badge_failed",
                     title      : String = "Confirmation",
                     message    : String = "After confirm ID and Password, please log in again with ID “asdlkfjkas484” ",
                     redTitle   : String = "Delete",
                     greyTitle  : String = "Cancel",
                     completion : @escaping Completion_Bool = {_ in}) {
        
        let vc = self.callCommonPopup(withStorybordName: "CustomAlertSB", identifier: "CustomAlertVC") as! CustomAlertVC
        vc.alertType     = type
        vc.imageString   = image
        vc.titleString   = title
        vc.messageString = message
        vc.redTitle      = redTitle
        vc.greyTitle     = greyTitle
        vc.redAction = {
            completion(true)
        }
        vc.greyAction = {
            completion(false)
        }
        self.present(vc, animated: true, completion: nil)
    }
}


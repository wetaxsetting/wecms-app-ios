//
//  YesNoPopupVC.swift
//  WeCMS_iOS
//
//  Created by Navy on 15/1/24.
//

import UIKit


class YesNoPopupVC: UIViewController {

    // MARK: - @IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    // MARK: - Variables
    var titleString         = ""
    var messageString       = ""
    var confirmTitle        = ""
    var cancelTitle         = ""
    var isDeletePopup       = false
    var completionYesNo     : Completion_Bool = {_ in}

    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    // MARK: - Functions
    func setupData() {
        self.descriptionLabel.text = messageString
        self.titleLabel.text = titleString
        self.confirmButton.setTitle(confirmTitle, for: .normal)
        self.cancelButton.setTitle(cancelTitle, for: .normal)
        self.confirmButton.setTitleColor(isDeletePopup ? UIColor(resource: .bulletinDelete) : UIColor(resource: .mainTextBulletin) , for: .normal)
        
        self.titleLabel.getlocalizedFont()
        self.descriptionLabel.getlocalizedFont()
        self.descriptionLabel.getlocalizedFont()
        self.confirmButton.getlocalizedFont()
        self.cancelButton.getlocalizedFont()
        self.titleLabel.getlocalizedFont()
        self.confirmButton.getlocalizedFont()
        self.cancelButton.getlocalizedFont()
    }
    
    
    // MARK: - IBAction
    @IBAction func yesButtonDidTap(_ sender: UIButton) {
        completionYesNo(true)
    }
    
    @IBAction func noButtonDidTap(_ sender: UIButton) {
        completionYesNo(false)
    }
    
}


// MARK: - UIViewController
extension UIViewController  {

    func yesNoPopup(title: String, message: String, confirmTitle: String, cancelTitle: String, isDeletePopup: Bool, completion: @escaping Completion_Bool = {_ in}) {
        
        let vc = self.VC(sbName: "YesNoPopupSB", identifier: "YesNoPopupVC") as! YesNoPopupVC
        vc.titleString = title
        vc.messageString = message
        vc.confirmTitle = confirmTitle
        vc.cancelTitle = cancelTitle
        vc.isDeletePopup = isDeletePopup
        
        /*
         Illustration technique !!!!
         ===========================
         Label កំដរ 💔.... គេត្រូវការអ្នកដើម្បីជាឈ្នាន់សម្រាប់គណនាកម្ពស់របស់ Label ដែលគេចង់បានប៉ុណ្ណោះ អ្នកមិនបានស្ថិតក្នុងភ្នែករបស់ User ទេ 🙂
         This function is called before the real label has been show, so we cannot get exact number of lines from here
         So I created a hidden label and then pass the real value to see the exact number of line but I don't show it on screen
         We do this to calculate the height of the bottom sheet
         */
        
        // heremen, move this create only once at somewhere
        let labelWidth = UIScreen.main.bounds.width - 40 // Left 20, right 20
        let sadLabel = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 400))
        sadLabel.numberOfLines = 100
        sadLabel.textAlignment = .center
        sadLabel.text = message
        sadLabel.textColor = .clear
        
        let numberOfLine = sadLabel.calculateMaxLines()
        let topAndBottomHeight = 240 // title + 2 yes no buttons
        let descriptionHeight  = 22 * numberOfLine
        let heightOfPopup      = CGFloat(topAndBottomHeight + descriptionHeight)
        
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in heightOfPopup }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = true
        }

        vc.completionYesNo = { confirm in
            completion(confirm)
            self.dismiss(animated: true)
        }
        
        self.present(vc, animated: true, completion: nil)
    }
}



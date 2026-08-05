//
//  InfoMessagePopupVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Navy on 17/1/24.
//

import UIKit


class InfoMessagePopupVC: UIViewController {
    
    // MARK: - @IBOutlet
    @IBOutlet weak var iconImage        : UIImageView!
    @IBOutlet weak var titleLabel       : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var confirmButton    : UIButton!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    // MARK: - Variables
    var iconName            = ""
    var titleString         = ""
    var messageString       = ""
    var confirmTitle        = ""
    var completionOkay      : Completion = {}
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
        titleLabel.getlocalizedFont()
        descriptionLabel.getlocalizedFont()
        confirmButton.getlocalizedFont()
    }
    
    
    // MARK: - Function
    func setupData(){
        if self.iconName.isEmpty {
            self.iconImage.isHidden = true
            self.heightConstraint.constant = 0
        } else {
            self.heightConstraint.constant = 48
            self.iconImage.image = UIImage(named: iconName)
        }
        self.descriptionLabel.text = messageString
        self.titleLabel.text = titleString
        self.confirmButton.setTitle(confirmTitle, for: .normal)
        
        self.descriptionLabel.getlocalizedFont()
        self.titleLabel.getlocalizedFont()
        self.confirmButton.getlocalizedFont()
    }
    
    
    // MARK: - @IBAction
    @IBAction func okayButtonDidTap(_ sender: UIButton) {
        completionOkay()
    }
    
}


extension UIViewController  {

    func infoMessagePopup(iconName: String, title: String, message: String,dismissOnPull : Bool = true, confirmTitle: String, completion: @escaping Completion_Bool = {_ in}) {
        
        let vc = self.VC(sbName: "InfoMessagePopupSB", identifier: "InfoMessagePopupVC") as! InfoMessagePopupVC
        
        vc.iconName = iconName
        vc.titleString = title
        vc.messageString = message
        vc.confirmTitle = confirmTitle
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
        let topAndBottomHeight = (iconName == "") ? 170 : 215 // title + 1 confirm button
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

        vc.completionOkay = {
            self.dismiss(animated: true) {
                completion(true)
            }
        }
        
        self.present(vc, animated: true, completion: nil)
    }
}

//
//  DropDownVC.swift
//  WeCMS_iOS
//
//  Created by Seanghay Huort on 29/1/24.
//

import UIKit


class DropDownVC: UIViewController {

    @IBOutlet weak var backgroundView   : UIView!
    @IBOutlet weak var datePicker       : UIDatePicker!
    @IBOutlet weak var cancelButton     : UIButton!
    @IBOutlet weak var okayButton       : UIButton!
    
    var didSelectCompletion : Completion_String = {_ in}
    var datePop: Date = Date()
    var datePickerValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.okayButton.setTitle("ok".localized, for: .normal)
        self.cancelButton.setTitle("cancel".localized, for: .normal)
        self.datePicker.date = datePop
        self.datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.locale = Locale(identifier: MyDefaults.string(key: .appLang))
    }
    
    @IBAction func didTapOkayButton(_ sender: Any) {
        self.didSelectCompletion(self.datePickerValue)
    }
    
    @IBAction func didTapDismissAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func pickerValueChanged(_ sender: Any) {
        let today = self.datePicker.date.toString(format: "dd MMM yyyy")
        self.datePickerValue = today
    }
    
}

extension UIViewController  {

    func dropDownStartDate(date: String = "", completion: @escaping Completion_String = {_ in}) {
        
        let vc              = self.VC(sbName: "DropDownSB", identifier: "DropDownVC") as! DropDownVC
        let dateStr         = changeFormatDate(date, fromFormat: "dd MMM yyyy", toFormat: "yyyyMMdd")
        let dateForPicker   = dateStr == "" ? Date() : dateStr.stringToDate(format: "yyyyMMdd")
        vc.datePop          = dateForPicker
        
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.didSelectCompletion = { option in
            completion(option)
            self.dismiss(animated: true)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func dropDownSelectDate(date: String = "", completion: @escaping Completion_String = {_ in}) {
        
        let vc              = self.VC(sbName: "DropDownSB", identifier: "DropDownVC") as! DropDownVC
        let dateStr         = changeFormatDate(date, fromFormat: "dd MMM yyyy", toFormat: "yyyyMMdd")
        let dateForPicker   = dateStr == "" ? Date() : dateStr.stringToDate(format: "yyyyMMdd")
        vc.datePop          = dateForPicker
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.didSelectCompletion = { option in
            completion(option)
            self.dismiss(animated: true)
        }
        self.present(vc, animated: true, completion: nil)
    }
}

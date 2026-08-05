//
//  SelectOptionCheckedVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Seanghay Huort on 18/1/24.
//

import UIKit

typealias Completion_DoubleString         = (String, String, String)          -> Void
class SelectOptionCheckedVC: UIViewController {

    @IBOutlet weak var tableView        : UITableView!
    @IBOutlet weak var dateViewHeight   : NSLayoutConstraint!
    @IBOutlet weak var dateBackView     : UIView!
    
    var data : [OptionPopupWithoutTitleModel] = []
    var didSelectCompletion : Completion_String = {_ in}
    var didSelectDateCompletion : Completion_DoubleString = {_, _,_  in}
    var heightCompletion    : Completion_Int = {_ in}
    var strTitle        = ""
    var defaultStr      = ""
    var isNewArticle    = false
    var isDraft         = false
    var isSpecificDate  = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.isScrollEnabled       = false
    }
    
    private func getFullscreenHeight() -> CGFloat {
        let statusBarManager = UIApplication.shared.statusBarManagerInConnectedScenes
        let statusBarHeight = statusBarManager?.statusBarFrame.height ?? 0
        let fullscreenHeight = UIScreen.main.bounds.height - statusBarHeight - 200
        return fullscreenHeight
    }
    
    private func getHeight() -> CGFloat {
        let spaces       = 60 // top & bottom spaces
        let numberOfItem = data.count
        let cellHeight   = 58 * numberOfItem // 58 is height of one cell, multiples with item count to get all cells height
        let totalHeight  = CGFloat(cellHeight + spaces)
        return totalHeight
    }
    
    func initCell(){
        let tempData1 = OptionPopupWithoutTitleModel(icon: "ico_infinity",          title: "save_permanently".localized)
        let tempData2 = OptionPopupWithoutTitleModel(icon: "ico_calendar_select",   title: "until_specific_date".localized)
        let tempData3 = OptionPopupWithoutTitleModel(title: "DATE")
        self.data = [tempData1, tempData2, tempData3]
    }
    
    func initForeverCell(){
        let tempData1 = OptionPopupWithoutTitleModel(icon: "ico_infinity",          title: "save_permanently".localized)
        let tempData2 = OptionPopupWithoutTitleModel(icon: "ico_calendar_select",   title: "until_specific_date".localized)
        self.data = [tempData1, tempData2]
    }

}

// MARK: - UITableView
extension SelectOptionCheckedVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataType = data[indexPath.row].title
        switch dataType {
        case "DATE":
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectOptionDateCell", for: indexPath) as! SelectOptionDateCell
            let dateStr = changeFormatDate(strTitle, fromFormat: "dd MMM yyyy", toFormat: "yyyyMMdd")
            let dateForPicker = strTitle == "" ? Date() : strTitle.stringToDate(format: "yyyyMMdd")
            cell.datePicker.date = dateForPicker
            cell.didSelectDateCompletion = { value in
                self.didSelectDateCompletion("until_specific_date".localized, value, "LD")
                self.dismiss(animated: true)
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectOptionCheckCell", for: indexPath) as! SelectOptionCheckCell
            cell.iconCheckImage.isHidden = true
            if isDraft{
                cell.configDraftCell(data: data[indexPath.row], isNewArticle: self.isNewArticle)
            }else{
                cell.configCell(data: data[indexPath.row], isNewArticle: self.isNewArticle)
            }
            
            let isSelected = data[indexPath.row].title == self.defaultStr
            if isSelected {
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            cell.configSelected(isSelected)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch data[indexPath.row].title {
        case "until_specific_date".localized:
            self.initCell()
            self.defaultStr = "until_specific_date".localized
            self.heightCompletion(Int(getFullscreenHeight()))
        case "save_permanently".localized:
            self.initForeverCell()
            self.defaultStr = "save_permanently".localized
            self.heightCompletion(Int(getHeight()))
            self.didSelectDateCompletion("save_permanently".localized, "permanently".localized, "UD")
            self.dismiss(animated: true)
        default:
            self.didSelectCompletion(data[indexPath.row].title)
        }
        if let cell = self.tableView.cellForRow(at: indexPath) as? SelectOptionCheckCell {
            cell.configSelected(true)
        }
        self.tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? SelectOptionCheckCell {
            cell.configSelected(false)
        }
    }

}

extension UIViewController  {

    func selectOptionWithChek(optionData: [OptionPopupWithoutTitleModel], defaultApproval: String, isNewArticle: Bool,isDraft: Bool = false, completion: @escaping Completion_String = {_ in}) {
        
        let vc = self.VC(sbName: "SelectOptionCheckedSB", identifier: "SelectOptionCheckedVC") as! SelectOptionCheckedVC
        
        vc.data         = optionData
        vc.defaultStr   = defaultApproval
        vc.isNewArticle = isNewArticle
        vc.isDraft      = isDraft

        let numberOfItem = isNewArticle ? optionData.count + 1 : optionData.count
        let spaces       = 60 // top & bottom spaces
        let cellHeight   = 58 * numberOfItem // 58 is height of one cell, multiples with item count to get all cells height
        let totalHeight  = CGFloat(cellHeight + spaces)
        
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in totalHeight }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = true
        }
        
        vc.didSelectCompletion = { option in
            completion(option)
//            self.dismiss(animated: true)
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func selectOptionWithChekSpecificDate(optionData: String, defaultApproval: String, completion: @escaping Completion_DoubleString = {_, _,_  in}) {
        
        let vc = self.VC(sbName: "SelectOptionCheckedSB", identifier: "SelectOptionCheckedVC") as! SelectOptionCheckedVC
    
        vc.defaultStr   = defaultApproval
        vc.strTitle     = optionData
        vc.isSpecificDate = true
        let spaces       = 85 // top & bottom spaces
        if defaultApproval == "until_specific_date".localized {
            vc.initCell()
        }else{
            vc.initForeverCell()
        }
        let numberOfItem = vc.data.count
        let cellHeight   = defaultApproval == "until_specific_date".localized ? 58 * numberOfItem + 400 : 58 * numberOfItem// 58 is height of one cell, multiples with item count to get all cells height
        var totalHeight  = CGFloat(cellHeight + spaces)
        
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in totalHeight }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = true
        }
        vc.didSelectDateCompletion = { option, value, duration in
            completion(option, value, duration)
        }
        vc.heightCompletion = { height in
            totalHeight = CGFloat(height)
            vc.sheetPresentationController?.animateChanges {
                vc.sheetPresentationController?.selectedDetentIdentifier = .large
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
}

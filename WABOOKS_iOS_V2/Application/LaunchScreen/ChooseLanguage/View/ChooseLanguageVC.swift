//
//  ChooseLanguageVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Thea Chum on 11/1/21.
//

import UIKit
import IQKeyboardManagerSwift
import IQKeyboardToolbar
import IQKeyboardToolbarManager

class ChooseLanguageVC: UIViewController {

    // MARK: - IBOutlets -
    @IBOutlet weak var tableview : UITableView!
    
    var chooseLanguageVM        = ChooseLanguageVM()
      
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chooseLanguageVM.initChooseLanguage()
        self.intializeView()
//        let langCode        = MyDefaults.get(key: .appLang) as? String ?? ""
//        self.selectedRow    = langCode == "km" ? 0 : langCode == "ko" ? 1 : langCode == "en" ? 2 : langCode == "vi" ? 3 : 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.chooseLanguageVM.initChooseLanguage()
        self.tableview.reloadData()
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let doneConfig = IQBarButtonItemConfiguration(title: "done".localized)
        IQKeyboardToolbarManager.shared.toolbarConfiguration.doneBarButtonConfiguration = doneConfig //Localized for done button keyboard
    }
    
    // MARK: - Private Method -
    private func intializeView() {
        self.tableview.isScrollEnabled = false
        // for screen 5s down ->
        if UIScreen.main.bounds.height < 570 {
//            self.cstTopwb_sunny.constant            = 33
//            self.cstTopbadge_person_img.constant    = 0
            self.tableview.isScrollEnabled = (self.chooseLanguageVM.chooseLanguageRec?.count ?? 0) > 3
        }
    }
    
}

// MARK: - UITableViewDelegate && UITableviewDataSource -
extension ChooseLanguageVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chooseLanguageVM.chooseLanguageRec?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = self.chooseLanguageVM.chooseLanguageRec?[indexPath.row]
        
        let rowType = self.chooseLanguageVM.chooseLanguageRec?[indexPath.row].rowType
        
        switch rowType {
        case .ChooseLanguageTopCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseLanguageTopCell") as! ChooseLanguageTopCell
            
            cell.configCell(strTitle: data?.strTitle ?? "", strSubTitle: data?.strSubTitle ?? "", strImage: data?.strImage ?? "")
            cell.wbImage.image             = UIImage(named: "wb_sunny_ico")
            cell.lblTitle.font             = UIFont(name: "Inter-Bold", size: 21)

            // Product switching removed: this build is WeCMS only.
            cell.btnWabooksVersion.isHidden = true

            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseLanguageCell") as! ChooseLanguageCell
            
            cell.btnCover.tag = indexPath.row
            
            cell.configCell(title       : data?.strTitle ?? "",
                            imageStr    : data?.strImage ?? "",
                            isSelected  : data?.isSelected ?? false)
            
            cell.didTapBtnCoverComplition = { index in
//                self.selectedRow = self.index

                if #available(iOS 11.0, *) {
                    tableView.performBatchUpdates {
                        self.tableview.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .none
                        )
                    } completion: { (status) in
                        self.tableview.reloadData()
                    }
                } else {
                    // Fallback on earlier versions
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
                
                guard let lang = LanguageCode(rawValue: self.chooseLanguageVM.chooseLanguageRec?[index].strSubTitle ?? "") else {return }

                MyDefaults.set(key: .IS_FIRST_COACH_APP, value: true)
                Shared.language = lang
                MyDefaults.set(key: .appLang, value: lang.rawValue)
//                let vc  = self.VC(sbName: "LoginSB", identifier: "LoginVC") as! UINavigationController
//                self.pushVC(viewController: vc)
                let loginVC = self.VC(sbName: "LoginSB", identifier: "LoginNav") as! UINavigationController
                self.setRootNavViewController(navigation: loginVC, direction: .toRight)

            }
             
            cell.didTouchDownChooseBtnComplition = { index in
//                self.selectedRow = indexPath.row
//                self.index       = indexPath.row
                
                for row in 0..<(self.chooseLanguageVM.chooseLanguageRec?.count ?? 0) {
                    self.chooseLanguageVM.chooseLanguageRec?[row].isSelected = row == index ? true : false
                }
                
                if #available(iOS 11.0, *) {
                    tableView.performBatchUpdates {
                        self.tableview.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .none
                        )
                    } completion: { (status) in
                        self.tableview.reloadData()
                    }

                } else {
                    // Fallback on earlier versions
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            }
            
            cell.didDragExitChooseBtnComplition = {
//                self.selectedRow = self.index
                
                if #available(iOS 11.0, *) {
                    tableView.performBatchUpdates {
                        self.tableview.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .none
                        )
                    } completion: { (status) in
                        self.tableview.reloadData()
                    }
                } else {
                    // Fallback on earlier versions
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            }
            
            return cell
        }
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let rowType = self.chooseLanguageVM.chooseLanguageRec?[indexPath.row].rowType
        
        switch rowType {
        case .ChooseLanguageTopCell:
            
            return 375
            
        default:
            return 60
        }
    }
}

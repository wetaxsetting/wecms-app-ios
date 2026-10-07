//
//  CustomOptionVC.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 8/1/21.
//

import UIKit
import Photos
import PhotosUI


enum CustomOptionCellType : String, CaseIterable {
    case Detail         = "Detail"
    case MultipleChoice = "MultipleChoice"
}

///CustomOptionVC
class CustomOptionVC: UIViewController {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var vContainer    : UIView!
    @IBOutlet weak var labelTitle    : UILabel!
    @IBOutlet weak var labelSubTitle : UILabel!
    @IBOutlet weak var tableView     : UITableView!
    @IBOutlet weak var btnClose      : UIButton!
    
    @IBOutlet weak var constriantHeightTableview: NSLayoutConstraint!
    
    @IBOutlet weak var cnstHeightHeaderView: NSLayoutConstraint!
    
    @IBOutlet weak var containerHeaderView: UIView!
    // MARK: - Public -
    var customOptionType    : CustomOptionCellType = .Detail
    var dataRec             : [String]   = []
    var subDataRec          : [String]   = []
    var imgStrRec           : [String]   = []
    var selectRow           = 0
    var imageString         = ""
    var titleString         = ""
    var messageString       = ""
    var shouldDimiss        = false
    var isShowHeaderView    = true
    var isBtnDeleteDisable  = false
    
    // MARK: - Complition -
    var didTapCloseComplition : Completion      = {}
    var didTapCellComplition  : Completion_Int  = {_ in}
    
    //Variable to get data in first selected row
    var indexPathCell   : Int?
    
    var selectOption    : String?
    
    
    // for request login
    var loginVC         = LoginVC()
    var companyVM       = CompanyVM()
    var loginR001     : MREC_R001.RESPONSE?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        MyNotify.listen(self, selector: #selector(presentLimitedLibraryPicker), name: .presentLimitedLibraryPicker)
        
        //hide header view
        if isShowHeaderView {
            cnstHeightHeaderView.constant = 75
            btnClose.isHidden = false
        }else {
            cnstHeightHeaderView.constant = 0
            btnClose.isHidden = true
        }
        
        self.companyVM.initData(data: self.loginR001)
        
    }
    
    //present multi select image picker ios 14
    @objc func presentLimitedLibraryPicker() {
        
        //set font and color to nav picker
        
        setColorArtibuteNav: do {
            let defaultFont     = UIFont(name: "Inter", size: 14)
            let fontNameToTest  = defaultFont!.fontName.lowercased()
            let fontName        = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
            let attrsBarButton = [
                NSAttributedString.Key.font: UIFont(name: fontName, size: 15)!,
                NSAttributedString.Key.foregroundColor : UIColor(hexString: "0069B9")
            ]
            UIBarButtonItem.appearance().setTitleTextAttributes(attrsBarButton, for: .normal)
        }
        
        DispatchQueue.main.async {
            if #available(iOS 14, *) {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            } else {
                // Fallback on earlier versions
                
            }
        }
    }
    
    func animateDismiss(complitionHandler: @escaping () -> ()) {
        let offset              = CGPoint(x: 0, y: view.frame.maxY)
        let x: CGFloat          = 0
        let y: CGFloat          = 0
        
        
        vContainer.alpha = 1
        UIView.animate(withDuration: 0.4, delay: 0.1, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.vContainer.transform    = CGAffineTransform(translationX: offset.x + x, y: offset.y + y)
        }, completion: {_ in
            if self.shouldDimiss {
                self.dismiss(animated: true) {
                    self.didTapCloseComplition()
                }
            }else{
                self.didTapCloseComplition()
            }
            
        })
    }
    
    @IBAction func didTapCloseBtn(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.didTapCloseComplition()
        }
    }
    
    // MARK: - Private -
    private func setupTable() {
        
        labelTitle.text     = titleString
        labelSubTitle.text  = messageString
        btnClose.setTitle("cancel_btn".localized, for: .normal)
        
        labelTitle.getlocalizedFont()
        labelSubTitle.getlocalizedFont()
        btnClose.getlocalizedFont()
        
        switch customOptionType {
        case .Detail:
            self.tableView.isScrollEnabled          = self.dataRec.count > 3 //enable scroll when dataSource count bigger than 3
            self.labelTitle.font                    = UIFont(name: "Inter-Bold", size: 15)
            self.labelSubTitle.font                 = UIFont(name: "Inter-Medium", size: 13)
        case .MultipleChoice:
//            self.tableView.isScrollEnabled          = self.dataRec.count > 3 //enable scroll when dataSource count bigger than 3
            self.constriantHeightTableview.constant = CGFloat(self.dataRec.count >= 3 ? 150 : self.dataRec.count * 65) + 40
            self.tableView.separatorStyle = .singleLine
            self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
}

extension CustomOptionVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataRec.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch customOptionType{
        case .Detail:
            return UITableView.automaticDimension
        case .MultipleChoice:
            return 65
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch customOptionType {
        case .Detail:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomOptionCell") as! CustomOptionCell
            cell.labelTitle.text    = dataRec[indexPath.row]
//            cell.labelSubTitle.text = subDataRec[indexPath.row]
            
            cell.labelTitle.getlocalizedFont()
//            cell.labelSubTitle.getlocalizedFont()
            
            //set selection
            let isSelectedCell                  = dataRec[indexPath.row] == self.selectOption
            cell.viewContainer.backgroundColor  = isSelectedCell ? UIColor(hexString: "FAFAFA") : UIColor.white
            cell.labelTitle.textColor           = isSelectedCell ? UIColor(hexString: "494949") : UIColor(hexString: "494949")
            cell.btnCover.isSelected            = isSelectedCell
            
            cell.imageConstraint.constant     = 20
            cell.viewLeftConstraint.constant  = 20
            cell.viewRightConstraint.constant = 20

            cell.didTouchUpOutsideBtnImage = {
                self.smartSelectRow(indexPath: indexPath)
            }

            if indexPath.row == self.selectRow{
                cell.btnImg.setImage(UIImage(named: "radio_btn_on"), for: .normal)
            } else {
                cell.btnImg.setImage(UIImage(named: "radio_btn_off"), for: .normal)
            }
            
            if !imgStrRec.isEmpty {
                cell.btnImg.setImage(UIImage(named: self.imgStrRec[indexPath.row]), for: .normal)
            }
            
            cell.didTapCellComplition = {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                   if self.shouldDimiss {
                        self.dismiss(animated: true) {
                            self.didTapCellComplition(indexPath.row)
                        }
                    }else{
                        self.didTapCellComplition(indexPath.row)
                    }
                }
            }
            
            cell.didTouchDownBtnCover = {
                self.selectRow = indexPath.row
                self.tableView.reloadData()
            }
            
            cell.didTouchUpOutsideBtnCover = {
                self.selectRow = indexPath.row
                self.tableView.reloadData()
            }
            
            
            cell.didTap {
                self.smartSelectRow(indexPath: indexPath)
            }
            
            return cell
            
        case .MultipleChoice:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomOptionMultipleChoiceCell") as! CustomOptionMultipleChoiceCell
            
            if dataRec[indexPath.row] == "en".localized {
                cell.labelTitle.text = dataRec[indexPath.row]
                cell.labelTitle.font = UIFont(name: "Inter-Regular", size: 15)
            } else {
                cell.labelTitle.text = dataRec[indexPath.row]
                cell.labelTitle.font = UIFont(name: "Inter-Regular", size: 15)
                cell.labelTitle.getlocalizedFont()
            }
            
            if isBtnDeleteDisable {
                if indexPath.row == 1 {
                    cell.labelTitle.alpha = 0.3
                    cell.btnChoose.alpha  = 0.3
                }
            }else {
                cell.labelTitle.alpha = 1
                cell.btnChoose.alpha  = 1
            }

            //set selection
            let isSelectedCell = indexPath.row == selectRow//Shared.indexPathOption
            
            cell.viewContainer.backgroundColor  = isSelectedCell ? UIColor(hexString: "EEF5FF") : UIColor.white
            cell.labelTitle.textColor           = isSelectedCell ? UIColor(hexString: "0069B9") : UIColor(hexString: "494949")
            cell.btnChoose.isSelected           = isSelectedCell
            cell.btnCover.isSelected            = isSelectedCell
            
            if !imgStrRec.isEmpty {
                cell.btnChoose.setImage(UIImage(named: self.imgStrRec[indexPath.row]), for: .normal)
                cell.btnChoose.setImage(UIImage(named: "\(self.imgStrRec[indexPath.row])\("_select")"), for: .selected)
            }
            
            //Did Tap Btn Choose Complition
            cell.didTapBtnCoverComplition  = {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if self.shouldDimiss {
                            self.dismiss(animated: true) {
                                self.didTapCellComplition(indexPath.row)
                            }
                        }else{
                            self.didTapCellComplition(indexPath.row)
                        }
                    }
                }
            }
            
            cell.didTouchdownCoverComplition = {
                DispatchQueue.main.async {
                    self.selectRow = indexPath.row
                    self.tableView.reloadData()
                }
            }
            
            cell.didTap {
                self.smartSelectRow(indexPath: indexPath)
            }
            return cell
        }
    }
    
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch customOptionType {
        case .Detail:
            let cell = tableView.cellForRow(at: indexPath) as! CustomOptionCell
            self.selectRow      = indexPath.row
            let isSelectedCell  = indexPath.row == selectRow

            cell.viewContainer.backgroundColor = isSelectedCell ? UIColor(hexString: "FAFAFA") : UIColor.white
//            Shared.indexPathDetail = indexPath.row
            
            DispatchQueue.main.async {
                self.selectOption = self.dataRec[indexPath.row]
                self.tableView.reloadData()
                
                if self.shouldDimiss {
                    self.dismiss(animated: true) {
                        self.didTapCellComplition(indexPath.row)
                    }
                } else {
                    self.didTapCellComplition(indexPath.row)
                }
            }
            
        case .MultipleChoice:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomOptionMultipleChoiceCell") as! CustomOptionMultipleChoiceCell
//            self.selectRow                      = indexPath.row
//            let isSelectedCell                  = indexPath.row == Shared.indexPathOption
//            cell.viewContainer.backgroundColor  = isSelectedCell ? UIColor(hexString: "FAFAFA") : UIColor.white
//
//            print(isSelectedCell, Shared.indexPathOption , "Cell")
//            Shared.indexPathOption = indexPath.row
            DispatchQueue.main.async {
                self.selectOption = self.dataRec[indexPath.row]
                self.tableView.reloadData()
                
                if self.shouldDimiss {
                    self.dismiss(animated: true) {
                        self.didTapCellComplition(indexPath.row)
                    }
                } else {
                    self.didTapCellComplition(indexPath.row)
                }
            }
        }
    }
    */
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if customOptionType == .MultipleChoice {
            let cell = tableView.cellForRow(at: indexPath) as! CustomOptionMultipleChoiceCell
            if indexPath.row == dataRec.count - 1 {
                cell.viewContainer.backgroundColor = isBtnDeleteDisable ? .white : UIColor(hexString: "EEF5FF")
            }else {
                cell.viewContainer.backgroundColor = UIColor(hexString: "EEF5FF")
            }
//            cell.viewContainer.backgroundColor = UIColor(hexString: "FAFAFA")
        } else if customOptionType == .Detail {
            let cell = tableView.cellForRow(at: indexPath) as! CustomOptionCell
            cell.viewContainer.backgroundColor = UIColor(hexString: "FAFAFA")
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if customOptionType == .MultipleChoice {
            let cell = tableView.cellForRow(at: indexPath) as! CustomOptionMultipleChoiceCell
            cell.viewContainer.backgroundColor = UIColor.white
        } else if customOptionType == .Detail {
            let cell = tableView.cellForRow(at: indexPath) as! CustomOptionCell
            cell.viewContainer.backgroundColor = UIColor.white
        }
    }
    
    //TODO : Select ROW
    func smartSelectRow(indexPath : IndexPath) {
        
        // When hold one time and then try to tap not work on didSelectRowAt
        switch customOptionType {
        case .Detail:
            let cell = tableView.cellForRow(at: indexPath) as! CustomOptionCell
            self.selectRow      = indexPath.row
            let isSelectedCell  = indexPath.row == selectRow

            cell.viewContainer.backgroundColor = isSelectedCell ? UIColor(hexString: "FAFAFA") : UIColor.white
//            Shared.indexPathDetail = indexPath.row
            if isSelectedCell{
                cell.btnImg.setImage(UIImage(named: "radio_btn_on"), for: .normal)
                self.requestLoginAPI(bizKey: self.loginR001?.REC?[indexPath.row].BIZ_KEY ?? "")
            }else{
                cell.btnImg.setImage(UIImage(named: "radio_btn_off"), for: .normal)
            }
            
            DispatchQueue.main.async {
                self.selectOption = self.dataRec[indexPath.row]
                self.tableView.reloadData()
                
                if self.shouldDimiss {
                    self.dismiss(animated: true) {
                        self.didTapCellComplition(indexPath.row)
                    }
                } else {
                    self.didTapCellComplition(indexPath.row)
                }
            }
            
        case .MultipleChoice:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomOptionMultipleChoiceCell") as! CustomOptionMultipleChoiceCell
//            self.selectRow                      = indexPath.row
//            let isSelectedCell                  = indexPath.row == Shared.indexPathOption
//            cell.viewContainer.backgroundColor  = isSelectedCell ? UIColor(hexString: "FAFAFA") : UIColor.white
//
//            print(isSelectedCell, Shared.indexPathOption , "Cell")
//            Shared.indexPathOption = indexPath.row
            self.selectRow = indexPath.row
            DispatchQueue.main.async {
                self.selectOption = self.dataRec[indexPath.row]
                self.tableView.reloadData()
                
                if self.shouldDimiss {
                    self.dismiss(animated: true) {
                        self.didTapCellComplition(indexPath.row)
                    }
                } else {
                    self.didTapCellComplition(indexPath.row)
                }
            }
        }
        
    }
}

//Detail
class CustomOptionCell : UITableViewCell {
    // MARK: - IBOutlets -
    @IBOutlet weak var labelTitle       : UILabel!
    @IBOutlet weak var labelSubTitle    : UILabel!
    @IBOutlet weak var viewContainer    : UIView!
    @IBOutlet weak var btnCover         : UIButton!
    @IBOutlet weak var btnImg           : UIButton!
    @IBOutlet weak var imageConstraint  : NSLayoutConstraint!
    @IBOutlet weak var viewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewRightConstraint: NSLayoutConstraint!
    
    
    //Complition
    var didTapCellComplition            : Completion = {}
    var didTouchDownBtnCover            : Completion = {}
    var didTouchUpOutsideBtnCover       : Completion = {}
    var didTouchUpOutsideBtnImage       : Completion = {}
    
    override func awakeFromNib() {
        
    }
    
    @IBAction func didTapBtnCover(_ sender: UIButton) {
        self.didTapCellComplition()
    }
    
    @IBAction func didTouchDownBtnCover(_ sender: UIButton) {
        self.didTouchDownBtnCover()
    }
    
    @IBAction func didTouchUpOutside(_ sender: UIButton) {
        self.didTouchUpOutsideBtnCover()
    }
    
    @IBAction func didTapBtnImage(_ sender: Any) {
        self.didTouchUpOutsideBtnImage()
    }
}

// MARK: - CustomOptionMultipleChoiceCell -

enum CustomOptionMultipleChoiceType : String, CaseIterable {
    case Language   = "language"
    case Photo      = "Photo"
}

class CustomOptionMultipleChoiceCell : UITableViewCell {
    // MARK: - IBOutlets -
    @IBOutlet weak var labelTitle           : UILabel!
    @IBOutlet weak var btnChoose            : UIButton!
    @IBOutlet weak var viewContainer        : UIView!
    @IBOutlet weak var btnCover             : UIButton!
    
    var didTapBtnChooseComplition           : Completion = {}
    var didTouchdownCoverComplition         : Completion = {}
    var didTapBtnCoverComplition            : Completion = {}
    var didTouchUpOutsideBtnCoverComplition : Completion = {}
    // MARK: - Public -
    var type : CustomOptionMultipleChoiceType = .Language
    
    override func awakeFromNib() {
        self.initialize()
    }
    
    private
    func initialize() {
        if type == .Language {
            btnChoose.setImage(UIImage(named: "radio_btn_off"), for: .normal)
            btnChoose.setImage(UIImage(named: "radio_btn_on"), for: .selected)
        }
    }
    
    // MARK: - Setup Data -
    func setupData(title: String, isSelected: Bool = false) {
        labelTitle.text         = title
        btnChoose.isSelected    = isSelected
    }
    
    func setSelectedCell() {
        btnChoose.isSelected = true
    }
    
    func setNormalCell() {
        btnChoose.isSelected = false
    }
    
    @IBAction func didTapBtnChoose(_ sender: UIButton) {
        didTapBtnChooseComplition()
    }
    
    @IBAction func didTapBtnCover(_ sender: UIButton) {
        didTapBtnCoverComplition()
    }
    
    @IBAction func didTouchdownBtnCover(_ sender: Any) {
        didTouchdownCoverComplition()
    }
    
    @IBAction func didTouchUpOutsideBtnCover(_ sender: UIButton) {
        didTouchUpOutsideBtnCoverComplition()
    }
    // MARK: - private Method -
}

// API
extension CustomOptionVC {
    func requestLoginAPI(bizKey: String){
        self.companyVM.requestR002(bizKey: bizKey) { (result) in
            switch result {
            case .success(_):
                // Check allow notification
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.registerForRemoteNotifications()
                MyDefaults.set(key: .autoLogin, value: true)
                UserDefaults.standard.setValue(bizKey, forKey: "bizKey")
                
                // Must match LoginVC.requestLoginAPI: this is the multi-company branch of the
                // same login, reached after the company picker. The old "sideMenuNavigation"
                // identifier exists in no storyboard, so picking a company raised
                // NSInternalInconsistencyException for anyone with more than one company.
                self.setRootViewController(sbName: "MainTabBarSB", identifier: "MainTabBarNav", direction: .toRight)
            case .failure(let error):
//                self.loginVC.showAlertSuccuss(title: "notice".localized, message: error.localizedDescription) {}
                self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: "notice".localized, message: error.localizedDescription, redTitle: "", greyTitle: "ok".localized) { (isRedPress) in }
            }
        }
    }
}


extension UIViewController {
    func customOption(type       : CustomOptionCellType,
                      image      : String = "",
                      title      : String = "",
                      message    : String = "",
                      data       : [String],
                      selectRowAt: Int = -1,
                      subDataRec : [String] = [],
                      imgStrRec  : [String] = [],
                      shouldDimiss: Bool = true,
                      isShowHeaderView: Bool   = true,
                      isBtnDeleteDisable: Bool = false,
                      completion : @escaping Completion_Int = {_ in}) {
        
        let vc = self.callCommonPopup(withStorybordName: "CustomOptionSB", identifier: "CustomOptionVC") as! CustomOptionVC
        vc.customOptionType = type
        vc.imageString      = image
        vc.titleString      = title
        vc.messageString    = message
        vc.dataRec          = data
        vc.subDataRec       = subDataRec
        vc.imgStrRec        = imgStrRec
        vc.selectRow        = selectRowAt
        vc.shouldDimiss     = shouldDimiss
        vc.isShowHeaderView = isShowHeaderView
        
        var heightOfCell : CGFloat = 55
        vc.isBtnDeleteDisable = isBtnDeleteDisable
    
        if type.rawValue == "Detail" {
            heightOfCell = 80
        }
        
        // check safe area
        if !Shared.safeAreaBottom.isZero {
            heightOfCell = heightOfCell + 10
        }
        
        var heightOfTable: CGFloat = 0
        
        if isShowHeaderView {
            //heightOfTable   = (UIScreen.main.bounds.height / 3) 1/3 screen
            heightOfTable   = (CGFloat(data.count) * heightOfCell) + 115.0 + 40 // Hight of header + footer is 115.0 // height of each cell is 55
        }else {
            heightOfTable   = (CGFloat(data.count) * heightOfCell) + 40.0 //  height footer is 40.0 // height of each cell is 55
        }
        

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in heightOfTable }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = false
        }
        
        vc.didTapCloseComplition = {
            
            if !shouldDimiss {
                completion(-1)
            }
        }
        
        vc.didTapCellComplition = { row in
            completion(row)
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func customOptionCompany(type            : CustomOptionCellType,
                             data            : [String],
                             loginR001     : MREC_R001.RESPONSE?,
                             isShowHeaderView: Bool   = true,
                             completion      : @escaping Completion_Int = {_ in}) {
        
        let vc = self.callCommonPopup(withStorybordName: "CustomOptionSB", identifier: "CustomOptionVC") as! CustomOptionVC
        
        vc.loginR001   = loginR001
        vc.dataRec       = data
        vc.selectRow     = 0
        vc.titleString   = "Company"
        vc.messageString = "Please select a company"
        
        var heightOfCell : CGFloat = 55
        
        // check safe area
        if !Shared.safeAreaBottom.isZero {
            heightOfCell = heightOfCell + 10
        }
        
        var heightOfTable: CGFloat = 0
        
        if isShowHeaderView {
            //heightOfTable   = (UIScreen.main.bounds.height / 3) 1/3 screen
            heightOfTable   = (CGFloat(data.count) * heightOfCell) + 115.0 + 40 // Hight of header + footer is 115.0 // height of each cell is 55
        }else {
            heightOfTable   = (CGFloat(data.count) * heightOfCell) + 40.0 //  height footer is 40.0 // height of each cell is 55
        }

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in heightOfTable }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = false
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
}


//
//  PurposeVC.swift
//  WeCMS_iOS
//
//  Created by SteveChea  on 8/1/25.
//

import UIKit

class PurposeVC: UIViewController {
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak var btnClose         : UIButton!
    @IBOutlet weak var lblTitle         : UILabel!
    @IBOutlet weak var tableView        : UITableView!
    
    @IBOutlet weak var searchBtn        : UIButton!
    @IBOutlet weak var headerView       : UIView!
    @IBOutlet weak var searchView       : UIView!
    @IBOutlet weak var txtFieldSearch   : UITextField!
    
    //Not Found
    @IBOutlet weak var notFoundView     : UIView!
    @IBOutlet weak var notFoundImgView  : UIStackView!
    @IBOutlet weak var notFoundLbl      : UILabel!
    
    //Not Internet View
    @IBOutlet weak var noInternetView       : UIView!
    @IBOutlet weak var noInternetTitileLbl  : UILabel!
    @IBOutlet weak var noInternetDescLbl    : UILabel!
    @IBOutlet weak var tryAgainBtn          : UIButton!
    
    
    var sectionTitleRec     = [String]()
    var selectIndexPath     : IndexPath?
    var isSearchBtn         = false
    
    var selectUserListVM    = SelectUserListVM()
    var selectUserListKey   = "" //used for set selection
    var isInSearchMode      = false
    var isShowPlanned_money = true
    var isShowOnlyPlanned_money = true
    var isAdvanceLedger     = false
    
    var searchText          = ""
    var headerTitle         = ""

    var recFilteredData     : [LIST_POP_UP_RESPONSE.REC]        = []
    var rec2FilteredData    : [LIST_POP_UP_RESPONSE.REC2]       = []
    var rec3FilteredData    : [LIST_POP_UP_RESPONSE.USE_LIST]   = []
  
    ///Delegate
    var delegate            : SelectPurposeDelegate?
    var popUpType           = POPUP_TYPE.PURPOSE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLocalized()
        self.tableView.tableFooterView  = UIView()
        
        searchBtn.setTitle("", for: .normal)
        searchView.borderWidth = 1
        searchView.borderColor = UIColor(hexString: "#000000").withAlphaComponent(0.2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switch popUpType {
        case .PROJECT_SITE :
            self.fetch_Project_Site()
        case .WITH_HOLDING_TAX :
            self.fetchWithHoldingTax()
        default :
            self.fetchUserListAPI()
            
        }
    }
    
    private func setupLocalized() {
        notFoundView.isHidden       = true
        lblTitle.text               = headerTitle
//        lblTitle.text               = isAdvanceLedger ? "select_a_advance_ledger".localized : "select_a_purpose".localized
        notFoundLbl.text            = popUpType == .WITH_HOLDING_TAX ? "no_withholding_tax_found".localized : isShowOnlyPlanned_money ? "no_advance_ledger_found".localized : "no_purpose_found".localized
        txtFieldSearch.placeholder  = popUpType == .WITH_HOLDING_TAX ? "search_withholding_tax".localized : isShowOnlyPlanned_money ? "search_advance_ledger".localized : "search_purpose".localized
        
        sectionTitleRec = ["recent".localized, popUpType == .WITH_HOLDING_TAX ? "all_withholding_tax".localized : "all_purpose".localized , "all_advance_ledger".localized]
        
        //no internet
        self.noInternetView.isHidden = true
        noInternetTitileLbl.text    = "connection_is_unstable".localized
        noInternetDescLbl.text      = "connection_is_unstable_please_try_again_later".localized
        tryAgainBtn.setTitle("try_again".localized, for: .normal)
         
        lblTitle.getlocalizedFont()
        notFoundLbl.getlocalizedFont()
        tryAgainBtn.getlocalizedFont()
        txtFieldSearch.getlocalizedFont()
        noInternetDescLbl.getlocalizedFont()
        noInternetTitileLbl.getlocalizedFont()
    }
    
    // MARK: - IBActions -
    @IBAction func didTapBtnSearch(_ sender: UIButton) {
        animatedViewLeft()
        txtFieldSearch.becomeFirstResponder()
        self.isSearchBtn.toggle()
        self.notFoundView.isHidden          = true

    }
    
    @IBAction func didTapTryAgainBtn(_ sender: UIButton) {
//        self.fetchUserListAPI()
    }
    @IBAction func editChangedTfSearch(_ sender: UITextField) {
        let text = sender.text ?? ""
        
        searchText = text
        
        self.isInSearchMode = true
        self.searchFilter(text)
        
        if text.isEmpty {
            self.isInSearchMode = false
            self.tableView.reloadData()
        }
    }
    //cancel action
    @IBAction func cancelAction(_ sender: Any) {
        animatedViewRight()
        
        //if pressed btnSearch when btnSearch has text CANCEL
        //we need to clear search data
        txtFieldSearch.text         = ""
        self.isInSearchMode         = false
        self.notFoundView.isHidden  = true
        self.tableView.reloadData()
    }
    //close action
    @IBAction func didTapBtnClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PurposeVC {
    
    private func searchFilter(_ text: String) {
        self.recFilteredData = (self.selectUserListVM.userListResponse?.REC.filter {
            ($0.USAG_NM).localizedCaseInsensitiveContains(text)
        }) ?? []
        
        self.rec2FilteredData = (self.selectUserListVM.userListResponse?.REC2.filter {
            (($0.ADV_PAYM_NM).localizedCaseInsensitiveContains(text))
        }) ?? []
        
        self.rec3FilteredData = (self.selectUserListVM.userListResponse?.USE_LIST.filter {
            (($0.USAG_NM).localizedCaseInsensitiveContains(text))
        }) ?? []

        
        if popUpType == .PROJECT_SITE {
            if self.rec3FilteredData.count == 0 && self.txtFieldSearch.text != "" {
                self.notFoundView.isHidden = false
            } else {
                self.notFoundView.isHidden = true
            }
        } else if isShowOnlyPlanned_money {
            if self.rec2FilteredData.count == 0 && self.txtFieldSearch.text != "" {
                self.notFoundView.isHidden = false
            } else {
                self.notFoundView.isHidden = true
            }
        } else {
            if self.recFilteredData.count == 0 && self.txtFieldSearch.text != "" {
                self.notFoundView.isHidden = false
            } else {
                self.notFoundView.isHidden = true
            }
        }
        
        self.tableView.reloadData()
    }
    
    private func setDisableTfSearch(isDisable: Bool) {
        txtFieldSearch.isHidden                   = isDisable
        txtFieldSearch.isUserInteractionEnabled   = !isDisable
    }
    private func setHiddenLblTitle(isHidden: Bool) {
        lblTitle.isHidden = isHidden
    }
    
    private func isSelectAtThisIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath == self.selectIndexPath
    }
    // Slide Left Animation
    private func animatedViewLeft() {
        UIView.animate(withDuration: 0.35, animations: {
            
            let moveLeft = CGAffineTransform(translationX: -(self.view.bounds.width * 1), y: 0.0)
            self.headerView.transform = moveLeft
        })
    }
    
    // Slide Right Animation
    private func animatedViewRight() {
        self.isInSearchMode = false
        UIView.animate(withDuration: 0.35, animations: {
            
            let moveRight = CGAffineTransform(translationX: -(self.view.bounds.width * 0.0), y: 1)
            self.headerView.transform = moveRight
            self.txtFieldSearch.text = ""
        })
    }
}


extension PurposeVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isShowPlanned_money ? SelectPurposeSection.allCases.count : SelectPurposeSection.allCases.count - 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let selectPurposeSection = SelectPurposeSection(rawValue: section)
        
        if self.isInSearchMode {
            switch selectPurposeSection {
            case .Recently:
                return 0 //return number of recently section 0 when in search
                
            case .Entire:
                return popUpType == .PROJECT_SITE ? self.rec3FilteredData.count : self.isShowOnlyPlanned_money ? 0 : self.recFilteredData.count
                
            case .Planned_Money:
                return self.rec2FilteredData.count
                
            default:
                return 0
            }
        }
        else {
            switch selectPurposeSection {
            case .Recently  :
                return 1
                
            case .Entire    :
                return self.isShowOnlyPlanned_money ? 0 : (self.selectUserListVM.userListResponse?.REC.count ?? 0)
                
            case .Planned_Money :
                return self.isShowOnlyPlanned_money ? (self.selectUserListVM.userListResponse?.REC2.count ?? 0) : 0
                
            default  :
                return 0
            }
        }
    }
    
    /// WeCMS never shows section headers in the purpose list, so the height is always 0.
    ///
    /// This used to be `if popUpType == .PROJECT_SITE || Shared.wabooksVersion == .WeCMS { return 0 }`
    /// followed by the WABOOKS Recently / Entire / Planned-money header sizing. Collapsing the
    /// product check left that sizing unreachable after an unconditional `return`; it is dropped
    /// here rather than left as dead code the compiler warns about on every build.
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    /// No section headers in WeCMS — see `heightForHeaderInSection`.
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = SelectPurposeSection(rawValue: indexPath.section)
//        let font    =  UIFont(name: "Inter-Medium", size: 15) ?? UIFont.systemFont(ofSize: 15)
//
//
        let font =  UIFont(name: "Inter-Medium", size: 15)
        
        
        if self.isInSearchMode {
            switch section {
            case .Entire:
                var recFilteredData : LIST_POP_UP_RESPONSE.REC!
                var rec3FilteredData: LIST_POP_UP_RESPONSE.USE_LIST!
                
                if self.recFilteredData.count > 0 {
                    recFilteredData     = self.recFilteredData[indexPath.row]
                }
                
                if self.rec3FilteredData.count > 0 {
                    rec3FilteredData     = self.rec3FilteredData[indexPath.row]
                }

                let cell                = self.tableView.dequeueReusableCell(withIdentifier: "SelectPurposeCell") as! SelectPurposeCell
                
                if popUpType == .PROJECT_SITE {
                    cell.lblTitle.text  = self.rec3FilteredData[indexPath.row].USAG_NM
                    cell.styleSelectedCell(isSelected: rec3FilteredData.USE_USAG_CD == self.selectUserListKey)
                    cell.lblTitle.getlocalizedFont()
                } else {
                    cell.lblTitle.text  = self.recFilteredData[indexPath.row].USAG_NM
                    cell.styleSelectedCell(isSelected: recFilteredData.USE_USAG_CD == self.selectUserListKey)
                    cell.lblTitle.getlocalizedFont()
                }
                
                
                // highlight color on search result text
                let textForDisplay  = popUpType == .PROJECT_SITE ? self.rec3FilteredData[indexPath.row].USAG_NM : self.recFilteredData[indexPath.row].USAG_NM
                var textAttribute   = NSMutableAttributedString()
                textAttribute       = NSMutableAttributedString(string: textForDisplay, attributes: [NSAttributedString.Key.font : font])
                textAttribute.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "3E4449")], range: NSMakeRange(0, textForDisplay.count))
                let range           : NSRange = (textForDisplay as NSString).range(of: self.searchText)
                textAttribute.setAttributes([NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : UIColor(hexString: "4286F5")], range: range)
                cell.lblTitle.attributedText = textAttribute
                
                cell.didTapBtnCoverCompletion = {
                    DispatchQueue.main.async {
                        self.selectIndexPath    = indexPath
                        self.selectUserListKey  = self.popUpType == .PROJECT_SITE ? rec3FilteredData.USE_USAG_CD : recFilteredData.USE_USAG_CD
                        self.tableView.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            switch self.popUpType {
                            case .WITH_HOLDING_TAX :
                                self.delegate?.sendRECItem(rec: recFilteredData, type: .WITH_HOLDING_TAX)
                            case.PURPOSE :
                                self.delegate?.sendRECItem(rec: recFilteredData, type: .PURPOSE)
                            case .PROJECT_SITE:
                                let REC = LIST_POP_UP_RESPONSE.PROJECT_SITE_LIST(PRJT_NO: rec3FilteredData.USE_USAG_CD, PRJT_NM: rec3FilteredData.USAG_NM)
                                self.delegate?.sendProjectREC(rec: REC)
                            }
                            self.popOrDismissVC()
                        }
                    }
                }
                return cell
                
            case .Planned_Money:
                let cell                = self.tableView.dequeueReusableCell(withIdentifier: "SelectAdvanceLedgerCell") as! SelectAdvanceLedgerCell
                let message             = "person_in_charge_OOO".localized
                cell.lblTitle.text      = self.rec2FilteredData[indexPath.row].ADV_PAYM_NM
                cell.lblSubTitle.text   = String(format: message, "\(self.rec2FilteredData[indexPath.row].USER_NM)")
                let filteredRec2        = self.rec2FilteredData[indexPath.row]
                cell.styleSelectedCell(isSelected: filteredRec2.ADV_PAYM_SEQ == self.selectUserListKey)
                
                // highlight color on search result text
                if rec2FilteredData.count > 0 {
                    let textForDisplay = self.rec2FilteredData[indexPath.row].ADV_PAYM_NM
                    var textAttribute = NSMutableAttributedString()
                    textAttribute = NSMutableAttributedString(string: textForDisplay, attributes: [NSAttributedString.Key.font : font])
                    textAttribute.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "3E4449")], range: NSMakeRange(0, textForDisplay.count))
                    let range : NSRange = (textForDisplay as NSString).range(of: self.searchText)
                    textAttribute.setAttributes([NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : UIColor(hexString: "4286F5")], range: range)
                    cell.lblTitle.attributedText = textAttribute
                }
 
                cell.didTapBtnCoverCompletion = {
                    DispatchQueue.main.async {
                        self.selectIndexPath    = indexPath
                        self.selectUserListKey  = filteredRec2.ADV_PAYM_SEQ
                        self.tableView.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.delegate?.sendREC2Item(rec2: filteredRec2)
                            self.popOrDismissVC()
                        }
                    }
                }
                
                return cell
                
            default:
                return UITableViewCell()
            }
        } else {
            
            switch section {
            case .Recently:
                let cell            = self.tableView.dequeueReusableCell(withIdentifier: "SelectPurposeCell") as! SelectPurposeCell
                let userList        = self.selectUserListVM.userListResponse?.USE_LIST[safe: indexPath.row]
                let noneUseList =  LIST_POP_UP_RESPONSE.USE_LIST(USE_USAG_CD: "", USAG_NM: "None")

                cell.lblTitle.text  = noneUseList.USAG_NM
                cell.styleSelectedCell(isSelected: "" == self.selectUserListKey)
               
                //Completion
                cell.didTapBtnCoverCompletion = {
                    DispatchQueue.main.async {
                        self.selectIndexPath    = indexPath
                        self.selectUserListKey  = noneUseList.USE_USAG_CD
                        self.tableView.reloadData()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            if self.popUpType == .PROJECT_SITE {
                                let REC = LIST_POP_UP_RESPONSE.PROJECT_SITE_LIST(PRJT_NO: userList?.USE_USAG_CD ?? "", PRJT_NM: userList?.USAG_NM ?? "")
                                self.delegate?.sendProjectREC(rec: REC)
                            } else {
                                self.delegate?.sendUserListItem(userList: noneUseList)
                            }
                            self.popOrDismissVC()
                        }
                    }
                }
                return cell
                
            case .Entire:
                let cell            = self.tableView.dequeueReusableCell(withIdentifier: "SelectPurposeCell") as! SelectPurposeCell
                let rec             = self.selectUserListVM.userListResponse?.REC[indexPath.row]

                cell.lblTitle.text  = rec?.USAG_NM ?? ""
                cell.styleSelectedCell(isSelected: rec?.USE_USAG_CD == self.selectUserListKey)
                
                //Completion
                cell.didTapBtnCoverCompletion = {
                    self.selectIndexPath      = indexPath
                    self.selectUserListKey    = rec?.USE_USAG_CD ?? ""
                    self.tableView.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if rec != nil {
                            switch self.popUpType {
                            case .WITH_HOLDING_TAX :
                                self.delegate?.sendRECItem(rec: rec!, type: .WITH_HOLDING_TAX)
                            case.PURPOSE :
                                self.delegate?.sendRECItem(rec: rec!, type: .PURPOSE)
                            case .PROJECT_SITE:
                                self.delegate?.sendRECItem(rec: rec!, type: .PROJECT_SITE)
                            }
                            
                            self.popOrDismissVC()
                        }
                    }
                }
                return cell
                
            case .Planned_Money:
                let cell    = self.tableView.dequeueReusableCell(withIdentifier: "SelectAdvanceLedgerCell") as! SelectAdvanceLedgerCell
                let message = "person_in_charge_OOO".localized
                let rec2    = self.selectUserListVM.userListResponse?.REC2[indexPath.row]
                cell.lblTitle.text      = rec2?.ADV_PAYM_NM ?? ""
//                cell.lblSubTitle.text   = "\("person_in_charge_OOO".localized) \(rec2?.USER_NM ?? "")"
                cell.lblSubTitle.text   = String(format: message, "\(rec2?.USER_NM ?? "")")
                cell.styleSelectedCell(isSelected: rec2?.ADV_PAYM_SEQ == self.selectUserListKey)
                
                //Completion
                cell.didTapBtnCoverCompletion = {
                    self.selectIndexPath      = indexPath
                    self.selectUserListKey    = rec2?.ADV_PAYM_SEQ ?? ""
                    self.tableView.reloadData()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if rec2 != nil {
                            self.delegate?.sendREC2Item(rec2: rec2!)
                            self.popOrDismissVC()
                        }
                    }
                }
                return cell
                
            default:
                return UITableViewCell()
            }
        }
        
    }
}

// MARK: - API -
extension PurposeVC {
    ///Fetch User List API
    func fetchUserListAPI() {
        self.selectUserListVM.fectchUserList { (error) in
            if error != nil {
                if error?.code == 1007 {
                    //self.noInternetView.isHidden = false
                } else {
                  //  self.noInternetView.isHidden = true
                }
                self.showCustomAlert(titlte: "notice".localized, message: error?.localizedDescription ?? "") {}
                return
            }
            //Success
            self.noInternetView.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    // TODO: - Fetch withHoldingTax
    func fetchWithHoldingTax() {
        self.selectUserListVM.fetchWithHoldingTax { (error) in
            if error != nil {
                if error?.code == 1007 {
                  //  self.noInternetView.isHidden = false
                } else {
                  //  self.noInternetView.isHidden = true
                }
                self.showCustomAlert(titlte: "notice".localized, message: error?.localizedDescription ?? "") {}
                return
            }
            //Success
          //  self.noInternetView.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    // TODO: - Fetch Project/Site
    func fetch_Project_Site() {
        self.selectUserListVM.fetch_Project_Site { (error) in
            if error != nil {
                if error?.code == 1007 {
                  //  self.noInternetView.isHidden = false
                } else {
                  //  self.noInternetView.isHidden = true
                }
                self.showCustomAlert(titlte: "notice".localized, message: error?.localizedDescription ?? "") {}
                return
            }
            //Success
          //  self.noInternetView.isHidden = true
            self.tableView.reloadData()
        }
    }
}

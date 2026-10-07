//
//  SelectPurposeVC.swift
//  WeCMS_iOS
//
//  Created by Thea Chum on 13/1/21.
//

import UIKit

///Enum representing Sections
enum SelectPurposeSection : Int, CaseIterable {
    case Recently
    case Entire
    case Planned_Money
}

enum POPUP_TYPE {
    case WITH_HOLDING_TAX
    case PURPOSE
    case PROJECT_SITE
}

///Delegate
protocol SelectPurposeDelegate: AnyObject {
    func sendRECItem(rec: LIST_POP_UP_RESPONSE.REC, type: POPUP_TYPE)
    func sendREC2Item(rec2: LIST_POP_UP_RESPONSE.REC2)
    func sendUserListItem(userList: LIST_POP_UP_RESPONSE.USE_LIST)
    func sendProjectREC(rec: LIST_POP_UP_RESPONSE.PROJECT_SITE_LIST)
}

class SelectPurposeVC: UIViewController {

    // MARK: - IBOutlets -

    @IBOutlet weak var btnClose         : UIButton!
    @IBOutlet weak var btnSearch        : UIButton!
    @IBOutlet weak var lblTitle         : UILabel!
    @IBOutlet weak var tableView        : UITableView!
    @IBOutlet weak var cstWBtnSearch    : NSLayoutConstraint!

    @IBOutlet weak var headerView       : UIView!
    @IBOutlet weak var searchView       : UIView!
    @IBOutlet weak var btnCancel1       : UIButton!
    @IBOutlet weak var txtFieldSearch   : UITextField!
    @IBOutlet weak var btnSearch1       : UIButton!

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

    private var hasLoadedData = false

    var searchText          = ""
    var headerTitle         = ""

    var recFilteredData     : [LIST_POP_UP_RESPONSE.REC]        = []
    var rec2FilteredData    : [LIST_POP_UP_RESPONSE.REC2]       = []
    var rec3FilteredData    : [LIST_POP_UP_RESPONSE.USE_LIST]   = []


    ///Delegate
    weak var delegate       : SelectPurposeDelegate?
    var popUpType           = POPUP_TYPE.PURPOSE

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLocalized()
        self.tableView.tableFooterView  = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !hasLoadedData else { return }
        hasLoadedData = true

        switch popUpType {
        case .PROJECT_SITE:
            self.fetch_Project_Site()
        case .WITH_HOLDING_TAX:
            self.fetchWithHoldingTax()
        default:
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
        btnCancel1.setTitle("cancel".localized , for: .normal)

        lblTitle.getlocalizedFont()
        btnSearch.getlocalizedFont()
        notFoundLbl.getlocalizedFont()
        tryAgainBtn.getlocalizedFont()
        txtFieldSearch.getlocalizedFont()
        noInternetDescLbl.getlocalizedFont()
        noInternetTitileLbl.getlocalizedFont()

//        setDisableTfSearch(isDisable: true)
//        setHiddenLblTitle(isHidden: false)
    }

    // MARK: - IBActions -
    @IBAction func didTapBtnSearch(_ sender: UIButton) {
        animatedViewLeft()
        txtFieldSearch.becomeFirstResponder()
        self.isSearchBtn.toggle()
        self.notFoundView.isHidden          = true
//        setDisableTfSearch(isDisable: !isSearchBtn)
//        setHiddenLblTitle(isHidden: self.isSearchBtn)

        //        UIView.animate(withDuration: 0.5, animations: {
        //            self.txtFieldSearch.transform = CGAffineTransform.identity.scaledBy(x: 0.99, y: 0.99)
        //        })

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
//        setDisableTfSearch(isDisable: isSearchBtn)
//        setHiddenLblTitle(isHidden: !isSearchBtn)

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
//        if !self.isSearchBtn {
//            self.dismiss(animated: true) {}
//        }
    }
}

extension SelectPurposeVC {

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

    // Returns attributed string with matching query range highlighted in blue.
    // Handles NSNotFound safely and uses NSString.length (UTF-16) for correct Khmer/emoji range math.
    private func highlightedAttributedString(_ text: String, query: String, font: UIFont?) -> NSAttributedString {
        let ns = text as NSString
        let attr = NSMutableAttributedString(
            string: text,
            attributes: [.font: font as Any, .foregroundColor: UIColor(hexString: "3E4449")]
        )
        guard !query.isEmpty else { return attr }
        let matchRange = ns.range(of: query, options: .caseInsensitive)
        guard matchRange.location != NSNotFound else { return attr }
        attr.addAttributes([.foregroundColor: UIColor(hexString: "4286F5")], range: matchRange)
        return attr
    }

//    private func setCancelBtn(){
//       btnCancel1.setTitle("cancel".localized , for: .normal)
//       btnSearch1.setImage(UIImage(named: "head_search_normal"), for: .normal)
//    }
//    private func setSearchBtn() {
//        btnSearch.setTitle(self.isSearchBtn ? "cancel".localized : "", for: .normal)
//        btnSearch.setImage(UIImage(named: isSearchBtn ? "" : "head_search_blue"), for: .normal)

        //btnClose
//        btnClose.setImage(UIImage(named: "head_close_blue"), for: .normal)
//        btnClose.setImage(UIImage(named: self.isSearchBtn ? "head_search_normal" : "head_close_blue"), for: .normal)
//        cstWBtnSearch.constant  = isSearchBtn ? 100 : 46

//    }
}


extension SelectPurposeVC : UITableViewDelegate, UITableViewDataSource {

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
                return self.isShowOnlyPlanned_money ? 0 : (self.selectUserListVM.userListResponse?.USE_LIST.count ?? 0)

            case .Entire    :
                return self.isShowOnlyPlanned_money ? 0 : (self.selectUserListVM.userListResponse?.REC.count ?? 0)

            case .Planned_Money :
                return self.isShowOnlyPlanned_money ? (self.selectUserListVM.userListResponse?.REC2.count ?? 0) : 0

            default  :
                return 0
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let selectPurposeSection = SelectPurposeSection(rawValue: section)

        if popUpType == .PROJECT_SITE {
            return 0
        }

        if self.isInSearchMode {
            switch selectPurposeSection {
            case .Recently: //hide header section when search mode
                return 0

            case .Entire:
                return self.isShowOnlyPlanned_money ? 0 : 34

            case .Planned_Money: //hide header section when search mode
                return self.isShowOnlyPlanned_money ? 34 : 0
                //
            default:
                return 0
            }
        } else {

            switch selectPurposeSection {
            case .Recently:
                return self.isShowOnlyPlanned_money ? 0 : (self.selectUserListVM.userListResponse?.USE_LIST.count == 0 ? 0 : 34)

            case .Entire:
                return self.isShowOnlyPlanned_money ? 0 : (self.selectUserListVM.userListResponse?.REC.count == 0 ? 0 : 34)

            case .Planned_Money:
                return self.isShowOnlyPlanned_money ? (self.selectUserListVM.userListResponse?.REC2.count == 0 ? 0 : 34) : 0

            default: return 0
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if popUpType == .PROJECT_SITE {
            return nil
        }

        //Init Label
        let titleLabel          = UILabel()
        titleLabel.frame        = CGRect(x: 7, y: 0, width: tableView.frame.size.width, height: 34)
        titleLabel.textColor    = UIColor(hexString: "9FADB9")
        titleLabel.font         = UIFont(name: "Inter-Regular", size: 13) //Init default font
        titleLabel.text         = self.isInSearchMode ? "result".localized.camelCased : self.sectionTitleRec[safe: section] ?? ""
        titleLabel.getlocalizedFont()

        //Add Label To HeaderView
        let headerView              = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 34))
        headerView.backgroundColor  = UIColor(hexString: "FFFFFF")
        headerView.addSubview(titleLabel)

        return headerView
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = SelectPurposeSection(rawValue: indexPath.section)
        let font: UIFont? = UIFont(name: "Inter-Medium", size: 15)

        if self.isInSearchMode {
            switch section {
            case .Entire:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectPurposeCell") as? SelectPurposeCell else { return UITableViewCell() }

                if popUpType == .PROJECT_SITE {
                    guard let item = self.rec3FilteredData[safe: indexPath.row] else { return UITableViewCell() }
                    cell.lblTitle.text = item.USAG_NM
                    cell.styleSelectedCell(isSelected: item.USE_USAG_CD == self.selectUserListKey)
                    cell.lblTitle.getlocalizedFont()
                    cell.lblTitle.attributedText = highlightedAttributedString(item.USAG_NM, query: searchText, font: font)
                    cell.didTapBtnCoverCompletion = { [weak self] in
                        guard let self else { return }
                        self.selectIndexPath = indexPath
                        self.selectUserListKey = item.USE_USAG_CD
                        self.tableView.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                            guard let self else { return }
                            let rec = LIST_POP_UP_RESPONSE.PROJECT_SITE_LIST(PRJT_NO: item.USE_USAG_CD, PRJT_NM: item.USAG_NM)
                            self.delegate?.sendProjectREC(rec: rec)
                            self.popOrDismissVC()
                        }
                    }
                } else {
                    guard let item = self.recFilteredData[safe: indexPath.row] else { return UITableViewCell() }
                    cell.lblTitle.text = item.USAG_NM
                    cell.styleSelectedCell(isSelected: item.USE_USAG_CD == self.selectUserListKey)
                    cell.lblTitle.getlocalizedFont()
                    cell.lblTitle.attributedText = highlightedAttributedString(item.USAG_NM, query: searchText, font: font)
                    cell.didTapBtnCoverCompletion = { [weak self] in
                        guard let self else { return }
                        self.selectIndexPath = indexPath
                        self.selectUserListKey = item.USE_USAG_CD
                        self.tableView.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                            guard let self else { return }
                            self.delegate?.sendRECItem(rec: item, type: self.popUpType)
                            self.popOrDismissVC()
                        }
                    }
                }
                return cell

            case .Planned_Money:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAdvanceLedgerCell") as? SelectAdvanceLedgerCell else { return UITableViewCell() }
                guard let item = self.rec2FilteredData[safe: indexPath.row] else { return UITableViewCell() }
                let message = "person_in_charge_OOO".localized
                cell.lblTitle.text = item.ADV_PAYM_NM
                cell.lblSubTitle.text = String(format: message, "\(item.USER_NM)")
                cell.styleSelectedCell(isSelected: item.ADV_PAYM_SEQ == self.selectUserListKey)
                cell.lblTitle.attributedText = highlightedAttributedString(item.ADV_PAYM_NM, query: searchText, font: font)
                cell.didTapBtnCoverCompletion = { [weak self] in
                    guard let self else { return }
                    self.selectIndexPath = indexPath
                    self.selectUserListKey = item.ADV_PAYM_SEQ
                    self.tableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                        guard let self else { return }
                        self.delegate?.sendREC2Item(rec2: item)
                        self.popOrDismissVC()
                    }
                }
                return cell

            default:
                return UITableViewCell()
            }
        } else {
            switch section {
            case .Recently:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectPurposeCell") as? SelectPurposeCell else { return UITableViewCell() }
                guard let response = self.selectUserListVM.userListResponse,
                      let item = response.USE_LIST[safe: indexPath.row] else { return UITableViewCell() }
                cell.lblTitle.text = item.USAG_NM
                cell.styleSelectedCell(isSelected: item.USE_USAG_CD == self.selectUserListKey)
                cell.didTapBtnCoverCompletion = { [weak self] in
                    guard let self else { return }
                    self.selectIndexPath = indexPath
                    self.selectUserListKey = item.USE_USAG_CD
                    self.tableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                        guard let self else { return }
                        if self.popUpType == .PROJECT_SITE {
                            let rec = LIST_POP_UP_RESPONSE.PROJECT_SITE_LIST(PRJT_NO: item.USE_USAG_CD, PRJT_NM: item.USAG_NM)
                            self.delegate?.sendProjectREC(rec: rec)
                        } else {
                            self.delegate?.sendUserListItem(userList: item)
                        }
                        self.popOrDismissVC()
                    }
                }
                return cell

            case .Entire:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectPurposeCell") as? SelectPurposeCell else { return UITableViewCell() }
                guard let response = self.selectUserListVM.userListResponse,
                      let item = response.REC[safe: indexPath.row] else { return UITableViewCell() }
                cell.lblTitle.text = item.USAG_NM
                cell.styleSelectedCell(isSelected: item.USE_USAG_CD == self.selectUserListKey)
                cell.didTapBtnCoverCompletion = { [weak self] in
                    guard let self else { return }
                    self.selectIndexPath = indexPath
                    self.selectUserListKey = item.USE_USAG_CD
                    self.tableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                        guard let self else { return }
                        self.delegate?.sendRECItem(rec: item, type: self.popUpType)
                        self.popOrDismissVC()
                    }
                }
                return cell

            case .Planned_Money:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAdvanceLedgerCell") as? SelectAdvanceLedgerCell else { return UITableViewCell() }
                guard let response = self.selectUserListVM.userListResponse,
                      let item = response.REC2[safe: indexPath.row] else { return UITableViewCell() }
                let message = "person_in_charge_OOO".localized
                cell.lblTitle.text = item.ADV_PAYM_NM
                cell.lblSubTitle.text = String(format: message, "\(item.USER_NM)")
                cell.styleSelectedCell(isSelected: item.ADV_PAYM_SEQ == self.selectUserListKey)
                cell.didTapBtnCoverCompletion = { [weak self] in
                    guard let self else { return }
                    self.selectIndexPath = indexPath
                    self.selectUserListKey = item.ADV_PAYM_SEQ
                    self.tableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                        guard let self else { return }
                        self.delegate?.sendREC2Item(rec2: item)
                        self.popOrDismissVC()
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
extension SelectPurposeVC {
    ///Fetch User List API
    func fetchUserListAPI() {
        self.selectUserListVM.fectchUserList { [weak self] error in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if let error {
                    self.showCustomAlert(titlte: "notice".localized, message: error.localizedDescription) {}
                    return
                }
                self.noInternetView.isHidden = true
                self.tableView.reloadData()
            }
        }
    }

    // TODO: - Fetch withHoldingTax
    func fetchWithHoldingTax() {
        self.selectUserListVM.fetchWithHoldingTax { [weak self] error in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if let error {
                    self.showCustomAlert(titlte: "notice".localized, message: error.localizedDescription) {}
                    return
                }
                self.tableView.reloadData()
            }
        }
    }

    // TODO: - Fetch Project/Site
    func fetch_Project_Site() {
        self.selectUserListVM.fetch_Project_Site { [weak self] error in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if let error {
                    self.showCustomAlert(titlte: "notice".localized, message: error.localizedDescription) {}
                    return
                }
                self.tableView.reloadData()
            }
        }
    }
}

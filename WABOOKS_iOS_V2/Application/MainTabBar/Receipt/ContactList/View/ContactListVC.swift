//
//  ContactListVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Nyta on 1/6/21.
//

import UIKit


class ContactListVC: UIViewController {
    
    @IBOutlet weak var tableView        : UITableView!
    
    // In Search View (TextField)
    @IBOutlet weak var tfSearch         : UITextField!
    @IBOutlet weak var btnCancel        : UIButton!
    @IBOutlet weak var viewSearch       : UIView!
    
    // In Select a Contact (Label)
    @IBOutlet weak var btnSearch1       : UIButton!
    @IBOutlet weak var lblSelectContact : UILabel!
    @IBOutlet weak var viewSelectContact: UIView!
    @IBOutlet weak var btnClose         : UIButton!
    @IBOutlet weak var noDataView       : UIView!
    @IBOutlet weak var noDataLbl        : UILabel!
    @IBOutlet weak var tryBtn           : UIButton!
    
    //No Network Connection
    @IBOutlet weak var noInternetConnectionView     : UIView!
    @IBOutlet weak var noInterConnectionTitleLbl    : UILabel!
    @IBOutlet weak var noInternetConnectionDescrLbl : UILabel!
    
    // Create Empty array to store data
    var arrayRecent         = [WABOOKS_MREC_R030.REC1]()
    var arrayAllContacts    = [WABOOKS_MREC_R030.REC2]()
    // Filtered Data
    var filteredArrayRecent         = [WABOOKS_MREC_R030.REC1]()
    var filteredArrayAllContacts    = [WABOOKS_MREC_R030.REC2]()
    
    // Obj
//    var REC1 : WABOOKS_MREC_R030.REC1?
//    var REC2 : WABOOKS_MREC_R030.REC2?
    
    var arrayAll            = [WABOOKS_MREC_R030.Respone]()
    
    var headerTitles = ["recent".localized, "all_contact".localized]
    
    //Store searched data
    var filterData          = [WABOOKS_MREC_R030.REC2]()
    var contactCompletion  : Completion_String       = {_ in}
    
    //Remember Selected Contact
    var contactSelected : String?
    
    var isInSearchMode      = false
    
    var delegate        : getContactListDelegate?
    var selectIndexPath : Int    = 0
    var selectedIndexPath : IndexPath?
    var r030REC1        : WABOOKS_MREC_R030.REC1?
    var r030REC2        : WABOOKS_MREC_R030.REC2?
    
    var searchText      : String?
    var heightOfAllCells : CGFloat = 0
    var height: CGFloat = 0
    
    // variable to get data from SubmitReceiptVC
    var TRCO_CMNM       : String?
    var TRSC_CCY_CD     : String?
    var TRCO_KEY        : String?
    var contact         : String?
   
    private var isSelectedCell = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Localized Font and Text
        setupView()
        
        // Fetch Contact
        requestContactData()
    }

    //MARK: - Private Function
    private func setupView() {
        localizeFont()
        localizeText()
    }
    
    private func localizeFont() {
        tfSearch.getlocalizedFont()
        btnCancel.getlocalizedFont()
        lblSelectContact.getlocalizedFont()
        noDataLbl.getlocalizedFont()
    }
    
    private func localizeText() {
        noDataLbl.text = "no_contact_found".localized
        
        noInterConnectionTitleLbl.text      = "connection_is_unstable".localized
        noInternetConnectionDescrLbl.text   = "connection_is_unstable_please_try_again_later".localized
        noDataLbl.text                      = "no_contact_found".localized
        tryBtn.setTitle("try_again".localized, for: .normal)
        lblSelectContact.text         = "select_a_contact".localized
        tfSearch.placeholder          = " " + "search_contact".localized
        btnCancel.setTitle("cancel_btn".localized, for: .normal)
    }
    
    // Search String depends on user input
    func filterSearch(NM: String) -> Bool {
        var REC1 : [WABOOKS_MREC_R030.REC1] = [] //recent
        var REC2 : [WABOOKS_MREC_R030.REC2] = [] //allcontact
        
        REC1 = self.arrayRecent.filter { ($0.TRCO_CMENM?.lowercased().contains(NM.lowercased()) ?? false) }
        
        REC2 = self.arrayAllContacts.filter { ($0.TRCO_CMENM?.lowercased().contains(NM.lowercased()) ?? false) }
        
        return REC1.isEmpty && REC2.isEmpty
    }
    
    
    // Search String in REC1
    func filteredREC1(NM: String) -> [WABOOKS_MREC_R030.REC1] {
        
//        REC2_Obj.TRCO_CMENM
        
        let REC1 = self.arrayRecent.filter { ($0.TRCO_CMENM?.lowercased().contains(NM.lowercased()) ?? false) }
        return REC1
        
    }
    
    // Search String in REC2
    func filteredREC2(NM: String) -> [WABOOKS_MREC_R030.REC2] {
        let REC2 = self.arrayAllContacts.filter { ($0.TRCO_CMENM?.lowercased().contains(NM.lowercased()) ?? false) }
        return REC2
    }
    
    @IBAction func didTapTryBtn(_ sender: UIButton) {
        requestContactData()
    }
    
    @IBAction func actionClose(_ sender: Any) {
        popOrDismissVC()
    }
    
    @IBAction func actionSearch(_ sender: Any) {
        animatedViewLeft()
        tfSearch.becomeFirstResponder()
    }
    @IBAction func didEditingChanged(_ sender: Any) {
        searchString()
    }
    
    
    @IBAction func actionCancel(_ sender: Any) {
        animatedViewRight()
    }
}

extension ContactListVC {
    
    // Slide Left Animation
    private func animatedViewLeft() {
        UIView.animate(withDuration: 0.35, animations: {
            
            let moveLeft = CGAffineTransform(translationX: -(self.view.bounds.width * 1), y: 0.0)
            self.viewSelectContact.transform = moveLeft
        })
    }
    
    // Slide Right Animation
    private func animatedViewRight() {
        self.isInSearchMode = false
        UIView.animate(withDuration: 0.35, animations: {
            
            let moveRight = CGAffineTransform(translationX: -(self.view.bounds.width * 0.0), y: 1)
            self.viewSelectContact.transform = moveRight
            
            //Clear textfield and filter data
            self.tfSearch.text = ""
            self.clearFilterData( isInSearchMode: false)

//            self.requestContactData()
        })

        self.view.endEditing(true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func searchString() {
        searchText = tfSearch.text ?? ""
        
        self.isInSearchMode = (searchText?.isNotEmpty ?? false)
        
        // Check !Empty String of user input
        if ((searchText?.isEmpty) != nil) {
            clearFilterData(isInSearchMode: true)
            
            // Find name of contact according to user input (NOT USING API)
            for contact in arrayAllContacts {
                if ((contact.TRCO_CMNM?.lowercased().starts(with: searchText?.lowercased() ?? ""))) == true {
                    self.filterData.append(contact)
                }
            }
            
            if searchText?.isNotEmpty ?? false {
                self.isInSearchMode = true
                let isNoData = self.filterSearch(NM: searchText?.lowercased() ?? "")
                
//                self.filteredArrayRecent = self.filteredREC1(NM: searchText ?? "")
                
                self.filteredArrayAllContacts = self.filteredREC2(NM: searchText ?? "")
                
                self.noDataView.isHidden    = !isNoData
                self.tableView.isHidden     = isNoData
            } else {
                self.isInSearchMode = false
            }
        
//            DispatchQueue.main.async {
                self.tableView.reloadData()
//                let indexPath = IndexPath(row: (self.arrayAllContacts.count / 2) - 1, section: 1)
//                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                
//            }
        } else {
            //Empty data in filterData
            clearFilterData(isInSearchMode: false)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func searchContact() {
        
        searchText = tfSearch.text ?? ""
        
        
        if searchText?.isNotEmpty ?? false {
            self.isInSearchMode = true
            let isNoData = self.filterSearch(NM: searchText?.lowercased() ?? "")
            self.noDataView.isHidden    = !isNoData
            self.tableView.isHidden     = isNoData
        } else {
            self.isInSearchMode = false
        }
        
//        // Search Contact from user input
//        ContactListVM().searchContact(body: WABOOKS_MREC_R030.Request(TRCO_CMNM: searchText, TRSC_CCY_CD: "")) { (result) in
//            switch result {
//            case .success(let data):
//                self.filterData             = data.REC2
//
//                self.noDataView.isHidden    = !self.filterData.isEmpty
//                self.tableView.isHidden     = self.filterData.isEmpty
//                self.noInternetConnectionView.isHidden = true
////                self.headerTitles = ["all_contact".localized]
//                self.filterData.isEmpty ? (self.headerTitles = []) : (self.headerTitles = ["recent".localized, "all_contact".localized])
//                self.tableView.reloadData()
//            case .failure(let err):
//                if err.code == 1004 {
//                    self.noInternetConnectionView.isHidden = false
//                    self.tableView.isHidden = true
//                    self.noDataView.isHidden = true
//                }
//                print("ERROR", err)
//            }
//        }
    }
    
    
    // Display Contact Data in TableView
    private func requestContactData() {
        // Request Data from API WABOOKS_MREC_R030
        ContactListVM().searchContact(body: WABOOKS_MREC_R030.Request(TRCO_CMNM: "", TRSC_CCY_CD: "")) { (result) in
            switch result {
            case .success(let data):
    
                // Append Result into empty array
//                self.arrayRecent        = data.REC1
                self.checkDuplicateData(data: data.REC1)
                self.arrayAllContacts   = data.REC2
                self.arrayAll           = [data]
                
                self.tableView.isHidden     = self.arrayAll.isEmpty
                self.noDataView.isHidden    = !self.arrayAll.isEmpty
                self.noInternetConnectionView.isHidden = true
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            case .failure(let err):
                if err.code == 1004 {
                    self.noInternetConnectionView.isHidden = false
                    self.tableView.isHidden = true
                    self.noDataView.isHidden = true
                }
            }
            
        }
        
    }
    
    func checkDuplicateData(data: [WABOOKS_MREC_R030.REC1]) {
        
        for item in data {
            if  !arrayRecent.contains(item) {
                arrayRecent.append(item)
            }
        }
    }
    
    // Clear Search Data
    private func clearFilterData( isInSearchMode: Bool) {
        self.isInSearchMode = isInSearchMode
        self.filterData = []
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

//MARK: - TableViewDelegate & TableViewDataSource
extension ContactListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // During Searching
        if self.isInSearchMode {
            switch section {
            case 0:
                return filteredArrayRecent.count
            case 1:
                return filteredArrayAllContacts.count
            default:
                return 0
            }
        } else { // Display contact when not searching
            switch section {
            case 0:
                return arrayRecent.count
            case 1:
                return arrayAllContacts.count
            default:
                return 0
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerTitles.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView                   = UIView()
        footerView.backgroundColor       = .white
        self.tableView.tableFooterView   = footerView
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0: return self.isInSearchMode ? 0 : 16
        default: return 16
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        // Recent
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ContactListCell
            
            let REC1_Obj = self.isInSearchMode ? filteredArrayRecent[indexPath.row] : arrayRecent[indexPath.row]
            
            // Contact Name
            let CMNM = REC1_Obj.TRCO_CMENM
            
            // Currency
            let CCY_CD = self.isInSearchMode ? filteredArrayRecent[indexPath.row].TRSC_CCY_CD : arrayRecent[indexPath.row].TRSC_CCY_CD
            
            // Display Data on Cell
            cell.lblContact.text     = CMNM ?? ""
            cell.lblCurrency.text    = CCY_CD

            // Set Background Remember Selected Cell
//            let isSelectedCell              = self.r030REC1 == REC1_Obj
//            cell.viewCell.backgroundColor   = isSelectedCell ? UIColor(hexString: "EBF7FF") : .white
            
            // Set Background Remember Selected Cell
            cell.isSelect = (TRCO_CMNM == REC1_Obj.TRCO_CMNM  || TRCO_CMNM == REC1_Obj.TRCO_CMENM) && TRCO_KEY == REC1_Obj.TRCO_KEY ? true : false
            cell.configCell()

            if self.isInSearchMode {
                // highlight color on search result text
                let textForDisplay = CMNM ?? ""
                var textAttribute = NSMutableAttributedString()
                textAttribute = NSMutableAttributedString(string: textForDisplay, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)])
                textAttribute.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "3E4449")], range: NSMakeRange(0, textForDisplay.count))
                let range : NSRange = (textForDisplay.lowercased() as NSString).range(of: self.searchText?.lowercased() ?? "")
                textAttribute.setAttributes(
                    [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),
                     NSAttributedString.Key.foregroundColor : UIColor(hexString: "4286F5")],
                    range: range
                )
                cell.lblContact.attributedText = textAttribute
            } else {
                cell.lblContact.textColor = UIColor(hexString: "494949")
            }

            return cell
        // All Contacts
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ContactListCell
            
            let REC2_Obj = self.isInSearchMode ? filteredArrayAllContacts[indexPath.row] : arrayAllContacts[indexPath.row]
            
            // Contact Name
            let CMNM = REC2_Obj.TRCO_CMENM
            
            // Currency
            let CCY_CD = self.isInSearchMode ? filteredArrayAllContacts[indexPath.row].TRSC_CCY_CD : arrayAllContacts[indexPath.row].TRSC_CCY_CD
            
            // Display Data on Cell
            cell.lblContact.text     = CMNM ?? ""
            cell.lblCurrency.text    = CCY_CD ?? ""
            
//            let isSelectedCell              = self.r030REC2 == REC2_Obj
//            cell.viewCell.backgroundColor   = isSelectedCell ? UIColor(hexString: "EBF7FF") : .white

            // Set Background Remember Selected Cell
            cell.isSelect = (TRCO_CMNM == REC2_Obj.TRCO_CMNM  || TRCO_CMNM == REC2_Obj.TRCO_CMENM) && TRCO_KEY == REC2_Obj.TRCO_KEY ? true : false
            cell.configCell()
            
            if self.isInSearchMode {
                // highlight color on search result text
                let textForDisplay = CMNM ?? ""
                var textAttribute = NSMutableAttributedString()
                textAttribute = NSMutableAttributedString(string: textForDisplay, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)])
                textAttribute.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "3E4449")], range: NSMakeRange(0, textForDisplay.count))
                let range : NSRange = (textForDisplay.lowercased() as NSString).range(of: self.searchText?.lowercased() ?? "")
                textAttribute.setAttributes(
                    [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),
                     NSAttributedString.Key.foregroundColor : UIColor(hexString: "4286F5")],
                    range: range
                )
                cell.lblContact.attributedText = textAttribute
            } else {
                cell.lblContact.textColor = UIColor(hexString: "494949")
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndexPath = indexPath
        
        switch indexPath.section {
        
        // Recent
        case 0:
            
            let r030REC1 = isInSearchMode ? self.filteredArrayRecent[indexPath.row] : self.arrayRecent[indexPath.row]
            
            self.contactSelected = r030REC1.TRCO_KEY
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.popOrDismissVC(animated: true) {
                    
                    // Pass value depends on language selected
                    if Shared.language.rawValue == "Km" {
                        self.contact = self.arrayRecent[indexPath.row].TRCO_CMNM
                    } else {
                        self.contact = self.arrayRecent[indexPath.row].TRCO_CMENM
                    }
                    self.contactCompletion(self.contact ?? "")
                }
            })
            
            self.delegate?.getREC030_REC1(data: r030REC1, selectIndexPath: self.selectedIndexPath)
            
        // All Contacts
        case 1:
            
            let r030REC2 = isInSearchMode ? self.filteredArrayAllContacts[indexPath.row] : self.arrayAllContacts[indexPath.row]
            
            self.contactSelected = r030REC2.TRCO_KEY
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.popOrDismissVC(animated: true) {
                    
                    // Pass value depends on language selected
                    if Shared.language.rawValue == "Km" {
                        self.contact = self.arrayAllContacts[indexPath.row].TRCO_CMNM
                    } else {
                        self.contact = self.arrayAllContacts[indexPath.row].TRCO_CMENM
                    }
                    
                    self.contactCompletion(self.contact ?? "")
                }
            })
            self.delegate?.getREC030_REC2(data: r030REC2, selectIndexPath: self.selectedIndexPath)
        default: break
            
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ContactListCell {
            cell.viewCell.backgroundColor = UIColor(hexString: "EBF7FF")
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ContactListCell {
            cell.viewCell.backgroundColor = .white
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return self.isInSearchMode ? "all_contact".localized : "recent".localized
        case 1:
            return self.isInSearchMode ? "" : "all_contact".localized
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor      = .white
            headerView.backgroundView?.backgroundColor  = .black
            headerView.textLabel?.textColor             = UIColor(hexString: "A6A6A6")
            headerView.textLabel?.font                  = UIFont.systemFont(ofSize: 15)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {//RECENT
            if isInSearchMode {
                return 40
            } else {
                return arrayRecent.isEmpty ? 0 : 40
            }
        } else {
            return isInSearchMode ? 0 : 40
        }
    }
}

class ContactListCell: UITableViewCell{
    
    
    @IBOutlet weak var lblContact       : UILabel!
    @IBOutlet weak var lblCurrency      : UILabel!
    @IBOutlet weak var viewCell         : UIView!
    @IBOutlet weak var chooseButton     : UIButton!
    
    var isSelect : Bool = false
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        viewCell.backgroundColor = isSelect ? UIColor(hexString: "EBF7FF") : .white
    }
    
    func configCell () {
        chooseButton.isSelected = self.isSelect
    }
}

class NoDataCell : UITableViewCell {
    
    @IBOutlet weak var img          : UIImageView!
    @IBOutlet weak var lblNoContact : UILabel!
  
}

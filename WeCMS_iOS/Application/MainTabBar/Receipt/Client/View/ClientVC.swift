//
//  ClientVC.swift
//  RecipetDetail
//
//  Created by Bong Kokkheang on 28/3/23.
//

import UIKit

class ClientVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchUIView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var viewNoContacts: UIView!
    @IBOutlet weak var lblNoContacts: UILabel!
    
    var indexPath : IndexPath!
    var clientVM        = ClientVM()
    var clientData      = [Client.ContentBody]()
    var copyClientData  = [Client.ContentBody]() // ប្រើបន្ទាប់ពី search words and isSelected true
    var completion      : (Client.ContentBody.Item, [Client.ContentBody], Bool, Bool) -> () = {_, _, _ , _ in} // Item, [ContentBody], isSearching, isManualInput
    var backToSubmit    : (String) -> () = { _ in }
    var receiptList     : MREC_R006.RESPONSE.REC?
    var isSelected      : Bool?
    var searchManualInputText = ""
    var isFromAddOtherExpense = false
    var itemTitle = ""
    var itemKey = ""
    var completionTRSC_CCY_CD : Completion_String = {_ in}
    var new_TRSC_CCY_CD = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchTextField.placeholder = "search_name".localized
        searchTextField.font = UIFont(name: "Inter-Regular", size: 13)
        searchUIView.layer.borderWidth = 0.5
        searchTextField.delegate = self
        searchTextField.getlocalizedFont()
        viewNoContacts.isHidden = true
        submitButton.setTitle("comfirm".localized, for: .normal)
        submitButton.titleLabel?.getlocalizedFont()
        self.setupNav()
        
        if self.clientData.count == 0 {
            self.fecthContact()
        }else{
            self.getSelectedData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromAddOtherExpense{
            setNavigationBarStyle(isHidden: false, animated: true, title: "contact".localized, leftBarButtonImage: "ico_closed", leftSelector: #selector(dismissTap))
        }else{
            setNavigationBarStyle(isHidden: false, animated: true, title: "contact".localized)
        }
    }
    
    private func fecthContact() {
        clientVM.fetchContactList(TRCO_CMNM: "", TRSC_CCY_CD: "", receiptList: self.receiptList) { result in
            switch result {
            case .success(_):
                self.copyClientData = self.clientVM.contentData
                self.clientData     = self.clientVM.contentData
                
                // Loop all sections (Recent, Favorite, All)
                for (sectionIndex, _) in self.copyClientData.enumerated() {
                    // Loop all rows based on each section
                    for (_, rowData) in self.copyClientData[sectionIndex].item.enumerated() {
                        if ((rowData.value as? Client.ContentBody.Item)?.isSelected ?? false) {
                            self.isSelected = true
                            self.submitButton.backgroundColor = UIColor(hexString: (self.isSelected ?? false) ? "#0069B9" : "#A6A6A6")
                            self.submitButton.isUserInteractionEnabled = self.isSelected ?? false
                            break
                        }
                    }
                }
                
                self.tableView.reloadData()
                self.viewNoContacts.isHidden = self.clientVM.contentData.count > 0 ? true : false
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getSelectedData() {
        var indexPath = IndexPath(row: -1, section: -1)
        var section = -1
        
        if clientData.count == 3 {
            // findIndex
            var index = -1
            let clientData2 = self.clientData[0].item //In Recent REC
            for (i, obj) in clientData2.enumerated() {
                let data2 = obj.value as? Client.ContentBody.Item
                if data2?.l_text == self.itemTitle && data2?.TRCO_KEY == self.itemKey {
                    index = i
                    section = 0
                    break
                }
            }
            
            if index != -1 {
                indexPath = IndexPath(row: index, section: section)
            } else {
                let clientData2 = self.clientData[1].item //In Favourite REC
                for (i, obj) in clientData2.enumerated() {
                    let data2 = obj.value as? Client.ContentBody.Item
                    if data2?.l_text == self.itemTitle && data2?.TRCO_KEY == self.itemKey {
                        index = i
                        section = 1
                        break
                    }
                }
            }
            
            if index != -1 {
                indexPath = IndexPath(row: index, section: section)
            } else {
                let clientData2 = self.clientData[2].item // In All REC
                for (i, obj) in clientData2.enumerated() {
                    let data2 = obj.value as? Client.ContentBody.Item
                    if data2?.l_text == self.itemTitle && data2?.TRCO_KEY == self.itemKey {
                        index = i
                        section = 2
                        break
                    }
                }
            }
          
            if index != -1 {
                indexPath = IndexPath(row: index, section: section)
            }
        }
        
        if indexPath.row != -1 {
            let temp = self.clientData[indexPath.section].item[indexPath.row].value as? Client.ContentBody.Item
            // Set selected on Recent while recentlyData.r_text == temp.r_text
            if let recentIndex = clientData.firstIndex(where: {$0.sectionType == .Recently}) {
                for (index, data) in self.clientData[recentIndex].item.enumerated() {
                    if var recentlyData = data.value as? Client.ContentBody.Item {
                        recentlyData.isSelected = recentlyData.TRCO_KEY == temp?.TRCO_KEY ? true : false
                        self.clientData[recentIndex].item[index].value = recentlyData
                    }
                }
            }
            
            if let favouriteIndex = clientData.firstIndex(where: {$0.sectionType == .Favorite}) {
                // Set selected on Favorite while recentlyData.r_text == temp.r_text
                for (index, data) in self.clientData[favouriteIndex].item.enumerated() {
                    if var favoriteData = data.value as? Client.ContentBody.Item {
                        favoriteData.isSelected = favoriteData.TRCO_KEY == temp?.TRCO_KEY ? true : false
                        self.clientData[favouriteIndex].item[index].value = favoriteData
                    }
                }
            }
                
            // Set selected on All while recentlyData.r_text == temp.r_text
            if let allIndex = clientData.firstIndex(where: {$0.sectionType == .All}) {
                for (index, data) in self.clientData[allIndex].item.enumerated() {
                    if var favoriteData = data.value as? Client.ContentBody.Item {
                        favoriteData.isSelected = favoriteData.TRCO_KEY == temp?.TRCO_KEY ? true : false
                        self.clientData[allIndex].item[index].value = favoriteData
                        self.clientData[allIndex].item[index].value = favoriteData
                    }
                }
            }
        }
        // Set indexPath to pass data by index in completion
        self.indexPath = IndexPath(row: indexPath.row, section: section)
    }
    
    @objc func submitButtonPressed(_ sender: UIButton) {
        let indexSection    = clientData.firstIndex(where: {$0.sectionType == .All})!
        let index           = self.clientData[indexSection].item.firstIndex(where: { ($0.value as? Client.ContentBody.Item)?.isSelected == true }) ?? 0
        if let data            = self.clientData[indexSection].item[index].value as? Client.ContentBody.Item{  // Check crash app when click submit
            let isSearching     = !(searchTextField.text?.folding(options: .diacriticInsensitive, locale: .current).isEmpty ?? false)
            var originalObject  = data
            
            // Loop all sections (Recent, Favorite, All)
            for (sectionIndex, _) in self.copyClientData.enumerated() {
                
                // Loop all rows based on each section
                for (rowIndex, rowData) in self.copyClientData[sectionIndex].item.enumerated() {
                    originalObject.isSelected   = (rowData.value as? Client.ContentBody.Item)?.r_text == data.r_text ? true : false
                    
                    var tempObject              = rowData.value as? Client.ContentBody.Item
                    tempObject?.isSelected      = false
                    self.copyClientData[sectionIndex].item[rowIndex].value = (rowData.value as? Client.ContentBody.Item)?.l_text == data.l_text ? originalObject : tempObject
                }
            }
            
            let clientData = isSearching ? self.copyClientData : self.clientData
            completion(data, clientData, isSearching, false)
        }

        if isFromAddOtherExpense{
            self.dismiss(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func dismissTap(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func favouriteButtonPressed(data: Client.ContentBody.Item) {
        
        if data.isFavourite == true {
            self.clientVM.deleteBookMark(TRCO_KEY: data.TRCO_KEY) { (result) in
                switch result {
                case .success(_):
                    self.fecthContact()
                case .failure(let error):
                    self.alert(message: error.localizedDescription)
                }
            }
        } else {
            self.clientVM.createBookMark(TRCO_KEY: data.TRCO_KEY) { (result) in
                switch result {
                case .success(_):
                    self.fecthContact()
                case .failure(let error):
                    self.alert(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func setupNav() {
        self.lblNoContacts.getlocalizedFont()
        self.lblNoContacts.text = "there_is_no_contacts_created_yet".localized
        submitButton.addTarget(self, action: #selector(submitButtonPressed(_:)), for: .touchUpInside)
        submitButton.backgroundColor = UIColor(hexString: clientData.isEmpty ? "#A6A6A6" : "#0069B9")
        submitButton.isUserInteractionEnabled = clientData.isEmpty ? false : true
    }
}

extension ClientVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.clientData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clientData[section].item.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contentData = self.clientData[indexPath.section]
        let rowType     = contentData.item[indexPath.row].rowType
        
        switch rowType {
            
        case .Title:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleSectionTVC", for: indexPath) as! TitleSectionTVC
            if self.isFromAddOtherExpense{
                if contentData.item.count > 2{
                    cell.config(data: contentData.title)
                    return cell
                }else{
                    return UITableViewCell()
                }

            }else{
                cell.config(data: contentData.title)
                return cell
            }

        case .Item:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListItemTVC", for: indexPath) as! ListItemTVC
            cell.config(data: contentData.item[indexPath.row].value as! Client.ContentBody.Item, sectionType: contentData.sectionType, searchText: searchTextField.text!)
            cell.favouriteButton.didTap{
                self.favouriteButtonPressed(data: contentData.item[indexPath.row].value as! Client.ContentBody.Item)
            }
            return cell
        case .Search:
            if !self.isFromAddOtherExpense{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchListItemTVC", for: indexPath) as! SearchListItemTVC
                cell.config(data: contentData.item[indexPath.row].value as! Client.ContentBody.Item)
                // Clean code when select button
                cell.rightButton.didTap {
                    var data = self.clientVM.contentData[indexPath.section].item[indexPath.row].value as! Client.ContentBody.Item
                    data.r_text = nil
                    self.completion(data, [], false, true)
                    self.navigationController?.popViewController(animated: true)
                }
                return cell
                
            }else{
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let temp = self.clientData[indexPath.section].item[indexPath.row].value as! Client.ContentBody.Item
        self.new_TRSC_CCY_CD = temp.TRSC_CCY_CD
        completionTRSC_CCY_CD(temp.TRSC_CCY_CD)
        // Set selected on Recent while recentlyData.r_text == temp.r_text
        if let recentIndex = clientData.firstIndex(where: {$0.sectionType == .Recently}) {
            for (index, data) in self.clientData[recentIndex].item.enumerated() {
                if var recentlyData = data.value as? Client.ContentBody.Item {
                    recentlyData.isSelected = recentlyData.TRCO_KEY == temp.TRCO_KEY ? true : false
                    self.clientData[recentIndex].item[index].value = recentlyData
                }
            }
        }
        
        if let favouriteIndex = clientData.firstIndex(where: {$0.sectionType == .Favorite}) {
            // Set selected on Favorite while recentlyData.r_text == temp.r_text
            for (index, data) in self.clientData[favouriteIndex].item.enumerated() {
                if var favoriteData = data.value as? Client.ContentBody.Item {
                    favoriteData.isSelected = favoriteData.TRCO_KEY == temp.TRCO_KEY ? true : false
                    self.clientData[favouriteIndex].item[index].value = favoriteData
                }
            }
        }
        
        // Set selected on All while recentlyData.r_text == temp.r_text
        if let allIndex = clientData.firstIndex(where: {$0.sectionType == .All}) {
            for (index, data) in self.clientData[allIndex].item.enumerated() {
                if var favoriteData = data.value as? Client.ContentBody.Item {
                    favoriteData.isSelected = favoriteData.TRCO_KEY == temp.TRCO_KEY ? true : false
                    self.clientData[allIndex].item[index].value = favoriteData
                    self.clientData[allIndex].item[index].value = favoriteData
                }
            }
        }
        
        //For save selection
        let indexSection    = clientData.firstIndex(where: {$0.sectionType == .All})!
        let index           = self.clientData[indexSection].item.firstIndex(where: { ($0.value as? Client.ContentBody.Item)?.isSelected == true }) ?? 0
        if let data            = self.clientData[indexSection].item[index].value as? Client.ContentBody.Item{  // Check crash app when click submit
            let isSearching     = !(searchTextField.text?.folding(options: .diacriticInsensitive, locale: .current).isEmpty ?? false)
            var originalObject  = data
            
            // Loop all sections (Recent, Favorite, All)
            for (sectionIndex, _) in self.copyClientData.enumerated() {
                
                // Loop all rows based on each section
                for (rowIndex, rowData) in self.copyClientData[sectionIndex].item.enumerated() {
                    originalObject.isSelected   = (rowData.value as? Client.ContentBody.Item)?.r_text == data.r_text ? true : false
                    
                    var tempObject              = rowData.value as? Client.ContentBody.Item
                    tempObject?.isSelected      = false
                    self.copyClientData[sectionIndex].item[rowIndex].value = (rowData.value as? Client.ContentBody.Item)?.l_text == data.l_text ? originalObject : tempObject
                }
            }
        }
        
        // Set indexPath to pass data by index in completion
        self.indexPath = IndexPath(row: indexPath.row, section: indexPath.section)
        submitButton.backgroundColor = UIColor(hexString: "0069B9")
        submitButton.isUserInteractionEnabled = true
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return self.clientData[indexPath.section].item[indexPath.row].rowType == .Search ? false : true
    }
}

extension ClientVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text!.folding(options: .diacriticInsensitive, locale: .current).isEmpty {
            self.clientData = self.copyClientData
            self.viewNoContacts.isHidden = self.clientData.count > 0 ? true : false
            UIView.transition(with: tableView, duration: 1.0, options: .curveEaseIn, animations: {self.tableView.reloadData()}, completion: nil)
            
        } else {
            let foldingtxtVN = textField.text!.folding(options: .diacriticInsensitive, locale: .current)
            self.clientData = !(textField.text?.folding(options: .diacriticInsensitive, locale: .current).isEmpty ?? false) ? self.copyClientData : self.clientVM.contentData
            clientVM.search(clientData: self.clientData, text: foldingtxtVN, completion: { searchClientData in
                self.clientData = searchClientData
                self.viewNoContacts.isHidden = self.clientData.count > 0 ? true : false
                UIView.transition(with: tableView, duration: 1.0, options: .curveEaseIn, animations: {self.tableView.reloadData()}, completion: nil)
            })
        }
    }
}



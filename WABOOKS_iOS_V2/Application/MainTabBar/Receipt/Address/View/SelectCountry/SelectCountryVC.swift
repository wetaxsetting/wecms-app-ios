//
//  SelectCountryVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Bung on 6/1/21.
//

import Foundation

struct Country:Codable {
    var name: String
    var code: String
}

class SelectCountryVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tableView        : UITableView!
    @IBOutlet weak var tfSearch         : UITextField!
    @IBOutlet weak var viewInside       : UIView!
    @IBOutlet weak var viewOutside      : UIView!
    @IBOutlet weak var lblSelectCountry : UILabel!
    @IBOutlet weak var btnCancel        : UIButton!
    
    //Store all country
    var dataCountry         : [Country]               = []
    var cityCompletion      : Completion_String       = {_ in}
    
    //Remember Selected City
    var citySelected        : String?
    
    //Remember Selected Cell
    var indexCell                       = 0
    
    //Store searched data
    var filterData                      = [String]()
    
    // User search input
    var searchText          : String?
    
    //Typing search mode
    var isInSearchMode                  = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        readDataFromFile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for (index, city) in dataCountry.enumerated() {
            if city.name == citySelected {
                indexCell = index
            }
        }
        //Automatic scroll to selected row
        tableView.scrollToRow(at: IndexPath(row: indexCell, section: 0), at: .middle, animated: true)
    }
    
    private func setupView() {
        tfSearch.delegate = self
        localizeFont()
        localizeText()
    }
    
    //Slide Left Animation
    private func animatedView(){
        UIView.animate(withDuration: 0.35, animations: {
            
            let moveLeft = CGAffineTransform(translationX: -(self.view.bounds.width * 1), y: 0.0)
            self.viewOutside.transform = moveLeft
        })
    }
    
    //Localize Font
    private func localizeFont() {
        tfSearch.getlocalizedFont()
        btnCancel.getlocalizedFont()
        lblSelectCountry.getlocalizedFont()
    }
    
    //Localize Text
    private func localizeText() {
        btnCancel.setTitle("cancel".localized, for: .normal)
        lblSelectCountry.text         = "select_a_country".localized
        tfSearch.placeholder          = " " + "search_country".localized
    }
    
    @IBAction func didTapEditingChange(_ sender: UITextField) {
        searchString()
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        popOrDismissVC()
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        animatedView()
        tfSearch.becomeFirstResponder()
    }
    @IBAction func actionCancel(_ sender: Any) {
        moveBack()
    }
}

extension SelectCountryVC {
    
    //Animation Move Back
    private func moveBack() {
        UIView.animate(withDuration: 0.35, animations: {
            
            let moveRight = CGAffineTransform(translationX: -(self.view.bounds.width * 0.0), y: 1)
            self.viewOutside.transform = moveRight
            self.clearFilterData()
            self.tfSearch.text = ""
        })
        
        self.view.endEditing(true)
        self.tableView.reloadData()
    }
    
    //Clear textfield and filter data
    private func clearFilterData() {
        self.filterData = []
        self.isInSearchMode = false
        tableView.reloadData()
    }
    
    private func searchString() {
        let query = tfSearch.text ?? ""
        
        //Check Empty String of user input
        if query.isEmpty {
            clearFilterData()
            return
        }else {
            //Empty data in filterData
            self.filterData = []
            
            self.isInSearchMode = true
            //Find name of country according to user input
            for country in dataCountry {
                if country.name.lowercased().starts(with: query.lowercased()) {
                    self.filterData.append(country.name)
                }
            }
            searchText = query
            self.tableView.reloadData()
        }
        
        
        // Request Data from API WABOOKS_MREC_R020
//        AddressVM().searchCoutry(body: WABOOKS_MREC_R020.Request(NATL_NM: query)) { (result) in
//            switch result {
//            case .success(let data):
//                print(data as Any, "DATA SUCCESS")
//
//            case .failure(let err):
//            print("ERROR", err)
//            }
//
//        }
    }
    
    //Decode JSONData
    private func parse(jsonData: Data) {
        do {
            let decodedData = try JSONDecoder().decode([Country].self,
                                                       from: jsonData)
            self.dataCountry = decodedData
            
        } catch {
            print(error)
        }
    }
    
    func readDataFromFile(){
        if let localData = self.readLocalFile(forName: "Country") {
            self.parse(jsonData: localData)
        }
    }
    
    //Read Data from Local File
    func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                print(bundlePath)
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
}

//MARK: - UITableView
extension SelectCountryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isInSearchMode {
            return filterData.isEmpty ? 1 : filterData.count
        }else {
            return dataCountry.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isInSearchMode {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCountryCell") as! SelectCountryTableViewCell
            tableView.isScrollEnabled = true
            
            if filterData.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoSelectCountryTableViewCell") as! NoSelectCountryTableViewCell
                tableView.isScrollEnabled = false
                cell.isSelected           = false
                tableView.isScrollEnabled = false
                cell.lblNotFound.getlocalizedFont()
                cell.lblNotFound.text          = "no_country_found".localized
                return cell
            } else{
                
                cell.lbCountryName.text     = filterData[indexPath.row]
                
                // highlight color on search result text
                let textForDisplay = self.filterData[indexPath.row]
                var textAttribute = NSMutableAttributedString()
                textAttribute = NSMutableAttributedString(string: textForDisplay, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)])
                textAttribute.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "494949")], range: NSMakeRange(0, textForDisplay.count))
                let range : NSRange = (textForDisplay.lowercased() as NSString).range(of: self.searchText?.lowercased() ?? "")
                textAttribute.setAttributes(
                    [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),
                     NSAttributedString.Key.foregroundColor : UIColor(hexString: "0069B9")],
                    range: range
                )
                cell.lbCountryName.attributedText = textAttribute
                
                //Set selected cell to remeber indexPath.row
                cell.selectedView.backgroundColor   = citySelected == filterData[indexPath.row] ? UIColor(hexString: "EBF7FF") : .white
                return cell
            }
        } else {
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCountryCell") as! SelectCountryTableViewCell
            tableView.isScrollEnabled = true
            
            cell.selectedView.backgroundColor = citySelected == dataCountry[indexPath.row].name ? UIColor(hexString: "EBF7FF") : .white
            
            cell.lbCountryName.textColor = UIColor(hexString: "494949")
            
            
            indexCell = indexPath.row

            cell.lbCountryName.text     = dataCountry[indexPath.row].name
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isInSearchMode {
            return filterData.isEmpty ? (UIScreen.main.bounds.height - 150) : UITableView.automaticDimension
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        indexCell        = indexPath.row
        //Pass value country via completion
        if self.isInSearchMode {
            if !self.filterData.isEmpty{
                self.citySelected = self.filterData[indexPath.row]
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.popOrDismissVC(animated: true) {
                        self.cityCompletion(self.filterData[indexPath.row])
                    }
                })
                
            }
        } else{
            self.citySelected = self.dataCountry[indexPath.row].name
            self.tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.popOrDismissVC(animated: true) {
                    self.cityCompletion(self.dataCountry[indexPath.row].name)
                }
            })
        }
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SelectCountryTableViewCell {
            cell.selectedView.backgroundColor = UIColor(hexString: "EBF7FF")
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SelectCountryTableViewCell {
            cell.selectedView.backgroundColor = .white
        }
    }
}


//MARK: - SelectCountryTableViewCell
class SelectCountryTableViewCell: UITableViewCell {
    @IBOutlet weak var lbCountryName        : UILabel!
    @IBOutlet weak var selectedView         : UIView!
}

//MARK: - NoSelectCountryTableViewCell
class NoSelectCountryTableViewCell: UITableViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblNotFound: UILabel!
}

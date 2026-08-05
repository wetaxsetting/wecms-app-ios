//
//  AddressVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Bung on 6/1/21.
//

import Foundation

class AddressVC: UIViewController {
     
    @IBOutlet weak var tableView    : UITableView!
    @IBOutlet weak var titleLbl     : UILabel!
    @IBOutlet weak var btnDone      : UIButton!
     
    var titleCellStr    = ["address_1".localized, "address_2".localized, "city_state".localized, "country".localized]
    var placeholderCell = ["enter_address_1".localized, "enter_address_2".localized, "enter_city_State".localized, ""]
    
    var cellValue       : AddressObjectModel.receiptRow?
    
    var delegate        : addressDelegate?
    
    var oldAddress      : [String] = []
    
    var citySelect      : String?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        // init cell for row code and value
        self.displayCell()
        
        // validate Done button
        self.enableDoneButton()
         
        setupView()
    }
    
    private func setupView() {
        localizeFont()
        localizeText()
        
    }
    
    // Localize Font
    private func localizeFont() {
        titleLbl.getlocalizedFont()
        btnDone.getlocalizedFont()
        btnDone.getlocalizedFont()
    }
    
    // Localize Font
    private func localizeText() {
        titleLbl.text = "add_address".localized
        btnDone.setTitle("done".localized, for: .normal)
    }
     
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
     
    //MARK: - IBActions
    @IBAction func dismissButton(_ sender: UIButton) {
        self.popOrDismissVC()
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        // pass data to Submit receipt
        oldAddress = [getValue(from: "ADD1"), getValue(from: "ADD2"), getValue(from: "CYST"), getValue(from: "COUNTRY")]
        self.delegate?.getAddess(data: oldAddress)
        
        self.popOrDismissVC()
    }
    
    //MARK: - Private Func
    
    private func displayCell() {
        cellValue = AddressObjectModel.receiptRow(content: [AddressObjectModel.receiptRow.content(code: "ADD1", value: ""),
                                                            AddressObjectModel.receiptRow.content(code: "ADD2", value: ""),
                                                            AddressObjectModel.receiptRow.content(code: "CYST", value: ""),
                                                            AddressObjectModel.receiptRow.content(code: "COUNTRY", value: "")])
        
        // set value if it has
        if !self.oldAddress.isEmpty {
            initValueFromSubmitReceipt()
        }
    }
    
    private func initValueFromSubmitReceipt() {
        setValue(newValue: oldAddress[0], code: "ADD1")
        setValue(newValue: oldAddress[1], code: "ADD2")
        setValue(newValue: oldAddress[2], code: "CYST")
        setValue(newValue: oldAddress[3], code: "COUNTRY")
    }
     
    
    private func validateAddAddress() -> Bool {
        return (getValue(from: "ADD1").isEmpty || getValue(from: "COUNTRY").isEmpty || getValue(from: "CYST").isEmpty)
    }
    
    private func enableDoneButton() {
        self.btnDone.isEnabled = !self.validateAddAddress()
        self.btnDone.setTitleColor(UIColor(hexString: self.validateAddAddress() ? "#A6A6A6" : "#0069B9"), for: .normal)
    }
    
    func setValue(newValue: String = "", code: String) {
        for (index, value) in (cellValue?.content ?? []).enumerated() {
            if value.code == code {
                cellValue?.content[index].value = newValue
            }
        }
    }
     
    // retrieve value base on code
    private func getValue(from code: String) -> String {
        var val: String = ""
        for (_, value) in (cellValue?.content ?? []).enumerated() {
            if value.code == code {
                val = (value.value ?? "")
            }
        }
        
        return val
    }
     
    //MARK: - @objc func
    @objc func selectCountry() {
        let vc = VC(sbName: "SelectCountrySB", identifier: "SelectCountryVC") as! SelectCountryVC
        vc.citySelected = self.citySelect
        vc.cityCompletion = {cityStr in
            self.citySelect = cityStr
            self.setValue(newValue: cityStr, code: "COUNTRY")
            self.tableView.reloadRows(at: [IndexPath(item: 3, section: 0)], with: .none)
            self.enableDoneButton()
        }
        self.presetVC(vc: vc)
    }

}

//MARK: - UITableView
extension AddressVC: UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell") as! AddressTableViewCell
        
        cell.configCell(data: cellValue?.content[indexPath.row], title: titleCellStr[indexPath.row], placeHolder: placeholderCell[indexPath.row])
        cell.btnSelectCountry.addTarget(self, action: #selector(selectCountry), for: .touchUpInside)
        cell.textfieldInput.delegate = self
        self.enableDoneButton()
        return cell
         
    }
    
}
 
//MARK: - UITextFieldDelegate
extension AddressVC: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let tempText = textField.text, let textRange = Range(range, in: tempText) {
            let updatedText = tempText.replacingCharacters(in: textRange, with: string)
             
            switch textField.tag {
            // Address 1
            case 100:
                self.setValue(newValue: updatedText.trim, code: "ADD1")
                self.enableDoneButton()
                return true
                
            // Address 2
            case 101:
                self.setValue(newValue: updatedText.trim, code: "ADD2")
                self.enableDoneButton()
                return true
                
            // City/State
            case 102:
                self.setValue(newValue: updatedText.trim, code: "CYST")
                self.enableDoneButton()
                return true
            
            default: break
                 
            }
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - AddressTableViewCell
class AddressTableViewCell: UITableViewCell {
    
    //AddressTableViewCell1
    @IBOutlet weak var lbCell1                  : UILabel!
    @IBOutlet weak var textviewEnterAddress     : PlaceholderTextView!
    
    //AddressTableViewCell2
    @IBOutlet weak var lbCell2                  : UILabel!
    @IBOutlet weak var btnSelectCountry         : UIButton!
    @IBOutlet weak var arrowListImageView       : UIImageView!
    @IBOutlet weak var textfieldInput           : UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(data: AddressObjectModel.receiptRow.content?, title: String, placeHolder: String) {
        
        self.lbCell2.text               = title
        self.textfieldInput.placeholder = placeHolder
        
        switch data?.code {
        case "ADD1":
            textfieldInput.isEnabled    = true
            textfieldInput.isHidden     = false
            textfieldInput.tag          = 100
                
            textfieldInput.text         = data?.value
            textfieldInput.becomeFirstResponder()
            
        case "ADD2":
            
            textfieldInput.isEnabled    = true
            textfieldInput.isHidden     = false
            textfieldInput.tag          = 101
                
            textfieldInput.text         = data?.value
            
        case "CYST":
            textfieldInput.isEnabled    = true
            textfieldInput.isHidden     = false
            textfieldInput.tag          = 102
                
            textfieldInput.text         = data?.value
            
        case "COUNTRY":
            
            textfieldInput.isEnabled    = false
            btnSelectCountry.isHidden   = false
            arrowListImageView.isHidden = false
             
            btnSelectCountry.setTitle((data?.value?.isEmpty ?? false) ? "select".localized : data?.value, for: .normal)
            btnSelectCountry.getlocalizedFont()
         
        default: break
             
        }
    }

}


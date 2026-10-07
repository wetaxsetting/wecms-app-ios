//
//  PaymentMethodVC.swift
//  WeCMS_iOS
//
//  Created by Bun on 19/10/22.
//

import UIKit

import CoreMIDI

class ImportTransactionVC: UIViewController {
    
    @IBOutlet weak var btnDismiss               : UIButton!
    
    @IBOutlet weak var lblTitle                 : UILabel!
    @IBOutlet weak var lblSubTitle              : UILabel!
    @IBOutlet weak var btnCancel                : UIButton!
        
    @IBOutlet weak var lblFromDate              : UILabel!
    @IBOutlet weak var btnFromDate              : UIButton!
     
    @IBOutlet weak var lblToDate                : UILabel!
    @IBOutlet weak var btnToDate                : UIButton!
     
    @IBOutlet weak var lblListTransTitle        : UILabel!
  
    @IBOutlet weak var tableView                : UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topViewTopConstraint     : NSLayoutConstraint!
    
    @IBOutlet weak var btnMatch                     : UIButton!
    @IBOutlet weak var matchBtnViewBottomContraint  : NSLayoutConstraint!
     
    @IBOutlet weak var datePicker                   : UIDatePicker!
    @IBOutlet weak var datePickerBottomConstraint   : NSLayoutConstraint!
     
    var importTransactionVM = ImportTransactionVM()
    
    var completion          : (MREC_R007.RESPONSE?, _ indexPath: Int) -> () = { _, _ in }
    
    let dateFormatter       = DateFormatter()
    var last7Days           : String = ""
    var currentDate         : String = ""
    var TRSC_AMT            : String = ""
    var CCY_CD              : String = ""
    
    var isScrollEnabled = false
    var heightOfTable   = 0.0
     
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLocalized()
        self.setupAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableViewHeightConstraint.constant = heightOfTable
        self.tableView.isScrollEnabled          = (self.importTransactionVM.importTransactionData?.REC?.count ?? 0) > 2 ? true : false
        self.validationMatchButton()
    }
    
    private func setupLocalized() {
        let date = Date()
        self.datePicker.datePickerMode  = .date
        self.datePicker.locale          = Locale(identifier: Shared.language.rawValue)
        self.datePicker.calendar        = Calendar(identifier: .gregorian)
        
        dateFormatter.timeZone          = TimeZone.current
        dateFormatter.locale            = Locale.current
        dateFormatter.dateFormat        = "yyyyMMdd"
         
        // Get current date and last 7 days
        let preCurrentDate  = self.importTransactionVM.importTransactionData?.REC?.first?.TO_DT ?? ""
        let preLast7Days    = self.importTransactionVM.importTransactionData?.REC?.first?.FROM_DT ?? ""
        self.currentDate    = preCurrentDate.isEmpty ? dateFormatter.string(from: date) : preCurrentDate
        self.last7Days      = preLast7Days.isEmpty ? dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -7, to: date) ?? date) : preLast7Days
        
        self.btnMatch.getlocalizedFont()
        self.btnMatch.setTitle("match".localized, for: .normal)
        self.btnMatch.isEnabled         = false
        self.btnMatch.backgroundColor   = UIColor(hexString: "#FAFAFA")
        self.btnMatch.setTitleColor(UIColor(hexString: "#A6A6A6"), for: .normal)
         
        self.lblTitle.getlocalizedFont()
        self.lblTitle.text = "transaction".localized
        
        self.lblSubTitle.getlocalizedFont()
        self.lblSubTitle.text = "please_select_transactions_date".localized
        
        self.btnCancel.getlocalizedFont()
        self.btnCancel.setTitle("cancel".localized, for: .normal)
        
        self.lblFromDate.getlocalizedFont()
        self.lblFromDate.text = formatteDate(date: self.last7Days)
        
        self.lblToDate.getlocalizedFont()
        self.lblToDate.text = formatteDate(date: self.currentDate)
        
        self.lblListTransTitle.getlocalizedFont()
        self.lblListTransTitle.text = "transactions".localized
    }
     
    private func validationMatchButton() {
        let isSelected                  = self.importTransactionVM.importTransactionData?.REC?.contains(where: { $0.isSelectedTransaction == true })
        self.btnMatch.isEnabled         = isSelected ?? false
        self.btnMatch.backgroundColor   = UIColor(hexString: (isSelected ?? false) ? "#0069B9" : "#FAFAFA")
        self.btnMatch.setTitleColor(UIColor(hexString: (isSelected ?? false) ? "#FFFFFF" : "#A6A6A6"), for: .normal)
    }
    
    private func showDatePicker() {
        self.dismissKeyboard()
        
        UIView.animate(withDuration: 0.3) {
            self.datePickerBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideDatePicker() {
        UIView.animate(withDuration: 0.3) {
            self.datePickerBottomConstraint.constant = 240
            self.view.layoutIfNeeded()
        }
    }
    
    // Fetch Transaction's List
    func fetchTransactionList(TRSC_AMT: String, CCY_CD: String, FROM_DT: String, TO_DT: String, completion: () -> () = {}) {
        let body = MREC_R007.REQUEST(TRSC_AMT: TRSC_AMT, CCY_CD: CCY_CD, FROM_DT: FROM_DT, TO_DT: TO_DT)
        
        self.importTransactionVM.fetchTransactionList(body: body, completion: { result in
            switch result {
            case .success(let data):
                self.importTransactionVM.importTransactionData = data
                
                // Calculate height for table
                self.heightOfTable                      = CGFloat(((data.REC?.count ?? 0) > 1 ? (2 * 62) : 62))
                self.tableViewHeightConstraint.constant = self.heightOfTable
                self.tableView.isScrollEnabled          = (data.REC?.count ?? 0) > 2 ? true : false
                
                self.validationMatchButton()
                self.tableView.reloadData()
                
            case .failure(let error):
                // No need to alert error message
                print(error.localizedDescription)
            }
        })
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
  
    @IBAction func didTapButtonCancel(_ sender: UIButton) {
        self.popOrDismissVC()
    }

    @IBAction func didTapButtonMatch(_ sender: UIButton) {
        let indexPath = self.importTransactionVM.importTransactionData?.REC?.firstIndex(where: { $0.isSelectedTransaction == true}) ?? 0
        self.popOrDismissVC()
        self.importTransactionVM.importTransactionData?.REC?[indexPath].FROM_DT  = self.last7Days
        self.importTransactionVM.importTransactionData?.REC?[indexPath].TO_DT    = self.currentDate
        self.completion(self.importTransactionVM.importTransactionData, indexPath)
    }
    
    @IBAction func didTapBtnPrevCalendar(_ sender: UIButton) {
        self.datePicker.tag     = 1
        self.datePicker.date    = dateFormatter.date(from: self.last7Days) ?? Date()
        self.showDatePicker()
    }
    
    @IBAction func didTapBtnCurCalendar(_ sender: UIButton) {
        self.datePicker.tag     = 2
        self.datePicker.date    = dateFormatter.date(from: self.currentDate) ?? Date()
        self.showDatePicker()
    }
     
    @IBAction func didTapBtnDoneDatePicker(_ sender: UIButton) {
        self.hideDatePicker()
        
        // Fetch Transaction's List
        self.fetchTransactionList(TRSC_AMT: self.TRSC_AMT, CCY_CD: self.CCY_CD, FROM_DT: self.last7Days, TO_DT: self.currentDate)
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        let currentDate             = Date()
        self.datePicker.locale      = Locale(identifier: Shared.language.rawValue)
        self.datePicker.calendar    = Calendar(identifier: .gregorian)
        let pickerDate              = self.datePicker.date
        let pickerDateString        = Shared.share.getCurrentDate(date: pickerDate <= currentDate ? pickerDate : currentDate).dateString
        let dateString              = pickerDateString.formattedDateFromString(dateString: pickerDateString, withFormat: "yyyyMMdd") ?? ""
        self.datePicker.date        = pickerDate <= currentDate ? pickerDate : currentDate

        if self.datePicker.tag == 1 {
            self.last7Days          = dateString
            self.lblFromDate.text   = formatteDate(date: self.last7Days)
        } else {
            self.currentDate        = dateString
            self.lblToDate.text     = formatteDate(date: self.currentDate)
        }
    }
    
    private func setupAction() {
        
        // Add target to button to Dismiss
        self.btnDismiss.addTarget(self, action: #selector(self.didTapDismiss(_:)), for: .touchUpInside)
        
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanAction(gesture:)))
         
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    private func animateContainerHeight(_ height: CGFloat, gesture: UIPanGestureRecognizer, state: UIGestureRecognizer.State) {
        UIView.animate(withDuration: 0.1) {
            
            switch state {
            case .changed:
                
                let transactionCount = CGFloat((self.importTransactionVM.importTransactionData?.REC?.count ?? 1) > 2 ? 2 : 1)
                
                // Update constraint when user's swipe up and down
                // 488 is default top constraint to superview.Top and 0 is a default bottom constraint to superview.Buttom
                // height > 0 means user's swipe down
                if height > 0 {
                    self.topViewTopConstraint.constant          = 488 + height
                    self.matchBtnViewBottomContraint.constant   = 0 - height
                }
                else {
                    self.topViewTopConstraint.constant           = 488 + height
                    self.matchBtnViewBottomContraint.constant    = 0
                }
                 
                // dismiss vc when user's swipe down 80% of VC
                if height > ((transactionCount * 80) + (transactionCount * 20) + 140) {
                    self.popOrDismissVC()
                }
                
            case .ended:
                // Update constraint to default constraint when unswiped
                // 488 is default top constraint to superview.Top and 0 is a default bottom constraint to superview.Buttom
                self.topViewTopConstraint.constant          = 488
                self.matchBtnViewBottomContraint.constant   = 0
              
            default:
                break
            }
            
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handlePanAction(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        self.animateContainerHeight(translation.y, gesture: gesture, state: gesture.state)
    }
    
    @objc func didTapDismiss(_ sender: UIButton) {
        self.popOrDismissVC()
    }
}
 
//MARK: - UITableView
extension ImportTransactionVC: UITableViewDelegate, UITableViewDataSource {
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.importTransactionVM.importTransactionData?.REC?.count ?? 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImportTransactionListCell", for: indexPath) as! ImportTransactionListCell
        cell.configCell(data: self.importTransactionVM.importTransactionData, index: indexPath.row, Currency: self.CCY_CD)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ImportTransactionListCell {
            if cell.viewNomatching.isHidden {
                for index in 0..<(self.importTransactionVM.importTransactionData?.REC?.count ?? 0) {
                    self.importTransactionVM.importTransactionData?.REC?[index].isSelectedTransaction = index == indexPath.row ? true : false
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                }
            }
        }
        
        self.validationMatchButton()
    }
}
 

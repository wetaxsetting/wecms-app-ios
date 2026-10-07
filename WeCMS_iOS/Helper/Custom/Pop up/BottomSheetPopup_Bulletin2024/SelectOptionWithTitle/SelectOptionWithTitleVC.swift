//
//  SelectOptionWithTitleVC.swift
//  WeCMS_iOS
//
//  Created by Seanghay Huort on 19/1/24.
//

import UIKit

class SelectOptionWithTitleVC: UIViewController {

    @IBOutlet weak var postBtnView      : UIView!
    @IBOutlet weak var headerView       : UIView!
    @IBOutlet weak var postLB           : UILabel!
    @IBOutlet weak var postBtn          : UIButton!
    @IBOutlet weak var titleVC          : UILabel!
    var simpleApprovalVM                = SimpleApprovalVM()
    private var dateFilterLayout        = DateFilterLayout()
    var CompletionDidFinishSelectDate   : (DateFilterModel) -> Void = {_ in}
    var heightCompletion                : Completion_Int = {_ in}
    var CompletionDidFinishSelectDateExpenses   : (DateFilterModel) -> Void = {_ in}
    var heightCompletionExpenses                : Completion_Int = {_ in}
    var bottomSpace                     = 0.0
    var topSpace                        = 0.0
    var cornerToDateTopRadius           = 0.0
    var fromDate                        = Date()
    var toDate                          = Date()
    var isSelectilterMaually            = true
    var isSelectFromDate                = false
    var seleteExpenseType               : ItemType  = .BILL
    var selectedDate                    : DateFilterModel?
    var selectedDateExpenses            : DateFilterModel?
    var isFromSearch                    : Bool = false
    var isFromHome                      : Bool = false

    /// The sheet height that exactly fits what is on screen: where the collection view starts
    /// inside the sheet, plus its laid-out content height, plus the home-indicator inset.
    ///
    /// The callers used to size the sheet with `(58 * rowCount) + 51 + 60`, but the rows are
    /// ~45pt tall rather than 58pt, so that estimate overshot by ~60pt and left dead space
    /// under the last row. Measuring the real content removes the guesswork — and it also
    /// covers the From/To-date states, where the inline picker makes the content grow.
    /// A presented sheet already reserves the home-indicator inset below its content, so no
    /// bottom margin is added on devices that have one; only devices without a home indicator
    /// need an explicit margin so the last row does not sit flush against the screen edge.
    var fittedSheetHeight: CGFloat {
        view.layoutIfNeeded()
        let collectionTop = collectionView.superview?.convert(collectionView.frame.origin, to: view).y ?? 0
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        let bottomMargin: CGFloat = view.safeAreaInsets.bottom > 0 ? 0 : 16
        return collectionTop + contentHeight + bottomMargin
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.simpleApprovalVM.initDateFilter()
        didFinishSelectDate()
        setUpView()
        postLB.getlocalizedFont()
        postBtn.getlocalizedFont()
        titleVC.getlocalizedFont()
    }
    
    lazy var collectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.makeLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "FilterManualCell", bundle: nil), forCellWithReuseIdentifier: "FilterManualCell")
        collectionView.register(UINib(nibName: "DateFilterCell", bundle: nil), forCellWithReuseIdentifier: "DateFilterCell")
        collectionView.register(UINib(nibName: "SelectDateCell", bundle: nil), forCellWithReuseIdentifier: "SelectDateCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private func makeLayout() -> UICollectionViewLayout {
        if #available(iOS 13.0, *) {
            let layout = UICollectionViewCompositionalLayout { (section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                let rowType = self.simpleApprovalVM.dateFilterModel[section].rowType
                
                switch rowType{
                case .LastOneMonth:
                    return self.dateFilterLayout.LastOneMonthLayout(topSpace: 20.0)
                
                case . LastSixMonth, .LastThreeMonth:
                    return self.dateFilterLayout.LastOneMonthLayout()
                    
                case .FilterMaually:
                    return self.dateFilterLayout.LastOneMonthLayout(topSpace: 10.0)
                
                case .FromDate:
                    return self.dateFilterLayout.LastOneMonthLayout(topSpace: 10.0, bottomSpace: self.bottomSpace)
                    
                case .SelectFromDate:
                    return self.dateFilterLayout.LastOneMonthLayout()
                
                case .ToDate:
                    return self.dateFilterLayout.LastOneMonthLayout(topSpace: self.topSpace)
                    
                case .SelectToDate:
                    return self.dateFilterLayout.LastOneMonthLayout()
                    
                default :
                    return self.dateFilterLayout.LastOneMonthLayout()
                }
            }
            return layout
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func didFinishSelectDate(){
        // For Bill filter Date
        if isFromSearch || isFromHome{
            self.titleVC.text  = "date_filter".localized
        }
        if self.seleteExpenseType == .BILL{
            if let data = selectedDate {
                simpleApprovalVM.initNewDateFilter()
                switch data.rowType {
                case .FilterMaually:
                    simpleApprovalVM.initNewCustomDateFilter()
                    self.bottomSpace = 2.0
                    self.fromDate = convertStringToDate(from: data.value.fromDate ?? "") ?? Date()
                    self.toDate = convertStringToDate(from: data.value.toDate ?? "") ?? Date()
                    self.titleVC.text  = "filter_manually".localized
                    self.postBtnView.isHidden = false
                    
                case .LastOneMonth, .LastThreeMonth, .LastSixMonth:
                    self.titleVC.text  = "date_filter".localized
                    self.postBtnView.isHidden = true
                    
                default: break
                }
                
                let index = simpleApprovalVM.dateFilterModel.firstIndex(where: {$0.rowType == data.rowType})
                if let index = index {
                    var filterData =  simpleApprovalVM.dateFilterModel[index].value
                    filterData.isSelected = true
                    simpleApprovalVM.dateFilterModel[index].value = filterData
                }
                
            }else{
                self.postBtnView.isHidden = true
            }
            
        }else{
            // For Receipt filter Date
            if let data = selectedDateExpenses {
                simpleApprovalVM.initNewDateFilter()
                switch data.rowType {
                case .FilterMaually:
                    simpleApprovalVM.initNewCustomDateFilter()
                    self.bottomSpace = 2.0
                    self.fromDate = convertStringToDate(from: data.value.fromDate ?? "") ?? Date()
                    self.toDate = convertStringToDate(from: data.value.toDate ?? "") ?? Date()
                    self.titleVC.text  = "filter_manually".localized
                    self.postBtnView.isHidden = false
                    
                case .LastOneMonth, .LastThreeMonth, .LastSixMonth:
                    self.titleVC.text  = "date_filter".localized
                    self.postBtnView.isHidden = true
                    
                default: break
                }
                
                let index = simpleApprovalVM.dateFilterModel.firstIndex(where: {$0.rowType == data.rowType})
                if let index = index {
                    var filterData =  simpleApprovalVM.dateFilterModel[index].value
                    filterData.isSelected = true
                    simpleApprovalVM.dateFilterModel[index].value = filterData
                }
                
            }else{
                self.postBtnView.isHidden = true
            }
        }
    }
    
    private func setUpView(){
        self.view.addSubview(self.collectionView)
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 66),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ])
        self.postBtn.setTitle("", for: .normal)
        self.postLB.text = "post".localized
    }
    
    @IBAction func postBtnAction(_ sender: Any) {
        let fromDate = formatyyyyMMdd(date: self.fromDate)
        let toDate = formatyyyyMMdd(date: self.toDate)
        let indexSection = IndexPath(item: 0, section: 3)
        self.simpleApprovalVM.setValue(rowType: .FilterMaually, fromdate: fromDate, toDate: toDate)
        if self.seleteExpenseType == .BILL{
            CompletionDidFinishSelectDate(self.simpleApprovalVM.dateFilterModel[indexSection.section])
        }else{
            CompletionDidFinishSelectDateExpenses(self.simpleApprovalVM.dateFilterModel[indexSection.section])
        }
    }
}

extension SelectOptionWithTitleVC : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.simpleApprovalVM.dateFilterModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rowType = self.simpleApprovalVM.dateFilterModel[section].rowType
        
        switch rowType{
        case .FilterMaually, .LastOneMonth, .LastSixMonth, .LastThreeMonth, .FromDate, .ToDate, .SelectToDate, .SelectFromDate:
            return 1
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let rowType = self.simpleApprovalVM.dateFilterModel[indexPath.section].rowType
        let data    = self.simpleApprovalVM.dateFilterModel[indexPath.section].value
        
        switch rowType{
            
        case .LastOneMonth:
            let cell1   = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterManualCell", for: indexPath) as! FilterManualCell
            cell1.viewBg.cornerTopRadius = 10
            cell1.configCell(data: data)
            return cell1
            
        case .LastThreeMonth:
            let cell1   = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterManualCell", for: indexPath) as! FilterManualCell
            cell1.viewBg.cornerAllRadius = 0.0
            cell1.configCell(data: data)
            return cell1
            
        case .LastSixMonth:
            let cell1   = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterManualCell", for: indexPath) as! FilterManualCell
            cell1.viewBg.cornerBottomRadius = 10
            cell1.configCell(data: data)
            return cell1
            
        case .FilterMaually:
            let cell1   = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterManualCell", for: indexPath) as! FilterManualCell
            cell1.viewBg.cornerAllRadius = 10
            cell1.configCell(data: data)
            return cell1
            
        case.FromDate:
            
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "DateFilterCell", for: indexPath) as! DateFilterCell
            cell2.configCell(data: data)
            cell2.desLb.text = formatDateToString(date: self.fromDate)
            if self.isSelectFromDate{
                cell2.viewBg.cornerAllRadius = 10
            }else{
                cell2.viewBg.cornerTopRadius = 10
            }
            return cell2
            
        case.SelectFromDate:
            
            let cell3 = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectDateCell", for: indexPath) as! SelectDateCell
            cell3.datePicker.tag = 1
            cell3.datePicker.date = self.fromDate
            cell3.datePicker.addTarget(self, action: #selector(didChangeFromDate), for: .valueChanged)
            return cell3
            
        case.ToDate:
            
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "DateFilterCell", for: indexPath) as! DateFilterCell
            cell2.configCell(data: data)
            cell2.desLb.text = formatDateToString(date: self.toDate)
            
            if self.isSelectFromDate{
                cell2.viewBg.cornerAllRadius = 10
            }else{
                cell2.viewBg.cornerBottomRadius = 10
            }
            return cell2
            
        case.SelectToDate:
            
            let cell3 = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectDateCell", for: indexPath) as! SelectDateCell
            cell3.datePicker.tag = 2
            cell3.datePicker.date = self.toDate
            cell3.datePicker.addTarget(self, action: #selector(didChangeFromDate), for: .valueChanged)
            return cell3
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let rowType = self.simpleApprovalVM.dateFilterModel[indexPath.section].rowType
        let spaces       = 60 // top & bottom spaces
        let cellHeight   = 58 // 58 is height of one  ell, multiples with item count to get all cells height
        let headerViewSize   = 51 // header View Size
        
        switch rowType {
        case .LastOneMonth:
            self.titleVC.text           = "date_filter".localized
            self.postBtnView.isHidden   = true
            self.isSelectilterMaually   = true
            self.isSelectFromDate       = false
            self.simpleApprovalVM.initDateFilter()
            getNumberOfDaysInMonth(indexPath: indexPath, amountMonth: 1)
            if self.seleteExpenseType == .BILL{
                self.heightCompletion((cellHeight * 4) + headerViewSize + spaces)
                CompletionDidFinishSelectDate(self.simpleApprovalVM.dateFilterModel[indexPath.section])
            }else{
                self.heightCompletionExpenses((cellHeight * 4) + headerViewSize + spaces)
                CompletionDidFinishSelectDateExpenses(self.simpleApprovalVM.dateFilterModel[indexPath.section])
            }
            
        case .LastThreeMonth:
            self.titleVC.text           = "date_filter".localized
            self.postBtnView.isHidden   = true
            self.isSelectilterMaually   = true
            self.isSelectFromDate       = false
            self.simpleApprovalVM.initDateFilter()
            getNumberOfDaysInMonth(indexPath: indexPath, amountMonth: 3)
            if self.seleteExpenseType == .BILL{
                self.heightCompletion((cellHeight * 4) + headerViewSize + spaces)
                CompletionDidFinishSelectDate(self.simpleApprovalVM.dateFilterModel[indexPath.section])
            }else{
                self.heightCompletionExpenses((cellHeight * 4) + headerViewSize + spaces)
                CompletionDidFinishSelectDateExpenses(self.simpleApprovalVM.dateFilterModel[indexPath.section])
            }
            
        case .LastSixMonth:
            self.titleVC.text  = "date_filter".localized
            self.postBtnView.isHidden = true
            self.isSelectilterMaually = true
            self.isSelectFromDate = false
            self.simpleApprovalVM.initDateFilter()
            getNumberOfDaysInMonth(indexPath: indexPath, amountMonth: 6)
            if self.seleteExpenseType == .BILL{
                self.heightCompletion((cellHeight * 4) + headerViewSize + spaces)
                CompletionDidFinishSelectDate(self.simpleApprovalVM.dateFilterModel[indexPath.section])
            }else{
                self.heightCompletionExpenses((cellHeight * 4) + headerViewSize + spaces)
                CompletionDidFinishSelectDateExpenses(self.simpleApprovalVM.dateFilterModel[indexPath.section])
            }
            
        case .FilterMaually:
            self.postBtnView.isHidden = false
            self.titleVC.text  = "filter_manually".localized
            if self.isSelectilterMaually{
                if self.seleteExpenseType == .BILL{
                    self.heightCompletion((cellHeight * 6) + headerViewSize + spaces)
                }else{
                    self.heightCompletionExpenses((cellHeight * 6) + headerViewSize + spaces)
                }
                self.isSelectFromDate = false
                self.bottomSpace = 2.0
                self.topSpace = 0.0
                self.simpleApprovalVM.initCustomDateFilter()
                self.collectionView.reloadData()
            }

        case .FromDate:
            if self.seleteExpenseType == .BILL{
                self.heightCompletion(Int(getFullscreenHeight()))
            }else{
                self.heightCompletionExpenses(Int(getFullscreenHeight()))
            }
            self.bottomSpace = 0.0
            self.topSpace = 0.0
            self.isSelectilterMaually = false
            self.isSelectFromDate = true
            self.simpleApprovalVM.initFromDateFilter()
            
        case .ToDate:
            if self.seleteExpenseType == .BILL{
                self.heightCompletion(Int(getFullscreenHeight()))
            }else{
                self.heightCompletionExpenses(Int(getFullscreenHeight()))
            }
            self.bottomSpace = 0.0
            self.topSpace = 10.0
            self.isSelectilterMaually = false
            self.isSelectFromDate = true
            self.simpleApprovalVM.initToDate()
            
        default: break
        }
    
        for (n, c) in self.simpleApprovalVM.dateFilterModel.enumerated() {
            switch rowType {
            case .LastOneMonth, .LastThreeMonth, .LastSixMonth, .FilterMaually:
                if n == indexPath.section {
                    self.simpleApprovalVM.dateFilterModel[n].value.isSelected = true
                } else {
                    self.simpleApprovalVM.dateFilterModel[n].value.isSelected = false
                }
            default: break
            }
        }
        self.collectionView.reloadData()
    }
    
    @objc func didChangeFromDate(_ sender: UIDatePicker) -> Void {
        let indexSection = IndexPath(item: 0, section: 3)
        let section = self.simpleApprovalVM.dateFilterModel[indexSection.section]

        if sender.tag == 1 {
            self.fromDate = sender.date
            let indexPath = IndexPath(item: 0, section: 4)
            self.collectionView.reloadItems(at: [indexPath])
            
        }else{
            self.toDate = sender.date
            let indexPath = IndexPath(item: 0, section: 5)
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func formatDateToString(date: Date) -> String {
        var formattedString = ""
        let dateFormatter = DateFormatter()
        dateFormatter.locale    = Locale(identifier: MyDefaults.string(key: .appLang))
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        formattedString = dateFormatter.string(from: date)
        return formattedString
    }
 
   private func formatyyyyMMdd(date: Date) -> String{
       var formattedString = ""
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "yyyyMMdd"
       formattedString = dateFormatter.string(from: date)
       return formattedString
    }
    

    func convertStringToDate(from dateString: String) -> Date? {
        let originalFormat = "yyyyMMdd"
          let targetFormat = "yyyy-MM-dd HH:mm:ss Z"
          
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = originalFormat
          
          if let date = dateFormatter.date(from: dateString) {
              dateFormatter.dateFormat = targetFormat
              let formattedDateString = dateFormatter.string(from: date)
              
              return dateFormatter.date(from: formattedDateString)
          }   
          return nil
    }
    
    
    private func getFullscreenHeight() -> CGFloat {
        let statusBarManager = UIApplication.shared.statusBarManagerInConnectedScenes
        let statusBarHeight = statusBarManager?.statusBarFrame.height ?? 0
        let fullscreenHeight = UIScreen.main.bounds.height - statusBarHeight
        return fullscreenHeight
    }
    
    private func getNumberOfDaysInMonth(indexPath: IndexPath, amountMonth: Int) {
        let currentDate = Date()
        let calendar = Calendar.current
        var fromDate = ""
        var nowDate = ""
        let rowType = self.simpleApprovalVM.dateFilterModel[indexPath.section].rowType

        if let monthAgo = calendar.date(byAdding: .month, value: -amountMonth , to: currentDate){
            fromDate = formatyyyyMMdd(date: monthAgo)
            nowDate = formatyyyyMMdd(date: currentDate)
        }
        
        switch rowType {
        case .LastOneMonth:
            self.simpleApprovalVM.setValue(rowType: .LastOneMonth, fromdate: fromDate, toDate: nowDate)
        case .LastThreeMonth:
            self.simpleApprovalVM.setValue(rowType: .LastThreeMonth, fromdate: fromDate, toDate: nowDate)
        case .LastSixMonth:
            self.simpleApprovalVM.setValue(rowType: .LastSixMonth, fromdate: fromDate, toDate: nowDate)
        default: break
        }
    }
    
}

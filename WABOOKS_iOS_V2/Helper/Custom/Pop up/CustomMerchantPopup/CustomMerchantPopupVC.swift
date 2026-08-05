//
//  CustomMerchantPopupVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Nyta on 2/6/21.
//

import UIKit


class CustomMerchantPopupVC: UIViewController {

    @IBOutlet weak var tableView        : UITableView!
    @IBOutlet weak var lblTitleHeader   : UILabel!
    @IBOutlet weak var lblDescription   : UILabel!
    @IBOutlet weak var btnCancel        : UIButton!
    @IBOutlet weak var containerView    : UIView!
    
    // Data Display on Popup
    var titleString                      = ""
    var descriptionString                = ""
    var shouldDimiss                     = false
    var dataRec             : [String]   = []
    
    // String in Selected Cell
    var selectSupplier      : String?
    
    // Row in Selected Cell
    var selectRow                        = 0
    
    var currentIndex = 0
    
    //Completion -
    var didTapCloseCompletion : Completion      = {}
    var didTapCellCompletion  : Completion_Int  = {_ in}

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocalizeFont()
        localizeText()
    }

    //MARK: - Private Func
    private func getLocalizeFont() {
        lblTitleHeader.getlocalizedFont()
        lblDescription.getlocalizedFont()
        btnCancel.getlocalizedFont()
    }
    private func localizeText() {
        lblTitleHeader.text     = titleString
        lblDescription.text     = descriptionString
        btnCancel.setTitle("cancel_btn".localized, for: .normal)
    }
    
    private func dismiss() {
        
        if self.shouldDimiss {
            self.dismiss(animated: true) {
                self.didTapCloseCompletion()
            }
        }else{
            self.didTapCloseCompletion()
        }
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        dismiss()
    }
}

extension CustomMerchantPopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataRec.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomMerchantPopupCell
        
        cell.lblSupplier.text = dataRec[indexPath.row]
        
        //Set selected cell to remeber indexPath.row
        let isSelectedCell = dataRec[indexPath.row] == selectSupplier
        
        if dataRec[indexPath.row] == selectSupplier {
            selectRow = indexPath.row
        }
        
        cell.viewCell.backgroundColor       = isSelectedCell ? UIColor(hexString: "EBF7FF") : .white
        cell.btnCircle.isSelected           = isSelectedCell
        cell.btnCircle.addTarget(self, action: #selector(selectAction(sender:)), for: .touchUpInside)
        cell.btnCircle.tag = indexPath.row
        //Did Tap Btn Choose Completion
        cell.didTapCellCompletion = {
            DispatchQueue.main.async {
               if self.shouldDimiss {
                    self.dismiss(animated: true) {
                        self.didTapCellCompletion(indexPath.row)
                    }
                }else{
                    self.didTapCellCompletion(indexPath.row)
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
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectSupplier = dataRec[indexPath.row]
        self.tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.dismiss(animated: true) {
                self.didTapCellCompletion(indexPath.row)
            }
        })
        
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? CustomMerchantPopupCell {
            cell.viewCell.backgroundColor = UIColor(hexString: "EBF7FF")
            cell.btnCircle.setImage(UIImage(named: "def_radio_on"), for: .normal)
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if indexPath.row != self.selectRow {
            if let cell = tableView.cellForRow(at: indexPath) as? CustomMerchantPopupCell {
                cell.viewCell.backgroundColor = .white
                cell.btnCircle.setImage(UIImage(named: "def_radio_off"), for: .normal)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    //select button
    @objc func selectAction(sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
            let cell = tableView.cellForRow(at: indexPath)

        guard !cell!.isSelected else { return } // return if cell is already selected
            tableView.beginUpdates()
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            tableView(tableView, didSelectRowAt: indexPath)
            tableView.endUpdates()
        
    }

}

class CustomMerchantPopupCell: UITableViewCell {
    
    @IBOutlet weak var lblSupplier   : UILabel!
    @IBOutlet weak var btnCircle     : UIButton!
    @IBOutlet weak var viewCell      : UIView!
    
    //Completion
    var didTapCellCompletion            : Completion = {}
    var didTouchDownBtnCover            : Completion = {}
    var didTouchUpOutsideBtnCover       : Completion = {}


//    override func setSelected(_ selected: Bool, animated: Bool) {
//        if selected {
//            self.viewCell.backgroundColor = UIColor(hexString: "EBF7FF")
//            self.btnCircle.setImage(UIImage(named: "def_radio_on"), for: .normal)
//        }else {
//            self.viewCell.backgroundColor = .white
//            self.btnCircle.setImage(UIImage(named: "def_radio_off"), for: .normal)
//        }
//    }
    
}

extension UIViewController {
    func customMerchantPopup (title         : String = "",
                              message       : String = "",
                              data          : [String],
                              selectValue   : String = "",
                              shouldDimiss  : Bool = false,
                              completion    : @escaping Completion_Int = {_ in}) {
        
        
        let vc = self.VC(sbName: "CustomMerchantPopupSB", identifier: "CustomMerchantPopupVC") as! CustomMerchantPopupVC
        
        vc.selectSupplier = selectValue
        
        
        vc.titleString                   = title
        vc.descriptionString             = message
        vc.shouldDimiss                  = shouldDimiss
        vc.dataRec                       = data
        
        let heightOfTable: CGFloat       = CGFloat(data.count * 50) + 115.0  // Hight of header + footer is 115.0 // height of each cell is 50

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in heightOfTable }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = false
        }
        
        vc.didTapCloseCompletion = {
            
            if !shouldDimiss {
                completion(-1)
            }
        }
        vc.didTapCellCompletion = { row in
            completion(row)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
}

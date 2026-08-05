//
//  OptionPopupWithoutTitleVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Navy on 16/1/24.
//

import UIKit


class OptionPopupWithoutTitleVC: UIViewController {
    
    // MARK: - @IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
   
    // MARK: - Variables
    var data : [OptionPopupWithoutTitleModel] = []
    var didSelectCompletion : Completion_String = {_ in}
    
    

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = false
    }
    
}


// MARK: - UITableView
extension OptionPopupWithoutTitleVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionPopupWithoutTitleCell", for: indexPath) as! OptionPopupWithoutTitleCell
        cell.configCell(data: data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(data[indexPath.row].title)
        didSelectCompletion(data[indexPath.row].title)
    }

}



extension UIViewController  {

    func optionPopupWithoutTitle(optionData: [OptionPopupWithoutTitleModel], completion: @escaping (_ option: String, _ owner: UIViewController) -> () = {_,_  in}) {
        
        let vc = self.VC(sbName: "OptionPopupWithoutTitleSB", identifier: "OptionPopupWithoutTitleVC") as! OptionPopupWithoutTitleVC
        
        vc.data = optionData

        let numberOfItem = optionData.count
        let spaces       = 60 // top & bottom spaces
        let cellHeight   = 58 * numberOfItem // 58 is height of one cell, multiples with item count to get all cells height
        let totalHeight  = CGFloat(cellHeight + spaces)
        
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in totalHeight }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = true
        }
        
        vc.didSelectCompletion = { option in
            self.dismiss(animated: true)
            completion(option, vc)
        }
        
        self.present(vc, animated: true, completion: nil)
    }
}


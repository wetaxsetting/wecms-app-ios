//
//  SwitchOptionVC.swift
//  WeCMS_iOS
//
//  Created by Seanghay Huort on 21/1/24.
//

import UIKit


class SwitchOptionVC: UIViewController {

    @IBOutlet weak var titleLabel       : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var tableView        : UITableView!
    
    var data : [OptionPopupWithoutTitleModel] = []
    var didOptionCompletion : Completion_String = {_ in}
    var TITLE       = ""
    var DESCRIPTION = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate      = self
        tableView.dataSource    = self
        self.titleLabel.text    = self.TITLE
        self.descriptionLabel.text = self.DESCRIPTION
        self.titleLabel.getlocalizedFont()
        self.descriptionLabel.getlocalizedFont()

        // Do any additional setup after loading the view.
    }

}

extension SwitchOptionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchOptionCell", for: indexPath) as! SwitchOptionCell
        cell.titleLabel.textColor = indexPath.row == 0 ? UIColor(hexString: "#0F1FEA") : .black
        if data[indexPath.row].title == "delete".localized {
            cell.titleLabel.textColor = indexPath.row == 0 ? UIColor(hexString: "#CB0D0D") : .black
        }
        cell.titleLabel.text = data[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didOptionCompletion(data[indexPath.row].title)
    }
    
}

extension UIViewController  {

    func switchOption(optionData: [OptionPopupWithoutTitleModel],title: String, description: String, isFromAddManual: Bool = false, completion: @escaping Completion_String = {_ in}) {
        
        let vc = self.VC(sbName: "SwitchOptionSB", identifier: "SwitchOptionVC") as! SwitchOptionVC
        
        vc.data = optionData
        vc.TITLE          = title
        vc.DESCRIPTION    = description

        let numberOfItem = optionData.count
        let spaces       = 60 // top & bottom spaces
        let cellHeight   = 58 * numberOfItem // 58 is height of one cell, multiples with item count to get all cells height
        let headerView   = 51
        let totalHeight  = CGFloat(cellHeight + spaces + headerView)
        
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in totalHeight }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = true
        }
        
        vc.didOptionCompletion = { option in
            if isFromAddManual{
                self.dismiss(animated: true) {
                    completion(option)
                }
            }else{
                completion(option)
            }
//            completion(option)
        }
        
        self.present(vc, animated: true, completion: nil)
    }
}

class SwitchOptionCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.getlocalizedFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

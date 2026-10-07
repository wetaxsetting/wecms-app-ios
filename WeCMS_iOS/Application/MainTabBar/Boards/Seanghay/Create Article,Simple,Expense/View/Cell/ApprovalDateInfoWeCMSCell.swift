//
//  ApprovalDateInfoWeCMSCell.swift
//  WeCMS_iOS
//
//  Created by lymanny on 15/1/25.
//

import UIKit

class ApprovalDateInfoWeCMSCell: UITableViewCell {

    //MARK: - @IBOutlet
    @IBOutlet weak var scheduleLabel    : UILabel!
    @IBOutlet weak var dataImageView    : UIImageView!
    @IBOutlet weak var selectDateButton : UIButton!
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        scheduleLabel.getlocalizedFont()
        selectDateButton.getlocalizedFont()
    }
    
    //MARK: - Function
    func configEditCell(data: EditArticleData){
        scheduleLabel.text      = data.decription
        selectDateButton.setTitle(data.endDate, for: .normal)
        selectDateButton.setTitleColor(.label, for: .normal)
    }
    
    func configCell(data: ApprovalContent, PAY_DATE: String, PAY_REQ_DATE: String){
        scheduleLabel.text  = data.Description
        dataImageView.image = UIImage(named: data.Image ?? "")
        let language = "dd MMM yyyy"
        let formattedDate   = Date.getCurrentDate2()
        let payDate         = changeFormatDate(PAY_DATE,        fromFormat: "yyyyMMdd", toFormat: language)
        
        selectDateButton.setTitle   (PAY_DATE       == "" ? "Select" : payDate,     for: .normal)

    }
    
    func configDraftCell(data: ApprovalContent, PAY_DATE: String, PAY_REQ_DATE: String){
        scheduleLabel.text      = data.Description
        let language = "dd MMM yyyy"
        let formattedDate = Date.getCurrentDate2()
        let startDefault     = formattedDate.formattedDateFromString(dateString: formattedDate, withFormat: language)
        
        let payDate         = changeFormatDate(PAY_DATE, fromFormat: "yyyyMMdd", toFormat: language)
        
        selectDateButton.setTitle   (PAY_DATE == "" ? startDefault : payDate, for: .normal)
        
        dataImageView.image = UIImage(named: data.Image ?? "")
    }

}

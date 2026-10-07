//
//  ApprovalDateInfoCell.swift
//  WeCMS_iOS
//
//  Created by Seanghay Huort on 16/1/24.
//

import UIKit

class ApprovalDateInfoCell: UITableViewCell {

    @IBOutlet weak var scheduleLabel    : UILabel!
    @IBOutlet weak var requestLabel     : UILabel!
    @IBOutlet weak var dataImageView    : UIImageView!
    @IBOutlet weak var startDateButton  : UIButton!
    @IBOutlet weak var selectDateButton : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scheduleLabel.getlocalizedFont()
        requestLabel.getlocalizedFont()
        startDateButton.getlocalizedFont()
        selectDateButton.getlocalizedFont()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configEditCell(data: EditArticleData){
        requestLabel.text       = data.title
        scheduleLabel.text      = data.decription
        startDateButton.setTitle(data.startDate, for: .normal)
        selectDateButton.setTitle(data.endDate, for: .normal)
        startDateButton.setTitleColor(.label, for: .normal)
        selectDateButton.setTitleColor(.label, for: .normal)
    }
    
    func configCell(data: ApprovalContent, PAY_DATE: String, PAY_REQ_DATE: String){
        requestLabel.text   = data.Title
        scheduleLabel.text  = data.Description
        dataImageView.image = UIImage(named: data.Image ?? "")
        let language = "dd MMM yyyy"
        let formattedDate   = Date.getCurrentDate2()
        let startDefault    = formattedDate.formattedDateFromString(dateString: formattedDate, withFormat: language)
        let payDate         = changeFormatDate(PAY_DATE,        fromFormat: "yyyyMMdd", toFormat: language)
        let payReqDate      = changeFormatDate(PAY_REQ_DATE,    fromFormat: "yyyyMMdd", toFormat: language)
        
        startDateButton.setTitle    (PAY_REQ_DATE   == "" ? startDefault : payReqDate,  for: .normal)
        selectDateButton.setTitle   (PAY_DATE       == "" ? startDefault : payDate,     for: .normal)

    }
    
    func configDraftCell(data: ApprovalContent, PAY_DATE: String, PAY_REQ_DATE: String){
        requestLabel.text       = data.Title
        scheduleLabel.text      = data.Description
        let language = "dd MMM yyyy"
        let formattedDate = Date.getCurrentDate2()
        let startDefault     = formattedDate.formattedDateFromString(dateString: formattedDate, withFormat: language)
        
        let payDate         = changeFormatDate(PAY_DATE, fromFormat: "yyyyMMdd", toFormat: language)
        let payReqDate      = changeFormatDate(PAY_REQ_DATE, fromFormat: "yyyyMMdd", toFormat: language)
        
        startDateButton.setTitle    (PAY_REQ_DATE == "" ? startDefault : payReqDate, for: .normal)
        selectDateButton.setTitle   (PAY_DATE == "" ? startDefault : payDate, for: .normal)
        
        dataImageView.image = UIImage(named: data.Image ?? "")
    }
    
    func convertStringToDate(from dateString: String) -> Date? {
        let originalFormat = "yyyyMMdd"
          let targetFormat = "dd MMM yyyy"
          
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = originalFormat
          
          if let date = dateFormatter.date(from: dateString) {
              dateFormatter.dateFormat = targetFormat
              let formattedDateString = dateFormatter.string(from: date)
              
              return dateFormatter.date(from: formattedDateString)
          }
          return nil
    }

}
extension Date {

 static func getCurrentDate2() -> String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "dd MMM yyyy"

        return dateFormatter.string(from: Date())

    }
}

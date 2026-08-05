//
//  UserCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 19/1/24.
//

import UIKit

class UserCell: UICollectionViewCell {

    @IBOutlet weak var img          : UIImageView!
    @IBOutlet weak var nameLabel    : UILabel!
    @IBOutlet weak var optionButton : UIButton!
    @IBOutlet weak var dateLabel    : UILabel!
    
    private var timer: Timer?
    private var apiDate: Date?
    
    var isHighLight: Bool = false {
        didSet {
            self.backgroundColor = isHighLight ? UIColor(hexString: "#EDF7FF") : .none
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.dateLabel.getlocalizedFont()
        self.nameLabel.getlocalizedFont()
    }
    
    
    func configure(with apiResponseDate: String) {
        // Parse the API response date
        apiDate = parseDate(from: apiResponseDate)
        
        // Check if the time difference from now is greater than 60 minutes
        guard let apiDate = apiDate else {
            dateLabel.text = "Invalid Date"
            return
        }
        
        let elapsedTime = Int(Date().timeIntervalSince(apiDate))
        let maxAllowedTime = 60 * 60 // 60 minutes in seconds
        
        if abs(elapsedTime) > maxAllowedTime {
            dateLabel.text = apiResponseDate.getRelativeDateInComment
            return // Do not update the time if it's more than 60 minutes
        }
        
        // If it's within 60 minutes, start the timer
        startTimer()
    }
    
    private func parseDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss" // API date format
        dateFormatter.timeZone = .current
        return dateFormatter.date(from: dateString)
    }
    
    private func startTimer() {
        // Start the timer to update time every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func updateElapsedTime() {
        guard let apiDate = apiDate else { return }
        
        // Calculate the elapsed time in seconds
        let elapsedTime = Int(Date().timeIntervalSince(apiDate))
        
        // Update the label dynamically
        if elapsedTime < 0 {
            dateLabel.text = "Time in future"
        } else if elapsedTime < 60 {
            // Show seconds
            dateLabel.text = "\(elapsedTime)" + "s".localized
        } else if elapsedTime < 3600 {
            // Show minutes
            let minutes = elapsedTime / 60
            dateLabel.text = "\(minutes)" + "m".localized
        } else {
            // Show hours
            let hours = elapsedTime / 3600
            dateLabel.text = "\(hours)" + "h".localized
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Invalidate the timer when the cell is reused
        timer?.invalidate()
        dateLabel.text = nil
    }
    
    func WABOOKS_MREC_BLTB_0002_R003(data: WABOOKS_MREC_BLTB_0002_R003.RESPONES.REC) {
        self.img.sd_setImage(with: data.REG_IMG_URL?.formatFileURL,  completed: { (image, error, SDImageCacheType , url) in
            if error == nil {
                self.img.image  = image
            } else {
                self.img.image  = UIImage(named: "head_employee_ico")
            }
        })
        
        //Seanghay > Dynamic Update time when time under 1hour <
        configure(with: data.REG_DTM ?? "")
//        dateLabel.text = data.REG_DTM?.getRelativeDateInComment
        
        if data.COMNT_DV_CD == "R" { // "R" = Remark: hide action button ;
            optionButton.isHidden = true
        } else if data.COMNT_DV_CD == "C" { // C = Comment: show action button ;
            if data.REG_ID == Shared.R002_DATA?.USER_ID { // R002_DATA is login data
                optionButton.isHidden = false
            } else {
                optionButton.isHidden = true
            }
        }
        nameLabel.text = data.REG_NM
    }

}

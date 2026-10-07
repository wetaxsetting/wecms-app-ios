//
//  SelectDateCell.swift
//  WeCMS_iOS
//
//  Created by SteveChea  on 25/1/24.
//

import UIKit

class SelectDateCell: UICollectionViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.datePicker.calendar = Calendar(identifier: .gregorian)
        self.datePicker.locale = Locale(identifier: MyDefaults.string(key: .appLang))
    }

}

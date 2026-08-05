//
//  SelectOptionDateCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Seanghay Huort on 18/3/24.
//

import UIKit

class SelectOptionDateCell: UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    var didSelectDateCompletion : Completion_String = {_ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.datePicker.calendar = Calendar(identifier: .gregorian)
    }
    @IBAction func didChangeDate(_ sender: Any) {
        let today = self.datePicker.date.toString(format: "dd MMM yyyy")

        self.didSelectDateCompletion(today)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

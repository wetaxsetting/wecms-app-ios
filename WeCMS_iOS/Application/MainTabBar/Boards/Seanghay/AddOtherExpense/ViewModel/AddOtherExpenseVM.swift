//
//  AddOtherExpenseVM.swift
//  WeCMS_iOS
//
//  Created by SteveChea  on 12/3/24.
//

import Foundation

class AddOtherExpenseVM{
    var cells : [AddOtherExpenseModel] = []
    
    func initCells(){
        cells = []
        cells.append(AddOtherExpenseModel(value: AddOtherExpenseData(leftImg: "purpose_icon", title: "select_purpose_account".localized, rightImg: "right_icon", requireImg: "red_bullet", placeholder: ""), rowType: .PURPOSE))
        cells.append(AddOtherExpenseModel(value: AddOtherExpenseData(leftImg: "contact_icon", title: "select_contact".localized, rightImg: "right_icon", requireImg: "red_bullet", placeholder: ""), rowType: .CONTACT))
        cells.append(AddOtherExpenseModel(value: AddOtherExpenseData(leftImg: "currency_icon", title: "Currency", rightImg: "", dec: "", placeholder: "", key: "USD"), rowType: .CURRENCY))
        cells.append(AddOtherExpenseModel(value: AddOtherExpenseData(leftImg: "amount_icon", title: "Amount", rightImg: "", dec: "", requireImg: "red_bullet", placeholder: "", key: ""), rowType: .AMOUNT))
        cells.append(AddOtherExpenseModel(value: AddOtherExpenseData(leftImg: "", title: "", rightImg: "", placeholder: "Description".localized + " " + "max_200_characters".localized), rowType: .DESCRIPTION))
    }
    
    func setValue(rowType: AddOtherExpenseRow, value: String? = nil, value2: String? = nil, otherValue: String? = nil, key: String? = nil) {
        for (index, obj) in (self.cells.enumerated()) {
            if obj.rowType == rowType {
                self.cells[index].value.title = value
                self.cells[index].value.dec = value2
                self.cells[index].value.key = key
                self.cells[index].value.otherValue = otherValue
            }
        }
    }
    
    func getkey(rowType: AddOtherExpenseRow) -> String {
        var val: String = ""
        for  (_, obj) in cells.enumerated() {
            if obj.rowType == rowType {
                val = obj.value.key ?? ""
            }
        }
        return val
    }
    
    func getValue(rowType: AddOtherExpenseRow) -> String {
        var val: String = ""
        for  (_, obj) in cells.enumerated() {
            if obj.rowType == rowType {
                val = obj.value.title ?? ""
            }
        }
        return val
    }
    
    func getTRCO_CMNM(rowType: AddOtherExpenseRow) -> String {
        var val: String = ""
        for  (_, obj) in cells.enumerated() {
            if obj.rowType == rowType {
                val = obj.value.dec ?? ""
            }
        }
        return val
    }
    
    func getTRCO_CMENM(rowType: AddOtherExpenseRow) -> String {
        var val: String = ""
        for  (_, obj) in cells.enumerated() {
            if obj.rowType == rowType {
                val = obj.value.otherValue ?? ""
            }
        }
        return val
    }
}

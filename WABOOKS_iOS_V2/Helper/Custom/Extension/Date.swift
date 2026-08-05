//
//  Date.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 25/1/21.
//

import Foundation

extension Date {
    
    func getDateFromString(dateString: String) -> Date {
        
        if dateString.isEmpty {
            return Date()
        }
        let formatter = DateFormatter()
        if dateString.count <= 4 {
            formatter.dateFormat = "yyyy"
        } else if dateString.count <= 6 {
            formatter.dateFormat = "yyyyMM"
        } else if dateString.count <= 8 {
            formatter.dateFormat = "yyyyMMdd"
        } else if dateString.count <= 12 {
            formatter.dateFormat = "yyyyMMddHHmm"
        } else {
            formatter.dateFormat = "yyyyMMddHHmmss"
        }
        guard let date = formatter.date(from: dateString) else{
            return Date()
        }
        return date
    }
    
    public func toString(format: String = "yyyy/MM/dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Locale(identifier: Shared.language.rawValue)
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)!
        return formatter.string(from: self)
    }
    
    public func getMonthName(format: String) -> String {
        let dateFormatter = DateFormatter()
     dateFormatter.locale = Locale(identifier: Shared.language.rawValue)
        dateFormatter.dateFormat = format
     let strMonth = dateFormatter.string(from: self)
        return strMonth
    }
      
}

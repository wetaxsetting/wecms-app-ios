//
//  String.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 5/1/21.
//

import Foundation
import UIKit

// Simple cache helper
class HTMLCache {
    static let shared = HTMLCache()
    private var cache: [String: NSAttributedString] = [:]
    private let queue = DispatchQueue(label: "html.cache", attributes: .concurrent)
    
    func get(key: String) -> NSAttributedString? {
        return queue.sync { cache[key] }
    }
    
    func set(key: String, value: NSAttributedString) {
        queue.async(flags: .barrier) {
            self.cache[key] = value
        }
    }
}

extension String {
    
    /// Parse HTML specifically optimized for UITextView
    /// - Parameters:
    ///   - fontSize: Base font size
    ///   - textColor: Text color
    /// - Returns: NSAttributedString or nil
    func parseHTMLForTextView(
        fontSize: CGFloat = 14
    ) -> NSAttributedString? {
        
        
        // Return cached result if available
        let cacheKey = "\(self.hashValue)_\(fontSize)"
        if let cached = HTMLCache.shared.get(key: cacheKey) {
            return cached
        }
        
        guard let data = self.data(using: .utf8) else { return nil }
        
        do {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            
            let attributedString = try NSMutableAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
            )
            
            let customFont = UIFont(name: "Inter-Medium", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
            attributedString.addAttribute(.font, value: customFont, range: NSRange(location: 0, length: attributedString.length))
            
            // Cache the result
            HTMLCache.shared.set(key: cacheKey, value: attributedString)
            
            return attributedString
            
        } catch {
            print("HTML parsing error: \(error)")
            return nil
        }
    }
    
    /// Strip HTML and format for plain text display
    func stripHTMLAndFormat() -> String {
        var text = self
        
        // Handle specific tags with proper spacing
        text = text.replacingOccurrences(of: "</h[1-6]>", with: "\n\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "<h[1-6][^>]*>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "</p>", with: "\n\n")
        text = text.replacingOccurrences(of: "<p[^>]*>", with: "", options: .regularExpression)
        
        // Remove all remaining HTML tags
        text = text.replacingOccurrences(of: "<[^>]*>", with: "", options: .regularExpression)
        
        // Decode HTML entities
        text = text.decodingHTMLEntities()
        
        // Clean up whitespace
        text = text.replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
        text = text.replacingOccurrences(of: " +", with: " ", options: .regularExpression)
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Decode HTML entities
    func decodingHTMLEntities() -> String {
        let entities: [String: String] = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&#39;": "'",
            "&nbsp;": " ",
            "&copy;": "©",
            "&reg;": "®"
        ]
        
        var decoded = self
        for (entity, character) in entities {
            decoded = decoded.replacingOccurrences(of: entity, with: character, options: .caseInsensitive)
        }
        
        return decoded
    }
    
    /// Decode HTML entities
    func decodeHTMLEntities() -> String {
        let entities: [String: String] = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&#39;": "'",
            "&apos;": "'",
            "&nbsp;": " ",
            "&copy;": "©",
            "&reg;": "®",
            "&trade;": "™",
            "&euro;": "€",
            "&pound;": "£",
            "&yen;": "¥"
        ]
        
        var decoded = self
        for (entity, character) in entities {
            decoded = decoded.replacingOccurrences(of: entity, with: character, options: .caseInsensitive)
        }
        
        return decoded
    }
    
    var convertHTMLToString: String {
        // Method 1: Using NSAttributedString (most accurate)
        if let attributedString = self.parseHTMLForTextView() {
            return attributedString.string
        }
        return self
    }
    
    var usdCurrency: String {
         let formatter = NumberFormatter()
         formatter.numberStyle = .currency
         formatter.minimumFractionDigits = 2
         formatter.maximumFractionDigits = 2
         formatter.currencySymbol = ""
         formatter.locale = Locale(identifier: "en_US")
         
         let format = formatter.string(from: NSNumber(floatLiteral: (self as NSString).doubleValue))!
         
//         if format.contains(".00"){
//             return format.components(separatedBy: ".")[0]
//         }else {
             return format
//         }
     }
    
    var convertStringToHTML: String {
        let replaceNewLine = replace(of: "\n", with: "<br>")
        return replaceNewLine.replace(of: " ", with: "&nbsp;")
    }
    
    var vndCurrency: String {
         let formatter = NumberFormatter()
         formatter.numberStyle = .currency
         formatter.minimumFractionDigits = 2
         formatter.maximumFractionDigits = 2
         formatter.currencySymbol = ""
         formatter.locale = Locale(identifier: "vi_VN")
         
//         let format = formatter.string(from: NSNumber(floatLiteral: (self as NSString).doubleValue))!
        let format = (formatter.string(from: NSNumber(floatLiteral: (self as NSString).doubleValue))!)
         
//         if format.contains(".00"){
//             return format.components(separatedBy: ".")[0]
//         }else {
        return format.trim
//         }
     }
    
    // Kheang: 23 Feb 2024
    var jsonStringRedecoded: String? {
        let data = ("\""+self+"\"").data(using: .utf8)!
        let result = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! String
        return result
    }
    
    // Kheang: 4 Feb 2024
    var getRelativeDateInComment : String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let endDate = NSDate() as Date
        guard let startDate = dateFormatter.date(from: self) else { return "" }
        let diff = endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
        let exampleDate = Date().addingTimeInterval(-Double(diff))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let relativeDate = formatter.localizedString(for: exampleDate, relativeTo: Date())
        if let shortForm = convertRelativeToShortFormInComment(relativeDate) {
            return shortForm
        } else {
            return "now".localized
        }
    }
    
    // Kheang: 4 Feb 2024
    func convertRelativeToShortForm(_ dateString: String) -> String? {
        let components = dateString.components(separatedBy: " ")
        guard components.count == 3 else {
            return nil // Invalid input format
        }
        
        guard let value = Int(components[0]), let unit = components[1].lowercased().first else {
            return nil // Invalid numeric value or unit
        }
        
        let unitString: String
        switch unit {
        case "s":
            unitString = "s".localized
        case "m":
            unitString = "m".localized
        case "h":
            unitString = "h".localized
        case "d", "w", "y":
            unitString = "d"
        case "w":
            unitString = "w"
        case "y":
            unitString = "y"
        default:
            return nil // Unsupported unit
        }
        
        return "\(value)\(unitString)"
    }
    
    // Kheang: 4 Feb 2024
    func convertRelativeToShortFormInComment(_ dateString: String) -> String? {
        let components = dateString.components(separatedBy: " ")
        guard components.count == 3 else {
            return nil // Invalid input format
        }
        
        guard let value = Int(components[0]), let unit = components[1].lowercased().first else {
            return nil // Invalid numeric value or unit
        }
        
        let unitString: String
        switch unit {
        case "s":
            unitString = "s".localized
        case "m":
            unitString = "m".localized
        case "h":
            unitString = "h".localized
        case "d", "w", "y":
            return formatArticleDate
        default:
            return nil // Unsupported unit
        }
        
        return "\(value)\(unitString)"
    }
    
    // Kheang: 4 Feb 2024
    var getRelativeDate : String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let endDate = NSDate() as Date
        guard let startDate = dateFormatter.date(from: self) else { return "" }
        let diff = endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
        let exampleDate = Date().addingTimeInterval(-Double(diff))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let relativeDate = formatter.localizedString(for: exampleDate, relativeTo: Date())
        if let shortForm = convertRelativeToShortForm(relativeDate) {
            return shortForm
        } else {
            return "Now"
        }
    }
    
    // Kheang: 11 Mar 2024
    var formatArticleDate: String {
        if let date = self.toDate(withFormat: "yyyyMMddHHmmss") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            // localize data
            dateFormatter.locale = Locale(identifier: MyDefaults.string(key: .appLang))
            dateFormatter.locale = Locale(identifier: Shared.language.rawValue)
                            dateFormatter.dateFormat = "dd MMM yyyy"
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate
        } else {
            return ""
        }
    }
    
    // Kheang: 4 Feb 2024
    var formatExpenseDateToString: String {
        if let date = self.toDate(withFormat: "yyyyMMdd") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            // localize data
            dateFormatter.locale = Locale(identifier: MyDefaults.string(key: .appLang))
            dateFormatter.dateFormat = "dd MMM yyyy"
            dateFormatter.locale = Locale(identifier: Shared.language.rawValue)
                            dateFormatter.dateFormat = "dd MMM yyyy"
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate
        } else {
            return ""
        }
    }
    
    // Kheang: 4 Feb 2024
    var formatFullExpenseDateToString: String {
        if let date = self.toDate(withFormat: "yyyyMMddHHmmss") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale(identifier: Shared.language.rawValue)
            switch Shared.language{
            case .English:
                dateFormatter.dateFormat = "dd MMM yyyy '@'h:mm a."
            case .Vietnamese:
                dateFormatter.dateFormat = "dd MMM yyyy '@'h:mm a"

            }
            dateFormatter.amSymbol = "am".localized
            dateFormatter.pmSymbol = "pm".localized
            
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate
        } else {
            return ""
        }
    }
    
    
    
    
    
    // Kheang: 4 Feb 2024
    func highlight(searchText: String, withHighlightColor color: UIColor) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        let range = (self as NSString).range(of: searchText, options: .caseInsensitive)
        attributedString.addAttribute(.backgroundColor, value: color, range: range)
        return attributedString
    }
    
    // Kheang: 4 Feb 2024
    func toDate(withFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    // Kheang: 4 Feb 2024
    var bytesToKilobytes: String {
        let result = (Double(self) ?? 0) / 1024.0
        return String(format: "%.2f", result)
    }
    
    // Kheang: 4 Feb 2024
    var formatStringDouble: String {
        return String(format: "%.2f", Double(self) ?? "")
    }
    
    // Kheang: 6 Feb 2024
    var formatFileURL: URL? {
        let authorization   = "\(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
        let split_url       = self.components(separatedBy: "?")
        let img_url         = "\(split_url.first ?? "")?token=\(authorization)&\(split_url.last ?? "")"
        let url             = URL(string: "\(img_url)")
        return url
    }
    
    var trim: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isNotEmpty: Bool {
        return self.trim != ""
    }
    
    var toInt: Int {
        return Int(self) ?? 0
    }
    
    var toDouble: Double {
        return Double(self) ?? 0
    }
    
    var toDoubleWithSpecialChar: Double {
        var str = self
        if self.contains(",") {
            str = self.replace(of: ",", with: "")
        }
        return Double(str) ?? 0
    }
    
    var camelCased: String {
        return (self as NSString)
            .replacingOccurrences(of: "([A-Z])", with: " $1", options:
                                    .regularExpression, range: NSRange(location: 0, length: count))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
    }
    
    mutating func replaced(of: String, with: String) {
        self = self.replacingOccurrences(of: of, with: with)
    }
    
    func replace(of: String, with: String) -> String {
        return self.replacingOccurrences(of: of, with: with)
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func validate(regex: String) -> Bool {
        let char = self.cString(using: String.Encoding.utf8)
        if (strcmp(char, "\\b") != -92) {
            return NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: self)
        }
        return true
    }
     
    // USD
    func formatUSDCurrency() -> String {
        var intNumber : Double = 0
        if let myNumber = NumberFormatter().number(from: self) {
            intNumber = myNumber.doubleValue
        }
        var mycurrencyStr = String(intNumber)
        if intNumber < 0 {
            mycurrencyStr = "-" + String(intNumber)
        }
        
        let currencyFormatter               = NumberFormatter()
        currencyFormatter.numberStyle       = .currency
//        currencyFormatter.locale            = Locale(identifier: "en_US")
        currencyFormatter.currencyCode      = ""
        currencyFormatter.currencySymbol    = ""
        
        currencyFormatter.currencyGroupingSeparator = ","
        currencyFormatter.currencyDecimalSeparator  = "."
        
        currencyFormatter.maximumFractionDigits = 2
        
        let currencyStr = currencyFormatter.string(from: NSNumber(value: Double(mycurrencyStr) ?? 0)) ?? ""
        let str:NSString = currencyStr as NSString
        
        //Check format .00 & .##
//        if str.contains(".00") {
//            currencyFormatter.positiveFormat = "¤#,###.##"
//            currencyFormatter.negativeFormat = "-¤#,###.##"
//        }else {
//            currencyFormatter.positiveFormat = "¤#,###.##"
//            currencyFormatter.negativeFormat = "-¤#,###.##"
//        }
       
        return str as String
    }
     
    // for KHR
    func formatKHRCurrency() -> String {
        var intNumber :Int64 = 0
        if let myNumber = NumberFormatter().number(from: self) {
            intNumber = myNumber.int64Value
        }
        var mycurrencyStr = String(intNumber)
        if intNumber < 0 {
            mycurrencyStr = "-" + String(intNumber)
        }
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
         
        currencyFormatter.usesGroupingSeparator = true
        
        currencyFormatter.currencyGroupingSeparator = ","
        currencyFormatter.currencyDecimalSeparator  = "."
        
        
        currencyFormatter.currencySymbol = ""
        currencyFormatter.currencyCode   = ""
        
        currencyFormatter.maximumFractionDigits = 0
      
//        currencyFormatter.positiveFormat    = "¤#,##0"
//        currencyFormatter.negativeFormat    = "-¤#,##0"

        let currencyStr = currencyFormatter.string(from: NSNumber(value: Int64(mycurrencyStr) ?? 0)) ?? ""
        let str:NSString = currencyStr as NSString
        
        return str as String
    }
       
    func toKHRCurrency() -> String {
        var intNumber :Int64 = 0
        if let myNumber = NumberFormatter().number(from: self) {
            intNumber = myNumber.int64Value
        }
        var mycurrencyStr = String(intNumber)
        if intNumber < 0 {
            mycurrencyStr = "-" + String(intNumber)
        }
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .decimal
         
        currencyFormatter.usesGroupingSeparator = true
        
        currencyFormatter.currencyGroupingSeparator = ","
        currencyFormatter.currencyDecimalSeparator  = ","
     
        currencyFormatter.currencySymbol = ""
        currencyFormatter.currencyCode   = ""
        
        currencyFormatter.maximumFractionDigits = 0
        
        let currencyStr = currencyFormatter.string(from: NSNumber(value: Int64(mycurrencyStr) ?? 0)) ?? ""
        let str:NSString = currencyStr as NSString
        
        return str as String
    }
    
    func toUSDCurrency() -> String {
        
        var intNumber : Double = 0
        var strToFormat = self
        
        //check . replacing . with ""
        if self.contains(".") {
            strToFormat = self.replacingOccurrences(of: ".", with: "")
        }
        if let myNumber = NumberFormatter().number(from: strToFormat) {
            intNumber = myNumber.doubleValue
        }
        
        var mycurrencyStr = String(intNumber)
        if intNumber < 0 {
            mycurrencyStr = "-" + String(intNumber)
        }
        
        let currencyFormatter               = NumberFormatter()
        currencyFormatter.numberStyle       = .decimal
         
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.currencyCode      = ""
        currencyFormatter.currencySymbol    = ""
       
        // example: 1,323.50
        currencyFormatter.currencyGroupingSeparator = ","
        currencyFormatter.currencyDecimalSeparator  = "."
      
        let currencyStr  = currencyFormatter.string(from: NSNumber(value: Double(mycurrencyStr) ?? 0)) ?? ""
        let str:NSString = currencyStr as NSString
          
        return str as String
    }
    
    func separate(every: Int, with separator: String) -> String {
        return String(stride(from: 0, to: Array(self).count, by: every).map { Array(Array(self)[$0..<min($0 + every, Array(self).count)])}.joined(separator: separator))
    }
     
    func format(format: String, fromFormat: String = "yyyy-MM-dd") -> String {
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = format
        dateFormatter.timeZone      = Calendar.current.timeZone
        dateFormatter.locale        = Locale(identifier: Shared.language.rawValue)
        
        let getDate = DateFormatter()
//        getDate.dateFormat = fromFormat
        
        switch Shared.language {
        case .English:
            getDate.dateFormat  =  "MMM dd yyyy"
        case .Vietnamese:
            getDate.dateFormat  =  "dd MMM yyyy"
        }
        
        return dateFormatter.string(from: getDate.date(from: self) ?? Date())
    }
     
    func formattedDateFromString(dateString: String, withFormat format: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"

        if let date = inputFormatter.date(from: dateString) {
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = format
            outputFormatter.locale = Locale(identifier: Shared.language.rawValue)
            return outputFormatter.string(from: date)
        }

        return nil
    }
    
    func formatDate(format: String, fromFormat: String = "yyyy-MM-dd") -> String {
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = format
        dateFormatter.timeZone      = Calendar.current.timeZone
        dateFormatter.locale        = Locale(identifier: Shared.language.rawValue)
        
        let getDate = DateFormatter()
        getDate.dateFormat = fromFormat
        
        if getDate.date(from: self) == nil {
            return ""
        }
        
        return dateFormatter.string(from: getDate.date(from: self) ?? Date())
    }
     
    var fromBase64: String? {
        guard let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0)) else {
            return nil
        }
        return String(data: data as Data, encoding: String.Encoding.utf8)
    }
    
    var toBase64: String? {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
    
    // Convert String  to UIImage
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
    
    func base64ToImage() -> UIImage? {
        if let url = URL(string: self),let data = try? Data(contentsOf: url),let image = UIImage(data: data) {
            return image
        }
        return nil
    }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func usdCurrencyFormatter() -> String {
        var number                          : NSNumber = NSNumber()
        let formatter                       = NumberFormatter()
        formatter.numberStyle               = .currency
        formatter.currencySymbol            = ""
        formatter.currencyDecimalSeparator  = "."
        formatter.currencyGroupingSeparator = ","
        formatter.maximumFractionDigits     = 2
        formatter.minimumFractionDigits     = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        if let regex = try? NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive) {
            amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        }
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number) ?? ""
    }
    
    func khrCurrencyFormatter() -> String {
        var number                          : NSNumber = NSNumber()
        let formatter                       = NumberFormatter()
        formatter.numberStyle               = .decimal
        formatter.currencySymbol            = ""
        formatter.currencyGroupingSeparator = ","
        formatter.currencyDecimalSeparator  = ","
        formatter.decimalSeparator          = ","
        formatter.currencyCode              = ""
        formatter.groupingSeparator         = ","
 
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        if let regex = try? NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive) {
            amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        }
            
        if let myInteger = Int(((amountWithPrefix as NSString) as String)) {
            number = NSNumber(value: myInteger)
        }
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number) ?? ""
    }
    
    func vndCurrencyFormatter() -> String {
        var number                          : NSNumber = NSNumber()
        let formatter                       = NumberFormatter()
        formatter.numberStyle               = .decimal
        formatter.currencySymbol            = ""
        formatter.currencyGroupingSeparator = "."
        formatter.currencyDecimalSeparator  = "."
        formatter.decimalSeparator          = "."
        formatter.currencyCode              = ""
        formatter.groupingSeparator         = "."
 
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        if let regex = try? NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive) {
            amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        }
            
        if let myInteger = Int(((amountWithPrefix as NSString) as String)) {
            number = NSNumber(value: myInteger)
        }
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number) ?? ""
    }
}

func changeFormatDate(_ dateStr: String, fromFormat: String, toFormat: String) -> String {
    let dateFormatter           = DateFormatter()
    dateFormatter.dateFormat    = fromFormat
    dateFormatter.locale      = Locale(identifier: Shared.language.rawValue)
    var dateString              = ""
    if let date = dateFormatter.date(from: dateStr) {
        dateFormatter.dateFormat    = toFormat
        let formattedDate           = dateFormatter.string(from: date)
        dateString                  = formattedDate

    }
    return dateString
}

func customDate(date: String, week: String = "") -> String {
    var h: String = ""
    
    let dateFormatter           = DateFormatter()
    dateFormatter.dateFormat    = "yyyyMMddHHmmss"
     
    if let hour = dateFormatter.date(from: date) {
        let date         = DateFormatter()
        date.dateFormat  = "HH:mm"
        date.locale      = Locale(identifier: Shared.language.rawValue)
        h = date.string(from: hour)
    }
    
    if let dateft = dateFormatter.date(from: date) {
        let date         = DateFormatter()
        date.dateFormat  = "dd MMM yyyy" // HH:mm
        date.locale      = Locale(identifier: Shared.language.rawValue)
        return week.isEmpty ? "\(date.string(from: dateft)) " : "\(date.string(from: dateft)) (\(week))"
//        return week.isEmpty ? "\(date.string(from: dateft)) @\(h)" : "\(date.string(from: dateft)) @\(h) (\(week))"
    }
    
    let dateFormatter2 = DateFormatter()
    dateFormatter2.dateFormat = "yyyyMMdd"
    
    if let dateft2 = dateFormatter2.date(from: date) {
        let date         = DateFormatter()
        date.dateFormat  = "dd MMM yyyy" // HH:mm
        date.locale      = Locale(identifier: Shared.language.rawValue)
        return week.isEmpty ? "\(date.string(from: dateft2)) " : "\(date.string(from: dateft2)) (\(week))"
//        return week.isEmpty ? "\(date.string(from: dateft2)) \(h.isEmpty ? "" : "@\(h)")" : "\(date.string(from: dateft2)) \(h.isEmpty ? "" : "@\(h)") (\(week))"
    }
    
    return ""
}
 
func formatterDate(date: String, week: String = "", dateFormat: String = "dd MMM yyyy") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = date.count == 14 ? "yyyyMMddHHmmss" : "yyyyMMdd"
    dateFormatter.locale = Locale(identifier: Shared.language.rawValue)
    var str = ""
       
    if let dateft = dateFormatter.date(from: date) {
        let date         = DateFormatter()
        date.dateFormat  = dateFormat
        date.locale      = Locale(identifier: Shared.language.rawValue)
        str = week.isEmpty ? "\(date.string(from: dateft)) " : "\(date.string(from: dateft)) (\(week))"
    }
    
    return str
}
 

func customFormatteDate(date: String, week: String = "") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = date.count == 14 ? "yyyyMMddHHmmss" : "yyyyMMdd"
    dateFormatter.locale = Locale(identifier: Shared.language.rawValue)
       
    var d: String = ""
    if let day = dateFormatter.date(from: date) {
        let date         = DateFormatter()
        date.dateFormat  = "dd"
        date.locale      = Locale(identifier: Shared.language.rawValue)
//        d = toKhmerNumber(str: date.string(from: day))
        d = date.string(from: day)
        d = date.string(from: day)
    }
   
    var y: String = ""
    if let year = dateFormatter.date(from: date) {
        let date         = DateFormatter()
        date.dateFormat  = "yyyy"
        date.locale      = Locale(identifier: Shared.language.rawValue)
//        y = toKhmerNumber(str: date.string(from: year))
      
        y = date.string(from: year)
    }
    
    var m: String = ""
    if let month = dateFormatter.date(from: date) {
        let date         = DateFormatter()
        date.dateFormat  = "MM"
        date.locale      = Locale(identifier: Shared.language.rawValue)
        m = date.string(from: month)
        m = date.string(from: month)
    }
    
    if let dateft = dateFormatter.date(from: date) {
        let date         = DateFormatter()
        date.locale      = Locale(identifier: Shared.language.rawValue)
        
        switch Shared.language {
        case .English:
            date.dateFormat  =  "dd-MM-yyyy"
            return week.isEmpty ? "\(date.string(from: dateft))" : "\(date.string(from: dateft)) (\(week))"
        case .Vietnamese:
            date.dateFormat  =  "dd-MM-yyyy"
            let newDateFormatter = "\(d)-\(m.replace(of: "thg", with: ""))-\(y)"
            return week.isEmpty ? "\(newDateFormatter) " : "\(newDateFormatter) (\(week))"
        }
    }
    
    return ""
}
func formatTime(_ timeString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HHmmss"
    
    if let date = dateFormatter.date(from: timeString) {
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    } else {
        return nil // Return nil for invalid time string
    }
}
func formatDate(_ timeString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    
    if let date = dateFormatter.date(from: timeString) {
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: date)
    } else {
        return nil // Return nil for invalid time string
    }
}


func convertDate(strDate: String)-> Date?{
        
        //CurrentDate
    let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        // Past
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"

        
       return dateFormatter.date(from: strDate)

    }

func calDateformatTime(_ timeString: String) -> String? {
    
        let startDate = convertDate(strDate: timeString)
        
        var finalDate = ""
        
        guard let startDate = startDate else { return "" }
        
    let currentDate = Date()
        
        let time = Date.calculateDate(end_Date: currentDate, start_date: startDate)
        let formatter = DateComponentsFormatter()
        
    if time <= 1{
        formatter.allowedUnits = [.second]
       
        finalDate = formatter.string(from: time)! + "now".localized
    }
       else if time >= 1 && time < 60{
            formatter.allowedUnits = [.second]
            
           finalDate = formatter.string(from: time)! + "second".localized
        }
         else if time >= 60 && time < 3600{
            formatter.allowedUnits = [.minute]
            
             finalDate = formatter.string(from: time)! + "min".localized
        }
         else if time >= 3600 && time < 86400  {
            formatter.allowedUnits = [.hour]
             var hourlocalize = "hour_ago".localized
             if time == 3600 {
                 hourlocalize = "hour".localized
             }
           finalDate = formatter.string(from: time)! + hourlocalize
        }
        else
        {
            let dateFormatter = DateFormatter()
            switch Shared.language{
            case .English, .Vietnamese:
                dateFormatter.dateFormat = "dd-MM-yyyy"
            }
            finalDate = dateFormatter.string(from: startDate)
           
        }
        return finalDate
    }




func formatteDate(date: String, week: String = "") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = date.count == 14 ? "yyyyMMddHHmmss" : "yyyyMMdd"
    dateFormatter.locale = Locale(identifier: Shared.language.rawValue)
       
    var d: String = ""
    if let day = dateFormatter.date(from: date) {
        let date         = DateFormatter()
        date.dateFormat  = "dd"
        date.locale      = Locale(identifier: Shared.language.rawValue)
//        d = toKhmerNumber(str: date.string(from: day))
        d = date.string(from: day)
        d = date.string(from: day)
    }
   
    var y: String = ""
    if let year = dateFormatter.date(from: date) {
        let date         = DateFormatter()
        date.dateFormat  = "yyyy"
        date.locale      = Locale(identifier: Shared.language.rawValue)
//        y = toKhmerNumber(str: date.string(from: year))
      
        y = date.string(from: year)
    }
    
    var m: String = ""
    if let month = dateFormatter.date(from: date) {
        let date         = DateFormatter()
        date.dateFormat  = "MM"
        date.locale      = Locale(identifier: Shared.language.rawValue)
        m = date.string(from: month)
        m = date.string(from: month)
    }
    
    if let dateft = dateFormatter.date(from: date) {
        let date         = DateFormatter()
        date.locale      = Locale(identifier: Shared.language.rawValue)
        
        switch Shared.language {
        case .English:
            date.dateFormat  =  "dd-MM-yyyy"
            return week.isEmpty ? "\(date.string(from: dateft))" : "\(date.string(from: dateft)) (\(week))"
        case .Vietnamese:
            date.dateFormat  =  "dd-MM-yyyy"
            let newDateFormatter = "\(d)-\(m.replace(of: "thg", with: ""))-\(y)"
            return week.isEmpty ? "\(newDateFormatter) " : "\(newDateFormatter) (\(week))"
        }
    }
    
    return ""
}

func formatteDate(dateStr: String, fromFormat: String = "") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateStr.count == 14 ? "yyyyMMddHHmmss" : "yyyyMMdd"
    dateFormatter.locale = Locale(identifier: Shared.language.rawValue)
       
    var d: String = ""
    if let day = dateFormatter.date(from: dateStr) {
        let date         = DateFormatter()
        date.dateFormat  = "dd"
        date.locale      = Locale(identifier: Shared.language.rawValue)
        d = date.string(from: day)
    }
    
    var m: String = ""
    if let month = dateFormatter.date(from: dateStr) {
        let date         = DateFormatter()
        date.dateFormat  = "MMMM"
        date.locale      = Locale(identifier: Shared.language.rawValue)
        m = date.string(from: month)
    }
    
    if let dateft = dateFormatter.date(from: dateStr) {
        let date         = DateFormatter()
        date.locale      = Locale(identifier: Shared.language.rawValue)
        
        switch Shared.language {
        case .English:
            date.dateFormat  =  "MMMM dd"
            return "\(date.string(from: dateft))"
        case .Vietnamese:
            date.dateFormat  =  "dd MMMM"
            let newDateFormatter = "\(d) \(m)"
            return "\(newDateFormatter)"
        }
    }
    
    return ""
}
 
func formattingNumber(_ num: Double) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.groupingSeparator       = ","
    numberFormatter.groupingSize            = 3
    numberFormatter.usesGroupingSeparator   = true
    numberFormatter.decimalSeparator        = "."
    numberFormatter.numberStyle             = .decimal
    return numberFormatter.string(from: num as NSNumber)!
}

func dateft(date: String, df: String = "MMMM, yyyy") -> String {
    let dateFormatter           = DateFormatter()
    dateFormatter.dateFormat    = "yyMM"
    dateFormatter.locale        = Locale(identifier: Shared.language.rawValue)
    
    var m: String = ""
    if let month = dateFormatter.date(from: date) {
        let date         = DateFormatter()
        date.dateFormat  = "MMM"
        date.locale      = Locale(identifier: Shared.language.rawValue)
        m = date.string(from: month)
    }
    
    var y: String = ""
    if let year = dateFormatter.date(from: date) {
        let date         = DateFormatter()
        date.dateFormat  = "yyyy"
        date.locale      = Locale(identifier: Shared.language.rawValue)
        y = date.string(from: year)
    }
    
    let dateformate     = DateFormatter()
    dateformate.locale  = Locale(identifier: Shared.language.rawValue)
    
    switch Shared.language {
    case .English:
        dateformate.dateFormat  = df
        dateformate.locale      = Locale(identifier: Shared.language.rawValue)
        return dateformate.string(from: dateFormatter.date(from: date) ?? Date())
        
    case .Vietnamese:
        dateformate.dateFormat  = df
        let newDateFormatter    = "tháng\(m.replace(of: "thg", with: "")), năm \(y)"
        return newDateFormatter
    }
}

/// Formats an amount for display.
///
/// This build is WeCMS (Vietnam), so amounts are always formatted as VND — USD values keep
/// their decimal part, everything else is grouped without one. The former `WABOOKS_VERSION`
/// parameter selected KHR formatting for WABOOKS Cambodia and is gone with that product.
func customFormatCurrency(CCY_CD: String, amount: String) -> String {

    // NOTE: the server always responds with currency amounts in ##.## form.
    return CCY_CD == "USD" ? amount.vndCurrency : amount.vndCurrencyFormatter()
}

func formatCurrency(type: String, amount: String) -> String {
 
    var amtFormatter : String = ""
    if type == "USD" {
        
        if amount.contains(".") {
            let formatte = amount.components(separatedBy: ".")
            
            // server will alwasy ##.## if Currency type USD
            let str = (formatte.first ?? "").formatUSDCurrency() // formatte prefix value
            let fmt = str.components(separatedBy: ".").first ?? "" // remove .00
            amtFormatter = "\(fmt).\(String(formatte.last ?? "").prefix(2))" // combine formatte to ##.##
            
//            if amount.contains(".00") {
//                amtFormatter = (formatte.first ?? "").formatUSDCurrency()
//            }else {
//                let str = (formatte.first ?? "").formatUSDCurrency() // formatte prefix value
//                let fmt = str.components(separatedBy: ".").first ?? "" // remove .00
//                amtFormatter = "\(fmt).\(String(formatte.last ?? "").prefix(2))" // combine formatte to ##.##
//            }
            
        } else {
            amtFormatter = amount.formatUSDCurrency()
            
        }
    }
    else {
        if amount.contains(".") {
            let formatte = amount.components(separatedBy: ".")
            amtFormatter = (formatte.first ?? "").formatKHRCurrency()
        }
        else {
            amtFormatter = amount.formatKHRCurrency()
        }
    }

    return amtFormatter
}
 
func convertToBase64(_ image: UIImage) -> String! {
    return image.jpegData(compressionQuality: 0.5)?.base64EncodedString(options: .endLineWithLineFeed)
}

func customSectionDate(date: String) -> String {
    let dateFormatter           = DateFormatter()
    dateFormatter.dateFormat    = "yyyyMM"
    
    let components  = Calendar.current.dateComponents(
        [.year, .month],
        from: date == "" ? Date() : dateFormatter.date(from: date)!
    )
    
    switch Shared.language {
    case .English:
        return "\("month".localized)\(components.month!) \(components.year!)\("year".localized)"
    case .Vietnamese:
        return "\("month".localized)\(components.month!) \("year".localized)\(components.year!)"
    }
}

//> Seanghay <\\ CONVERT IMAGE URL to BASE64
func convertImage(imageURL: String) -> String {
    var afterStr = ""
    let url = URL(string: imageURL)
        if let data = try? Data(contentsOf: url!)
        {
            let image: UIImage = UIImage(data: data) ?? UIImage()
            if let base64 = convertToBase64(image) {
                afterStr = base64
            }
            
        }
    return afterStr
}

func convertImageURLSession(imageURL: String) -> String {
    guard let url = URL(string: imageURL) else {
        return ""
    }

    var base64String = ""
    
    let semaphore = DispatchSemaphore(value: 0)
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
        
        if let data = data, let image = UIImage(data: data) {
            base64String = convertToBase64(image) ?? ""
        }
        
        semaphore.signal()
    }.resume()

    semaphore.wait()
    
    return base64String
}

extension String {
    
    func stringHeightWithFontSize(_ fontSize: CGFloat,width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping;
        let attributes = [NSAttributedString.Key.font:font,
                          NSAttributedString.Key.paragraphStyle:paragraphStyle.copy()]
        
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.height
    }
    
    var toDictionary: [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                #if DEBUG
                print(error.localizedDescription)
                #endif
            }
        }
        return nil
    }
    
    func formatToDate(format: String, locale: String = MyDefaults.string(key: .appLang)) -> Date {
           let dateFormatter           = DateFormatter()
           dateFormatter.dateFormat    = format
           dateFormatter.timeZone      = Calendar.current.timeZone
           dateFormatter.locale        = Locale(identifier: locale /*"en_US_POSIX"*/) // Calendar.current.locale
           
        return dateFormatter.date(from: self) ?? Date()
    }
    
    func stringToDate(format: String) -> Date {

        let dateFormatter = DateFormatter()
        
        dateFormatter.locale     = Locale(identifier: MyDefaults.get(key: .appLang) as! String)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self) ?? Date()
        return date
    }
    
    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(encodedOffset: index)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
    
    func getLast3Characters() -> String {
        if self.count > 3 {
            let product = self.suffix(3)
            return String(product)
        }
        else {
            return self
        }
    }
    
    func getLast2Characters() -> String {
        if self.count > 2 {
            let product = self.suffix(2)
            return String(product)
        }
        else {
            return self
        }
    }
    
    func getLast30Characters() -> String {
        if self.count > 30 {
            let product = self.suffix(30)
            return String(product)
        }
        else {
            return self
        }
    }
    
    func removing(charactersOf string: String) -> String {
        let characterSet = CharacterSet(charactersIn: string)
        let components   = self.components(separatedBy: characterSet)
        return components.joined(separator: "")
    }
    
    func deletingPrefix(_ prefix: String) -> String {
            guard self.hasPrefix(prefix) else { return self }
            return String(self.dropFirst(prefix.count))
        }
    
    subscript(_ range: CountableRange<Int>) -> String {
          let start = index(startIndex, offsetBy: max(0, range.lowerBound))
          let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                               range.upperBound - range.lowerBound))
          return String(self[start..<end])
      }

      subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
          let start = index(startIndex, offsetBy: max(0, range.lowerBound))
           return String(self[start...])
      }
}

extension Date {
    static func calculateDate (end_Date: Date, start_date: Date) -> TimeInterval {
        return end_Date.timeIntervalSinceReferenceDate - start_date.timeIntervalSinceReferenceDate
    }
}

extension String {
    func numberOfOccurrencesOf(string: String) -> Int {
        return self.components(separatedBy:string).count - 1
    }
}



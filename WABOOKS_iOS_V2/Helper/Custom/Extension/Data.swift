//
//  Data.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 5/1/21.
//

import Foundation


extension Data {
    // - For Print Response Data
    var prettyPrinted: String {
        return MyJSON.prettyPrint(value: self.dataToDic)
    }
    
    var dataToDic: NSDictionary {
        guard let dic: NSDictionary = (try? JSONSerialization.jsonObject(with: self, options: [])) as? NSDictionary else {
            return [:]
        }
        
        return dic
    }
    
    var hexString: String {
        return self.reduce("", { $0 + String(format: "%02x", $1) })
    }
    
    func toBase64() -> String? {
        Data( self).base64EncodedString()
    }
    
    init?(hexString: String) {
        let length = hexString.count / 2
        var data = Data(capacity: length)
        for i in 0 ..< length {
            let j = hexString.index(hexString.startIndex, offsetBy: i * 2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var byte = UInt8(bytes, radix: 16) {
                data.append(&byte, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Relocated from EditArticleVC.swift (removed with the WABOOKS-only screens).
// Still used by EditArticleWeCMSVC.
extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

//
//  Log.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 5/1/21.
//

import Foundation

public class log: Log {
    
}

public class Log {
    
    /// Show "P R I N T" Message
    @discardableResult init(_ object: Any?..., filename: String = #file, line: Int = #line, funcname: String = #function) {
        print("\n---------------------------------- ᑭ ᖇ I ᑎ T -------------------------------------")
        Log.customLog(object, filename: filename, line: line, funcname: funcname)
    }
    
    /// Show "S U C C E S S" Message
    class func s(_ object: Any?..., filename: String = #file, line: Int = #line, funcname: String = #function) {
        print("\n-------------------------------- ᔕ ᑌ ᑕ ᑕ E ᔕ ᔕ ----------------------------------")
        customLog(object, filename: filename, line: line, funcname: funcname)
    }
    
    /// Show "E R R O R" Message
    class func e(_ object: Any?..., filename: String = #file, line: Int = #line, funcname: String = #function) {
        print("\n---------------------------------- E ᖇ ᖇ O ᖇ -------------------------------------")
        customLog(object, filename: filename, line: line, funcname: funcname)
    }
    
    /// Show "W A R N I N G" Message
    class func w(_ object: Any?..., filename: String = #file, line: Int = #line, funcname: String = #function) {
        print("\n-------------------------------- ᗯ ᗩ ᖇ ᑎ I ᑎ G ---------------------------------")
        customLog(object, filename: filename, line: line, funcname: funcname)
    }
    
    /// Show "R E Q U E S T" Message
    class func r(_ object: Any?..., filename: String = #file, line: Int = #line, funcname: String = #function) {
        print("\n--------------------------------- ᖇ E ᑫ ᑌ E ᔕ T ----------------------------------")
        customLog(object, filename: filename, line: line, funcname: funcname)
    }
    
    private class func customLog(_ object: [Any?], filename: String = #file, line: Int = #line, funcname: String = #function) {
        print("‣ \(filename.components(separatedBy: "/").last ?? "") | Line: \(line) | \(funcname.replace(of: ":", with: ", ").replace(of: ", )", with: ")"))")
        print("")
        print("", terminator: "")
        
        object.forEach { (obj) in
            if let obj = obj {
                if (obj as? String ?? "").contains("\n") {
                    print((obj as? String ?? "") /*.replace(of: "\n", with: "\n| ") */, terminator: " ")
                }
                else {
                    debugPrint(obj, terminator: " ")
                }
            }
            else {
                print("nil", terminator: " ")
            }
        }
        
        print("\n----------------------------------------------------------------------------------\n")
    }
}

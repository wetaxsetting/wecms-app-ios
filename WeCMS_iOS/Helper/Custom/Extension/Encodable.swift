//
//  Encodable.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 5/1/21.
//

import Foundation

extension Encodable {
    
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
    
    func asJSONString() -> String? {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData    = try jsonEncoder.encode(self)
            let jsonString  = String(data: jsonData, encoding: .utf8)
            return jsonString
        } catch {
            return nil
        }
    }
}

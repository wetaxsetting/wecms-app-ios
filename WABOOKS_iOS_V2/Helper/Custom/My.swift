//
//  My.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 5/1/21.
//

import Foundation
import AVFoundation

struct MyJSON {
    
    enum JSONError: Error {
        case serializedJSONError // dic -> JSON
        case deserializedJSONError
    }
    
    enum DataError: Error {
        case invalidEncodingData
    }
    
    static func prettyPrint(value: AnyObject) -> String {
        if JSONSerialization.isValidJSONObject(value) {
            if let data = try? JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted) {
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }
        }
        return ""
    }
    
    static func dataToDic(_ data: Data) -> NSDictionary? {
        guard let dic: NSDictionary = (try? JSONSerialization.jsonObject(with: data, options: [])) as? NSDictionary else {
            return nil
        }
        
        return dic
    }
    
    static func jsonToDic(_ data: Data) throws -> NSDictionary {
        guard let dic: NSDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
            throw JSONError.deserializedJSONError
        }
        
        return dic
    }
    
    static func dicToJSONString(_ dic: [String:Any]) throws -> String {
        let data: Data = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions(rawValue: 0))
        
        guard let jsonString: String = String(data: data, encoding: String.Encoding.utf8) else {
            throw DataError.invalidEncodingData
        }
        
        return jsonString
    }
    
    static func jsonStringToDic(_ jsonString : String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
        } catch {
            #if DEBUG
            Log.e(error.localizedDescription)
            #endif
            return nil
        }
    }
}

struct MyNotify {
    
    static func send(name: NotifyKey) {
        NotificationCenter.default.post(name: Notification.Name(name.rawValue), object: nil)
    }
    
    static func send(name: NotifyKey, object: AnyObject) {
        print(object, "obj")
        NotificationCenter.default.post(name: Notification.Name(name.rawValue), object: object)
    }
    
    static func listen(_ me: Any, selector: Selector, name: NotifyKey) {
        NotificationCenter.default.addObserver(me, selector: selector, name: Notification.Name(name.rawValue), object: nil)
    }
    
    static func listen(name: NotifyKey, completion: @escaping Completion) {
        NotificationCenter.default.addObserver(forName: Notification.Name(name.rawValue), object: nil, queue: nil) { _ in
            completion()
        }
    }
    
    static func listen(name: NotifyKey, completion: @escaping (AnyObject) -> Void) {
        NotificationCenter.default.addObserver(forName: Notification.Name(name.rawValue), object: nil, queue: nil) { sender in
            completion(sender.object as AnyObject)
        }
    }
    
    static func remove(_ me: Any, name: String) {
        NotificationCenter.default.removeObserver(me, name: NSNotification.Name(rawValue: name), object: nil)
    }
}

struct MyDefaults {
    
    static func set(key: UserDefaultKey, value: Any?) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func get(key: UserDefaultKey) -> Any? {
        return UserDefaults.standard.object(forKey: key.rawValue)
    }
    
    static func bool(key: UserDefaultKey) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    static func int(key: UserDefaultKey) -> Int {
        return UserDefaults.standard.integer(forKey: key.rawValue)
    }
    
    static func float(key: UserDefaultKey) -> Float {
        return UserDefaults.standard.float(forKey: key.rawValue)
    }
    
    static func double(key: UserDefaultKey) -> Double {
        return UserDefaults.standard.double(forKey: key.rawValue)
    }
    
    static func string(key: UserDefaultKey) -> String {
        return UserDefaults.standard.string(forKey: key.rawValue) ?? ""
    }
    
    static func dic(key: UserDefaultKey) -> [String: Any] {
        return UserDefaults.standard.dictionary(forKey: key.rawValue) ?? [:]
    }
    
    static func data(key: UserDefaultKey) -> Data {
        return UserDefaults.standard.data(forKey: key.rawValue) ?? Data()
    }
    
    static func array(key: UserDefaultKey) -> [Any] {
        return UserDefaults.standard.array(forKey: key.rawValue) ?? []
    }
    
    static func url(key: UserDefaultKey) -> URL? {
        return UserDefaults.standard.url(forKey: key.rawValue)
    }
}

struct UTF8 {
    
    static func encode(_ string:String) -> String! {
        let allowedCharacterSets = (NSCharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSets.removeCharacters(in: "!@#$%^&*()-_+=~`:;\"'<,>.?/")
        
        guard let encodeString = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSets as CharacterSet) else{
            return nil
        }
        
        return encodeString
    }
    
    static func decode(_ string:String) -> String! {
        guard let encodeString = string.removingPercentEncoding else{
            return nil
        }
        
        return encodeString
    }
    
    static func decodeForData(_ data: Data) -> Data! {
        guard let decode = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else{
            return nil
        }
        
        if let percentageDecode = decode.removingPercentEncoding {
            return percentageDecode.data(using: String.Encoding.utf8)
        }
        return decode.data(using: String.Encoding.utf8.rawValue)
    }
}

struct MySound {
    
    static private var player: AVAudioPlayer?
    
    static func play() {
        guard let url = Bundle.main.url(forResource: "beep", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            player.prepareToPlay()
            player.play()
        }
        catch let error{
            print(error.localizedDescription)
        }
    }
}

struct MyConnection {
  
//  static let banner1 = StatusBarNotificationBanner(title: "No Internet Connection", style: BannerStyle.danger)
//  static let banner2 = StatusBarNotificationBanner(title: "Connected", style: BannerStyle.success)'
    
    
    static func showNoConnection() {
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindowInConnectedScenes
            window?.rootViewController?.customAlert(type: .CONFIRM_ALERT,
                                                    image: "badge_failed",
                                                    title: "notice".localized,
                                                    message: "connection_is_unstable_please_try_again_later".localized,
                                                    redTitle: "", greyTitle: "try_again".localized) { (_) in
                
            }
        }
    }
    
    static func dissmissNoConnection() {
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow
            window?.rootViewController?.presentedViewController?.dismiss(animated: true, completion: {
                
            })
        }
    }
    
    static func showConnected() {
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow
            window?.rootViewController?.customAlert(type: .CONFIRM_ALERT,
                                                    image: "badge_failed",
                                                    title: "notice".localized,
                                                    message: "Connected",
                                                    redTitle: "", greyTitle: "confirm".localized) { (_) in
                
            }
        }
    }
  
  static func isReachable(completion: @escaping Completion) {
      NetworkManager.isReachable { _ in
          completion()
      }
  }
  
  static func isUnreachable(completion: @escaping Completion) {
      NetworkManager.isUnreachable { _ in
          completion()
      }
  }
  
  static func checkWhenReachable(completion: @escaping Completion = { }) {
//      banner1.layer.zPosition = 999
//      banner2.layer.zPosition = 999
      
      NetworkManager.isUnreachable { _ in
        print("No internet connection")
//            #if DEBUG
//            Log.e("Error Connection")
//            #endif
          
//          banner2.dismiss()
//          banner1.show()
        self.showNoConnection()
      }
      
      NetworkManager.sharedInstance.whenUnreachable = { _ in
        Log.e("Error Unreachable")
//            #if DEBUG
//            Log.e("Error Unreachable")
//            #endif
          
//          banner2.dismiss()
//          banner1.show()
        self.showNoConnection()
      }
      
      NetworkManager.sharedInstance.whenReachable = { _ in
        Log.e("reachable")
//          banner1.dismiss()
//          completion()
        
        self.dissmissNoConnection()
        completion()
      }
  }
}

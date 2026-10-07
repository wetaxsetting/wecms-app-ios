//
//  UIDevice.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 19/1/21.
//

import Foundation

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
}

extension UIDevice {
    
    public struct ScreenSize {
        static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
        static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
        static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }

    enum DeviceScreenSize {
        case Mini           // iPhone 4 4s 5 or 5S or 5C or 5SE
        case Meduim         // iPhone 6/6S/7/8
        case Plus           // iPhone 6+/6S+/7+/8+
        case XSerial        // iPhone X, XS, 11Pro, iPhone XR, 11
        case XMaxSerial     // iPhone XS Max, 11Pro Max
    }
    
    private static func deviceId() -> Int {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 960:
                return 0
            case 1136:
                return 1
            case 1334:
                return 2
            case 1920, 2208:
                return 3
            case 2436:
                return 4
            case 2688:
                return 5
            case 1792:
                return 6
            default:
                return 999
            }
        }
        return 0
    }
    
    static func getDeviceScreenType() -> DeviceScreenSize {
        let _deviceId = Self.deviceId()
        if _deviceId == 0 || _deviceId == 1 { return .Mini }
        else if _deviceId == 2 { return .Meduim }
        else if _deviceId == 3 { return .Plus }
        else if _deviceId == 4 || _deviceId == 6 { return .XSerial }
        else if _deviceId == 5 { return .XMaxSerial }
        else { return .Meduim }
    }
    
    
    public enum EnumModel: String {
        case simulator     = "simulator/sandbox",
        //iPod
        iPod1              = "iPod 1",
        iPod2              = "iPod 2",
        iPod3              = "iPod 3",
        iPod4              = "iPod 4",
        iPod5              = "iPod 5",
        
        //iPad
        iPad2              = "iPad 2",
        iPad3              = "iPad 3",
        iPad4              = "iPad 4",
        iPadAir            = "iPad Air ",
        iPadAir2           = "iPad Air 2",
        iPad5              = "iPad 5", //aka iPad 2017
        iPad6              = "iPad 6", //aka iPad 2018
        
        //iPad mini
        iPadMini           = "iPad Mini",
        iPadMini2          = "iPad Mini 2",
        iPadMini3          = "iPad Mini 3",
        iPadMini4          = "iPad Mini 4",
        
        //iPad pro
        iPadPro9_7         = "iPad Pro 9.7\"",
        iPadPro10_5        = "iPad Pro 10.5\"",
        iPadPro12_9        = "iPad Pro 12.9\"",
        iPadPro2_12_9      = "iPad Pro 2 12.9\"",
        
        //iPhone
        iPhone4            = "iPhone 4",
        iPhone4S           = "iPhone 4S",
        iPhone5            = "iPhone 5",
        iPhone5S           = "iPhone 5S",
        iPhone5C           = "iPhone 5C",
        iPhone6            = "iPhone 6",
        iPhone6plus        = "iPhone 6 Plus",
        iPhone6S           = "iPhone 6S",
        iPhone6Splus       = "iPhone 6S Plus",
        iPhoneSE           = "iPhone SE",
        iPhone7            = "iPhone 7",
        iPhone7plus        = "iPhone 7 Plus",
        iPhone8            = "iPhone 8",
        iPhone8plus        = "iPhone 8 Plus",
        iPhoneX            = "iPhone X",
        iPhoneXS           = "iPhone XS",
        iPhoneXSMax        = "iPhone XS Max",
        iPhoneXR           = "iPhone XR",
        iPhone11           = "iPhone 11",
        iPhone11Pro        = "iPhone 11 Pro",
        iPhone11ProMax     = "iPhone 11 Pro Max",
        
        //Apple TV
        AppleTV            = "Apple TV",
        AppleTV_4K         = "Apple TV 4K",
        unrecognized       = "?unrecognized?"
    }
    
    static func getOSVerstion() -> Double {
        Double(UIDevice.current.systemVersion) ?? 0
    }
    
    /// 앱 버전 가져옴
    static func getAppVersion() -> String {
        let mainBundleDictionary = Bundle.main.infoDictionary! as NSDictionary
        return mainBundleDictionary.object(forKey: "CFBundleShortVersionString") as? String ?? ""
    }
}

extension UIDevice {
    
    static let deviceIdentifier: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        return identifier
    }()
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()
}


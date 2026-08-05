//
//  LanguageManager.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 5/1/21.
//

import Foundation

/// Parsed once and held for the process lifetime — `LocalizedString.json` is a bundle
/// resource, so it cannot change while the app is running. Previously every `.localized`
/// call re-read and re-parsed all ~540 keys from disk, on every label.
private let localizedStrings: [String: [String: String]] = {
    guard let path = Bundle.main.path(forResource: "LocalizedString", ofType: "json"),
          let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
          let dic  = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return [:] }

    var out: [String: [String: String]] = [:]
    for (key, value) in dic {
        if let translations = value as? [String: String] { out[key] = translations }
    }
    return out
}()

extension String {

    var localized: String {
        // Falls back to English, then to the key itself. Never force-unwraps: a key that
        // is missing a translation for the active language must not crash the app.
        guard let translations = localizedStrings[self] else { return self }
        return translations[Shared.language.rawValue]
            ?? translations[LanguageCode.English.rawValue]
            ?? self
    }
}

extension UILabel {
   
   func getlocalizedFont() {
       let fontNameToTest = self.font.fontName.lowercased();
       let fontName = Shared.share.getLocalizedFont(preFontName: fontNameToTest)

       
       self.font =  UIFont(name: fontName, size: self.font.pointSize)
//        self.sizeToFit()
   }
   
    
//    @objc var localizedFont : UIFont? {
//        get {
//            let fontNameToTest = self.font.fontName.lowercased();
//
//            let fontName = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
//
//            return UIFont(name: fontName, size: self.font.pointSize)
//        }
//    }
   
   @objc var substituteFontName : String {
       get {
           return self.font.fontName;
       }
       set {
           
           let fontNameToTest = self.font.fontName.lowercased();
           
           let fontName = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
           
           self.font = UIFont(name: fontName, size: self.font.pointSize)
       }
   }
   
  

}

extension UITextView {
   
   func getlocalizedFont() {
       let fontNameToTest = self.font?.fontName.lowercased() ?? "";
       let fontName = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
       self.font =  UIFont(name: fontName, size: self.font?.pointSize ?? 17)
   }
   
   @objc var localizedFont : UIFont? {
       get {
           let fontNameToTest = self.font?.fontName.lowercased() ?? "";
           
           let fontName = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
           
           return UIFont(name: fontName, size: self.font?.pointSize ?? 17)
       }
   }
   
   @objc var substituteFontName : String {
       get {
           return self.font?.fontName ?? "";
       }
       set {
           let fontNameToTest = self.font?.fontName.lowercased() ?? "";
           
           let fontName = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
           
           self.font = UIFont(name: fontName, size: self.font?.pointSize ?? 17)
       }
   }
}

extension UITextField {
   
   func getlocalizedFont() {
       let fontNameToTest = self.font?.fontName.lowercased() ?? "";
       let fontName = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
       self.font =  UIFont(name: fontName, size: self.font?.pointSize ?? 17)
   }
   
   @objc var localizedFont : UIFont? {
       get {
           let fontNameToTest = self.font?.fontName.lowercased() ?? "";
           
           let fontName = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
           
           return UIFont(name: fontName, size: self.font?.pointSize ?? 17)
       }
   }
   
   @objc var substituteFontName : String {
       get {
           return self.font?.fontName ?? "";
       }
       set {
           let fontNameToTest = self.font?.fontName.lowercased() ?? "";
           
           let fontName = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
           
           self.font = UIFont(name: fontName, size: self.font?.pointSize ?? 17)
       }
   }
}

extension UIButton {
   
   func getlocalizedFont() {
       let fontNameToTest = self.titleLabel?.font?.fontName.lowercased() ?? ""
       let fontName = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
       self.titleLabel?.font =  UIFont(name: fontName, size: self.titleLabel?.font?.pointSize ?? 17)

   }
   
   @objc var localizedFont : UIFont? {
       get {
           
           let fontNameToTest = self.titleLabel?.font?.fontName.lowercased() ?? ""
           
           let fontName = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
           
           return UIFont(name: fontName, size: self.titleLabel?.font?.pointSize ?? 17)
       }
   }
   
   @objc var substituteFontName : String {
       get {
           return self.titleLabel?.font?.fontName ?? "";
       }
       set {
           let fontNameToTest = self.titleLabel?.font?.fontName.lowercased() ?? "";
           
           let fontName = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
           
           self.titleLabel?.font = UIFont(name: fontName, size: self.titleLabel?.font?.pointSize ?? 17)
       }
   }
   
}


extension UINavigationBar {
   
   func getlocalizedFont() {
       
       var name = "Battambang";
       if Shared.language.rawValue == LanguageCode.English.rawValue {
           name = "Rubik";
       }
       
       let fontName = "\(name)-Bold";
   
       // for default title size
       let attrs = [
           NSAttributedString.Key.font: UIFont(name: fontName, size: 18)!
       ]
       self.titleTextAttributes        = attrs
       

       // for large title size
       let attrsLargeNavi = [
           NSAttributedString.Key.font: UIFont(name: fontName, size: 28)!
       ]
       self.largeTitleTextAttributes   = attrsLargeNavi
       
       
       // For back bar button
       let attrsBarButton = [
           NSAttributedString.Key.font: UIFont(name: fontName, size: 15)!,
           NSAttributedString.Key.foregroundColor : UIColor.black
       ]
       UIBarButtonItem.appearance().setTitleTextAttributes(attrsBarButton, for: .normal)
       
       self.tintColor = .black
   }
   
   
   @objc var substituteFontName : String {
       get {
           return ""
       }
       set {
           let fontName = "\(newValue)-Bold";
           
           // for default title size
           let attrs = [
               NSAttributedString.Key.font: UIFont(name: fontName, size: 18)!
           ]
           self.titleTextAttributes        = attrs
           
           // for large title size
           let attrsLargeNavi = [
               NSAttributedString.Key.font: UIFont(name: fontName, size: 28)!
           ]
           self.largeTitleTextAttributes   = attrsLargeNavi
       }
   }
}

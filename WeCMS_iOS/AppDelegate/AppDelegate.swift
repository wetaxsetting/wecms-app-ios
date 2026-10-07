//
//  AppDelegate.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 5/1/21.
//

import UIKit
import IQKeyboardManagerSwift
import IQKeyboardToolbar
import IQKeyboardToolbarManager
import AudioToolbox
import Firebase
import UserNotifications
import Foundation



@main
 class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window      : UIWindow?
    var notificationList    : [MREC_R010.RESPONSE.REC] = []
    
    
    private func isDuplicateData(data: MREC_R010.RESPONSE.REC) -> Bool {
        return self.notificationList.contains(where: {$0 == data})
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().delegate = self
        
        // One-time migration: move old shared keychain keys to service-specific keys
        if let oldUsername = KeychainManager.get("username"), !oldUsername.isEmpty {
            KeychainManager.setCredential(oldUsername, forKey: "username")
            KeychainManager.delete("username")
        }
        if let oldPassword = KeychainManager.get("password"), !oldPassword.isEmpty {
            KeychainManager.setCredential(oldPassword, forKey: "password")
            KeychainManager.delete("password")
        }

        // Check app language
        if MyDefaults.get(key: .appLang) == nil {
            MyDefaults.set(key: .appLang, value: LanguageCode.English.rawValue)
            Shared.language = .English
        }
        else {
            Shared.language = LanguageCode(rawValue: MyDefaults.get(key: .appLang) as? String ?? "vi") ?? LanguageCode.Vietnamese
        }
        
        // Badge Icon to 0 when first launching app
        let isFirstTimeRunApp = MyDefaults.get(key: .firstTimeRunApp) as? Bool ?? true
        if isFirstTimeRunApp {
            UIApplication.shared.applicationIconBadgeNumber = 0
            MyDefaults.set(key: .firstTimeRunApp, value: false)
        }
        let hasReceivedNewNotification      = MyDefaults.get(key: .hasReceivedNotification) as? Bool ?? false
        Shared.hasReceivedNewNotification   = hasReceivedNewNotification
        
        Shared.badgeCount = UIApplication.shared.applicationIconBadgeNumber
        Shared.hasReceivedNewNotification = Shared.badgeCount != 0 // true: hide, false : show
        
        //IQKeyboardManager
        configIQKeyboard: do {
            IQKeyboardManager.shared.isEnabled                                = true
            IQKeyboardManager.shared.resignOnTouchOutside                     = true
            IQKeyboardManager.shared.resignGesture.isEnabled                  = true
            let doneConfig = IQBarButtonItemConfiguration(title: "done".localized)
            IQKeyboardToolbarManager.shared.toolbarConfiguration.doneBarButtonConfiguration = doneConfig
        }
        UITableView.appearance().sectionHeaderTopPadding = 0.0
        
 
        // Notification .plist file Setup
        var filePath:String!
        #if DEBUG
            print("[FIREBASE] Development mode.")
            filePath = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")
        #else
            print("[FIREBASE] Production mode.")
            filePath = Bundle.main.path(forResource: "GoogleService-Info-Release", ofType: "plist")
        #endif

        let options = FirebaseOptions.init(contentsOfFile: filePath)!
        FirebaseApp.configure(options: options)
        

        Messaging.messaging().delegate = self
        
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

//Push Notification
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        #if DEBUG
        print("Firebase registration token: \(String(describing: fcmToken ?? ""))")
        #endif
        Shared.deviceToken = fcmToken ?? ""
        
        MyDefaults.set(key: .deviceToken, value: fcmToken)
        
        if !(KeychainManager.getCredential("username") ?? "").isEmpty {
            
            PushNotificationVM().pushNotification_C006(reqBody: MREC_C006.REQUEST(
                                                            PUSHSERVER_KIND     : "APNS",
                                                            APP_ID              : Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? "",
                                                            DEVICE_ID           : UIDevice.current.identifierForVendor?.uuidString ?? "",
                                                            PUSH_ID             : Shared.deviceToken,
                                                            MODEL_NAME          : UIDevice.deviceIdentifier,
                                                            OS                  : UIDevice.current.systemVersion,
                                                            NOTE                : "",
                                                            RETRANS_YN          : "N", LANG_CODE: Shared.language.rawValue))

        }

    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.e(error.localizedDescription)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
        #if DEBUG
        print("MessagingDelegate recieved")
        print("didReceiveRemoteNotification \(userInfo)")
        #endif
 
        
        // has receive notification, for show or hide notification badge number on notification button
        MyDefaults.set(key: .hasReceivedNotification, value: true)
        
        // badge count
        let aps   = userInfo["aps"] as? [String : Any]
        let badge = aps?["badge"] as? Int ?? 0
        let url   = aps?["sound"] as? String
        
        let gcm     = userInfo["action"] as? String
        var urlStr  = ""
        
        if let data = gcm?.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let type = json["type"] as? Int, let url = json["url"] as? String {
                        
                        urlStr = "\(url)"
                        print("Type: \(type)")
                        print("URL: \(url)")
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        Shared.notificationURL  = urlStr
        Shared.badgeCount       = badge

        UIApplication.shared.applicationIconBadgeNumber = badge
        
        // has receive notification, for show or hide notification badge number on notification button
        Shared.hasReceivedNewNotification = true
        MyDefaults.set(key: .hasReceivedNotification, value: true)
        
        MyNotify.send(name: .checkingBadgeCount) // notification button style has new notification
        MyNotify.send(name: .gotoNotification) // fetching new notification R010
        
    }
    
    public func registerForRemoteNotifications() {
        
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
            
            switch error {
            case .none:
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                        
                    }
                } 
            case .some(let error):
                Log.e(error)
            }
        }
    }
    
    @objc func gotoNotificationVC() {
        MyNotify.send(name: .gotoNotification)
    }
}

// MARK: - Notification Delegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) { }
    
    // If the app is in the foreground, the app will call this
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    // If the app is in the background, nothing is called until the user taps the notification, at that point, the app will open and call this
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        let application = UIApplication.shared
        
        if (application.applicationState == .active) {
#if DEBUG
            print("user tapped the notification bar when the app is in foreground")
#endif
        }
        
        if (application.applicationState == .inactive) {
#if DEBUG
            print("user tapped the notification bar when the app is in background")
#endif
        }
        
        MyNotify.send(name: .gotoNotification)
        
        // has receive notification, for show or hide notification badge number on notification button
        MyDefaults.set(key: .hasReceivedNotification, value: true)
        Shared.hasReceivedNewNotification = true
        
        // badge count
        let aps   = userInfo["aps"] as? [String : Any]
        let badge = aps?["badge"] as? Int ?? 0
        
        let gcm     = userInfo["action"] as? String
        var urlStr  = ""
        
        if let data = gcm?.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let type = json["type"] as? Int, let url = json["url"] as? String {
                        
                        urlStr = "\(url)"
#if DEBUG
                        print("Type: \(type)")
                        print("URL: \(url)")
#endif
                    }
                    let DV_CD = json["dv_cd"] as? String
                    let REG_SEQ_NO = json["req_seq_no"] as? String
                    let BLTB_CD = json["bltb_cd"] as? String
                    let COMNT_SEQ_NO = json["comnt_seq_no"] as? String
                    let POST_APPR_DV = json["post_appr_dv"] as? String
                    let SEQ_NO = json["seq_no"] as? String
                  
                    Shared.actionData = ActionData(DV_CD:DV_CD ,REG_SEQ_NO:REG_SEQ_NO,BLTB_CD:BLTB_CD,POST_APPR_DV:POST_APPR_DV, COMNT_SEQ_NO:COMNT_SEQ_NO,SEQ_NO:SEQ_NO)
                 
                }
            } catch {
#if DEBUG
                print("Error parsing JSON: \(error)")
#endif
            }
        }
        Shared.notificationURL = urlStr
        Shared.badgeCount = badge
        UIApplication.shared.applicationIconBadgeNumber = badge
        
        Shared.isGetNotification = true
        
        completionHandler()
    }
}

struct ActionData {
    var DV_CD           : String?
    var REG_SEQ_NO      : String?
    var BLTB_CD         : String?
    var POST_APPR_DV    : String?
    var COMNT_SEQ_NO    : String?
    var SEQ_NO          : String?
}

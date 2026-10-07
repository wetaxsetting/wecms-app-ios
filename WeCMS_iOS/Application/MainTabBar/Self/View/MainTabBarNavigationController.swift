//
//  MainTabBarNavigationController.swift
//  WeCMS_iOS
//
//  Root navigation controller for the three WeCMS tabs (Receipt / Approvals / Notification).
//  Set as the app root from LaunchScreenVC and LoginVC via the "MainTabBarNav" scene in
//  MainTabBarSB, which replaced RootSplitViewController when the WABOOKS boards side menu
//  was removed — the split view existed only to host that sidebar.
//
//  A UINavigationController answers `supportedInterfaceOrientations` for itself rather than
//  asking its top child, so the `.all` mask that used to live on the split controller has to
//  be restated here or the app would silently lose portrait-upside-down on iPhone.
//

import UIKit

class MainTabBarNavigationController: UINavigationController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}

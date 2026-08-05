//
//  NetworkManager.swift
//  wegarden
//
//  Created by         TUYNUY         on 3/13/19.
//  Copyright © 2019         TUYNUY        . All rights reserved.
//

import Foundation
import Network

class NetworkManager: NSObject {
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.wmobile.NetworkMonitor")
    
    var whenReachable: ((NWPath) -> Void)?
    var whenUnreachable: ((NWPath) -> Void)?
    
    static let sharedInstance: NetworkManager = {
        return NetworkManager()
    }()
    
    override init() {
        monitor = NWPathMonitor()
        super.init()
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            if path.status == .satisfied {
                self.whenReachable?(path)
            } else {
                self.whenUnreachable?(path)
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    static func stopNotifier() {
        NetworkManager.sharedInstance.monitor.cancel()
    }
    
    // Network is reachable
    static func isReachable(completed: @escaping (NetworkManager) -> Void) {
        if NetworkManager.sharedInstance.monitor.currentPath.status == .satisfied {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    // Network is unreachable
    static func isUnreachable(completed: @escaping (NetworkManager) -> Void) {
        if NetworkManager.sharedInstance.monitor.currentPath.status != .satisfied {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    // Network is reachable via WWAN/Cellular
    static func isReachableViaWWAN(completed: @escaping (NetworkManager) -> Void) {
        let path = NetworkManager.sharedInstance.monitor.currentPath
        if path.status == .satisfied && path.usesInterfaceType(.cellular) {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    // Network is reachable via WiFi
    static func isReachableViaWiFi(completed: @escaping (NetworkManager) -> Void) {
        let path = NetworkManager.sharedInstance.monitor.currentPath
        if path.status == .satisfied && path.usesInterfaceType(.wifi) {
            completed(NetworkManager.sharedInstance)
        }
    }
}

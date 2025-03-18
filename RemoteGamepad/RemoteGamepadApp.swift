//
//  RemoteGamepadApp.swift
//  RemoteGamepad
//
//  Created by artchsh on 3/17/25.
//

import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Prevent device from auto-locking during gamepad use
        UIApplication.shared.isIdleTimerDisabled = true
        return true
    }
}

@main
struct RemoteGamepadApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var websocketManager = WebSocketManager(serverIP: "192.168.1.1", port: 8000)
    
    var body: some Scene {
        WindowGroup {
            GamepadView(websocketManager: websocketManager)
        }
    }
}

// Add orientation restriction
extension RemoteGamepadApp {
    var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
}

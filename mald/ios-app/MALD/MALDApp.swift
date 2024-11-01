//
//  MALDApp.swift
//  MALD
//
//  Created by Ishaan
//

import SwiftUI
import IQKeyboardManagerSwift

@main
struct MALDApp: App {
    @StateObject var appState = AppState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)

        }
    }
}

class AppState: ObservableObject {
    @Published var isAppLaunched = false
}



final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Your app initialization code can go here
        IQKeyboardManager.shared.enable = true

        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        SocketIOManager.sharedInstance.establishConnection()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketIOManager.sharedInstance.closeConnection()

    }
    
}

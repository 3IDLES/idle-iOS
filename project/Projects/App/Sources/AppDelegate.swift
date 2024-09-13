//
//  AppDelegate.swift
//  
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import AppTrackingTransparency
import AdSupport
import PresentationCore
import FirebaseCore


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
            self?.requestTrackingAuthorization()
        })
        
        // FireBase setting
        FirebaseApp.configure()
        
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

    private func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            switch status {
            case .authorized:
                // Tracking authorization dialog was shown
                // and we are authorized
                printIfDebug("앱추적권한: Authorized")
                
                // 추적을 허용한 사용자 식별자
                printIfDebug(ASIdentifierManager.shared().advertisingIdentifier)
            case .denied:
                // Tracking authorization dialog was
                // shown and permission is denied
                printIfDebug("앱추적권한: Denied")
            case .notDetermined:
                // Tracking authorization dialog has not been shown
                printIfDebug("앱추적권한: Not Determined")
            case .restricted:
                printIfDebug("앱추적권한: Restricted")
            @unknown default:
                printIfDebug("앱추적권한: Unknown")
            }
        })
    }
}

//
//  RemoteNotificationHelper.swift
//  RootFeature
//
//  Created by choijunios on 10/8/24.
//

import Foundation
import UserNotifications
import BaseFeature
import Core


import RxSwift

struct DeeplinkBundle {
    let deeplinks: [DeeplinkExecutable]
    let userInfo: [AnyHashable: Any]?
}

class RemoteNotificationHelper: NSObject {
    
    // Observable
    let deeplinks: BehaviorSubject<DeeplinkBundle> = .init(
        value: .init(deeplinks: [], userInfo: nil)
    )
    
    let deeplinkParser: DeeplinkParser = .init()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
}

extension RemoteNotificationHelper: UNUserNotificationCenterDelegate {
    
    /// 앱이 포그라운드에 있는 경우, 노티페이케이션이 도착하기만 하면 호출된다.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("!!")
    }
    
    /// 앱이 백그라운드에 있는 경우, 유저가 노티피케이션을 통해 액션을 선택한 경우 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let linkInfo = userInfo["link"] as? String {
            
            let testLinks = linkInfo.split(separator: "/").map(String.init)
            print(testLinks)
            do {
                let parsedLinks = try deeplinkParser.makeDeeplinkList(components: testLinks)
                deeplinks.onNext(.init(
                    deeplinks: parsedLinks,
                    userInfo: userInfo
                ))
                
            } catch {
                printIfDebug("딥링크 파싱실패 \(error.localizedDescription)")
            }
        }
    }
}

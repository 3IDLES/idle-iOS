//
//  RemoteNotificationHelper.swift
//  RootFeature
//
//  Created by choijunios on 10/8/24.
//

import Foundation
import UserNotifications
import BaseFeature
import Domain
import Core


import RxSwift

public class DefaultRemoteNotificationHelper: NSObject, RemoteNotificationHelper {
    
    // Observable
    public let deeplinks: BehaviorSubject<DeeplinkBundle> = .init(
        value: .init(deeplinks: [], userInfo: nil)
    )
    
    let deeplinkParser: DeeplinkParser = .init()
    
    public override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    public func handleNotificationInApp(detail: Domain.NotificationDetailVO) {
        switch detail {
        case .applicant(let id):
            let desination: PreDefinedDeeplinkPath = .postApplicant
            do {
                let parsedLinks = try deeplinkParser.makeDeeplinkList(components: desination.insideLinks, startFromRoot: false)
                deeplinks.onNext(.init(
                    deeplinks: parsedLinks,
                    userInfo: ["jobPostingId": id]
                ))
            } catch {
                printIfDebug("딥링크 파싱실패 \(error.localizedDescription)")
            }
        }
    }
}

extension DefaultRemoteNotificationHelper: UNUserNotificationCenterDelegate {
    
    /// 앱이 포그라운드에 있는 경우, 노티페이케이션이 도착하기만 하면 호출된다.
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        // 유저 인터렉션 불가 내부 이벤트로 처리야해야함
    }
    
    /// 앱이 백그라운드에 있는 경우, 유저가 노티피케이션을 통해 액션을 선택한 경우 호출
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        handleNotification(notification: response.notification)
    }
    
    private func handleNotification(notification: UNNotification) {
        
        let userInfo = notification.request.content.userInfo
        
        let _ = userInfo["notificationId"] as? String
        let notificationType = userInfo["notificationType"] as? String
        
        guard let notificationType, let desination = PreDefinedDeeplinkPath(rawValue: notificationType) else { return }
        
        do {
            let parsedLinks = try deeplinkParser.makeDeeplinkList(components: desination.outsideLinks)
            deeplinks.onNext(.init(
                deeplinks: parsedLinks,
                userInfo: userInfo
            ))
        } catch {
            printIfDebug("딥링크 파싱실패 \(error.localizedDescription)")
        }
    }
}

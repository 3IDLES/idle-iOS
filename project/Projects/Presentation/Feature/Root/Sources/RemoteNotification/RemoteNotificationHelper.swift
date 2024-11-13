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
    
    public func handleNotificationInApp(detail: Domain.NotificationDestinationForInApp) {
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
        case .postDetailForWorker(let info):
            
            // 미구현 기능
            if info.type == .workNet { return }
            
            let desination: PreDefinedDeeplinkPath = .newJobPostingForWorker
            do {
                let parsedLinks = try deeplinkParser.makeDeeplinkList(components: desination.insideLinks, startFromRoot: false)
                deeplinks.onNext(.init(
                    deeplinks: parsedLinks,
                    userInfo: ["jobPostingId": info.id]
                ))
            } catch {
                printIfDebug("딥링크 파싱실패 \(error.localizedDescription)")
            }
        }
    }
}

extension DefaultRemoteNotificationHelper: UNUserNotificationCenterDelegate {
    
    private func parseNotificationToDestination(_ notification: UNNotification) -> PreDefinedDeeplinkPath? {
        
        let userInfo = notification.request.content.userInfo
        
        let _ = userInfo["notificationId"] as? String
        let notificationType = userInfo["notificationType"] as? String
        
        guard let notificationType, let desination = PreDefinedDeeplinkPath(rawValue: notificationType) else { return nil }
        
        return desination
    }
    
    /// 앱이 포그라운드에 있는 경우, 노티페이케이션이 도착하기만 하면 호출된다.
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
//        guard let destination = parseNotificationToDestination(notification) else {
//            return
//        }
//        
//        let userInfo = notification.request.content.userInfo
//        
//        var inAppDestination: NotificationDestinationForInApp?
//        
//        switch destination {
//        case .postApplicant:
//            guard let id = userInfo["jobPostingId"] as? String else { return }
//            inAppDestination = .applicant(id: id)
//        case .newJobPostingForWorker:
//            guard let id = userInfo["jobPostingId"] as? String else { return }
//            inAppDestination = .postDetailForWorker(info: .init(type: .native, id: id))
//        }
//        
//        // 유저 인터렉션 불가 내부 이벤트로 처리야해야함
//        if let inAppDestination {
//            
//            handleNotificationInApp(detail: inAppDestination)
//        }
    }
    
    /// 앱이 백그라운드에 있는 경우, 유저가 노티피케이션을 통해 액션을 선택한 경우 호출
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let notification = response.notification
        let userInfo = notification.request.content.userInfo
        
        guard let destination = parseNotificationToDestination(notification) else {
            return
        }
        
        handleNotification(desination: destination, userInfo: userInfo)
    }
    
    private func handleNotification(desination: PreDefinedDeeplinkPath, userInfo: [AnyHashable: Any]?) {
        
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

//
//  IdleLogger.swift
//  LoggerInterface
//
//  Created by choijunios on 9/16/24.
//

import Foundation

public protocol IdleLogger {
    
    /// 이벤트를 로깅합니다.
    func logEvent(event: LoggingEvent)
    
    /// 이벤트의 주체를 설정합니다.
    func setUserId(id: String)
}

public extension IdleLogger {
    
    /// 특정 스크린 진입 이벤트를 로깅합니다.
    func logScreen(screenName: String) {
        let event = LoggingEvent(
            type: .screenView,
            properties: [
                PropertiesKeys.screenName: screenName
            ]
        )
        logEvent(event: event)
    }
    
    /// 특정버튼 클릭이벤트를 로깅합니다.
    func logButtonClick(screenName: String, buttonId: String) {
        let event = LoggingEvent(
            type: .buttonClick,
            properties: [
                PropertiesKeys.screenName: screenName,
                PropertiesKeys.buttonId: buttonId
            ]
        )
        logEvent(event: event)
    }
    
    /// 특정 동작의 지속시간을 로깅합니다.
    func logActionDuration(screenName: String, actionName: String, isSuccess: Bool, duration: Double) {
        let event = LoggingEvent(
            type: .action,
            properties: [
                PropertiesKeys.screenName: screenName,
                PropertiesKeys.actionName: actionName,
                PropertiesKeys.actionResult: isSuccess,
                PropertiesKeys.duration: duration,
            ]
        )
        logEvent(event: event)
    }
}

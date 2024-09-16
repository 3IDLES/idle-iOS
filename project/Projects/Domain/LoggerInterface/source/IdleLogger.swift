//
//  IdleLogger.swift
//  LoggerInterface
//
//  Created by choijunios on 9/16/24.
//

import Foundation

public protocol IdleLogger: AnyObject {
    
    var timerDict: [String: Date] { get set }
    var timerQueue: DispatchQueue { get }
    
    /// 이벤트를 로깅합니다.
    func logEvent(event: LoggingEvent)
    
    /// 이벤트의 주체를 설정합니다.
    func setUserId(id: String)
    
    /// 이벤트의 시작시간을 알립니다.
    func startTimer(screenName: String, actionName: String)
    
    /// 이벤트의 종료를 알리며, 지속시간을 기록합니다.
    func endTimer(screenName: String, actionName: String, isSuccess: Bool)
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
    
    func startTimer(screenName: String, actionName: String) {
        timerQueue.sync {
            let key = screenName + actionName
            timerDict[key] = Date()
        }
    }
    
    func endTimer(screenName: String, actionName: String, isSuccess: Bool) {
        timerQueue.sync {
            let key = screenName + actionName
            var duration: Int = -1
            
            if let startTime = timerDict.removeValue(forKey: key) {
                
                let endTime = Date()
                
                duration = Calendar.current.dateComponents([.second], from: startTime, to: endTime).second ?? -1
            }
            
            self.logActionDuration(
                screenName: screenName,
                actionName: actionName,
                isSuccess: isSuccess,
                duration: Double(duration)
            )
        }
    }
    
    /// 특정 동작의 지속시간을 로깅합니다.
    private func logActionDuration(screenName: String, actionName: String, isSuccess: Bool, duration: Double) {
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

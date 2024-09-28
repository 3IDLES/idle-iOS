//
//  LoggerMessagePublisher.swift
//  LoggerInterface
//
//  Created by choijunios on 9/16/24.
//

import Foundation
import Domain


public protocol LoggerMessagePublisher: AnyObject {
    
    var timerDict: [String: Date] { get set }
    var timerQueue: DispatchQueue { get }
    
    /// 이벤트를 로깅합니다.
    func send(event: LoggingEvent)
    
    /// 이벤트의 주체를 설정합니다.
    func setUserId(id: String)
}

public extension LoggerMessagePublisher {
    
    /// 특정 스크린 진입 이벤트를 로깅합니다.
    func sendScreen(screenName: String) {
        let event = LoggingEvent(type: .screenView)
            .addValue(.screenName, value: screenName)
        
        send(event: event)
    }
    
    /// 특정버튼 클릭이벤트를 로깅합니다.
    func sendButtonClick(screenName: String, buttonId: String) {
        let event = LoggingEvent(type: .buttonClick)
            .addValue(.screenName, value: screenName)
            .addValue(.buttonId, value: buttonId)
                                 
        send(event: event)
    }
    
    /// 이벤트의 시작시간을 알립니다.
    func startTimer(screenName: String, actionName: String) {
        timerQueue.sync {
            let key = screenName + actionName
            timerDict[key] = Date()
        }
    }
    
    /// 이벤트의 종료를 알리며, 지속시간을 기록합니다.
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
        let event = LoggingEvent(type: .action)
            .addValue(.screenName, value: screenName)
            .addValue(.actionName, value: actionName)
            .addValue(.actionResult, value: isSuccess)
            .addValue(.duration, value: duration)
        
        send(event: event)
    }
    
    /// 피로깅의 주체를 인식하는 식별자를 반환합니다.
    func getAnonymousUserId() -> String {
        
        let key = "AnonymousUserIdForDevice"
        
        if let cachedId = UserDefaults.standard.string(forKey: key) {
            
            return cachedId
        }
        
        let id = UUID().uuidString
        
        UserDefaults.standard.setValue(id, forKey: key)
        
        return id
    }
}

//
//  LoggingEvent.swift
//  LoggerInterface
//
//  Created by choijunios on 9/16/24.
//

import Foundation

public struct LoggingEvent {
    public let type: EventType
    private var properties: [PropertiesKeys: Any] = [:]
    
    public init(type: EventType) {
        self.type = type
    }
    
    public mutating func addValue(_ key: PropertiesKeys, value: Any) -> Self {
        self.properties[key] = value
        return self
    }
}

public enum EventType: String {
    /// 사용자가 화면을 봅니다.
    case screenView = "screen_view"
    
    /// 사용자가 버튼을 클릭합니다.
    case buttonClick = "button_click"
    
    /// 사용자가 특정 동작을 수행합니다. Ex) 공고 등록완료
    case action = "action"
}

public enum PropertiesKeys: String {
    case screenName = "screen_name"
    case actionName = "action_name"
    case actionResult = "action_result"
    case buttonId = "button_id"
    case duration = "duration"
    case step = "step"
}

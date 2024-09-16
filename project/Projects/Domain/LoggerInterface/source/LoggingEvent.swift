//
//  LoggingEvent.swift
//  LoggerInterface
//
//  Created by choijunios on 9/16/24.
//

import Foundation

public struct LoggingEvent {
    public let type: EventType
    public var properties: [String: Any?]?
}

public enum EventType: String {
    case screenView = "screen_view"
    case buttonClick = "button_click"
    case action = "action"
}

public enum PropertiesKeys {
    static let screenName: String = "screen_name"
    static let actionName: String = "action_name"
    static let actionResult: String = "action_result"
    static let buttonId: String = "button_id"
    static let duration: String = "duration"
}

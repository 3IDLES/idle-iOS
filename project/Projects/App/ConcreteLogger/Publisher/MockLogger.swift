//
//  Debug.swift
//  ConcreteLogger
//
//  Created by choijunios on 9/16/24.
//

import Foundation
import LoggerInterface
import Entity

public class DebugLogger: LoggerMessagePublisher {
    
    public private(set) var currentUser: String?
    
    /// key = screenName+actionName
    public var timerDict: [String: Date] = [:]
    public let timerQueue = DispatchQueue.global(qos: .utility)
    
    public init() { }
    
    public func send(event: LoggingEvent) {
        print("""
        [Mock Logger]
        - 현재 유저id: \(currentUser ?? "정보 없음")
        - 이벤트 타입: \(event.type.rawValue)
        - 프로퍼티 키:
            \(
                {
                    let propList = event.properties.map({ key, value in
                        "\(key) : \(value)"
                    }).joined(separator: "\n")
                            
                    return propList
                }() ?? "없음"
            )
        """)
    }
    
    public func setUserId(id: String) {
        self.currentUser = id
    }
}

//
//  AmplitudeLogger.swift
//  ConcreteLogger
//
//  Created by choijunios on 9/16/24.
//

import Foundation
import LoggerInterface
import Entity

public class AmplitudeLogger: LoggerMessagePublisher {
    
    public var timerDict: [String : Date] = [:]
    public var timerQueue: DispatchQueue = .global(qos: .utility)

    public init() { }
    
    public func send(event: LoggingEvent) {
        
    }
    
    public func setUserId(id: String) {
        
    }
}

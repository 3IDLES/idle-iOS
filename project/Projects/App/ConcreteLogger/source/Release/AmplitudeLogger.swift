//
//  AmplitudeLogger.swift
//  ConcreteLogger
//
//  Created by choijunios on 9/16/24.
//

import Foundation
import LoggerInterface

public class AmplitudeLogger: IdleLogger {
    
    public var timerDict: [String : Date] = [:]
    public var timerQueue: DispatchQueue = .global(qos: .utility)

    public init() { }
    
    public func logEvent(event: LoggerInterface.LoggingEvent) {
        
    }
    
    public func setUserId(id: String) {
        
    }
    
    public func startTimer(screenName: String, actionName: String) {
        
    }
    
    public func endTimer(screenName: String, actionName: String, isSuccess: Bool) {
        
    }
}

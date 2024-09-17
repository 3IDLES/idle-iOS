//
//  OverallLogger.swift
//  ConcreteLogger
//
//  Created by choijunios on 9/18/24.
//

import Foundation
import LoggerInterface
import AuthFeature
import Entity

public protocol OverallLogger:
    CenterRegisterLogger, 
    WorkerRegisterLogger {
    
}

public class DefaultOverallLogger {
    
    let publisher: LoggerMessagePublisher
    
    public init(publisher: LoggerMessagePublisher) {
        self.publisher = publisher
    }
}

extension DefaultOverallLogger: OverallLogger {
    
    public func logCenterRegisterStep(stepName: String, stepIndex: Int) {
        
        let event = LoggingEvent(type: .screenView)
            .addValue(.screenName, value: "center_signup")
            .addValue(.actionName, value: "center_signup" + stepName)
            .addValue(.step, value: stepIndex+1)
        
        publisher.send(event: event)
    }
    
    public func logWorkerRegisterStep(stepName: String, stepIndex: Int) {
        let event = LoggingEvent(type: .screenView)
            .addValue(.screenName, value: "worker_signup")
            .addValue(.actionName, value: "worker_signup" + stepName)
            .addValue(.step, value: stepIndex+1)
        
        publisher.send(event: event)
    }
}

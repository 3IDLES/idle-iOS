//
//  OverallLogger.swift
//  ConcreteLogger
//
//  Created by choijunios on 9/18/24.
//

import Foundation
import PresentationCore
import AuthFeature
import CenterFeature
import Domain

public protocol OverallLogger:
    CenterRegisterLogger, 
    WorkerRegisterLogger,
    PostRegisterLogger {
    
}

public class DefaultOverallLogger {
    
    let publisher: LoggerMessagePublisher
    
    public init(publisher: LoggerMessagePublisher) {
        self.publisher = publisher
    }
}

extension DefaultOverallLogger: OverallLogger {

    // MARK: Auth
    public func logCenterRegisterStep(stepName: String, stepIndex: Int) {
        
        let event = LoggingEvent(type: .screenView)
            .addValue(.screenName, value: "center_signup")
            .addValue(.actionName, value: "center_signup" + stepName)
            .addValue(.step, value: stepIndex+1)
        
        publisher.send(event: event)
    }
    
    public func startCenterRegister() {
        publisher.startTimer(
            screenName: "center_signup",
            actionName: "completion_duration"
        )
    }
    
    public func logCenterRegisterDuration() {
        publisher.endTimer(
            screenName: "center_signup",
            actionName: "completion_duration",
            isSuccess: true
        )
    }
    
    public func logWorkerRegisterStep(stepName: String, stepIndex: Int) {
        let event = LoggingEvent(type: .screenView)
            .addValue(.screenName, value: "worker_signup")
            .addValue(.actionName, value: "worker_signup" + stepName)
            .addValue(.step, value: stepIndex+1)
        
        publisher.send(event: event)
    }
    
    public func startWorkerRegister() {
        publisher.startTimer(
            screenName: "worker_signup",
            actionName: "completion_duration"
        )
    }
    
    public func logWorkerRegisterDuration() {
        publisher.endTimer(
            screenName: "worker_signup",
            actionName: "completion_duration",
            isSuccess: true
        )
    }
    
    // MARK: Recruitment post
    public func logPostRegisterStep(stepName: String, stepIndex: Int) {
        let event = LoggingEvent(type: .screenView)
            .addValue(.screenName, value: "post_job_posting")
            .addValue(.actionName, value: "post_job_posting" + stepName)
            .addValue(.step, value: stepIndex+1)
        
        publisher.send(event: event)
    }
    
    public func startPostRegister() {
        publisher.startTimer(
            screenName: "post_job_posting",
            actionName: "completion_duration"
        )
    }
    
    public func logPostRegisterDuration() {
        publisher.endTimer(
            screenName: "post_job_posting",
            actionName: "completion_duration",
            isSuccess: true
        )
    }
}

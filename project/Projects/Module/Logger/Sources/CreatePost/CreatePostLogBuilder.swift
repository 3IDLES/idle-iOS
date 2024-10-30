//
//  CreatePostLogBuilder.swift
//  Logger
//
//  Created by choijunios on 10/30/24.
//

import Foundation

public struct CreatePostLogObject: LoggingObject {
    
    public var eventType: String = "CreatePost"
    
    public var properties: [String : Any] {
        [
            "step": step,
            "stepName": stepName
        ]
    }
    
    let step: Int
    let stepName: String
    
    init(step: Int, stepName: String) {
        self.step = step
        self.stepName = stepName
    }
}

public class CreatePostLogBuilder {
    
    let step: Int
    let stepName: String
    
    public init(step: Int, stepName: String) {
        self.step = step
        self.stepName = stepName
    }
    
    public func build() -> AccountRegisterationLogObject {
        .init(step: step, stepName: stepName)
    }
}

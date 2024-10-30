//
//  CenterAccountRegisterationLogBuilder.swift
//  Logger
//
//  Created by choijunios on 10/30/24.
//

import Foundation

public struct CenterAccountRegisterationLogObject: LoggingObject {
    
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

public class CenterAccountRegisterationLogBuilder {
    
    let step: Int
    let stepName: String
    
    public init(step: Int, stepName: String) {
        self.step = step
        self.stepName = stepName
    }
    
    public func build() -> CenterAccountRegisterationLogObject {
        .init(step: step, stepName: stepName)
    }
}

//
//  CenterRegisterLogger.swift
//  AuthFeature
//
//  Created by choijunios on 9/18/24.
//

import Foundation

public protocol CenterRegisterLogger {
    
    func logCenterRegisterStep(stepName: String, stepIndex: Int)
}


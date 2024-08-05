//
//  AdditionalApplicationInfoStateObject.swift
//  Entity
//
//  Created by choijunios on 8/2/24.
//

import Foundation

public class ApplicationDetailStateObject {
    public var experiencePreferenceType: ExperiencePreferenceType?
    public var applyType: ApplyType?
    public var applyDeadlineType: ApplyDeadlineType?
    public var deadlineDate: Date?
    
    public init() { }
    
    public static var mock: ApplicationDetailStateObject {
        let mockObject = ApplicationDetailStateObject()
        mockObject.experiencePreferenceType = .beginnerPossible
        mockObject.applyType = .app
        mockObject.applyDeadlineType = .untilApplicationFinished
        mockObject.deadlineDate = Date(timeIntervalSinceNow: 86400 * 7) // 7 days from now
        return mockObject
    }
}

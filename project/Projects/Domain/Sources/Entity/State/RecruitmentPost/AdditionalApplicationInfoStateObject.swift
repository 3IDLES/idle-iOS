//
//  AdditionalApplicationInfoStateObject.swift
//  Entity
//
//  Created by choijunios on 8/2/24.
//

import Foundation

public class ApplicationDetailStateObject: NSCopying {
    public var experiencePreferenceType: ExperiencePreferenceType?
    public var applyType: [ApplyType: Bool] = {
        var dict: [ApplyType: Bool] = [:]
        ApplyType.allCases.forEach { type in
            dict[type] = false
        }
        return dict
    }()
    
    public var applyDeadlineType: ApplyDeadlineType?
    public var deadlineDate: Date?
    
    public init() { }
    
    public static var mock: ApplicationDetailStateObject {
        let mockObject = ApplicationDetailStateObject()
        mockObject.experiencePreferenceType = .beginnerPossible
        mockObject.applyType = [
            .app : true,
            .phoneCall : false
        ]
        mockObject.applyDeadlineType = .untilApplicationFinished
        mockObject.deadlineDate = Date(timeIntervalSinceNow: 86400 * 7) // 7 days from now
        return mockObject
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = ApplicationDetailStateObject()
        copy.experiencePreferenceType = self.experiencePreferenceType
        copy.applyType = self.applyType
        copy.applyDeadlineType = self.applyDeadlineType
        copy.deadlineDate = self.deadlineDate
        return copy
    }
}

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
}

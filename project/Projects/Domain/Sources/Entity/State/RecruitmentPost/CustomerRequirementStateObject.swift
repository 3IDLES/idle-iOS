//
//  CustomerRequirementState.swift
//  Entity
//
//  Created by choijunios on 7/31/24.
//

import Foundation

/// 공고등록화면중 고객요구사항 입력창에 사용됩니다.
public class CustomerRequirementStateObject: NSCopying {
    
    public var mealSupportNeeded: Bool?
    public var toiletSupportNeeded: Bool?
    public var movingSupportNeeded: Bool?
    public var additionalRequirement: String = ""
    public var dailySupportTypeNeeds: [DailySupportType: Bool] = {
        var dict: [DailySupportType: Bool] = [:]
        DailySupportType.allCases.forEach { type in
            dict[type] = false
        }
        return dict
    }()
    
    public init() { }
    
    public static var mock: CustomerRequirementStateObject {
        let mockObject = CustomerRequirementStateObject()
        mockObject.mealSupportNeeded = true
        mockObject.toiletSupportNeeded = false
        mockObject.movingSupportNeeded = true
        mockObject.additionalRequirement = "Additional help with medication."
        mockObject.dailySupportTypeNeeds = [.cleaning: true, .exerciseSupport: false, .laundry: true, .listener: false, .walking: true]
        return mockObject
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = CustomerRequirementStateObject()
        copy.mealSupportNeeded = self.mealSupportNeeded
        copy.toiletSupportNeeded = self.toiletSupportNeeded
        copy.movingSupportNeeded = self.movingSupportNeeded
        copy.additionalRequirement = self.additionalRequirement
        copy.dailySupportTypeNeeds = self.dailySupportTypeNeeds
        return copy
    }    
}

public enum DailySupportType: Int, CaseIterable {
    case cleaning
    case laundry
    case walking
    case exerciseSupport
    case listener
    
    public var korLetterTextForBtn: String {
        switch self {
        case .cleaning:
            "청소"
        case .laundry:
            "빨래"
        case .walking:
            "산책"
        case .exerciseSupport:
            "운동보조"
        case .listener:
            "말벗"
        }
    }
}

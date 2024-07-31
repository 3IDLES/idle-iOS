//
//  CustomerRequirementState.swift
//  Entity
//
//  Created by choijunios on 7/31/24.
//

import Foundation

/// 공고등록화면중 고객요구사항 입력창에 사용됩니다.
public class CustomerRequirementState {
    
    public var mealSupportNeeded: Bool? = nil
    public var toiletSupportNeeded: Bool? = nil
    public var movingSupportNeeded: Bool? = nil
    public var dailySupportTypeNeeds: [DailySupportType: Bool] = {
        var dict: [DailySupportType: Bool] = [:]
        DailySupportType.allCases.forEach { type in
            dict[type] = false
        }
        return dict
    }()
    public var additionalRequirement: String? = nil
    
    public init() { }
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

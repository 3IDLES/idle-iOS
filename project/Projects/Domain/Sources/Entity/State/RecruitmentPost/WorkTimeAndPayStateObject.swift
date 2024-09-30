//
//  WorkTimeAndPayStateObject.swift
//  Entity
//
//  Created by choijunios on 7/31/24.
//

import Foundation

/// 오전/오후, 시, 분을 나타냅니다.
public struct IdleDateComponent {
    public var part: Part
    public var hour: String
    public var minute: String
    
    public func convertToStringForButton() -> String {
        if part == .AM {
            return "\(hour):\(minute)"
        } else {
            return "\(Int(hour)! + 12):\(minute)"
        }
    }
    
    public init(part: Part, hour: String, minute: String) {
        self.part = part
        self.hour = hour
        self.minute = minute
    }
    
    public enum Part: String, CaseIterable {
        case AM="오전"
        case PM="오후"
    }
}

/// 요일에 대한 정보
public enum WorkDay: Int, CaseIterable {
    
    case mon, tue, wed, thu, fri, sat, sun
    
    public var korOneLetterText: String {
        switch self {
        case .mon:
            "월"
        case .tue:
            "화"
        case .wed:
            "수"
        case .thu:
            "목"
        case .fri:
            "금"
        case .sat:
            "토"
        case .sun:
            "일"
        }
    }
}

public enum PaymentType: Int, CaseIterable {
    
    case hourly, weekly, monthly
    
    public var korLetterText: String {
        switch self {
        case .hourly:
            "시급"
        case .weekly:
            "주급"
        case .monthly:
            "월급"
        }
    }
}

public class WorkTimeAndPayStateObject {
    
    public var selectedDays: [WorkDay: Bool] = {
        var dict: [WorkDay:Bool] = [:]
        WorkDay.allCases.forEach { dict[$0] = false }
        return dict
    }()
    public var workStartTime: IdleDateComponent?
    public var workEndTime: IdleDateComponent?
    public var paymentType: PaymentType?
    public var paymentAmount: String = ""
    
    public init() { }
    
    public static var mock: WorkTimeAndPayStateObject {
        let mockObject = WorkTimeAndPayStateObject()
        mockObject.selectedDays = [.mon: true, .tue: true, .wed: false, .thu: true, .fri: true, .sat: false, .sun: false]
        mockObject.workStartTime = .init(
            part: .AM,
            hour: "06",
            minute: "24"
        )
        mockObject.workEndTime = .init(
            part: .PM,
            hour: "05",
            minute: "30"
        )
        mockObject.paymentType = .hourly
        mockObject.paymentAmount = "15000"
        return mockObject
    }
}

extension WorkTimeAndPayStateObject: NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = WorkTimeAndPayStateObject()
        copy.selectedDays = self.selectedDays
        copy.workStartTime = self.workStartTime
        copy.workEndTime = self.workEndTime
        copy.paymentType = self.paymentType
        copy.paymentAmount = self.paymentAmount
        return copy
    }
}

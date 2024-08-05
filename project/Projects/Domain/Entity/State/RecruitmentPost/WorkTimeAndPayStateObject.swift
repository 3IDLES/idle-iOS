//
//  WorkTimeAndPayStateObject.swift
//  Entity
//
//  Created by choijunios on 7/31/24.
//

import Foundation

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
    public var workStartTime: String = ""
    public var workEndTime: String = ""
    public var paymentType: PaymentType?
    public var paymentAmount: String = ""
    
    public init() { }
    
    public static var mock: WorkTimeAndPayStateObject {
        let mockObject = WorkTimeAndPayStateObject()
        mockObject.selectedDays = [.mon: true, .tue: true, .wed: false, .thu: true, .fri: true, .sat: false, .sun: false]
        mockObject.workStartTime = "오전 09:00"
        mockObject.workEndTime = "오후 05:00"
        mockObject.paymentType = .hourly
        mockObject.paymentAmount = "15000"
        return mockObject
    }
}

//
//  WorkTimeAndPayState.swift
//  Entity
//
//  Created by choijunios on 7/31/24.
//

import Foundation

/// 요일에 대한 정보
public enum DayItem: Int, CaseIterable {
    
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

public enum PaymentItem: Int, CaseIterable {
    
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

public class WorkTimeAndPayState {
    
    public var selectedDays: [DayItem:Bool] = {
        var dict: [DayItem:Bool] = [:]
        DayItem.allCases.forEach { dict[$0] = false }
        return dict
    }()
    public var workStartTime: String = ""
    public var workEndTime: String = ""
    public var paymentType: PaymentItem?
    public var paymentAmount: String = ""
    
    public init() { }
}

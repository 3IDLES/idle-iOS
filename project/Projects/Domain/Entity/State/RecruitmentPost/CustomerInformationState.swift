//
//  File.swift
//  Entity
//
//  Created by choijunios on 7/31/24.
//

import Foundation

public enum CareGrade: Int, CaseIterable {
    case one
    case two
    case three
    case four
    case five
    
    public var textForCellBtn: String {
        String(self.rawValue + 1)
    }
}

public enum CognitionItem: Int, CaseIterable {
    case stable
    case earlyStage
    case overEarlyStage
    
    public var korTextForCellBtn: String {
        switch self {
        case .stable:
            "양호"
        case .earlyStage:
            "치매 초기"
        case .overEarlyStage:
            "치매 중/말기"
        }
    }
}

public class CustomerInformationState {
    public var gender: Gender?
    public var birthYear: String = ""
    public var weight: String = ""
    public var careGrade: CareGrade?
    public var cognitionState: CognitionItem?
    public var deceaseDescription: String = ""
    
    public init() { }
}

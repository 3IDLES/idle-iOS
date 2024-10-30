//
//  RegisterRecruitmentPage.swift
//  CenterMainPageFeature
//
//  Created by choijunios on 10/30/24.
//

import Foundation

enum RegisterRecruitmentPage: Int, CaseIterable {
    case start = 0
    case workTimeAndPayment = 1
    case workPlaceAddress = 2
    case customerInformation = 3
    case customerRequirement = 4
    case additionalInfo = 5
    case overview = 6
    case editPage = 7
    case finish = 8
    
    var screenKorName: String {
        switch self {
        case .start:
            "센터 구인공고 등록 시작"
        case .workTimeAndPayment:
            "근무 시간 및 급여"
        case .workPlaceAddress:
            "근무지 주소입력"
        case .customerInformation:
            "수급자 정보 입력"
        case .customerRequirement:
            "수급자 요구사항 입력"
        case .additionalInfo:
            "추가 지원정보 입력"
        case .overview:
            "오버뷰 화면"
        case .editPage:
            "전체 수정화면"
        case .finish:
            "구인공고 등록완료"
        }
    }
    
    var step: Int { self.rawValue }
    
    static var stages: [RegisterRecruitmentPage] {
        [
            .workTimeAndPayment,
            .workPlaceAddress,
            .customerInformation,
            .customerRequirement,
            .additionalInfo,
        ]
    }
    
    var stageIndex: Int {
        switch self {
        case .workTimeAndPayment:
            0
        case .workPlaceAddress:
            1
        case .customerInformation:
            2
        case .customerRequirement:
            3
        case .additionalInfo:
            4
        default:
            -1
        }
    }
}

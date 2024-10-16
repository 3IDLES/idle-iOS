//
//  WorkerProfileRenderObject.swift
//  WorkerFeature
//
//  Created by choijunios on 8/10/24.
//

import UIKit
import Domain

// MARK: RO
public struct WorkerProfileRenderObject {
    
    let navigationTitle: String
    let showEditButton: Bool
    let showContactButton: Bool
//    let showStarButton: Bool
    let isJobFinding: Bool
    let stateText: String
    let nameText: String
    let phoneNumber: String
    let ageText: String
    let genderText: String
    let expText: String
    let address: String
    let oneLineIntroduce: String
    let specialty: String
    
    static func createRO(isMyProfile: Bool, vo: WorkerProfileVO) -> WorkerProfileRenderObject {
        
        return .init(
            navigationTitle: isMyProfile ? "내 프로필" : "요양보호사 프로필",
            showEditButton: isMyProfile,
            showContactButton: !isMyProfile,
//            showStarButton: !isMyProfile,
            isJobFinding: vo.isLookingForJob,
            stateText: vo.isLookingForJob ? "구인중" : "휴식중",
            nameText: vo.nameText,
            phoneNumber: vo.phoneNumber,
            ageText: "\(vo.age)세",
            genderText: vo.gender.twoLetterKoreanWord,
            expText: vo.expYear == nil ? "신입" : "\(vo.expYear!)년차",
            address: vo.address.roadAddress,
            oneLineIntroduce: vo.introductionText.emptyDefault("-"),
            specialty: vo.specialty
                .emptyDefault("-")
        )
    }
}

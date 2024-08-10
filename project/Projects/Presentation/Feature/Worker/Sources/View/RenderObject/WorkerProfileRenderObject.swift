//
//  File.swift
//  WorkerFeature
//
//  Created by choijunios on 8/10/24.
//

import Foundation
import Entity

// MARK: RO
public struct WorkerProfileRenderObject {
    
    let navigationTitle: String
    let showEditButton: Bool
    let isJobFinding: Bool
    let stateText: String
    let nameText: String
    let ageText: String
    let genderText: String
    let expText: String
    let address: String
    let oneLineIntroduce: String
    let specialty: String
    let imageUrl: URL?
    
    static func createRO(isMyProfile: Bool, vo: WorkerProfileVO) -> WorkerProfileRenderObject {
        
        .init(
            navigationTitle: isMyProfile ? "내 프로필" : "요양보호사 프로필",
            showEditButton: isMyProfile,
            isJobFinding: vo.isLookingForJob,
            stateText: vo.isLookingForJob ? "구인중" : "휴식중",
            nameText: vo.nameText,
            ageText: "\(vo.age)세",
            genderText: vo.gender.twoLetterKoreanWord,
            expText: vo.expYear == nil ? "신입" : "\(vo.expYear!)년차",
            address: vo.address.roadAddress,
            oneLineIntroduce: vo.introductionText,
            specialty: vo.specialty,
            imageUrl: URL(string: vo.profileImageURL ?? "")
        )
    }
}

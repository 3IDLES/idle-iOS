//
//  WorkerProfileViewModel.swift
//  WorkerFeature
//
//  Created by choijunios on 7/22/24.
//

import UIKit
import PresentationCore
import RxSwift
import RxCocoa
import DSKit
import Entity


public struct WorkerProfileRenderObject {
    
    let navigationTitle: String
    let showEditButton: Bool
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
            stateText: vo.isLookingForJob ? "구인중" : "휴식중",
            nameText: vo.nameText,
            ageText: "\(vo.age)세",
            genderText: vo.gender.twoLetterKoreanWord,
            expText: vo.expYear == nil ? "신입" : "\(vo.expYear!)년차",
            address: vo.addressText,
            oneLineIntroduce: vo.introductionText,
            specialty: vo.specialty,
            imageUrl: URL(string: vo.profileImageURL ?? "")
        )
    }
}


public class WorkerMyProfileViewModel: WorkerProfileViewModelable {
    
    // Input
    public var viewWillAppear: PublishRelay<Void> = .init()
    
    // Output
    public var profileRenderObject: Driver<WorkerProfileRenderObject>?
    
    public init() {
        
        // Input
        let fetchedProfileVOResult = viewWillAppear
            .flatMap { [unowned self] _ in
                fetchProfileVO()
            }
            .share()
        
        let fetchedProfileVOSuccess = fetchedProfileVOResult
            .compactMap { $0.value }
        
        profileRenderObject = fetchedProfileVOSuccess
            .map({ vo in
                WorkerProfileRenderObject.createRO(isMyProfile: false, vo: vo)
            })
            .asDriver(onErrorRecover: { _ in fatalError() })
        
    }
    
    private func fetchProfileVO() -> Single<Result<WorkerProfileVO, Error>> {
        return .just(.success(.mock))
    }
}


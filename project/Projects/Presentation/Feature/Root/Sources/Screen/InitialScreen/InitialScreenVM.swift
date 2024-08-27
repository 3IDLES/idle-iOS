//
//  InitialScreenVM.swift
//  RootFeature
//
//  Created by choijunios on 8/25/24.
//

import RxSwift
import RxCocoa
import Foundation
import PresentationCore
import UseCaseInterface
import RepositoryInterface

public class InitialScreenVM {
    
    weak var coordinator: RootCoorinatable?
    
    // Input
    let viewWillAppear: PublishRelay<Void> = .init()
    
    let workerProfileUseCase: WorkerProfileUseCase
    let centerProfileUseCase: CenterProfileUseCase
    let userInfoLocalRepository: UserInfoLocalRepository
    
    let disposeBag = DisposeBag()
    
    public init(
            coordinator: RootCoorinatable?,
            workerProfileUseCase: WorkerProfileUseCase,
            centerProfileUseCase: CenterProfileUseCase,
            userInfoLocalRepository: UserInfoLocalRepository
        )
    {
        self.coordinator = coordinator
        self.workerProfileUseCase = workerProfileUseCase
        self.centerProfileUseCase = centerProfileUseCase
        self.userInfoLocalRepository = userInfoLocalRepository
        
        // MARK: 로그아웃, 회원탈퇴시
        NotificationCenter.default.rx.notification(.popToInitialVC)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                
                guard let self else { return }
                
                self.coordinator?.popToRoot()
            })
            .disposed(by: disposeBag)
        
        
        viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                
                self?.userCheckingFlow()
            })
            .disposed(by: disposeBag)
    }
    
    private func userCheckingFlow() {
        
        // 유저 타입확인
        guard let userType = userInfoLocalRepository.getUserType() else {
            printIfDebug("☑️ 저장된 유저정보가 없습니다 Auth화면으로 이동합니다.")
            coordinator?.auth()
            return
        }
        
        // 로컬 유저정보확인
        if userType == .center {
            
            // 센터관리자 확인
            printIfDebug("☑️ 센터관리자 정보를 확인합니다.")
            
            if userInfoLocalRepository.getCurrentCenterData() == nil {
                // 저장된 센터정보가 없는 경우
                let requestCenterInfoResult = centerProfileUseCase.getProfile(mode: .myProfile)
                let success = requestCenterInfoResult.compactMap { $0.value }
                let failure = requestCenterInfoResult.compactMap { $0.error }
                
                success
                    .subscribe(onSuccess: { [weak self] fetchedVO in
                        
                        guard let self else { return }
                        
                        userInfoLocalRepository.updateCurrentCenterData(vo: fetchedVO)
                        
                        printIfDebug("✅ 센터관리자 프로필 정보가 존재합니다.")
                        
                        // 센터 메인화면으로 이동
                        coordinator?.centerMain()
                    })
                    .disposed(by: disposeBag)
                
                // 실패한 경우
                failure
                    .subscribe(onSuccess: { [weak self] error in
                        
                        guard let self else { return }
                        
                        if error == .tokenExpiredException {
                            // 토큰이 만료된 경우로 재로그인 필요
                            
                            printIfDebug("☑️ 재로그인이 필요합니다.")
                            
                            coordinator?.auth()
                            return
                        }
                        
                        printIfDebug("☑️ 센터관리자 프로필 정보가 없습니다.")
                        
                        // 센터 메인화면으로 이동
                        coordinator?.centerMain()
                    })
                    .disposed(by: disposeBag)
            } else {
                coordinator?.centerMain()
            }
        } else {
            
            // 요양보호사 확인
            
            if userInfoLocalRepository.getCurrentWorkerData() == nil {
                // 저장된 요양보호사
                let requestWorkerInfoResult = workerProfileUseCase.getProfile(mode: .myProfile)
                let success = requestWorkerInfoResult.compactMap { $0.value }
                let failure = requestWorkerInfoResult.compactMap { $0.error }
                
                success
                    .subscribe(onSuccess: { [weak self] fetchedVO in
                        
                        guard let self else { return }
                        
                        userInfoLocalRepository.updateCurrentWorkerData(vo: fetchedVO)
                        
                        printIfDebug("✅ 요양보호사 프로필 정보가 존재합니다.")
                        
                        // 요양보호사 메인화면으로 이동
                        coordinator?.workerMain()
                    })
                    .disposed(by: disposeBag)
                
                // 실패한 경우
                failure
                    .subscribe(onSuccess: { [weak self] error in
                        
                        guard let self else { return }
                        
                        if error == .tokenExpiredException {
                            // 토큰이 만료된 경우로 재로그인 필요
                            
                            printIfDebug("☑️ 재로그인이 필요합니다.")
                            
                            coordinator?.auth()
                            return
                        }
                        
                        printIfDebug("☑️ 요양보호사 프로필 정보가 없습니다.")
                        
                        // 요양보호사 메인화면으로 이동
                        coordinator?.workerMain()
                    })
                    .disposed(by: disposeBag)
            } else {
                coordinator?.workerMain()
            }
        }
    }
}

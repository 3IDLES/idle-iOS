//
//  WaitCertificatePageViewModel.swift
//  WaitCertificatePageCoordinator
//
//  Created by choijunios on 9/11/24.
//

import UIKit
import PresentationCore
import BaseFeature
import DSKit
import Domain
import Core

import RxSwift
import RxCocoa

class WaitCertificatePageViewModel: BaseViewModel {
    
    @Injected var centerCertificateUseCase: CenterCertificateUseCase
    
    // Navigation
    var changeToAuthPage: (() -> ())?
    var presentMakeProfilePage: (() -> ())?
    
    // input
    let requestCurrentStatus: PublishSubject<Void> = .init()
    let logoutButtonClicked: PublishSubject<Void> = .init()
    let certificateRequestButtonClicked: PublishSubject<Void> = .init()
    
    // output
    var currentStatus: Driver<CenterAccountStatus>?
    var certificateRequestSuccess: Driver<Void>?
    
    // internal
    private let signOutButtonComfirmed: PublishSubject<Void> = .init()
    
    override init() {
        super.init()
        
        // MARK: 로그아웃
        logoutButtonClicked
            .subscribe(onNext: {
                [weak self] in
                guard let self else { return }
                let object = IdleAlertObject()
                    .setTitle("로그아웃하시겠어요?")
                    .setAcceptAction(.init(
                        name: "로그아웃",
                        action: { [signOutButtonComfirmed] in
                            signOutButtonComfirmed.onNext(())
                        }
                    ))
                    .setCancelAction(.init(name: "취소하기"))
                
                alertObject.onNext(object)
            })
            .disposed(by: disposeBag)
            
        
        let signOutRequestResult = mapEndLoading(mapStartLoading(signOutButtonComfirmed)
            .flatMap { [centerCertificateUseCase] _ in
                centerCertificateUseCase.signoutCenterAccount()
            })
            .share()
        
        let signOutSuccess = signOutRequestResult.compactMap { $0.value }
        let signOutFailure = signOutRequestResult.compactMap { $0.error }
        
        signOutSuccess
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.changeToAuthPage?()
            })
            .disposed(by: disposeBag)
        
        let signOutFailureAlert = signOutFailure.map { error in
            DefaultAlertContentVO(
                title: "로그아웃 실패",
                message: error.message
            )
        }
        
        // MARK: 현재상태확인하기
        let requestCurrentStatusResult = requestCurrentStatus
            .flatMap { [centerCertificateUseCase] in
                centerCertificateUseCase
                    .getCenterJoinStatus()
            }
            .share()
        
        let requestCurrentStatusSuccess = requestCurrentStatusResult.compactMap { $0.value }
        let requestCurrentStatusFailure = requestCurrentStatusResult.compactMap { $0.error }
        
        self.currentStatus = requestCurrentStatusSuccess
            .unretained(self)
            .compactMap({ (obj, vo) in
                
                let status = vo.centerManagerAccountStatus
                
                if status == .approved {
                    
                    obj.presentMakeProfilePage?()
                    
                    return nil
                }
                return status
            })
            .asDriver(onErrorDriveWith: .never())
        
            
        let requestCurrentStatusFailureAlert = requestCurrentStatusFailure.map { error in
            DefaultAlertContentVO(
                title: "현재상태 확인 실패",
                message: error.message
            )
        }

        
        // MARK: 인증 요청하기
        let certificateRequestResult = mapEndLoading(mapStartLoading(certificateRequestButtonClicked)
            .flatMap { [centerCertificateUseCase] _ in
                centerCertificateUseCase
                    .requestCenterCertificate()
            })
            .share()
        
        let certificateRequestSuccess = certificateRequestResult.compactMap { $0.value }
        let certificateRequestFailure = certificateRequestResult.compactMap { $0.error }
        
        self.certificateRequestSuccess = certificateRequestSuccess
            .asDriver(onErrorDriveWith: .never())
            
        let certificateRequestFailureAlert = certificateRequestFailure.map { error in
            DefaultAlertContentVO(
                title: "인증요청 실패",
                message: error.message
            )
        }
        
        // MARK: Alert
        Observable
            .merge(
                signOutFailureAlert,
                certificateRequestFailureAlert,
                requestCurrentStatusFailureAlert
            )
            .subscribe(onNext: { [weak self] alertVO in
                
                guard let self else { return }
                
                alert.onNext(alertVO)
            })
            .disposed(by: disposeBag)
    }
}

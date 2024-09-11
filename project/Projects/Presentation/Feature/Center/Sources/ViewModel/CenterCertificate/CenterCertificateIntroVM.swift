//
//  CenterCertificateIntroVM.swift
//  CenterFeature
//
//  Created by choijunios on 9/11/24.
//

import PresentationCore
import UseCaseInterface
import BaseFeature

import RxSwift
import RxCocoa

public class CenterCertificateIntroVM: BaseViewModel {
    
    // Init
    let centerCertificateUseCase: CenterCertificateUseCase
    
    // input
    let logoutButtonClicked: PublishSubject<Void> = .init()
    let certificateRequestButtonClicked: PublishSubject<Void> = .init()
    
    // output
    var certificateRequestSuccess: Driver<Void>?
    
    // internal
    let signOutButtonComfirmed: PublishSubject<Void> = .init()
    
    public init(centerCertificateUseCase: CenterCertificateUseCase) {
        self.centerCertificateUseCase = centerCertificateUseCase
        super.init()
        
        // MARK: 로그아웃
        let signOutRequestResult = signOutButtonComfirmed.flatMap({ [centerCertificateUseCase] _ in
            centerCertificateUseCase.signoutCenterAccount()
        })
            .share()
        
        let signOutSuccess = signOutRequestResult.compactMap { $0.value }
        let signOutFailure = signOutRequestResult.compactMap { $0.error }
        
        signOutSuccess
            .subscribe(onNext: { [weak self] _ in
                
                guard let self else { return }
                
            })
            .disposed(by: disposeBag)
    }
    
    public func createSingOutVM() -> any DSKit.IdleAlertViewModelable {
        let viewModel = CenterSingOutVM(
            title: "로그아웃하시겠어요?",
            description: "",
            acceptButtonLabelText: "로그아웃",
            cancelButtonLabelText: "취소하기"
        )
        
        viewModel
            .acceptButtonClicked
            .bind(to: signOutButtonComfirmed)
            .disposed(by: disposeBag)
        
        return viewModel
    }
}

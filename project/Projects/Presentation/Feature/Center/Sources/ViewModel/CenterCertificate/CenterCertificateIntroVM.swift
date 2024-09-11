//
//  CenterCertificateIntroVM.swift
//  CenterFeature
//
//  Created by choijunios on 9/11/24.
//

import PresentationCore
import UseCaseInterface
import BaseFeature
import DSKit

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
        logoutButtonClicked
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let object = IdleAlertObject()
                    .setTitle("로그아웃하시겠어요?")
                    .setAcceptButtonLabelText("로그아웃")
                    .setCancelButtonLabelText("취소하기")
                
                object
                    .acceptButtonClicked?
                    .asObservable()
                    .bind(to: signOutButtonComfirmed)
                    .disposed(by: disposeBag)
                
                alertObject.onNext(object)
            })
            .disposed(by: disposeBag)
        
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
}

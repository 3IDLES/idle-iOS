//
//  SettingPageViewModel.swift
//  WorkerFeature
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Domain
import DSKit
import UserNotifications
import Core


import RxCocoa
import RxSwift

class SettingPageViewModel: BaseViewModel {
    
    // Injected
    @Injected var settingUseCase: SettingScreenUseCase
    @Injected var centerProfileUseCase: CenterProfileUseCase
    
    // Navigation(
    var presentMyProfilePage: (() -> ())?
    var changeToAuthFlow: (() -> ())?
    var presentDeregisterPage: (() -> ())?
    
    // Input
    let viewWillAppear: PublishRelay<Void> = .init()
    let myProfileButtonClicked: PublishRelay<Void> = .init()
    let approveToPushNotification: PublishRelay<Bool> = .init()
    
    let signOutButtonComfirmed: PublishRelay<Void> = .init()
    let removeAccountButtonClicked: PublishRelay<Void> = .init()
    
    let additionalInfoButtonClieck: PublishRelay<SettingAdditionalInfoType> = .init()
    
    // Output
    var pushNotificationApproveState: Driver<Bool>?
    var showSettingAlert: Driver<Void>?
    
    override init() {
        
        super.init()
        
        // 기존의 알람수신 동의 여부 확인
        // 설정화면에서 다시돌아온 경우 이벤트 수신
        let refreshNotificationStatusRequest = Observable.merge(
            NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification).map {_ in },
            viewWillAppear.asObservable()
        )
        
        let currentNotificationAuthStatus = refreshNotificationStatusRequest
            .flatMap { [settingUseCase] _ in
                settingUseCase.checkPushNotificationApproved()
            }
        
        let requestApproveNotification = approveToPushNotification.filter { $0 }.map { _ in () }
        let requestDenyNotification = approveToPushNotification.filter { !$0 }.map { _ in () }
        
        let approveRequestResult = requestApproveNotification
            .flatMap { [settingUseCase] _ in
                settingUseCase
                    .requestNotificationPermission()
            }
            
        let approveGranted = approveRequestResult.filter { $0 == .granted }
        let openSettingAppToApprove = approveRequestResult.filter { $0 == .openSystemSetting }.map { _ in () }
        let approveRequestError = approveRequestResult.filter {
            if case let .error(message) = $0 {
                printIfDebug("알림동의 실패: \(message)")
                return true
            }
            return false
        }
        
        // MARK: 뷰가 표시할 알람수신 동의 상태
        pushNotificationApproveState = Observable.merge(
            currentNotificationAuthStatus,
            approveGranted.map { _ in true }
        )
        .asDriver(onErrorJustReturn: false)
        
        
        // MARK: 세팅앱 열기
        showSettingAlert = Observable.merge(
            openSettingAppToApprove,
            requestDenyNotification
        )
        .asDriver(onErrorJustReturn: ())
        
        // MARK: 내프로필 보기
        myProfileButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                
                obj.presentMyProfilePage?()
            })
            .disposed(by: disposeBag)
        
        // MARK: 추가정보
        additionalInfoButtonClieck
            .subscribe(onNext: {
                [weak self] type in
                guard let self else { return }
                
                let url = type.getWebUrl()
                
                if !openURL(url) {
                    
                    alert.onNext(
                        .init(
                            title: "오류가 발생했습니다.",
                            message: "잠시후 다시시도해 주세요."
                        )
                    )
                }
            })
            .disposed(by: disposeBag)
        
        // MARK: 로그아웃
        let signOutRequestResult = signOutButtonComfirmed.flatMap({ [settingUseCase] _ in
            settingUseCase.signoutWorkerAccount()
        })
            .share()
        
        let signOutSuccess = signOutRequestResult.compactMap { $0.value }
        let signOutFailure = signOutRequestResult.compactMap { $0.error }
        
        signOutSuccess
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                // 로그이아웃 성공 -> 원격알림 토큰 제거
                NotificationCenter.default.post(name: .requestDeleteTokenFromServer, object: nil)
                obj.changeToAuthFlow?()
            })
            .disposed(by: disposeBag)
        
        
        // MARK: 회원 탈퇴
        removeAccountButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.presentDeregisterPage?()
            })
            .disposed(by: disposeBag)
        
        
        // MARK: Alert
        Observable.merge(
            approveRequestError.map { _ in "알람수신 동의 실패" },
            signOutFailure.map { $0.message }
        )
        .map({ message in
            DefaultAlertContentVO(
                title: "환경설정 오류",
                message: message
            )
        })
        .subscribe(alert)
        .disposed(by: disposeBag)
    }
    
    func createSingOutVM() -> any DSKit.IdleAlertViewModelable {
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
    
    private func openURL(_ url: URL) -> Bool {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
            return true
        }
        return false
    }
}

class CenterSingOutVM: IdleAlertViewModelable {

    var acceptButtonLabelText: String
    var cancelButtonLabelText: String
    
    var acceptButtonClicked: RxRelay.PublishRelay<Void> = .init()
    var cancelButtonClicked: RxRelay.PublishRelay<Void> = .init()
    
    var dismiss: RxCocoa.Driver<Void>?
    
    var title: String
    var description: String
    
    init(
        title: String,
        description: String,
        acceptButtonLabelText: String,
        cancelButtonLabelText: String
    ) {
        self.title = title
        self.description = description
        self.acceptButtonLabelText = acceptButtonLabelText
        self.cancelButtonLabelText = cancelButtonLabelText
        
        dismiss = Observable
            .merge(
                acceptButtonClicked.asObservable(),
                cancelButtonClicked.asObservable()
            )
            .asDriver(onErrorDriveWith: .never())
    }
}

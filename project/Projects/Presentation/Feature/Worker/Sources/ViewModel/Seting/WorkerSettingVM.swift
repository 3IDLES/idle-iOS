//
//  WorkerSettingVM.swift
//  WorkerFeature
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit
import UseCaseInterface
import UserNotifications

public protocol WorkerSettingVMable: BaseViewModel {
    
    // Input
    var viewWillAppear: PublishRelay<Void> { get }
    var myProfileButtonClicked: PublishRelay<Void> { get }
    var approveToPushNotification: PublishRelay<Bool> { get }
    
    var signOutButtonComfirmed: PublishRelay<Void> { get }
    var removeAccountButtonClicked: PublishRelay<Void> { get }
    
    // Output
    var pushNotificationApproveState: Driver<Bool>? { get }
    var showSettingAlert: Driver<Void>? { get }
    
    // SignOut
    func createSingOutVM() -> IdleAlertViewModelable
}

public class WorkerSettingVM: BaseViewModel, WorkerSettingVMable {
    
    // Init
    weak var coordinator: WorkerSettingScreenCoordinator?
    let settingUseCase: SettingScreenUseCase
    let centerProfileUseCase: CenterProfileUseCase
    
    public var viewWillAppear: RxRelay.PublishRelay<Void> = .init()
    public var myProfileButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var approveToPushNotification: RxRelay.PublishRelay<Bool> = .init()
    
    public var signOutButtonComfirmed: RxRelay.PublishRelay<Void> = .init()
    public var removeAccountButtonClicked: RxRelay.PublishRelay<Void> = .init()
    
    public var pushNotificationApproveState: RxCocoa.Driver<Bool>?
    public var showSettingAlert: Driver<Void>?
    
    public init(
        coordinator: WorkerSettingScreenCoordinator?,
        settingUseCase: SettingScreenUseCase,
        centerProfileUseCase: CenterProfileUseCase
        )
    {
        self.coordinator = coordinator
        self.settingUseCase = settingUseCase
        self.centerProfileUseCase = centerProfileUseCase
        
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
            .subscribe(onNext: { [weak self] _ in
                
                self?.coordinator?.showMyProfileScreen()
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
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.popToRoot()
            })
            .disposed(by: disposeBag)
        
        
        // MARK: 회원 탈퇴
        removeAccountButtonClicked
            .subscribe(onNext: { [weak self] _ in
                
                self?.coordinator?.startRemoveWorkerAccountFlow()
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

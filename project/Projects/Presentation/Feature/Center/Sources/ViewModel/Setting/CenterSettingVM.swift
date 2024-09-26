//
//  CenterSettingVM.swift
//  CenterFeature
//
//  Created by choijunios on 8/19/24.
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

public protocol CenterSettingVMable: BaseViewModel {
    
    // Input
    var viewWillAppear: PublishRelay<Void> { get }
    var myCenterProfileButtonClicked: PublishRelay<Void> { get }
    var approveToPushNotification: PublishRelay<Bool> { get }
    
    var signOutButtonComfirmed: PublishRelay<Void> { get }
    var removeAccountButtonClicked: PublishRelay<Void> { get }
    
    var additionalInfoButtonClieck: PublishRelay<SettingAdditionalInfoType> { get }
    
    // Output
    var pushNotificationApproveState: Driver<Bool>? { get }
    var showSettingAlert: Driver<Void>? { get }
    var centerInfo: Driver<(name: String, location: String)>? { get }
    
    // SignOut
    func createSingOutVM() -> IdleAlertViewModelable
}

public class CenterSettingVM: BaseViewModel, CenterSettingVMable {
    
    // Init
    weak var coordinator: CenterSettingScreenCoordinator?
    let settingUseCase: SettingScreenUseCase
    
    public var viewWillAppear: PublishRelay<Void> = .init()
    public var myCenterProfileButtonClicked: PublishRelay<Void> = .init()
    public var approveToPushNotification: PublishRelay<Bool> = .init()
    
    public var signOutButtonComfirmed: PublishRelay<Void> = .init()
    public var removeAccountButtonClicked: PublishRelay<Void> = .init()
    
    public let additionalInfoButtonClieck: PublishRelay<SettingAdditionalInfoType> = .init()
    
    public var pushNotificationApproveState: RxCocoa.Driver<Bool>?
    public var centerInfo: RxCocoa.Driver<(name: String, location: String)>?
    public var showSettingAlert: Driver<Void>?
    
    public init(
        coordinator: CenterSettingScreenCoordinator?,
        settingUseCase: SettingScreenUseCase
        )
    {
        self.coordinator = coordinator
        self.settingUseCase = settingUseCase
        
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
        
        
        // MARK: 센터카드 정보 알아내기
        centerInfo = viewWillAppear
            .map { centerProfileVO in
                let vo = settingUseCase.getCenterProfile()
                return (vo.centerName, vo.roadNameAddress)
            }
            .asDriver(onErrorJustReturn: ("재가요양센터", "대한민국"))
            
        
        // MARK: 센터 정보로 이동하기
        myCenterProfileButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.coordinator?.showMyCenterProfile()
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
            settingUseCase.signoutCenterAccount()
        })
            .share()
        
        let signOutSuccess = signOutRequestResult.compactMap { $0.value }
        let signOutFailure = signOutRequestResult.compactMap { $0.error }
        
        signOutSuccess
            .subscribe(onNext: { [weak self] _ in
                
                // 로그이아웃 성공 -> 원격알림 토큰 제거
                NotificationCenter.default.post(name: .requestDeleteTokenFromServer, object: nil)
                
                self?.coordinator?.popToRoot()
            })
            .disposed(by: disposeBag)
        
        
        // MARK: 회원 탈퇴
        removeAccountButtonClicked
            .subscribe(onNext: { [weak self] _ in
                
                self?.coordinator?.startRemoveCenterAccountFlow()
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

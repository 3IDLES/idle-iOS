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

public protocol CenterSettingScreenCoordinatable: ParentCoordinator {
    /// 로그인및 회원가입 화면으로 이동합니다.
    func showAuthScreen()
    
    /// 시설 관리자 계정을 지우는 작업을 시작합니다.
    func startRemoveCenterAccountFlow()
}

public protocol CenterSettingVMable {
    
    // Input
    var viewWillAppear: PublishRelay<Void> { get }
    var myCenterProfileButtonClicked: PublishRelay<Void> { get }
    var approveToPushNotification: PublishRelay<Bool> { get }
    
    var signOutButtonComfirmed: PublishRelay<Void> { get }
    var removeAccountButtonClicked: PublishRelay<Void> { get }
    
    // Output
    var pushNotificationApproveState: Driver<Bool>? { get }
    var showSettingAlert: Driver<Void>? { get }
    var centerInfo: Driver<(name: String, location: String)>? { get }
    var alert: Driver<AlertWithCompletionVO>? { get }
    
    // SignOut
    func createSingOutVM() -> IdleAlertViewModelable
}

public class CenterSettingVM: CenterSettingVMable {
    
    public var viewWillAppear: RxRelay.PublishRelay<Void> = .init()
    public var myCenterProfileButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var approveToPushNotification: RxRelay.PublishRelay<Bool> = .init()
    
    public var signOutButtonComfirmed: RxRelay.PublishRelay<Void> = .init()
    public var removeAccountButtonClicked: RxRelay.PublishRelay<Void> = .init()
    
    public var pushNotificationApproveState: RxCocoa.Driver<Bool>?
    public var centerInfo: RxCocoa.Driver<(name: String, location: String)>?
    public var showSettingAlert: Driver<Void>?
    public var alert: RxCocoa.Driver<Entity.AlertWithCompletionVO>?
    
    let disposeBag = DisposeBag()
    
    weak var coordinator: CenterSettingScreenCoordinatable?
    let settingUseCase: SettingScreenUseCase
    let centerProfileUseCase: CenterProfileUseCase
    
    public init(
        coordinator: CenterSettingScreenCoordinatable?,
        settingUseCase: SettingScreenUseCase,
        centerProfileUseCase: CenterProfileUseCase
        )
    {
        self.settingUseCase = settingUseCase
        self.centerProfileUseCase = centerProfileUseCase
        
        // 기존의 알람수신 동의 여부 확인
        let currentNotificationAuthStatus = viewWillAppear
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
            if case let .error(message) = $0 { return true }
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
        let fetchCenterProfileResult = viewWillAppear
            .flatMap { [centerProfileUseCase] _ in
                centerProfileUseCase.getProfile(mode: .myProfile)
            }
        
        let fetchCenterProfileSuccess = fetchCenterProfileResult.compactMap { $0.value }
        let fetchCenterProfileFailure = fetchCenterProfileResult.compactMap { $0.error }
    
        centerInfo = fetchCenterProfileSuccess
            .map { centerProfileVO in
                (
                    centerProfileVO.centerName,
                    centerProfileVO.roadNameAddress
                )
            }
            .asDriver(onErrorJustReturn: ("재가요양센터", "대한민국"))
        
        // MARK: 로그아웃 확인됨
        signOutButtonComfirmed
            .subscribe(onNext: { [weak self] _ in
                
                // ‼️ ‼️ 계정 정보 삭제 ‼️ ‼️
                
                self?.coordinator?.showAuthScreen()
            })
            .disposed(by: disposeBag)
        
        
        // MARK: Alert
        alert = Observable.merge(
            approveRequestError.map { _ in "알람수신 동의 실패" },
            fetchCenterProfileFailure.map { $0.message }
        )
        .map({ message in
            AlertWithCompletionVO(
                title: "환경설정 오류",
                message: message
            )
        })
        .asDriver(onErrorJustReturn: .default)
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
    }
}

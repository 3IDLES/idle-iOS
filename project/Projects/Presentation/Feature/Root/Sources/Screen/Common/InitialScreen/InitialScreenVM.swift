//
//  InitialScreenVM.swift
//  RootFeature
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import Network

import PresentationCore
import UseCaseInterface
import RepositoryInterface
import BaseFeature
import Entity
import DSKit

import RxSwift
import RxCocoa
import FirebaseCrashlytics


public class InitialScreenVM: BaseViewModel {
    
    weak var coordinator: RootCoorinatable?
    
    // Input
    let viewDidLoad: PublishRelay<Void> = .init()
    let viewWillAppear: PublishRelay<Void> = .init()
    
    let authUseCase: AuthUseCase
    let workerProfileUseCase: WorkerProfileUseCase
    let centerProfileUseCase: CenterProfileUseCase
    let userInfoLocalRepository: UserInfoLocalRepository
    let remoteConfigRepository: RemoteConfigRepository
    
    // network monitoring
    private let networkMonitor: NWPathMonitor = .init()
    private let networkMonitoringQueue = DispatchQueue.global(qos: .background)
    private let networtIsAvailablePublisher: PublishSubject<Bool> = .init()
    
    public init(
            coordinator: RootCoorinatable?,
            authUseCase: AuthUseCase,
            workerProfileUseCase: WorkerProfileUseCase,
            centerProfileUseCase: CenterProfileUseCase,
            userInfoLocalRepository: UserInfoLocalRepository,
            remoteConfigRepository: RemoteConfigRepository
        )
    {
        self.coordinator = coordinator
        self.authUseCase = authUseCase
        self.workerProfileUseCase = workerProfileUseCase
        self.centerProfileUseCase = centerProfileUseCase
        self.userInfoLocalRepository = userInfoLocalRepository
        self.remoteConfigRepository = remoteConfigRepository
        
        super.init()
        
        // MARK: 네트워크 모니터링 시작
        let networkConnected: ReplaySubject<Void> = .create(bufferSize: 1)
        
        // 최초 1회 네트워크 연결이벤트 전송
        networtIsAvailablePublisher
            .filter { $0 }
            .take(1)
            .map { _ in }
            .bind(to: networkConnected)
            .disposed(by: disposeBag)
        
        // 네트워크가 연결되지 않은 경우 재시도 하며, 재시도 실패시 같은 플로우 반복
        networtIsAvailablePublisher.filter { !$0 }
            .subscribe(onNext: { [weak self] _ in
                
                let alertVO = DefaultAlertContentVO(
                    title: "인터넷 연결이 불안정해요",
                    message: "Wi-Fi 또는 셀룰러 데이터 연결을 확인한 후 다시 시도해 주세요.",
                    dismissButtonLabelText: "다시 시도하기") { [weak self] in
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
                            guard let self else { return }
                            
                            if self.networkMonitor.currentPath.status == .unsatisfied {
                                
                                self.networtIsAvailablePublisher.onNext(false)
                            }
                        }
                    }
                
                // 네트워크 연결되지 않음
                self?.alert.onNext(alertVO)
            })
            .disposed(by: disposeBag)
        
        startNeworkMonitoring()
        
        
        // MARK: 강제업데이트 확인
        // 네트워크 확인 -> 강제업데이트 확인
        let needsForceUpdate = networkConnected
            .flatMap { [remoteConfigRepository] _ in
                remoteConfigRepository.fetchRemoteConfig()
            }
            .compactMap { $0.value }
            .map { [remoteConfigRepository] isConfigFetched in
                
                if !isConfigFetched {
                    Crashlytics.crashlytics().log("Remote Config fetch실패")
                }
                
                guard let config = remoteConfigRepository.getForceUpdateInfo() else {
                    // ‼️ Config로딩 불가시 크래쉬
                    Crashlytics.crashlytics().log("Remote Config획득 실패")
                    fatalError("Remote Config fetching에러")
                }
                
                return config
            }
            .map { info in
                
                let minAppVersion = info.minVersion
                
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                
                printIfDebug("앱 버전: \(appVersion) 최소앱버전: \(minAppVersion)")
                
                return minAppVersion > appVersion
            }
            .share()
        	
        // 강제업데이트 필요
        needsForceUpdate
            .filter { $0 }
            .subscribe(onNext: {
                [weak self] _ in
                
                guard let self else { return }
                
                // 네트워크 연결되지 않음
                let object = IdleAlertObject()
                    .setTitle("최신 버전의 앱이 있어요")
                    .setDescription("유저분들의 의견을 반영해 앱을 더 발전시켰어요.\n보다 좋은 서비스를 만나기 위해, 업데이트해주세요.")
                    .setAcceptButtonLabelText("앱 종료")
                    .setCancelButtonLabelText("앱 업데이트")
                
                object
                    .cancelButtonClicked
                    .subscribe(onNext: { [weak self] in
                        self?.openAppStoreForUpdate()
                    })
                    .disposed(by: disposeBag)
                
                object
                    .acceptButtonClicked
                    .subscribe(onNext: {
                        exit(0)
                    })
                    .disposed(by: disposeBag)
                
                alertObject.onNext(object)
            })
            .disposed(by: disposeBag)
        
        // 강제업데이트 필요하지 않음
        let forceUpdateChecked = needsForceUpdate.filter { !$0 }

        // MARK: 유저별 플로우 시작
        // 네트워크 연결확인 -> 강제업데이트 확인 -> 유저별 플로우 시작
        Observable
            .combineLatest(
                // 강제업데이트 확인 완료
                forceUpdateChecked,
                
                // viewWillAppear
                viewWillAppear
            )
            .subscribe(onNext: { [weak self] _ in
                
                guard let self else { exit(0) }
                
                // 유저타입이 없는 경우 Auth로 이동
                guard let userType = userInfoLocalRepository.getUserType() else {
                    coordinator?.auth()
                    return
                }
                
                // 유저타입별 플로우 시작
                switch userType {
                case .center:
                    centerInitialFlow()
                case .worker:
                    workerInitialFlow()
                }
                
            })
            .disposed(by: disposeBag)
        
        
        // MARK: 로그아웃, 회원탈퇴시
        NotificationCenter.default.rx.notification(.popToInitialVC)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                
                guard let self else { return }
                
                self.coordinator?.popToRoot()
            })
            .disposed(by: disposeBag)
    }
    
    func workerInitialFlow() {
        
        let profileFetchResult = workerProfileUseCase
            .getFreshProfile(mode: .myProfile)
            .asObservable()
            .share()
        
        let profileFetchSuccess = profileFetchResult.compactMap { $0.value }
        let profileFetchFailure = profileFetchResult.compactMap { $0.error }
        
        profileFetchSuccess
            .subscribe(onNext: { [weak self] profileVO in
                
                guard let self else { return }
                
                // 불로온 정보 로컬에 저장
                userInfoLocalRepository.updateCurrentWorkerData(vo: profileVO)
                
                // 요양보호사 홈으로 이동
                coordinator?.workerMain()
            })
            .disposed(by: disposeBag)
        
        
        profileFetchFailure
            .subscribe(onNext: { [weak self] error in
                
                guard let self else { return }
                
                switch error {
                case .tokenExpiredException:
                    // 토큰이 만료된 경우
                    coordinator?.auth()
                default:
                    // 토큰과 무관한 에러상황
                    let alertVO = DefaultAlertContentVO(
                        title: "초기화면 오류",
                        message: error.message) {
                            // 어플리케이션 종료
                            exit(0)
                        }
                    
                    // 어플리케이션 종료 이벤트
                    self.alert.onNext(alertVO)
                }
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    func startNeworkMonitoring() {
        
        networkMonitor.pathUpdateHandler = { [weak self] path in
            
            DispatchQueue.main.async {
                self?.checkNetworkStatusAndPublish(status: path.status, delay: 0)
            }
        }
        
        networkMonitor.start(queue: networkMonitoringQueue)
    }
    
    func checkNetworkStatusAndPublish(status: NWPath.Status, delay: Int) {
        
        switch status {
        case .requiresConnection, .satisfied:
            // requiresConnection는 일반적으로 즉시 연결이 가능한 상태
            networtIsAvailablePublisher.onNext(true)
            networtIsAvailablePublisher.onCompleted()
            networkMonitor.cancel()
            return
        default:
            networtIsAvailablePublisher.onNext(false)
            return
        }
    }
    
    func centerInitialFlow() {
        
        // #1. 센터 상태를 확인함과 동시에 토큰 유효성 확인
        let centerJoinStatusResult = authUseCase
            .checkCenterJoinStatus()
            .asObservable()
            .share()

        let centerJoinStatusSuccess = centerJoinStatusResult.compactMap { $0.value }
        let centerJoinStatusFailure = centerJoinStatusResult.compactMap { $0.error }
        
        centerJoinStatusFailure
            .subscribe(onNext: { [weak self] error in
                
                guard let self else { return }
                
                switch error {
                case .tokenExpiredException, .tokenNotFound:
                    // 토큰이 만료된 경우
                    coordinator?.auth()
                default:
                    // 토큰과 무관한 에러상황
                    let alertVO = DefaultAlertContentVO(
                        title: "초기화면 오류",
                        message: error.message) {
                            // 어플리케이션 종료
                            exit(0)
                        }
                    
                    // 어플리케이션 종료 이벤트
                    self.alert.onNext(alertVO)
                }
            })
            .disposed(by: disposeBag)
            
        // #2. 센터 상태에 따른 분기후 프로필 확인
        let checkProfileRegisterResult = centerJoinStatusSuccess
            .compactMap { [weak self] info -> CenterJoinStatusInfoVO? in
                guard let self else { return nil }
                
                switch info.centerManagerAccountStatus {
                case .approved:
                    return info
                case .pending, .new:
                    
                    self.coordinator?.centerAuth()
                    
                    return nil
                }
            }
            .flatMap { [centerProfileUseCase] _ in
                centerProfileUseCase
                    .getProfile(mode: .myProfile)
            }
            .share()
        
        let profileExists = checkProfileRegisterResult.compactMap { $0.value }
        let profileDoentExistOrError = checkProfileRegisterResult.compactMap { $0.error }
        
        profileDoentExistOrError
            .subscribe(onNext: { [weak self] error in
                
                guard let self else { return }
                
                switch error {
                case .centerNotFoundException:
                    
                    // 센터가 없는 경우 -> 프로필이 등록되지 않음
                    // 프로필 등록화면으로 이동
                    self.coordinator?.makeCenterProfile()
                    
                    return
                    
                default:
                    // 토큰과 무관한 에러상황
                    let alertVO = DefaultAlertContentVO(
                        title: "초기화면 오류",
                        message: error.message) {
                            // 어플리케이션 종료
                            exit(0)
                        }
                    
                    // 어플리케이션 종료 이벤트
                    self.alert.onNext(alertVO)
                }
            })
            .disposed(by: disposeBag)
        
        // 프로필이 존재함으로 메인화면으로 이동
        profileExists
            .subscribe(onNext: { [weak self] profileVO in
                guard let self else { return }
                
                // 불로온 정보를 로컬에 저장
                userInfoLocalRepository.updateCurrentCenterData(vo: profileVO)
                
                coordinator?.centerMain()
            })
            .disposed(by: disposeBag)
    }
    
    func checkForceUpdate() {
        
        
    }
    
    /// 앱스토에에서 해당앱을 엽니다.
    func openAppStoreForUpdate() {
        let url = "itms-apps://itunes.apple.com/app/6670529341";
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}


//
//  NativePostDetailForWorkerVM.swift
//  BaseFeature
//
//  Created by choijunios on 8/15/24.
//

import UIKit
import RxCocoa
import RxSwift
import Entity
import PresentationCore
import UseCaseInterface
import DSKit

public protocol NativePostDetailForWorkerViewModelable: BaseViewModel {
    
    // Output
    var postForWorkerBundle: Driver<RecruitmentPostForWorkerBundle>? { get }
    var locationInfo: Driver<WorkPlaceAndWorkerLocationMapRO>? { get }
    var idleAlertVM: Driver<IdleAlertViewModelable>? { get }
    var starButtonRequestResult: Driver<Bool>? { get }
     
    // Input
    var viewWillAppear: PublishRelay<Void> { get }
    
    var backButtonClicked: PublishRelay<Void> { get }
    var applyButtonClicked: PublishRelay<Void> { get }
    var starButtonClicked: PublishRelay<Bool> { get }
    var centerCardClicked: PublishRelay<Void> { get }
}

public class NativePostDetailForWorkerVM: BaseViewModel ,NativePostDetailForWorkerViewModelable {

    public weak var coordinator: PostDetailForWorkerCoodinator?
    
    // Init
    private let postId: String
    private let recruitmentPostUseCase: RecruitmentPostUseCase
    private let workerProfileUseCase: WorkerProfileUseCase
    
    // Ouput
    public var postForWorkerBundle: RxCocoa.Driver<Entity.RecruitmentPostForWorkerBundle>?
    public var locationInfo: RxCocoa.Driver<WorkPlaceAndWorkerLocationMapRO>?
    public var idleAlertVM: Driver<any IdleAlertViewModelable>?
    public var starButtonRequestResult: Driver<Bool>?
    
    // Input
    public var backButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var applyButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var starButtonClicked: RxRelay.PublishRelay<Bool> = .init()
    public var centerCardClicked: RxRelay.PublishRelay<Void> = .init()
    public var viewWillAppear: RxRelay.PublishRelay<Void> = .init()

    
    public init(
            postId: String,
            coordinator: PostDetailForWorkerCoodinator?,
            recruitmentPostUseCase: RecruitmentPostUseCase,
            workerProfileUseCase: WorkerProfileUseCase
        )
    {
        self.postId = postId
        self.coordinator = coordinator
        self.recruitmentPostUseCase = recruitmentPostUseCase
        self.workerProfileUseCase = workerProfileUseCase
        
        super.init()
        
        // MARK: 로딩 옵저버블
        var loadingStartObservables: [Observable<Void>] = []
        var loadingEndObservables: [Observable<Void>] = []
        
        
        let getPostDetailResult = viewWillAppear
            .flatMap { [recruitmentPostUseCase] _ in
                recruitmentPostUseCase
                    .getNativePostDetailForWorker(id: postId)
            }
            .share()
        
        let getPostDetailSuccess = getPostDetailResult.compactMap { $0.value }
        let getPostDetailFailure = getPostDetailResult.compactMap { $0.error }
        
        let getPostDetailFailureAlert = getPostDetailFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "공고 불러오기 실패",
                    message: error.message
                )
            }
        
        postForWorkerBundle = getPostDetailSuccess.asDriver(onErrorRecover: { _ in fatalError() })
        
        // MARK: 센터, 워커 위치정보
        let requestWorkerLocationResult = viewWillAppear
            .flatMap({ [workerProfileUseCase] _ in
                workerProfileUseCase
                    .getProfile(mode: .myProfile)
            })
        
        let requestWorkerLocationSuccess = requestWorkerLocationResult.compactMap { $0.value }
        let requestWorkerLocationFailure = requestWorkerLocationResult.compactMap { $0.error }
        
        locationInfo = Observable
            .zip(getPostDetailSuccess, requestWorkerLocationSuccess)
            .map {
                [weak self] bundle, profile in
                
                // 요양보호사 위치 가져오기
                let workerLocation: LocationInformation = .init(
                    longitude: profile.longitude,
                    latitude: profile.latitude
                )
                
                let workPlaceLocation = bundle.jobLocation
                
                let roadAddress = bundle.addressInfo.addressInfo?.roadAddress ?? "근무지 위치"
                let text = "거주지에서 \(roadAddress) 까지"
                var normalAttr = Typography.Body2.attributes
                normalAttr[.foregroundColor] = DSKitAsset.Colors.gray500.color
                
                let attrText = NSMutableAttributedString(string: text, attributes: normalAttr)
                
                let roadTextFont = Typography.Subtitle3.attributes[.font]!
                
                let range = NSRange(text.range(of: roadAddress)!, in: text)
                attrText.addAttribute(.font, value: roadTextFont, range: range)
                
                let estimatedArrivalTimeText = self?.timeForDistance(meter: bundle.distanceToWorkPlace)
                
                return WorkPlaceAndWorkerLocationMapRO(
                    workPlaceRoadAddress: roadAddress,
                    homeToworkPlaceText: attrText,
                    estimatedArrivalTimeText: estimatedArrivalTimeText ?? "",
                    workPlaceLocation: workPlaceLocation,
                    workerLocation: workerLocation
                )
            }
            .asDriver(onErrorRecover: { _ in fatalError() })
        
        // MARK: 버튼 처리
        backButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.coordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposeBag)
        
        // 지원하기 버튼 클릭
        // MARK: 지원하기
        let applyRequest: PublishRelay<Void> = .init()
        self.idleAlertVM = applyButtonClicked
            .map { _ in
                DefaultIdleAlertVM(
                    title: "공고에 지원하시겠어요?",
                    description: "",
                    acceptButtonLabelText: "지원하기",
                    cancelButtonLabelText: "취소하기") {
                        applyRequest.accept(())
                    }
            }
            .asDriver(onErrorDriveWith: .never())

        // 로딩 시작
        loadingStartObservables.append(applyRequest.map { _ in })
        
        let applyRequestResult = applyRequest
            .flatMap { [recruitmentPostUseCase] _ in
                
                // 리스트화면에서는 앱내 지원만 지원합니다.
                return recruitmentPostUseCase
                    .applyToPost(postId: postId, method: .app)
            }
            .share()
        
        // 로딩 종료
        loadingEndObservables.append(applyRequestResult.map { _ in })
        
        let applyRequestSuccess = applyRequestResult.compactMap { $0.value }
        let applyRequestFailure = applyRequestResult.compactMap { $0.error }
        
        let applyRequestFailureAlert = applyRequestFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "지원하기 실패",
                    message: error.message
                )
            }

        // MARK: 즐겨찾기
        starButtonRequestResult = starButtonClicked
            .flatMap { [weak self] isFavoriteRequest in
                self?.setPostFavoriteState(
                    isFavoriteRequest: isFavoriteRequest,
                    postId: postId,
                    postType: .native
                ) ?? .never()
            }
            .asDriver(onErrorJustReturn: false)
            
        
        // 센터 프로필 조회 버튼클릭
        centerCardClicked
            .withLatestFrom(getPostDetailSuccess)
            .subscribe(onNext: { [weak self] bundle in
                guard let self else { return }
                let centerId = bundle.centerInfo.centerId
                self.coordinator?.showCenterProfileScreen(centerId: centerId)
            })
            .disposed(by: disposeBag)
        
        
        // MARK: Alert
        Observable
            .merge(
                getPostDetailFailureAlert,
                applyRequestFailureAlert
            )
            .subscribe(onNext: { [weak self] alertVO in
                guard let self else { return }
                alert.onNext(alertVO)
            })
            .disposed(by: disposeBag)
        
        // MARK: 로딩
        Observable
            .merge(loadingStartObservables)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                showLoading.onNext(())
            })
            .disposed(by: disposeBag)
        
        Observable
            .merge(loadingEndObservables)
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                dismissLoading.onNext(())
            })
            .disposed(by: disposeBag)
    }
        
    public func setPostFavoriteState(isFavoriteRequest: Bool, postId: String, postType: Entity.RecruitmentPostType) -> RxSwift.Single<Bool> {
        
        return Single<Bool>.create { [weak self] observer in
            
            guard let self else { return Disposables.create { } }
            
            let observable: Single<Result<Void, DomainError>>!
            
            // 로딩화면 시작
            self.showLoading.onNext(())
            
            if isFavoriteRequest {
                
                observable = recruitmentPostUseCase
                    .addFavoritePost(
                        postId: postId,
                        type: postType
                    )
                
            } else {
                
                observable = recruitmentPostUseCase
                    .removeFavoritePost(postId: postId)
            }
            
            let reuslt = observable
                .asObservable()
                .map({ [weak self] result in
                    
                    // 로딩화면 종료
                    self?.dismissLoading.onNext(())
                    
                    return result
                })
                .share()
            
            let success = reuslt.compactMap { $0.value }
            let failure = reuslt.compactMap { $0.error }
            
            let failureAlertDisposable = failure.map { error in
                    DefaultAlertContentVO(
                        title: "즐겨찾기 오류",
                        message: error.message
                    )
                }
                .asObservable()
                .subscribe(onNext: { [weak self] alertVO in
                    guard let self else { return }
                    alert.onNext(alertVO)
                })
                
            	
            let disposable = Observable
                .merge(
                    success.map { _ in true }.asObservable(),
                    failure.map { _ in false }.asObservable()
                )
                .asSingle()
                .subscribe(observer)
            
            return Disposables.create {
                disposable.dispose()
                failureAlertDisposable.dispose()
            }
        }
    }
    
    func timeForDistance(meter: Int) -> String {
        switch meter {
        case 0..<200:
            return "도보 5분 이내"
        case 200..<400:
            return "도보 5 ~ 10분"
        case 400..<700:
            return "도보 10 ~ 15분"
        case 700..<1000:
            return "도보 15 ~ 20분"
        case 1000..<1250:
            return "도보 20 ~ 25분"
        case 1250..<1500:
            return "도보 25 ~ 30분"
        case 1500..<1750:
            return "도보 30 ~ 35분"
        case 1750..<2000:
            return "도보 35 ~ 40분"
        default:
            return "도보 40분 ~"
        }
    }
}

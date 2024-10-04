//
//  WorknetPostDetailForWorkerVM.swift
//  BaseFeature
//
//  Created by choijunios on 9/6/24.
//

import UIKit
import Domain
import PresentationCore
import DSKit
import Core


import RxCocoa
import RxSwift

public protocol WorknetPostDetailForWorkerViewModelable: BaseViewModel {
    
    // Output
    var postDetail: Driver<WorknetRecruitmentPostDetailVO>? { get }
    var locationInfo: Driver<WorkPlaceAndWorkerLocationMapRO>? { get }
    var starButtonRequestResult: Driver<Bool>? { get }
    
    // Input
    var requestRefresh: PublishRelay<Void> { get }
    var backButtonClicked: PublishRelay<Void> { get }
    var starButtonClicked: PublishRelay<Bool> { get }
}

public class WorknetPostDetailForWorkerVM: BaseViewModel, WorknetPostDetailForWorkerViewModelable {
    
    @Injected private var recruitmentPostUseCase: RecruitmentPostUseCase
    @Injected private var workerProfileUseCase: WorkerProfileUseCase
    
    public weak var coordinator: PostDetailForWorkerCoodinator?
    
    // Init
    private let postInfo: RecruitmentPostInfo
    
    // Ouput
    public var postDetail: RxCocoa.Driver<WorknetRecruitmentPostDetailVO>?
    public var locationInfo: RxCocoa.Driver<WorkPlaceAndWorkerLocationMapRO>?
    public var starButtonRequestResult: Driver<Bool>?
    
    // Input
    public var requestRefresh: RxRelay.PublishRelay<Void> = .init()
    public var backButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var starButtonClicked: RxRelay.PublishRelay<Bool> = .init()

    
    public init(postInfo: RecruitmentPostInfo, coordinator: PostDetailForWorkerCoodinator?) {
        self.postInfo = postInfo
        self.coordinator = coordinator
        
        super.init()
        
        let getPostDetailResult = requestRefresh
            .flatMap { [recruitmentPostUseCase] _ in
                recruitmentPostUseCase
                    .getWorknetPostDetailForWorker(id: postInfo.id)
            }
            .share()
        
        let getPostDetailSuccess = getPostDetailResult.compactMap { $0.value }
        let getPostDetailFailure = getPostDetailResult.compactMap { $0.error }
        
        let getPostDetailFailureAlert = getPostDetailFailure
            .map { [weak self] error in
                DefaultAlertContentVO(
                    title: "공고 불러오기 실패",
                    message: error.message
                ) { [weak self] in
                    self?.coordinator?.coordinatorDidFinish()
                }
            }
        
        postDetail = getPostDetailSuccess
            .asDriver(onErrorDriveWith: .never())
        
        // MARK: 센터, 워커 위치정보
        let requestWorkerLocationResult = requestRefresh
            .flatMap({ [workerProfileUseCase] _ in
                workerProfileUseCase
                    .getProfile(mode: .myProfile)
            })
        
        let requestWorkerLocationSuccess = requestWorkerLocationResult.compactMap { $0.value }
        let requestWorkerLocationFailure = requestWorkerLocationResult.compactMap { $0.error }
        
        locationInfo = Observable
            .zip(getPostDetailSuccess, requestWorkerLocationSuccess)
            .map { [weak self] postVO, profile in
                
                // 요양보호사 위치 가져오기
                let workerLocation: LocationInformation = .init(
                    longitude: profile.longitude,
                    latitude: profile.latitude
                )
                
                var workPlaceLocation: LocationInformation = .notFound
                
                if let longitude = postVO.longitude, let latitude = postVO.latitude {
                    workPlaceLocation = .init(
                        longitude: Double(longitude) ?? 0.0,
                        latitude: Double(latitude) ?? 0.0
                    )
                }
                
                let roadAddress = postVO.clientAddress
                let text = "거주지에서 \(roadAddress) 까지"
                var normalAttr = Typography.Body2.attributes
                normalAttr[.foregroundColor] = DSKitAsset.Colors.gray500.color
                
                let attrText = NSMutableAttributedString(string: text, attributes: normalAttr)
                
                let roadTextFont = Typography.Subtitle3.attributes[.font]!
                
                let range = NSRange(text.range(of: roadAddress)!, in: text)
                attrText.addAttribute(.font, value: roadTextFont, range: range)
                
                let estimatedArrivalTimeText = self?.timeForDistance(meter: postVO.distance)
                
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

        // MARK: 즐겨찾기
        starButtonRequestResult = starButtonClicked
            .flatMap { [weak self] isFavoriteRequest in
                self?.setPostFavoriteState(
                    isFavoriteRequest: isFavoriteRequest,
                    postId: postInfo.id,
                    postType: .native
                ) ?? .never()
            }
            .asDriver(onErrorJustReturn: false)
            
        
        // MARK: Alert
        Observable
            .merge(getPostDetailFailureAlert)
            .subscribe(onNext: { [weak self] alertVO in
                guard let self else { return }
                alert.onNext(alertVO)
            })
            .disposed(by: disposeBag)
    }
        
    public func setPostFavoriteState(isFavoriteRequest: Bool, postId: String, postType: PostOriginType) -> RxSwift.Single<Bool> {
        
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

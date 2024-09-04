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
    
    // Input
    var viewWillAppear: PublishRelay<Void> { get }
    
    var backButtonClicked: PublishRelay<Void> { get }
    var applyButtonClicked: PublishRelay<Void> { get }
    var startButtonClicked: PublishRelay<Bool> { get }
    var centerCardClicked: PublishRelay<Void> { get }
}

public class NativePostDetailForWorkerVM: BaseViewModel ,NativePostDetailForWorkerViewModelable {

    public weak var coordinator: PostDetailForWorkerCoodinator?
    
    // Init
    private let postId: String
    private let recruitmentPostUseCase: RecruitmentPostUseCase
    
    // Ouput
    public var postForWorkerBundle: RxCocoa.Driver<Entity.RecruitmentPostForWorkerBundle>?
    public var locationInfo: RxCocoa.Driver<WorkPlaceAndWorkerLocationMapRO>?
    public var idleAlertVM: Driver<any IdleAlertViewModelable>?
    
    // Input
    public var backButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var applyButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var startButtonClicked: RxRelay.PublishRelay<Bool> = .init()
    public var centerCardClicked: RxRelay.PublishRelay<Void> = .init()
    public var viewWillAppear: RxRelay.PublishRelay<Void> = .init()

    
    public init(
            postId: String,
            coordinator: PostDetailForWorkerCoodinator?,
            recruitmentPostUseCase: RecruitmentPostUseCase
        )
    {
        self.postId = postId
        self.coordinator = coordinator
        self.recruitmentPostUseCase = recruitmentPostUseCase
        
        super.init()
        
        // MARK: 로딩 옵저버블
        var loadingStartObservables: [Observable<Void>] = []
        var loadingEndObservables: [Observable<Void>] = []
        
        
        let getPostDetailResult = viewWillAppear
            .flatMap { [recruitmentPostUseCase] _ in
                recruitmentPostUseCase
                    .getPostDetailForWorker(id: postId)
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
        locationInfo = getPostDetailSuccess
            .map { [weak self] bundle in
                // 요양보호사 위치 가져오기
                let workerLocation = self?.getWorkerLocation()
                
                let workPlaceLocation = bundle.jobLocation
                
                let roadAddress = bundle.addressInfo.addressInfo?.roadAddress ?? "근무지 위치"
                let text = "거주지에서 \(roadAddress) 까지"
                var normalAttr = Typography.Body2.attributes
                normalAttr[.foregroundColor] = DSKitAsset.Colors.gray500.color
                
                let attrText = NSMutableAttributedString(string: text, attributes: normalAttr)
                
                let roadTextFont = Typography.Subtitle3.attributes[.font]!
                
                let range = NSRange(text.range(of: roadAddress)!, in: text)
                attrText.addAttribute(.font, value: roadTextFont, range: range)
                
                return WorkPlaceAndWorkerLocationMapRO(
                    workPlaceRoadAddress: roadAddress,
                    homeToworkPlaceText: attrText,
                    distanceToWorkPlaceText: "\(bundle.distanceToWorkPlace)m",
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
            .subscribe(alert)
            .disposed(by: disposeBag)
        
        
        // MARK: 로딩
        Observable
            .merge(loadingStartObservables)
            .subscribe(showLoading)
            .disposed(by: disposeBag)
        
        Observable
            .merge(loadingEndObservables)
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(dismissLoading)
            .disposed(by: disposeBag)
    }
    
    // MARK: Test
    func getWorkerLocation() -> LocationInformation {
        return .init(
            longitude: 127.046425,
            latitude: 37.504588
        )
    }
}

//
//  CenterRegisterCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 10/2/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Core

enum CenterAccountRegisterStage: Int {
    
    case registerFinished
    case name
    case phoneNumber
    case businessOwner
    case idPassword
    case finish
    
    var screenName: String {
        switch self {
        case .registerFinished:
            ""
        case .name:
            "name"
        case .phoneNumber:
            "phoneNumber"
        case .businessOwner:
            "businessOwner"
        case .idPassword:
            "idPassword"
        case .finish:
            ""
        }
    }
}

public enum CenterAccountRegisterCoordinatorDestination {
    case centerMainPage
}

public class CenterAccountRegisterCoordinator: Coordinator2 {
    
    @Injected var logger: CenterRegisterLogger
    
    let router: Router
    
    public var startFlow: ((CenterAccountRegisterCoordinatorDestination) -> ())!
    
    // Pages
    var stageViewControllers: [UIViewController] = []
    weak var pageViewController: UIPageViewController!
    private var currentStage: CenterAccountRegisterStage!
    
    public init(router: Router) {
        
        self.router = router
    }
    
    public func start() {
        
        let vm = CenterAccountRegisterViewModel()
        
        vm.presentNextPage = { [weak self] in
            
            self?.next()
        }
        
        vm.presentPrevPage = { [weak self] in
                
            self?.prev()
        }
        
        vm.presentCompleteScreen = { [weak self] in
            
            // MARK: 센터 계정 회원가입 완료 로깅
            self?.logger.logCenterRegisterDuration()
            
            let object: AnonymousCompleteVCRenderObject = .init(
                titleText: "센터관리자 로그인을\n완료했어요!",
                descriptionText: "로그인 정보는 마지막 접속일부터\n180일간 유지될 예정이에요.",
                completeButtonText: "시작하기") { [weak self] in
                    
                    // 메인페이지로 이동
                    self?.startFlow(.centerMainPage)
            }
            
            // 완료화면으로 이동
            self?.router.presentAnonymousCompletePage(object)
        }
    
        self.stageViewControllers = [
            EnterNameViewController(viewModel: vm),
            ValidatePhoneNumberViewController(viewModel: vm),
            AuthBusinessOwnerViewController(viewModel: vm),
            SetIdPasswordViewController(viewModel: vm),
        ]
        
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        self.pageViewController = pageViewController
        
        let viewController = CenterAccountRegisterViewController(
            pageCount: stageViewControllers.count,
            pageViewController: pageViewController
        )
        
        // 회원가입화면 벗어남
        viewController.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        
        router.push(module: viewController, animated: true)
        
        excuteStage(.name, moveTo: .next)
        
        // MARK: 센터 계정등록 시작 로깅
        logger.startCenterRegister()
    }
}

// MARK: PageViewController
extension CenterAccountRegisterCoordinator {
    
    enum MovingDirection {
        case next
        case prev
    }
    
    public func next() {
        if let nextStage = CenterAccountRegisterStage(rawValue: currentStage.rawValue+1) {
            excuteStage(nextStage, moveTo: .next)
            NotificationCenter.default.post(name: .centerRegisterProcess, object: nil, userInfo: [
                "move": "next"
            ])
        }
    }
    
    public func prev() {
        if let prevStage = CenterAccountRegisterStage(rawValue: currentStage.rawValue-1) {
            excuteStage(prevStage, moveTo: .prev)
            NotificationCenter.default.post(name: .centerRegisterProcess, object: nil, userInfo: [
                "move": "prev"
            ])
        }
    }
    
    private func excuteStage(_ stage: CenterAccountRegisterStage, moveTo: MovingDirection) {
        currentStage = stage
        switch stage {
        case .registerFinished:
            router.popModule(animated: true)
        case .finish:
            return
        default:
            
            // MARK: 등록 스테이지 이동 로깅
            if moveTo == .next {
                logger.logCenterRegisterStep(
                    stepName: stage.screenName,
                    stepIndex: stage.rawValue-1
                )
            }
            
            let vc = stageViewControllers[stage.rawValue-1]
            showPageViewControllerStage(viewController: vc, moveTo: moveTo)
        }
    }
    
    func showPageViewControllerStage(viewController: UIViewController, moveTo: MovingDirection) {
        pageViewController?.setViewControllers(
            [viewController],
            direction: moveTo == .next ? .forward : .reverse,
            animated: true
        )
    }
}

extension Notification.Name {
    
    static let centerRegisterProcess: Self = .init(rawValue: "centerRegisterProcess")
}

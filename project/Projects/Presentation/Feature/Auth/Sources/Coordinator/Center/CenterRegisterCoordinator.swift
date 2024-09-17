//
//  CenterRegisterCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import UseCaseInterface
import PresentationCore
import LoggerInterface

enum CenterRegisterStage: Int {
    
    case registerFinished=0
    case name=1
    case phoneNumber=2
    case businessOwner=3
    case idPassword=4
    case finish=5
    
    var screenName: String {
        switch self {
        case .registerFinished:
            ""
        case .name:
            "input|name"
        case .phoneNumber:
            "input|phoneNumber"
        case .businessOwner:
            "input|businessOwner"
        case .idPassword:
            "input|idPassword"
        case .finish:
            ""
        }
    }
}

public class CenterRegisterCoordinator: ChildCoordinator {
    
    @Injected var logger: CenterRegisterLogger
    
    public struct Dependency {
        let navigationController: UINavigationController
        
        public init(navigationController: UINavigationController) {
            self.navigationController = navigationController
        }
    }
    
    public var parent: AuthCoordinatable?
    
    public weak var viewControllerRef: UIViewController?
    
    weak var pageViewController: UIPageViewController?
    
    public var navigationController: UINavigationController
    
    var stageViewControllers: [UIViewController] = []
    
    private var currentStage: CenterRegisterStage!
    
    public init(
        dependency: Dependency
    ) {
        self.navigationController = dependency.navigationController
        
        let vm = CenterRegisterViewModel(coordinator: self)
        
        // stageViewControllerss에 자기자신과 ViewModel할당
        self.stageViewControllers = [
            EnterNameViewController(viewModel: vm),
            ValidatePhoneNumberViewController(viewModel: vm),
            AuthBusinessOwnerViewController(viewModel: vm),
            SetIdPasswordViewController(viewModel: vm),
        ]
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    public func start() {
        
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        self.pageViewController = pageViewController
        
        let viewController = CenterRegisterViewController(
            pageCount: stageViewControllers.count,
            pageViewController: pageViewController
        )
        
        viewController.coordinator = self
        
        viewControllerRef = viewController
        
        navigationController.pushViewController(viewController, animated: true)
        
        excuteStage(.name, moveTo: .next)
        
        // MARK: 시작 로깅
        logger.startCenterRegister()
    }
    
    public func coordinatorDidFinish() {
        
        stageViewControllers = []
        
        popViewController()
        
        parent?.removeChildCoordinator(self)
    }
}

extension CenterRegisterCoordinator {
    
    enum MoveTo {
        case next
        case prev
    }
    
    public func next() {
        if let nextStage = CenterRegisterStage(rawValue: currentStage.rawValue+1) {
            excuteStage(nextStage, moveTo: .next)
            NotificationCenter.default.post(name: .centerRegisterProcess, object: nil, userInfo: [
                "move": "next"
            ])
        }
    }
    
    public func prev() {
        if let prevStage = CenterRegisterStage(rawValue: currentStage.rawValue-1) {
            excuteStage(prevStage, moveTo: .prev)
            NotificationCenter.default.post(name: .centerRegisterProcess, object: nil, userInfo: [
                "move": "prev"
            ])
        }
    }
    
    private func excuteStage(_ stage: CenterRegisterStage, moveTo: MoveTo) {
        currentStage = stage
        switch stage {
        case .registerFinished:
            registerFinished()
        case .finish:
            authFinished()
        default:
            // MARK: 로깅
            if moveTo == .next {
                logger.logCenterRegisterStep(
                    stepName: stage.screenName,
                    stepIndex: stage.rawValue-1
                )
            }
            
            let vc = stageViewControllers[stage.rawValue-1]
            showStage(viewController: vc, moveTo: moveTo)
        }
    }
    
    func showStage(viewController: UIViewController, moveTo: MoveTo) {
        pageViewController?.setViewControllers(
            [viewController],
            direction: moveTo == .next ? .forward : .reverse,
            animated: true
        )
    }
    
    func authFinished() {
        stageViewControllers = []
        parent?.authFinished()
    }
    
    func registerFinished() {
        stageViewControllers = []
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    func showCompleteScreen() {
        let renderObject: AnonymousCompleteVCRenderObject = .init(
            titleText: "센터관리자 로그인을\n완료했어요!",
            descriptionText: "로그인 정보는 마지막 접속일부터\n180일간 유지될 예정이에요.",
            completeButtonText: "시작하기") { [weak self] in
                self?.authFinished()
            }
        parent?.showCompleteScreen(ro: renderObject)
        
        // MARK: 종료 로깅
        logger.logCenterRegisterDuration()
    }
}

extension Notification.Name {
    
    static let centerRegisterProcess: Self = .init(rawValue: "centerRegisterProcess")
}

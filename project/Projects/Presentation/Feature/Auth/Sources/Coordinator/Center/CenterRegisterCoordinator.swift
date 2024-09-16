//
//  CenterRegisterCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import UseCaseInterface
import PresentationCore

enum CenterRegisterStage: Int {
    
    case registerFinished=0
    case name=1
    case phoneNumber=2
    case businessOwner=3
    case idPassword=4
    case finish=5
}

public class CenterRegisterCoordinator: ChildCoordinator {
    
    public struct Dependency {
        let navigationController: UINavigationController
        let inputValidationUseCase: AuthInputValidationUseCase
        let authUseCase: AuthUseCase
        
        public init(navigationController: UINavigationController, inputValidationUseCase: AuthInputValidationUseCase, authUseCase: AuthUseCase) {
            self.navigationController = navigationController
            self.inputValidationUseCase = inputValidationUseCase
            self.authUseCase = authUseCase
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
        
        let vm = CenterRegisterViewModel(
            inputValidationUseCase: dependency.inputValidationUseCase,
            authUseCase: dependency.authUseCase
        )
        
        // stageViewControllerss에 자기자신과 ViewModel할당
        self.stageViewControllers = [
            EnterNameViewController(coordinator: self, viewModel: vm),
            ValidatePhoneNumberViewController(viewModel: vm),
            AuthBusinessOwnerViewController(coordinator: self, viewModel: vm),
            SetIdPasswordViewController(coordinator: self, viewModel: vm),
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
}

extension Notification.Name {
    
    static let centerRegisterProcess: Self = .init(rawValue: "centerRegisterProcess")
}

//
//  CenterSetNewPasswordCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/17/24.
//

import UIKit
import PresentationCore
import UseCaseInterface

enum SetNewPasswordStage: Int {
    
    case findPasswordFinished=0
    case phoneNumber=1
    case password=2
    case finish=3
}

public class CenterSetNewPasswordCoordinator: ChildCoordinator {
    
    public struct Dependency {
        let navigationController: UINavigationController
        let authUseCase: AuthUseCase
        let inputValidationUseCase: AuthInputValidationUseCase
        public init(navigationController: UINavigationController, authUseCase: AuthUseCase, inputValidationUseCase: AuthInputValidationUseCase) {
            self.navigationController = navigationController
            self.authUseCase = authUseCase
            self.inputValidationUseCase = inputValidationUseCase
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public var navigationController: UINavigationController
    
    var stageViewControllers: [UIViewController] = []
    weak var pageViewController: UIPageViewController?
    
    public var parent: CanterLoginFlowable?
    
    let authUseCase: AuthUseCase
    let inputValidationUseCase: AuthInputValidationUseCase
    
    var currentStage: SetNewPasswordStage!
    
    public init(
        dependency: Dependency
    ) {
        self.navigationController = dependency.navigationController
        self.authUseCase = dependency.authUseCase
        self.inputValidationUseCase = dependency.inputValidationUseCase
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    public func start() {
        
        let vm = CenterSetNewPasswordViewModel(
            authUseCase: authUseCase,
            inputValidationUseCase: inputValidationUseCase
        )
        
        // stageViewControllerss에 자기자신과 ViewModel할당
        self.stageViewControllers = [
            ValidatePhoneNumberViewController(coordinator: self, viewModel: vm),
            ValidateNewPasswordViewController(coordinator: self, viewModel: vm)
        ]
        
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        self.pageViewController = pageViewController
        
        let viewController = CenterSetNewPasswordController(
            pageViewController: pageViewController,
            pageCount: stageViewControllers.count
        )
        viewController.coordinator = self
        
        navigationController.pushViewController(viewController, animated: true)
        excuteStage(.phoneNumber, moveTo: .next)
    }
    
    public func coordinatorDidFinish() {
        
        stageViewControllers = []
        parent?.removeChildCoordinator(self)
    }
}

extension CenterSetNewPasswordCoordinator {
    
    /// 패스워드 변경화면 표시
    enum MoveTo {
        case next, prev
    }
    
    public func next() {
        if let nextStage = SetNewPasswordStage(rawValue: currentStage.rawValue+1) {
            excuteStage(nextStage, moveTo: .next)
        }
    }
    
    public func prev() {
        if let prevStage = SetNewPasswordStage(rawValue: currentStage.rawValue-1) {
            excuteStage(prevStage, moveTo: .prev)
        }
    }
    
    private func excuteStage(_ stage: SetNewPasswordStage, moveTo: MoveTo) {
        currentStage = stage
        switch stage {
        case .findPasswordFinished, .finish:
            popViewController()
            coordinatorDidFinish()
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
}

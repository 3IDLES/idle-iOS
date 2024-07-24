//
//  CenterSetNewPasswordCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/17/24.
//

import UIKit
import PresentationCore

enum SetNewPasswordStage: Int {
    
    case findPasswordFinished=0
    case phoneNumber=1
    case password=2
    case finish=3
}

public class CenterSetNewPasswordCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: (any PresentationCore.DisposableViewController)?
    public var navigationController: UINavigationController
    
    var stageViewControllers: [UIViewController] = []
    weak var pageViewController: UIPageViewController?
    
    public var parent: CenterAuthCoordinatable?
    
    private var viewModel: CenterSetNewPasswordViewModel
    
    var currentStage: SetNewPasswordStage!
    
    public init(
        viewModel: CenterSetNewPasswordViewModel,
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    public func start() {
        
        // stageViewControllerss에 자기자신과 ViewModel할당
        self.stageViewControllers = [
            ValidatePhoneNumberViewController(coordinator: self, viewModel: viewModel),
            ValidateNewPasswordViewController(coordinator: self, viewModel: viewModel)
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

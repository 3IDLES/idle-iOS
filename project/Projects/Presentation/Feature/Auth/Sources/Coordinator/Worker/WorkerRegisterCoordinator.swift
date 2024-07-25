//
//  WorkerRegisterCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore

enum WorkerRegisterStage: Int {
    
    case registerFinished=0
    case info=1
    case phoneNumber=2
    case address=3
    case finish=4
}

public class WorkerRegisterCoordinator: ChildCoordinator {

    public var parent: WorkerAuthCoordinatable?
    
    public let navigationController: UINavigationController
    
    public weak var viewControllerRef: UIViewController?
    
    weak var pageViewController: UIPageViewController?
    
    var stageViewControllers: [UIViewController] = []
    
    private var currentStage: WorkerRegisterStage!
    
    public init(
        navigationController: UINavigationController,
        viewModel: WorkerRegisterViewModel
    ) {
    
        self.navigationController = navigationController
        
        self.stageViewControllers = [
            EntetPersonalInfoViewController(coordinator: self, viewModel: viewModel),
            ValidatePhoneNumberViewController(coordinator: self, viewModel: viewModel),
            EnterAddressViewController(coordinator: self, viewModel: viewModel),
        ]
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
    
    public func start() {
        
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        self.pageViewController = pageViewController
        
        let viewController = WorkerRegisterViewController(
            pageCount: stageViewControllers.count,
            pageViewController: pageViewController
        )
        
        viewController.coordinator = self
        
        viewControllerRef = viewController
        
        navigationController.pushViewController(viewController, animated: true)
        
        excuteStage(.info, moveTo: .next)
    }

    public func coordinatorDidFinish() {
        
        stageViewControllers = []
        
        parent?.removeChildCoordinator(self)
    }
}

extension WorkerRegisterCoordinator {
    
    enum MoveTo {
        case next
        case prev
    }
    
    public func next() {
        if let nextStage = WorkerRegisterStage(rawValue: currentStage.rawValue+1) {
            excuteStage(nextStage, moveTo: .next)
            NotificationCenter.default.post(name: .workerRegisterProcess, object: nil, userInfo: [
                "move": "next"
            ])
        }
    }
    
    public func prev() {
        if let prevStage = WorkerRegisterStage(rawValue: currentStage.rawValue-1) {
            excuteStage(prevStage, moveTo: .prev)
            NotificationCenter.default.post(name: .workerRegisterProcess, object: nil, userInfo: [
                "move": "prev"
            ])
        }
    }
    
    private func excuteStage(_ stage: WorkerRegisterStage, moveTo: MoveTo) {
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
    
    static let workerRegisterProcess: Self = .init(rawValue: "workerRegisterProcess")
}

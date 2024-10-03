//
//  WorkerRegisterCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import Domain
import PresentationCore
import Core

enum WorkerRegisterStage: Int {
    
    case registerFinished
    case phoneNumber
    case info
    case address
    case finish
    
    var screenName: String {
        switch self {
        case .registerFinished:
            ""
        case .phoneNumber:
            "input|phoneNumber"
        case .info:
            "input|personalInfo"
        case .address:
            "input|address"
        case .finish:
            ""
        }
    }
}

public class WorkerRegisterCoordinator: ChildCoordinator {
    
    @Injected var logger: WorkerRegisterLogger
    
    public weak var parent: ParentCoordinator?
    var authCoordinator: AuthCoordinatable? {
        parent as? AuthCoordinatable
    }
    
    public let navigationController: UINavigationController
    public weak var viewControllerRef: UIViewController?
    weak var pageViewController: UIPageViewController?

    
    // MARK: Stage
    var stageViewControllers: [UIViewController] = []
    private var currentStage: WorkerRegisterStage!
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
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
        
        let vm = WorkerRegisterViewModel(coordinator: self)
        
        self.stageViewControllers = [
            ValidatePhoneNumberViewController(viewModel: vm),
            EntetPersonalInfoViewController(viewModel: vm),
            EnterAddressViewController(viewModel: vm),
        ]
        
        self.pageViewController = pageViewController
        
        let vc = WorkerRegisterViewController(
            pageCount: stageViewControllers.count,
            pageViewController: pageViewController
        )
        vc.bind(viewModel: vm)
        
        vc.coordinator = self
        
        viewControllerRef = vc
        
        navigationController.pushViewController(vc, animated: true)
        
        excuteStage(.phoneNumber, moveTo: .next)
        
        // MARK: 시작 로깅
        logger.startWorkerRegister()
    }

    public func coordinatorDidFinish() {
        
        stageViewControllers = []
        parent?.removeChildCoordinator(self)
        popViewController()
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
            // MARK: 로깅
            if moveTo == .next {
                logger.logWorkerRegisterStep(
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
    
    func showCompleteScreen() {
        let renderObject: AnonymousCompleteVCRenderObject = .init(
            titleText: "요양보호사 로그인을\n완료했어요!",
            descriptionText: "로그인 정보는 마지막 접속일부터\n180일간 유지될 예정이에요.",
            completeButtonText: "시작하기") { [weak self] in
                self?.authFinished()
            }
        authCoordinator?.showCompleteScreen(ro: renderObject)
        
        // MARK: 완료 로깅
        logger.startWorkerRegister()
    }
    
    func authFinished() {
        stageViewControllers = []
        authCoordinator?.authFinished()
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

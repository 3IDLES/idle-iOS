//
//  WorkerAccountRegisterCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 10/3/24.
//

import UIKit

import BaseFeature
import Logger
import PresentationCore
import Core

public enum WorkerAccountRegisterCoordinatorDestination {
    case workerMainPage
}

public class WorkerAccountRegisterCoordinator: Coordinator {
    
    public var onFinish: (() -> ())?
    
    // Injected
    @Injected var router: RouterProtocol
    @Injected var logger: Logger
    
    // startFlow
    public var startFlow: ((WorkerAccountRegisterCoordinatorDestination) -> ())!
    
    // PageViewController
    weak var pageViewController: UIPageViewController?
    var stageViewControllers: [UIViewController] = []
    private var currentStage: WorkerAccountRegisterStage!
    
    public init() { }
    
    public func start() {
        
        let viewModel = WorkerRegisterViewModel()
        
        viewModel.presentCompletePage = { [weak self] in
            
            guard let self else { return }
            
            // 회원가입 완료
            logCurrentStage(stage: .finish)
            
            let object: AnonymousCompleteVCRenderObject = .init(
                titleText: "요양보호사 로그인을\n완료했어요!",
                descriptionText: "로그인 정보는 마지막 접속일부터\n180일간 유지될 예정이에요.",
                completeButtonText: "시작하기") { [weak self] in
                    
                    // WorkerMainPage로 이동
                    self?.startFlow(.workerMainPage)
                }
            
            // 완료화면 표시
            router.presentAnonymousCompletePage(object)
        }
        
        viewModel.presentNextPage = { [weak self] in
            self?.presentNextPage()
        }
        
        viewModel.presentPrevPage = { [weak self] in
            self?.presentPrevPage()
        }
        
        self.stageViewControllers = [
            ValidatePhoneNumberViewController(viewModel: viewModel),
            EntetPersonalInfoViewController(viewModel: viewModel),
            EnterAddressViewController(viewModel: viewModel),
        ]
        
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
        
        viewController.exitPage = { [weak self] in
            
            self?.router.popModule(animated: true)
        }
        
        router.push(module: viewController, animated: true) { [weak self] in
            self?.onFinish?()
        }
        
        // 회원가입 시작
        logCurrentStage(stage: .start)
        
        excuteStage(.phoneNumber, moveTo: .next)
    }
}

// MARK: PageViewController
extension WorkerAccountRegisterCoordinator {
    
    enum MovingDirection {
        case next
        case prev
    }
    
    public func presentNextPage() {
        if let nextStage = WorkerAccountRegisterStage(rawValue: currentStage.rawValue+1) {
            excuteStage(nextStage, moveTo: .next)
            NotificationCenter.default.post(name: .workerRegisterProcess, object: nil, userInfo: [
                "move": "next"
            ])
        }
    }
    
    public func presentPrevPage() {
        if let prevStage = WorkerAccountRegisterStage(rawValue: currentStage.rawValue-1) {
            excuteStage(prevStage, moveTo: .prev)
            NotificationCenter.default.post(name: .workerRegisterProcess, object: nil, userInfo: [
                "move": "prev"
            ])
        }
    }
    
    private func excuteStage(_ stage: WorkerAccountRegisterStage, moveTo: MovingDirection) {
        currentStage = stage
        switch stage {
        case .start:
            router.popModule(animated: true)
        case .finish:
            return
        default:
            
            // MARK: 화면 전환 로깅
            logCurrentStage()
            
            let vc = stageViewControllers[stage.rawValue-1]
            showStage(viewController: vc, moveTo: moveTo)
        }
    }
    
    func showStage(viewController: UIViewController, moveTo: MovingDirection) {
        
        pageViewController?.setViewControllers(
            [viewController],
            direction: moveTo == .next ? .forward : .reverse,
            animated: true
        )
    }
    
    func logCurrentStage(stage: WorkerAccountRegisterStage? = nil) {
        let logObject = AccountRegisterationLogBuilder(
            step: (stage ?? currentStage).step,
            stepName: (stage ?? currentStage).screenKorName
        )
        .build()
        
        logger.send(logObject)
    }
}

// MARK: Notification for status UI
extension Notification.Name {
    
    static let workerRegisterProcess: Self = .init(rawValue: "workerRegisterProcess")
}

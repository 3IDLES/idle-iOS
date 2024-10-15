//
//  CenterSetNewPasswordCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/17/24.
//

import UIKit
import Domain
import BaseFeature
import DSKit
import Core

enum SetNewPasswordStage: Int {
    
    case findPasswordFinished
    case phoneNumber
    case password
    case finish
}

public class CenterSetupNewPasswordCoordinator: Coordinator {
    
    // Injected
    @Injected var router: RouterProtocol
    
    public var onFinish: (() -> ())?
    
    // PageConroller
    var stageViewControllers: [UIViewController] = []
    weak var pageViewController: UIPageViewController?
    var currentStage: SetNewPasswordStage!
    
    // State
    private var passwordSetupSuccess: Bool = false
    
    public init() { }
    
    public func start() {
        
        let viewModel = CenterSetupNewPasswordViewModel()
        
        viewModel.presentNextPage = { [weak self] in
            self?.presentNextPage()
        }
        
        viewModel.presentPrevPage = { [weak self] in
            self?.presentPrevPage()
        }
        
        viewModel.presentCompleteAndDismiss = { [weak self] in
            self?.passwordSetupSuccess = true
            self?.router.popModule(animated: true)
        }
        
        self.stageViewControllers = [
            ValidatePhoneNumberViewController(viewModel: viewModel),
            ValidateNewPasswordViewController(viewModel: viewModel)
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
        viewController.bind(viewModel: viewModel)
        viewController.exitPage = { [router] in
            router.popModule(animated: true)
        }
        
        router.push(module: viewController, animated: true) { [weak self] in
            guard let self else { return }
            if passwordSetupSuccess == true {
                router.presentSnackBarController(
                    bottomPadding: 70,
                    object: .init(titleText: "비밀번호 변경 성공")
                )
            }
            
            onFinish?()
        }
        
        excuteStage(.phoneNumber, moveTo: .next)
    }
}

extension CenterSetupNewPasswordCoordinator {
    
    enum MovingDirection {
        case next, prev
    }
    
    public func presentNextPage() {
        if let nextStage = SetNewPasswordStage(rawValue: currentStage.rawValue+1) {
            excuteStage(nextStage, moveTo: .next)
        }
    }
    
    public func presentPrevPage() {
        if let prevStage = SetNewPasswordStage(rawValue: currentStage.rawValue-1) {
            excuteStage(prevStage, moveTo: .prev)
        }
    }
    
    private func excuteStage(_ stage: SetNewPasswordStage, moveTo: MovingDirection) {
        currentStage = stage
        switch stage {
        case .findPasswordFinished, .finish:
            router.popModule(animated: true)
        default:
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
}

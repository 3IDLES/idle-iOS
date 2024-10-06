//
//  CreatePostCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/14/24.
//

import UIKit
import PresentationCore
import Domain
import BaseFeature
import Core

public class CreatePostCoordinator: Coordinator {
    
    public var onFinish: (() -> ())?
    
    public typealias Module = UIViewController
    
    @Injected var logger: PostRegisterLogger
    
    let router: Router
    let presentingModule: Module
    
    public init(router: Router, presentingModule: Module) {
        self.router = router
        self.presentingModule = presentingModule
    }
    
    deinit {
        printIfDebug("deinit \(CreatePostCoordinator.self)")
    }
    
    public func start() {
        
        let viewModel = CreatePostViewModel()
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        viewModel.presentPostOverviewPage = { [weak self] viewModel in
            self?.presentOverviewPage(viewModel: viewModel)
        }
        viewModel.presentEditPostPage = { [weak self] viewModel in
            self?.presentEditPostPage(viewModel: viewModel)
        }
        viewModel.presentCompletePage = { [weak self] in
            self?.presentCompletePage()
        }
        
        let viewController = CreatePostViewController()
        viewController.bind(viewModel: viewModel)
        
        router.push(module: viewController, animated: true) { [weak self] in
            self?.onFinish?()
        }
        
        // MARK: 공고등록 시작 로깅
        logger.startPostRegister()
    }
}

public extension CreatePostCoordinator {
    
    func presentOverviewPage(viewModel: PostOverviewViewModelable) {
        let viewController = PostOverviewVC()
        viewController.bind(viewModel: viewModel)
        router.push(module: viewController, animated: true)
    }
    
    func presentEditPostPage(viewModel: EditPostViewModelable) {
        let viewController = EditPostVC()
        viewController.bind(viewModel: viewModel)
        router.push(module: viewController, animated: true)
    }
    
    func presentCompletePage() {
        let object = AnonymousCompleteVCRenderObject(
            titleText: "요양보호사 구인 공고를\n등록했어요!",
            descriptionText: "",
            completeButtonText: "확인") { [weak self] in
                guard let self else { return }
                router.popTo(module: presentingModule, animated: true)
            }
        
        router.presentAnonymousCompletePage(object)
    }
}

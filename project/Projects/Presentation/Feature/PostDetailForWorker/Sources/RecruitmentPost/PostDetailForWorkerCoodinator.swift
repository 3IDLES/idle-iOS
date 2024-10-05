//
//  Coordinator.swift
//  BaseFeature
//
//  Created by choijunios on 8/15/24.
//

import UIKit
import BaseFeature
import Domain
import Core

public enum PostDetailForWorkerCoodinatorDestination {
    case centerProfile(mode: ProfileMode)
}

public class PostDetailForWorkerCoodinator: Coordinator2 {

    public var startFlow: ((PostDetailForWorkerCoodinatorDestination) -> ())!
    
    public var onFinish: (() -> ())?
    
    let router: Router
    let postInfo: RecruitmentPostInfo
    
    public init(router: Router, postInfo: RecruitmentPostInfo) {
        self.router = router
        self.postInfo = postInfo
    }
    
    deinit {
        printIfDebug("\(String(describing: PostDetailForWorkerCoodinator.self))")
    }
    
    public func start() {
        switch postInfo.type {
        case .native:
            presentNativePostDetail(id: postInfo.id)
        case .workNet:
            presentWorknetPostDetail(id: postInfo.id)
        }
    }
}

public extension PostDetailForWorkerCoodinator {
    
    func presentNativePostDetail(id: String) {
        
        let viewModel = NativePostDetailForWorkerVM(id: id)
        viewModel.presentSnackBar = { [weak self] object in
            self?.router.presentSnackBarController(bottomPadding: 0, object: object)
        }
        viewModel.presentCenterProfile = { [weak self] id in
            self?.startFlow(.centerProfile(mode: .otherProfile(id: id)))
        }
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        
        let viewController = NativePostDetailForWorkerVC()
        viewController.bind(viewModel: viewModel)
        
        router.push(module: viewController, animated: true)
    }
    
    func presentWorknetPostDetail(id: String) {
        
        let viewModel = WorknetPostDetailForWorkerVM(id: id)
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        
        let viewController = WorknetPostDetailForWorkerVC()
        viewController.bind(viewModel: viewModel)
        
        router.push(module: viewController, animated: true)
    }
}

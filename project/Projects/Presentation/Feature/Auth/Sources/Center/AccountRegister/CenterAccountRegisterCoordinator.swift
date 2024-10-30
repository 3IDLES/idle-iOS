//
//  CenterRegisterCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 10/2/24.
//

import UIKit

import BaseFeature
import Logger
import PresentationCore
import Core

enum CenterAccountRegisterStage: Int {
    
    case registerFinished
    case name
    case phoneNumber
    case businessOwner
    case idPassword
    case finish
    
    var screenKorName: String {
        switch self {
        case .registerFinished:
            "회원가입 페이지 이탈"
        case .name:
            "이름 입력"
        case .phoneNumber:
            "전화번호 입력"
        case .businessOwner:
            "사업자 인증번호 입력"
        case .idPassword:
            "아이디 패스워드 입력"
        case .finish:
            "가입완료"
        }
    }
    
    var step: Int {
        switch self {
        case .registerFinished:
            0
        case .name:
            1
        case .phoneNumber:
            2
        case .businessOwner:
            3
        case .idPassword:
            4
        case .finish:
            5
        }
    }
}

public enum CenterAccountRegisterCoordinatorDestination {
    case centerMainPage
}

public class CenterAccountRegisterCoordinator: Coordinator {
    
    // Injected
    @Injected var router: RouterProtocol
    @Injected var logger: Logger
    
    public var onFinish: (() -> ())?
    
    public var startFlow: ((CenterAccountRegisterCoordinatorDestination) -> ())!
    
    // Pages
    var stageViewControllers: [UIViewController] = []
    weak var pageViewController: UIPageViewController!
    private var currentStage: CenterAccountRegisterStage!
    
    public init() { }
    
    public func start() {
        
        let vm = CenterAccountRegisterViewModel()
        
        vm.presentNextPage = { [weak self] in
            
            self?.next()
        }
        
        vm.presentPrevPage = { [weak self] in
                
            self?.prev()
        }
        
        vm.presentCompleteScreen = { [weak self] in
            
            guard let self else { return }
            
            // MARK: 센터 계정 회원가입 완료 로깅
            let stage: CenterAccountRegisterStage = .finish
            let logObject = CenterAccountRegisterationLogBuilder(
                step: currentStage.step,
                stepName: currentStage.screenKorName
            )
            .build()
            
            logger.send(logObject)
            
            
            // MARK: 완료화면으로 이동
            let object: AnonymousCompleteVCRenderObject = .init(
                titleText: "센터관리자 로그인을\n완료했어요!",
                descriptionText: "로그인 정보는 마지막 접속일부터\n180일간 유지될 예정이에요.",
                completeButtonText: "시작하기") { [weak self] in
                    
                    // 메인페이지로 이동
                    self?.startFlow(.centerMainPage)
            }
            
            // 완료화면으로 이동
            router.presentAnonymousCompletePage(object)
        }
        
        vm.presentAlert = { [weak self] object in
            
            self?.router.presentDefaultAlertController(object: object)
        }
    
        self.stageViewControllers = [
            EnterNameViewController(viewModel: vm),
            ValidatePhoneNumberViewController(viewModel: vm),
            AuthBusinessOwnerViewController(viewModel: vm),
            SetIdPasswordViewController(viewModel: vm),
        ]
        
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        self.pageViewController = pageViewController
        
        let viewController = CenterAccountRegisterViewController(
            pageCount: stageViewControllers.count,
            pageViewController: pageViewController
        )
        
        // 회원가입화면 벗어남
        viewController.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        
        router.push(module: viewController, animated: true) { [weak self] in
            self?.onFinish?()
        }
        
        excuteStage(.name, moveTo: .next)
    }
}

// MARK: PageViewController
extension CenterAccountRegisterCoordinator {
    
    enum MovingDirection {
        case next
        case prev
    }
    
    public func next() {
        if let nextStage = CenterAccountRegisterStage(rawValue: currentStage.rawValue+1) {
            excuteStage(nextStage, moveTo: .next)
            NotificationCenter.default.post(name: .centerRegisterProcess, object: nil, userInfo: [
                "move": "next"
            ])
        }
    }
    
    public func prev() {
        if let prevStage = CenterAccountRegisterStage(rawValue: currentStage.rawValue-1) {
            excuteStage(prevStage, moveTo: .prev)
            NotificationCenter.default.post(name: .centerRegisterProcess, object: nil, userInfo: [
                "move": "prev"
            ])
        }
    }
    
    private func excuteStage(_ stage: CenterAccountRegisterStage, moveTo: MovingDirection) {
        currentStage = stage
        switch stage {
        case .registerFinished:
            router.popModule(animated: true)
        case .finish:
            return
        default:
            
            // 로깅
            logCurrentStage()

            let vc = stageViewControllers[stage.rawValue-1]
            showPageViewControllerStage(viewController: vc, moveTo: moveTo)
        }
    }
    
    func showPageViewControllerStage(viewController: UIViewController, moveTo: MovingDirection) {
        pageViewController?.setViewControllers(
            [viewController],
            direction: moveTo == .next ? .forward : .reverse,
            animated: true
        )
    }
    
    func logCurrentStage() {
        let logObject = CenterAccountRegisterationLogBuilder(
            step: currentStage.step,
            stepName: currentStage.screenKorName
        )
        .build()
        
        logger.send(logObject)
    }
}

extension Notification.Name {
    
    static let centerRegisterProcess: Self = .init(rawValue: "centerRegisterProcess")
}

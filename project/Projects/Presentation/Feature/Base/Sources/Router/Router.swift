//
//  Router.swift
//  BaseFeature
//
//  Created by choijunios on 9/30/24.
//

import UIKit
import Domain
import DSKit
import PresentationCore

public protocol RouterProtocol {
    
    typealias Module = UIViewController
    typealias RoutingCompletion = () -> Void
    
    // MARK: present modal module
    func present(_ module: Module, animated: Bool, modalPresentationSytle: UIModalPresentationStyle, completion: RoutingCompletion?)
    
    
    
    // MARK: dismiss module
    func dismissModule(animated: Bool, completion: (() -> Void)?)
    
    
    
    // MARK: push module
    // pop시 호출할 클로저를 여기서 지정(항상 최상단 VC가 팝되지 않음으로)
    func push(module: Module, animated: Bool, popCompletion: (() -> Void)?)
    
    
    
    // MARK: pop module
    func popModule(animated: Bool)
    
    /// 특정 모듈까지 네비게이션 스택을 비움
    func popTo(module: Module, animated: Bool)
    
    
    
    // MARK: Set root module
    /// RootController의 루트 Module을 변경
    func changeRootModuleTo(module: Module, animated: Bool)
    
    
    // MARK: change window
    /// 키 윈도우의 rootController를 변경, 페인드 인/아웃 애니메이션 적용됨
    func replaceRootModuleTo(module: Module, animated: Bool, completion: RoutingCompletion?)
    
    
    /// RootController를 생성및 KeyWindow의 루트로 지정
    func setRootModuleTo(module: Module)
    
    
    /// Default alert를 표출
    func presentDefaultAlertController(object: DefaultAlertObject)
    
    
    /// Default alert를 표출
    func presentIdleAlertController(type: IdleBigAlertController.ButtonType, object: IdleAlertObject)
}

public final class Router: NSObject, RouterProtocol {
    
    weak var rootController: UINavigationController?
    
    var completion: [UnsafeRawPointer: RoutingCompletion] = [:]
    
    var transition: UIViewControllerAnimatedTransitioning?
    
    /// 네비게이션 최상단ViewController
    var topViewController: UIViewController? {
        rootController?.topViewController
    }
    
    public override init() {
        super.init()
    }
    
    public func present(_ module: Module, animated: Bool, modalPresentationSytle: UIModalPresentationStyle, completion: RoutingCompletion? = nil) {
        
        rootController?.modalPresentationStyle = modalPresentationSytle
        rootController?.present(
            module,
            animated: animated,
            completion: completion
        )
    }
    
    public func dismissModule(animated: Bool, completion: (() -> Void)? = nil) {
        
        rootController?.dismiss(
            animated: animated,
            completion: completion
        )
    }
    
    public func push(module: Module, animated: Bool, popCompletion: (() -> Void)? = nil) {
        
        guard (module is UINavigationController) == false else {
            // 디버그 모드시 런타임에러발생시킴
            return assertionFailure("\(#function) 네비게이션 컨트롤러 삽입 불가")
        }
        
        completion[module.getRawPointer] = popCompletion
        
        rootController?.pushViewController(
            module,
            animated: animated
        )
    }
    
    public func popModule(animated: Bool) {
        
        if let module = rootController?.popViewController(animated: animated) {
            
            let pointer = module.getRawPointer
            completion[pointer]?()
            completion.removeValue(forKey: pointer)
        }
    }
    
    public func popTo(module: Module, animated: Bool) {
    
        guard let controllers = rootController?.viewControllers else { return }
        
        for controller in controllers {
            
            if controller === module {
                
                rootController?.popToViewController(controller, animated: true)
            }
        }
    }
    
    public func changeRootModuleTo(module: Module, animated: Bool) {
        
        rootController?.setViewControllers([module], animated: animated)
    }
    
    public func replaceRootModuleTo(module: Module, animated: Bool, completion: (() -> Void)? = nil) {
        
        guard let keyWindow = UIWindow.keyWindow else { return }
        
        let navigationController = UINavigationController(rootViewController: module)
        navigationController.setNavigationBarHidden(true, animated: false)
        
        self.rootController = navigationController
        
        if !animated {
            // 애니메이션이 없는 경우
            setRootModuleTo(module: module)
            completion?()
            
            return
        }
        
        if let snapshot = keyWindow.snapshotView(afterScreenUpdates: true) {
            
            module.view.addSubview(snapshot)
            keyWindow.rootViewController = navigationController
            
            completion?()
            
            UIView.animate(withDuration: 0.35, animations: {
                snapshot.layer.opacity = 0
            }, completion: { _ in
                snapshot.removeFromSuperview()
            })
        }
    }
    
    public func setRootModuleTo(module: Module) {
        guard let keyWindow = UIWindow.keyWindow else { return }
        let navigationController = UINavigationController(rootViewController: module)
        navigationController.setNavigationBarHidden(true, animated: false)
        
        keyWindow.rootViewController = navigationController
        
        self.rootController = navigationController
    }
    
    public func presentDefaultAlertController(object: DefaultAlertObject) {
        
        let alertController = UIAlertController(
            title: object.title,
            message: object.description,
            preferredStyle: .alert
        )
        
        for action in object.actions {
            
            let alertAction = UIAlertAction(title: action.titleName, style: .default) { _ in
                
                // on dismiss
                action.action?()
            }
            
            alertController.addAction(alertAction)
        }
        
        self.present(
            alertController,
            animated: true,
            modalPresentationSytle: .automatic
        )
    }
}

// MARK: Alert
extension Router {
    
    public func presentIdleAlertController(type: IdleBigAlertController.ButtonType, object: DSKit.IdleAlertObject) {
        
        let alertVC = IdleBigAlertController(type: type)
        alertVC.bindObject(object)
        alertVC.modalPresentationStyle = .custom
        self.present(alertVC, animated: true, modalPresentationSytle: .custom)
    }
}

extension Router {
    
    public func presentAnonymousCompletePage(_ object: AnonymousCompleteVCRenderObject) {
        
        let completeViewController = AnonymousCompleteVC()
        completeViewController.applyRO(object)
        
        self.push(module: completeViewController, animated: true)
    }
}

extension UIWindow {
    
    static var keyWindow: UIWindow? {
        
        if let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            
            return keyWindow
        }
        return nil
    }
}

extension UIViewController {
    
    var getRawPointer: UnsafeMutableRawPointer {
        Unmanaged.passUnretained(self).toOpaque()
    }
}

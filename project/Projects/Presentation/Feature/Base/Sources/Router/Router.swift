//
//  Router.swift
//  BaseFeature
//
//  Created by choijunios on 9/30/24.
//

import UIKit

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
    /// 컨트롤러의 루트 VC를 변경
    func setRootModule(module: Module, animated: Bool)
    
    
    
    // MARK: change window
    /// 키 윈도우의 rootController를 변경, 페인드 인/아웃 애니메이션 적용됨
    func replaceRootModule(module: Module, animated: Bool, completion: RoutingCompletion?)
    
    /// 루트윈도우를 설정
    func setKeyWindow(module: Module)
}

public final class Router: NSObject, RouterProtocol {
    
    weak var rootController: UINavigationController?
    
    var completion: [UnsafePointer<Module>: RoutingCompletion] = [:]
    
    var transition: UIViewControllerAnimatedTransitioning?
    
    /// 네비게이션 최상단ViewController
    var topViewController: UIViewController? {
        rootController?.topViewController
    }
    
    public init(rootController: UINavigationController? = nil) {
        self.rootController = rootController
    }
    
    public func present(_ module: Module, animated: Bool, modalPresentationSytle: UIModalPresentationStyle, completion: RoutingCompletion?) {
        
        rootController?.modalPresentationStyle = modalPresentationSytle
        rootController?.present(
            module,
            animated: animated,
            completion: completion
        )
    }
    
    public func dismissModule(animated: Bool, completion: (() -> Void)?) {
        
        rootController?.dismiss(
            animated: animated,
            completion: completion
        )
    }
    
    public func push(module: Module, animated: Bool, popCompletion: (() -> Void)?) {
        
        guard (module is UINavigationController) == false else {
            // 디버그 모드시 런타임에러발생시킴
            return assertionFailure("\(#function) 네비게이션 컨트롤러 삽입 불가")
        }
        
        rootController?.pushViewController(
            module,
            animated: animated
        )
    }
    
    public func popModule(animated: Bool) {
        
        rootController?
            .popViewController(animated: animated)
    }
    
    public func popTo(module: Module, animated: Bool) {
        
        guard let controllers = rootController?.viewControllers else { return }
        
        for controller in rootController!.viewControllers {
            
            if controller === module {
                
                rootController?.popToViewController(controller, animated: true)
            }
        }
    }
    
    public func setRootModule(module: Module, animated: Bool) {
        
        rootController?.setViewControllers([module], animated: animated)
    }
    
    public func replaceRootModule(module: Module, animated: Bool, completion: (() -> Void)?) {
        
        guard let keyWindow = UIWindow.keyWindow else { return }
        
        let navigationController = UINavigationController(rootViewController: module)
        
        self.rootController = navigationController
        
        if !animated {
            // 애니메이션이 없는 경우
            setKeyWindow(module: module)
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
    
    public func setKeyWindow(module: Module) {
        guard let keyWindow = UIWindow.keyWindow else { return }
        let navigationController = UINavigationController(rootViewController: module)
        
        keyWindow.rootViewController = navigationController
        
        self.rootController = navigationController
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

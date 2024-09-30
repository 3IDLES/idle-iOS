//
//  Router.swift
//  BaseFeature
//
//  Created by choijunios on 9/30/24.
//

import UIKit

public protocol Router {
    
    typealias Module = UIViewController
    typealias RoutingCompletion = () -> Void
    
    // MARK: present modal module
    func present(_ module: Module, animated: Bool, modalPresentationSytle: UIModalPresentationStyle, completion: RoutingCompletion?)
    
    
    
    // MARK: dismiss module
    func dismissModule(animated: Bool, completion: (() -> Void)?)
    
    
    
    // MARK: push module
    // pop시 호출할 클로저를 여기서 지정(항상 최상단 VC가 팝되지 않음으로)
    func push(module: Module, transition: UIViewControllerAnimatedTransitioning?, animated: Bool, popCompletion: (() -> Void)?)
    
    
    
    // MARK: pop module
    func popModule(transition: UIViewControllerAnimatedTransitioning?, animated: Bool)
    
    /// 전달한 모듈을 해당 스택에서 제거
    func popModule(module: Module, transition: UIViewControllerAnimatedTransitioning?, animated: Bool)
    
    
    
    // MARK: Set root module
    /// 컨트롤러의 루트 VC를 변경
    func setRootModule(module: Module)
    
    
    
    // MARK: change window
    /// 루트 윈도우를 변경, 페인드 인/아웃 애니메이션 적용됨
    func replaceKeyWindow(module: Module)
    
    /// 루트윈도우를 설정
    func setKeyWindow(module: Module)
}

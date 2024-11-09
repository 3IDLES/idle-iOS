//
//  BaseViewController.swift
//  BaseFeature
//
//  Created by choijunios on 7/23/24.
//

import UIKit
import Domain
import DSKit


import RxSwift

open class BaseViewController: UIViewController {
    
    /// ViewModel을 hold합니다.
    public var viewModel: BaseViewModel?
    
    // MARK: loading trigger
    /// present애니메이션중 dismiss가 발동될 경우 충돌이 발생하여 예상치못한 동작유발
    private var isLoadingPresenting: Bool = false
    private var loadingDimissionRequested: Bool = false
    private var loadingVC: UIViewController?
    
    open var snackBarBottomPadding: CGFloat = 0.0
    
    /// disposeBag
    public let disposeBag = DisposeBag()
    
    /// 기본 바인딩
    open func bind(viewModel: BaseViewModel) {
        
        self.viewModel = viewModel
        
        // Life cycle
        rx.viewDidAppear
            .map({ _ in })
            .bind(to: viewModel.viewDidAppear)
            .disposed(by: disposeBag)
        
        // Alert
        viewModel
            .alertDriver?
            .drive(onNext: { [weak self] alertVO in
                self?.showAlert(vo: alertVO)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .alertObjectDriver?
            .drive(onNext: { [weak self] object in
                self?.showIdleModal(object: object)
            })
            .disposed(by: disposeBag)
        
        // 로딩
        viewModel
            .showLoadingDriver?
            .drive(onNext: { [weak self] _ in
                self?.showDefaultLoadingScreen()
            })
            .disposed(by: disposeBag)
        
        viewModel
            .dismissLoadingDriver?
            .drive(onNext: { [weak self] _ in
                self?.dismissDefaultLoadingScreen()
            })
            .disposed(by: disposeBag)
    }
    
    open func alert(vo: DefaultAlertContentVO) { }
}

// MARK: Alert
public extension BaseViewController {
    
    func showAlert(vo: DefaultAlertContentVO, onClose: (() -> ())? = nil) {
        
        guard let _ = self.parent else { return }
        
        let alert = UIAlertController(
            title: vo.title,
            message: vo.message,
            preferredStyle: .alert
        )
        let close = UIAlertAction(title: vo.dismissButtonLabelText, style: .default) { [weak self] _ in
            self?.alert(vo: vo)
            
            // dismiss
            vo.onDismiss?()
        }
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
    
    func showIdleModal(
        type: IdleBigAlertController.ButtonType = .red,
        viewModel: IdleAlertViewModelable
    ) {
        let alertVC = IdleBigAlertController(type: type)
        alertVC.bind(viewModel: viewModel)
        alertVC.modalPresentationStyle = .custom
        present(alertVC, animated: true, completion: nil)
    }
    
    func showIdleModal(
        type: IdleBigAlertController.ButtonType = .red,
        object: IdleAlertObject
    ) {
        let alertVC = IdleBigAlertController(type: type)
        alertVC.bindObject(object)
        alertVC.modalPresentationStyle = .custom
        present(alertVC, animated: true, completion: nil)
    }
}

// MARK: Default loading screen
public extension BaseViewController {
    
    func showDefaultLoadingScreen() {
    
        let loadingView = DefaultLoadingView()
        loadingView.alpha = 0.0
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            loadingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        UIView.animate(withDuration: 0.25) {
            loadingView.alpha = 1.0
        }
    }
    
    func dismissDefaultLoadingScreen() {
        
        if let loadingView = view.subviews.first(where: { $0 is DefaultLoadingView }) {
            
            UIView.animate(withDuration: 0.25) {
                loadingView.alpha = 0.0
            }
            loadingView.removeFromSuperview()
        }
    }
}

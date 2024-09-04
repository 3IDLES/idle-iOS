//
//  BaseViewController.swift
//  BaseFeature
//
//  Created by choijunios on 7/23/24.
//

import UIKit
import Entity
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
    
    /// disposeBag
    public let disposeBag = DisposeBag()
    
    /// 기본 바인딩
    open func bind(viewModel: BaseViewModel) {
        
        self.viewModel = viewModel
        
        // Alert
        viewModel
            .alert?
            .drive(onNext: { [weak self] alertVO in
                self?.showAlert(vo: alertVO)
            })
            .disposed(by: disposeBag)
        
        // 로딩
        viewModel
            .showLoading?
            .drive(onNext: { [weak self] _ in
                self?.showDefaultLoadingScreen()
            })
            .disposed(by: disposeBag)
        
        viewModel
            .dismissLoading?
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
        let alert = UIAlertController(
            title: vo.title,
            message: vo.message,
            preferredStyle: .alert
        )
        let close = UIAlertAction(title: "닫기", style: .default) { [weak self] _ in
            self?.alert(vo: vo)
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
}

public extension BaseViewController {
    
    func showDefaultLoadingScreen() {
        
        let vc = DefaultLoadingVC()
        loadingVC = vc
        vc.modalPresentationStyle = .custom
        
        isLoadingPresenting = true
        present(vc, animated: true) {
            
            if self.loadingDimissionRequested {
                DispatchQueue.main.async { [weak self] in
                    vc.dismiss(animated: true) {
                        self?.loadingVC = nil
                    }
                    self?.isLoadingPresenting = false
                }
            } else {
                self.isLoadingPresenting = false
            }
        }
    }
    
    func dismissDefaultLoadingScreen() {
        if let loadingVC {
            
            if !isLoadingPresenting {
                loadingVC.dismiss(animated: true) {
                    self.loadingVC = nil
                }
            } else {
                loadingDimissionRequested = true
            }
        }
    }
}

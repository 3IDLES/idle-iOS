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
    
    // MARK: loading trigger
    /// present애니메이션중 dismiss가 발동될 경우 충돌이 발생하여 예상치못한 동작유발
    private var isLoadingPresenting: Bool = false
    private var loadingDimissionRequested: Bool = false
    private var loadingVC: UIViewController?
}

// MARK: Alert
public extension BaseViewController {
    
    func showAlert(vo: DefaultAlertContentVO, onClose: (() -> ())? = nil) {
        let alert = UIAlertController(title: vo.title, message: vo.message, preferredStyle: .alert)
        let close = UIAlertAction(title: "닫기", style: .default) { _ in
            onClose?()
        }
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(vo: AlertWithCompletionVO) {
        let alert = UIAlertController(title: vo.title, message: vo.message, preferredStyle: .alert)
        
        vo.buttonInfo.forEach { (buttonTitle: String, completion: AlertWithCompletionVO.AlertCompletion?) in
            let button = UIAlertAction(title: buttonTitle, style: .default) { _ in
                completion?()
            }
            alert.addAction(button)
        }
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
    
    func bind(viewModel: DefaultLoadingVMable, disposeBag: DisposeBag) {
        
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
}

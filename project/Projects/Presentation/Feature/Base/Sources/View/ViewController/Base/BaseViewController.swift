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
        
        // Snack bar
        viewModel
            .snackBarDriver?
            .drive(onNext: { [weak self] snackBarRO in
                self?.showSnackBar(ro: snackBarRO)
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
        let close = UIAlertAction(title: "닫기", style: .default) { [weak self] _ in
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

// MARK: Snack bar
extension BaseViewController {
    
    func showSnackBar(ro: IdleSnackBarRO) {
        
        let viewSize = self.view.bounds.size
        let horizontalPadding: CGFloat = 20
        let bottomPadding: CGFloat = 20
        
        let snackBarHeight: CGFloat = 48
        let snackBarWidth: CGFloat = viewSize.width - horizontalPadding*2
        
        let snackBarXPos: CGFloat = horizontalPadding
        let snackBarYPos: CGFloat = viewSize.height - bottomPadding - snackBarHeight
        
        let snackBar = IdleSnackBar(
            frame: .init(
                origin: .init(x: snackBarXPos, y: snackBarYPos),
                size: .init(width: snackBarWidth, height: snackBarHeight)
            )
        )
        
        // ro적용
        snackBar.applyRO(ro)
        
        // 스낵바를 하단에 감춘다
        snackBar.transform = .init(translationX: 0, y: snackBarHeight+horizontalPadding)
        snackBar.alpha = 0.5
        
        // 뷰계층에 추가
        view.addSubview(snackBar)
        
        let snackBarShowingDuration: CGFloat = 2
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            snackBar.transform = .identity
            snackBar.alpha = 1.0
        } completion: { _ in
            
            UIView.animate(withDuration: 0.2, delay: snackBarShowingDuration, options: .curveEaseIn) {
                snackBar.transform = .init(translationX: 0, y: snackBarHeight+horizontalPadding)
                snackBar.alpha = 0.5
            }
        }
    }
}

public extension BaseViewController {
    
    func showDefaultLoadingScreen() {
        
        guard let _ = self.parent else { return }
        
        let vc = DefaultLoadingVC()
        loadingVC = vc
        vc.modalPresentationStyle = .overFullScreen
        isLoadingPresenting = true
        present(vc, animated: false) {
            
            if self.loadingDimissionRequested {
                DispatchQueue.main.async { [weak self] in
                    vc.dismiss(animated: false) {
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
                loadingVC.dismiss(animated: false) {
                    self.loadingVC = nil
                }
            } else {
                loadingDimissionRequested = true
            }
        }
    }
}

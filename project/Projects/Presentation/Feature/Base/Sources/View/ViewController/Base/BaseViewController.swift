//
//  BaseViewController.swift
//  BaseFeature
//
//  Created by choijunios on 7/23/24.
//

import UIKit
import Entity
import DSKit

open class BaseViewController: UIViewController { }

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
}

//
//  BaseViewController.swift
//  BaseFeature
//
//  Created by choijunios on 7/23/24.
//

import UIKit
import Entity

open class BaseViewController: UIViewController { }

// MARK: Alert
public extension BaseViewController {
    
    func showAlert(vo: DefaultAlertContentVO, onClose: (() -> ())? = nil) {
        let alret = UIAlertController(title: vo.title, message: vo.message, preferredStyle: .alert)
        let close = UIAlertAction(title: "닫기", style: .default) { _ in
            onClose?()
        }
        alret.addAction(close)
        present(alret, animated: true, completion: nil)
    }
}

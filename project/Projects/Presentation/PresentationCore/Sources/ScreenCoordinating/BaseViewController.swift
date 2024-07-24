//
//  BaseViewController.swift
//  PresentationCore
//
//  Created by choijunios on 7/23/24.
//

import UIKit
import Entity

open class BaseViewController: UIViewController { }

// MARK: Alert
extension BaseViewController {
    
    public func showAlert(vo: DefaultAlertContentVO) {
        let alret = UIAlertController(title: vo.title, message: vo.message, preferredStyle: .alert)
        let close = UIAlertAction(title: "닫기", style: .default, handler: nil)
        alret.addAction(close)
        present(alret, animated: true, completion: nil)
    }
}

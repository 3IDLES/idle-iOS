//
//  IdleSnackBarController.swift
//  DSKit
//
//  Created by choijunios on 10/3/24.
//

import Foundation


import UIKit
import PresentationCore
import RxCocoa
import RxSwift

public class IdleSnackBarController: UIViewController {
    
    // Init
    
    // View
    let snackBar = IdleSnackBar(frame: .zero)
    let bottomPadding: CGFloat
    
    
    let snackBarHeight: CGFloat = 48
    
    public init(bottomPaddingFromSafeArea: CGFloat, object: IdleSnackBarRO) {
        self.bottomPadding = bottomPaddingFromSafeArea
        super.init(nibName: nil, bundle: nil)
        
        self.snackBar.applyRO(object)
        
        setAppearance()
        setLayout()
        setObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        view.backgroundColor = .clear
    }
    
    private func setLayout() {
        view.addSubview(snackBar)
        snackBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            snackBar.heightAnchor.constraint(equalToConstant: snackBarHeight),
            snackBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            snackBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            snackBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -bottomPadding)
        ])
        
        snackBar.transform = .init(translationX: 0, y: snackBarHeight+bottomPadding)
        snackBar.alpha = 0.0
    }
    
    private func setObservable() { }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let displayingTime: CGFloat = 2
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.snackBar.transform = .identity
            self.snackBar.alpha = 1.0
        } completion: { _ in
            
            UIView.animate(withDuration: 0.2, delay: displayingTime, options: .curveEaseIn) { [weak self] in
                guard let self else { return }
                snackBar.transform = .init(translationX: 0, y: snackBarHeight+bottomPadding)
                snackBar.alpha = 0.0
            } completion: { _ in
                self.dismiss(animated: false)
            }
        }
    }
}


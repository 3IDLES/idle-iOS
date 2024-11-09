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
    let snackBar: IdleSnackBar = {
        let bar = IdleSnackBar(frame: .zero)
        bar.alpha = 0.0
        return bar
    }()
    
    let bottomPadding: CGFloat
    
    var isDismissing = false
    
    public init(bottomPaddingFromSafeArea: CGFloat, object: IdleSnackBarRO) {
        self.bottomPadding = bottomPaddingFromSafeArea
        super.init(nibName: nil, bundle: nil)
        
        self.snackBar.applyRO(object)
        
        setAppearance()
        setGesture()
        setLayout()
        setObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        view.backgroundColor = .clear
    }
    
    private func setGesture() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(gesture:)))
        view.addGestureRecognizer(recognizer)
    }
    
    private func setLayout() {
        view.addSubview(snackBar)
        snackBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            snackBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            snackBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            snackBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -bottomPadding)
        ])
    }
    
    private func setObservable() { }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        snackBar.transform = .init(translationX: 0, y: snackBar.bounds.height+bottomPadding)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.snackBar.transform = .identity
            self.snackBar.alpha = 1.0
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                self.dismissSnackBar()
            }
        }
    }
    
    @objc
    private func onTap(gesture: UITapGestureRecognizer) {
        dismissSnackBar()
    }
    
    private func dismissSnackBar() {
        
        if isDismissing { return }
        
        isDismissing = true
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) { [weak self] in
            guard let self else { return }
            snackBar.transform = .init(translationX: 0, y: snackBar.bounds.height+bottomPadding)
            snackBar.alpha = 0.0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}



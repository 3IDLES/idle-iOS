//
//  DefaultLoadingVC.swift
//  BaseFeature
//
//  Created by choijunios on 9/3/24.
//

import UIKit
import PresentationCore
import Domain
import DSKit


import RxCocoa
import RxSwift

public class DefaultLoadingView: UIView {
    
    let indicator: UIActivityIndicatorView = .init()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setAppearance()
        setLayout()
        indicator.startAnimating()
    }
    
    public required init?(coder: NSCoder) { nil }
    
    private func setAppearance() {
        self.backgroundColor = DSColor.gray050.color.withAlphaComponent(0.5)
    }
    
    private func setLayout() {
        [
            indicator
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
}

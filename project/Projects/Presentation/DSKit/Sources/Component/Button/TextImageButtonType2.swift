//
//  TextImageButtonType2.swift
//  DSKit
//
//  Created by choijunios on 7/31/24.
//

import UIKit
import RxSwift
import RxCocoa

/// 수평 버튼입니다.
public class TextImageButtonType2: TappableUIView {
    
    public let textLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.textColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    public let imageView: UIImageView = {
        DSKitAsset.Icons.chevronDown.image.toView()
    }()
    
    private let disposeBag = DisposeBag()
    
    public override init() {
        super.init()
        
        setAppearance()
        setLayout()
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        backgroundColor = .white
        layer.borderWidth = 1
        layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        layer.cornerRadius = 6
        layoutMargins = .init(top: 10, left: 16, bottom: 10, right: 16)
    }
    
    private func setLayout() {
        
        let stack = HStack(
            [
                textLabel,
                imageView
            ],
            alignment: .fill,
            distribution: .equalSpacing
        )
        
        [
            stack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            imageView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            
            textLabel.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
        ])
    }
    
    private func setObservable() {
        self.rx.tap
            .subscribe { [weak self] _ in
                self?.alpha = 0.5
                UIView.animate(withDuration: 0.35) { [weak self] in
                    self?.alpha = 1
                }
            }
            .disposed(by: disposeBag)
    }
}

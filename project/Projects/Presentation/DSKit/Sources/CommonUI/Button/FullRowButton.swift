//
//  FullRowButton.swift
//  DSKit
//
//  Created by choijunios on 8/19/24.
//

import UIKit
import RxSwift
import RxCocoa

public class FullRowButton: TappableUIView {
    
    let label: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.attrTextColor = DSColor.gray500.color
        return label
    }()
    
    let disposeBag = DisposeBag()
    
    public init(labelText: String) {
        self.label.textString = labelText
        super.init()
        setApearance()
        setLayout()
        setObservable()
    }
    required init?(coder: NSCoder) { return nil }
    
    private func setApearance() {
        self.backgroundColor = DSColor.gray0.color
    }
    private func setLayout() {
        
        self.layoutMargins = .init(
            top: 12,
            left: 20,
            bottom: 12,
            right: 20
        )
        
        let chevronImage = DSIcon.chevronRight.image.toView()
        chevronImage.tintColor = DSColor.gray200.color
        let mainStack = HStack([
            label,
            Spacer(),
            chevronImage
        ], alignment: .center, distribution: .fill)
        
        [
            mainStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            mainStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
    }
    private func setObservable() {
        self.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.backgroundColor = DSColor.gray050.color
                UIView.animate(withDuration: 0.35) {
                    self?.backgroundColor = DSColor.gray0.color
                }
            })
            .disposed(by: disposeBag)
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    FullRowButton(labelText: "내 프로필")
}

//
//  IdleUnderLineLabelButton.swift
//  DSKit
//
//  Created by choijunios on 8/19/24.
//

import UIKit
import RxSwift
import RxCocoa

public class IdleUnderLineLabelButton: TappableUIView {
    
    let label: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.attrTextColor = DSColor.gray300.color
        label.setAttr(attr: .underlineStyle, value: NSUnderlineStyle.single.rawValue)
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

        [
            label
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.leftAnchor.constraint(equalTo: self.leftAnchor),
            label.rightAnchor.constraint(equalTo: self.rightAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    private func setObservable() {
        self.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.label.alpha = 0.5
                UIView.animate(withDuration: 0.35) {
                    self?.label.alpha = 1.0
                }
            })
            .disposed(by: disposeBag)
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    IdleUnderLineLabelButton(labelText: "로그아웃")
}

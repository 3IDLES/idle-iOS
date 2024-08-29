//
//  IdleFloatingButton.swift
//  DSKit
//
//  Created by choijunios on 8/29/24.
//

import UIKit
import RxSwift
import RxCocoa

public class IdleFloatingButton: TappableUIView {
    
    // Init
    
    // View
    public let imageView: UIImageView = {
        let view = UIImageView()
        view.image = DSIcon.plus.image
        return view
    }()
    public let label: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle3)
        label.attrTextColor = DSColor.gray0.color
        return label
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(labelText: String) {
        self.label.textString = labelText
        super.init()
        
        setApearance()
        setAutoLayout()
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let hegiht = self.bounds.height
        self.layer.cornerRadius = hegiht/2
    }
    
    private func setApearance() {
        // InitialSetting
        self.backgroundColor = DSColor.gray700.color
    }
    
    private func setAutoLayout() {
        self.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        let contentStack = HStack([
            imageView, label
        ], spacing: 6, alignment: .center)
        [
            contentStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            contentStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor),
            contentStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor),
            contentStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        
        self.rx.tap
            .subscribe { [weak self] _ in
                guard let self else { return }
                self.alpha = 0.7
                UIView.animate(withDuration: 0.3) {
                    self.alpha = 1
                }
            }
            .disposed(by: disposeBag)
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    IdleFloatingButton(labelText: "공고 등록")
}

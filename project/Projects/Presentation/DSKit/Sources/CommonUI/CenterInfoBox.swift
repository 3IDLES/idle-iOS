//
//  CenterInfoBox.swift
//  DSKit
//
//  Created by choijunios on 7/7/24.
//

import UIKit
import RxSwift
import Entity

public class InfoBox: UIView {
    
    public typealias KeyValue = (key: String, value: String)
    
    // init paramters
    public let titleText: BehaviorSubject<String> = .init(value: "")
    public let items: BehaviorSubject<[KeyValue]> = .init(value: [])
    
    // View
    private let titleLabel: ResizableUILabel = {
        
       let label = ResizableUILabel()
        
        label.textColor = DSKitAsset.Colors.gray900.color
        label.font = DSKitFontFamily.Pretendard.semiBold.font(size: 16)
        
        return label
    }()
    
    private let mainStack: UIStackView = {
        
        let mainStack = UIStackView()
        
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.spacing = 4
        
        return mainStack
    }()
    
    private let keyValueStack: UIStackView = {
        
        let keyValueStack = UIStackView()
        
        keyValueStack.axis = .horizontal
        keyValueStack.spacing = 8
        
        return keyValueStack
    }()
    
    private let keyStack: UIStackView = {
        
        let keyStack = UIStackView()
        
        keyStack.axis = .vertical
        keyStack.alignment = .leading
        keyStack.spacing = 4
        
        return keyStack
    }()
    
    private let valueStack: UIStackView = {
        
        let valueStack = UIStackView()
        
        valueStack.axis = .vertical
        valueStack.alignment = .leading
        valueStack.spacing = 4
        
        return valueStack
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(titleText: String, items: [KeyValue]) {
        
        super.init(frame: .zero)
        
        setAppearance()
        setAutoLayout()
        setObservable()
        
        update(titleText: titleText, items: items)
    }
    
    required init(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        
        self.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        
        self.layoutMargins = .init(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    private func setAutoLayout() {
        
        // keyValueStack
        [
            keyStack,
            valueStack,
        ].forEach {
            keyValueStack.addArrangedSubview($0)
        }
        
        keyStack.setContentCompressionResistancePriority(.init(751), for: .horizontal)
        valueStack.setContentCompressionResistancePriority(.init(750), for: .horizontal)
        
        // mainStack
        mainStack.addArrangedSubview(titleLabel)
        if keyStack.arrangedSubviews.count > 0 {
            mainStack.addArrangedSubview(keyValueStack)
        }
        
        [
            mainStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        
        // titleText
        titleText
            .subscribe(onNext: { [weak self]  in
                self?.titleLabel.text = $0
            })
            .disposed(by: disposeBag)
        
        // keyValueStack
        items
            .subscribe(onNext: { [weak self] items in
                
                self?.keyStack.removeAllArrangedSubviews()
                self?.valueStack.removeAllArrangedSubviews()
                
                items
                    .forEach { (key, value) in
                        let keyLabel = ResizableUILabel()
                        
                        keyLabel.text = key
                        keyLabel.textColor = DSKitAsset.Colors.gray300.color
                        keyLabel.font = DSKitFontFamily.Pretendard.medium.font(size: 14)
                        
                        self?.keyStack.addArrangedSubview(keyLabel)
                        
                        let valueLabel = ResizableUILabel()
                        
                        valueLabel.text = value
                        valueLabel.textColor = DSKitAsset.Colors.gray900.color
                        valueLabel.font = DSKitFontFamily.Pretendard.medium.font(size: 14)
                        
                        self?.valueStack.addArrangedSubview(valueLabel)
                    }
            })
            .disposed(by: disposeBag)
    }
    
    public func update(titleText: String, items: [KeyValue]) {
        
        self.titleText.onNext(titleText)
        self.items.onNext(items)
    }
}

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        let arrangedSubviews = self.arrangedSubviews
        
        for subview in arrangedSubviews {
            self.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
}

//
//  TextImageButtonType1.swift
//  DSKit
//
//  Created by choijunios on 7/16/24.
//

import UIKit
import RxSwift
import RxCocoa

/// 이미지어ㅏ 텍스트가 수직으로 배치되는 버튼입니다.
public class TextImageButtonType1: UIView {
    
    private var tapGesture: UITapGestureRecognizer!
    
    public var eventPublisher: Signal<Void> { tapGesture.rx.event.asSignal().map { _ in () } }
    
    private let title: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle2)
        label.attrTextColor = DSKitAsset.Colors.gray900.color
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let labelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .cyan
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let contentStack: UIStackView = {
       
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.distribution = .fill
        return stack
    }()
    
    public init(
        titleText: String,
        labelImage: UIImage
    ) {
        
        super.init(frame: .zero)
        
        self.title.textString = titleText
        self.labelImageView.image = labelImage
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTouchAction))
        self.addGestureRecognizer(tapGesture)
        
        setApearance()
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setApearance() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        
        self.layoutMargins = .init(top: 37, left: 0, bottom: 37, right: 0)
    }
    
    func setAutoLayout() {
        
        [
            title,
            labelImageView
        ].forEach {
            contentStack.addArrangedSubview($0)
        }
        
        [
            contentStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            labelImageView.widthAnchor.constraint(equalToConstant: 68),
            labelImageView.heightAnchor.constraint(equalTo: labelImageView.widthAnchor),
            
            contentStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    @objc
    func onTouchAction(_ tapGesture: UITapGestureRecognizer) {
        
        self.alpha = 0.3
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.alpha = 1
        }
    }
}
    

//
//  BottomSheetButton.swift
//  DSKit
//
//  Created by choijunios on 8/28/24.
//

import UIKit
import RxCocoa
import RxSwift

public class BottomSheetButton: TappableUIView {
    
    // State
    public private(set) var isEnabled: Bool = true
    
    // Init
    
    // View
    let imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle3)
        return label
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(image: UIImage, titleText: String, imageColor: UIColor, textColor: UIColor) {
        self.imageView.image = image
        self.imageView.tintColor = imageColor
        self.titleLabel.textString = titleText
        self.titleLabel.attrTextColor = textColor
        
        super.init()
        
        setApearance()
        setAutoLayout()
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setApearance() {
        self.backgroundColor = DSColor.gray0.color
        self.layer.setGrayBorder(radius: 8)
    }
    
    private func setAutoLayout() {
        
        self.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        let mainStack = HStack([
            imageView,
            titleLabel,
            Spacer()
        ],spacing: 4, alignment: .center)
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        self.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
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
                self?.alpha = 0.5
                UIView.animate(withDuration: 0.35) {
                    self?.alpha = 1
                }
            })
            .disposed(by: disposeBag)
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    BottomSheetButton(
        image: DSIcon.postCheck.image,
        titleText: "채용 종료하기",
        imageColor: DSColor.red100.color,
        textColor: DSColor.red100.color
    )
}

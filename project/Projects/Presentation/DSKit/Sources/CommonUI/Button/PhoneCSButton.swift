//
//  PhoneCSButton.swift
//  DSKit
//
//  Created by choijunios on 8/8/24.
//

import UIKit
import RxSwift
import RxCocoa

public class PhoneCSButton: TappableUIView {
    
    // State
    public private(set) var isEnabled: Bool = true
    
    // Init
    
    // View
    let nameLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        return label
    }()
    let phoneNumberLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        return label
    }()
    
    
    private let disposeBag = DisposeBag()
    
    public override init() {
        
        super.init()
        
        setApearance()
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setApearance() {
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        self.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    private func setAutoLayout() {
        let phoneCallImage = DSKitAsset.Icons.csPhoneCall.image.toView()
        let phoneCallStack = HStack([
            phoneCallImage,
            {
                let label = IdleLabel(typography: .Subtitle3)
                label.textString = "전화로 문의하기"
                label.textAlignment = .left
                return label
            }(),
            Spacer()
        ],spacing: 4, alignment: .center)
        
        NSLayoutConstraint.activate([
            phoneCallImage.widthAnchor.constraint(equalToConstant: 24),
            phoneCallImage.heightAnchor.constraint(equalTo: phoneCallImage.widthAnchor),
        ])
        
        let divier = UIView()
        divier.backgroundColor = DSKitAsset.Colors.gray100.color
        
        let centerInfoStack = HStack(
            [
                nameLabel,
                divier,
                phoneNumberLabel,
                Spacer()
            ],
            spacing: 5,
            alignment: .center
        )
        NSLayoutConstraint.activate([
            divier.topAnchor.constraint(equalTo: centerInfoStack.topAnchor, constant: 2),
            divier.bottomAnchor.constraint(equalTo: centerInfoStack.bottomAnchor, constant: -2),
            divier.widthAnchor.constraint(equalToConstant: 1)
        ])
        
        let mainStack = VStack([
            phoneCallStack, centerInfoStack
        ], alignment: .fill)
        
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
    
    public func bind(nameText: String, phoneNumberText: String) {
        
        self.nameLabel.textString = nameText
        self.phoneNumberLabel.textString = phoneNumberText
        
        self
            .rx.tap
            .subscribe(onNext: {
                
                if let phoneURL = URL(string: "tel://\(phoneNumberText)"), UIApplication.shared.canOpenURL(phoneURL) {
                            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
                        }
            })
            .disposed(by: disposeBag)
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    let view = PhoneCSButton()
    view.bind(nameText: "세얼간이", phoneNumberText: "010-4444-5555")
    return view
}

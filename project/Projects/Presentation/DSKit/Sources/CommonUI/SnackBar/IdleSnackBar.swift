//
//  IdleSnackBar.swift
//  DSKit
//
//  Created by choijunios on 9/12/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public struct IdleSnackBarRO {
    let titleText: String
    let icon: UIImage?
    let backgroundColor: UIColor?
    
    public init(
        titleText: String="완료되었습니다.",
        icon: UIImage?=DSIcon.successCheck.image,
        backgroundColor: UIColor?=DSColor.gray500.color
    ) {
        self.titleText = titleText
        self.icon = icon
        self.backgroundColor = backgroundColor
    }
}

public class IdleSnackBar: UIView {
    
    private let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.attrTextColor = DSColor.gray0.color
        return label
    }()
    
    private let titleIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = DSColor.gray0.color
        return imageView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setAppearance()
        setLayout()
    }
    
    public required init?(coder: NSCoder) { nil }
    
    func setAppearance() {
        self.backgroundColor = DSColor.gray500.color
        self.layer.cornerRadius = 8
    }
    
    func setLayout() {
        
        self.layoutMargins = .init(top: 12, left: 16, bottom: 12, right: 16)
        
        let mainStack = HStack([
            titleIcon, titleLabel, Spacer()
        ], spacing: 4, alignment: .center)
        
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
    
    public func applyRO(_ ro: IdleSnackBarRO) {
        self.backgroundColor = ro.backgroundColor
        titleLabel.textString = ro.titleText
        titleIcon.image = ro.icon
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    let view = IdleSnackBar(
        frame: .init(
            origin: .init(x: 20, y: 300),
            size: .init(width: 300, height: 48)
        )
    )
    
    DispatchQueue.main.asyncAfter(deadline: .now()+3) {
        
        UIView.animate(withDuration: 0.35) {
            view.alpha = 0
        }
    }
    return view
}

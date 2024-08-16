//
//  CenterInfoCardView.swift
//  DSKit
//
//  Created by choijunios on 8/8/24.
//

import UIKit
import PresentationCore
import RxCocoa
import RxSwift
import Entity

public class CenterInfoCardView: TappableUIView {
    
    // Init
    
    // View
    let nameLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle3)
        return label
    }()
    let locationLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public override init() {
        super.init()
        setAppearance()
        setLayout()
        setObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        self.backgroundColor = .white
        self.layoutMargins = .init(top: 18, left: 20, bottom: 20, right: 18)
        self.layer.setGrayBorder(radius: 8)
        
    }
    
    private func setLayout() {
        
        let locationImageView = DSKitAsset.Icons.location.image.toView()
        locationImageView.tintColor = DSColor.gray400.color
        let locationStack = HStack(
            [
                locationImageView,
                locationLabel
            ],
            spacing: 2
        )
        
        let labelStack = VStack([nameLabel,locationStack], spacing: 4, alignment: .leading)
        
        let chevronLeftImage = DSKitAsset.Icons.chevronRight.image.toView()
        chevronLeftImage.tintColor = DSKitAsset.Colors.gray200.color
        
        NSLayoutConstraint.activate([
            locationImageView.widthAnchor.constraint(equalToConstant: 20),
            locationImageView.heightAnchor.constraint(equalTo: locationImageView.widthAnchor),
            
            chevronLeftImage.widthAnchor.constraint(equalToConstant: 24),
            chevronLeftImage.heightAnchor.constraint(equalTo: chevronLeftImage.widthAnchor),
        ])
        
        let mainStack = HStack(
            [
                labelStack,
                Spacer(),
                chevronLeftImage
            ],
            alignment: .center,
            distribution: .fill
        )
        
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
        
    }
    
    public func bind(nameText: String, locationText: String) {
        self.nameLabel.textString = nameText
        self.locationLabel.textString = locationText
    }
}

public extension CALayer {
    
    func setGrayBorder(radius: CGFloat = 8) {
        self.cornerRadius = radius
        self.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        self.borderWidth = 1
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    let view = CenterInfoCardView()
    view.bind(nameText: "세얼간이 요양보호소", locationText: "용인시 어쩌고 저쩌고")
    return view
}

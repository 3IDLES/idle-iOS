//
//  CenterProfileButton.swift
//  DSKit
//
//  Created by choijunios on 7/27/24.
//

import UIKit
import RxSwift
import RxCocoa

public class CenterProfileButton: TappableUIView {
    
    // Init
    public let nameString: String
    public let locatonString: String
    public let isArrow: BehaviorRelay<Bool>
    
    // View
    public private(set) lazy var nameLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle3)
        label.textString = nameString
        label.textAlignment = .left
        return label
    }()
    
    public private(set) lazy var addressLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.textString = locatonString
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.textAlignment = .left
        return label
    }()
    
    private let chevronRightImage: UIImageView = {
        let image = DSKitAsset.Icons.chevronRight.image.toView()
        image.tintColor = DSKitAsset.Colors.gray200.color
        return image
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(nameString: String, locatonString: String, isArrow: Bool = false) {
        self.nameString = nameString
        self.locatonString = locatonString
        self.isArrow = .init(value: isArrow)
        
        super.init()
        
        setApearance()
        setLayout()
        setObservable()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setApearance() {
        
        self.backgroundColor = .white
        self.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        
        self.layoutMargins = .init(top: 16, left: 20, bottom: 16, right: 20)
    }
    
    private func setLayout() {
        
        let locImage = DSKitAsset.Icons.location.image.toView()
        let locationStack = HStack(
            [
                locImage,
                addressLabel,
            ],
            spacing: 2,
            distribution: .fill
        )
        locImage.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locImage.widthAnchor.constraint(equalToConstant: 20),
            locImage.heightAnchor.constraint(equalTo: locImage.widthAnchor),
            
            addressLabel.heightAnchor.constraint(equalTo: locImage.heightAnchor)
        ])
        
        let textStack = VStack(
            [
                nameLabel,
                locationStack
            ],
            spacing: 4,
            alignment: .leading
        )
        
        let mainStack = HStack(
            [
                textStack,
                chevronRightImage
            ],
            spacing: 14,
            alignment: .center
        )
        NSLayoutConstraint.activate([
            chevronRightImage.widthAnchor.constraint(equalToConstant: 24),
            chevronRightImage.heightAnchor.constraint(equalTo: locImage.widthAnchor),
        ])
        
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
        super.rx.tap
            .subscribe { [weak self] _ in
                
                self?.alpha = 0.5
                
                UIView.animate(withDuration: 0.2) {
                    self?.alpha = 1
                }
            }
            .disposed(by: disposeBag)
        
        isArrow
            .map { !$0 }
            .bind(to: chevronRightImage.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

//
//  ImagePrefixButton.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa

public class ImageTextButton: TappableUIView {
    
    public enum ImagePose {
        case prefix
        case postfix
    }
    
    let imagePose: ImagePose
    
    let icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    public let label: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        return label
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(iconImage: UIImage, position: ImagePose) {
        self.imagePose = position
        super.init()
        
        icon.image = iconImage
        
        setAppearance()
        setLayout()
        setObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        
    }
    
    private func setLayout() {
        let mainStack = imagePose == .prefix ? HStack([
            icon,
            label
        ], spacing: 2, alignment: .center) : HStack([
            label,
            icon
        ], spacing: 2, alignment: .center)
        
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor),
        ])
        
        [
            mainStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(mainStack)
        }
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.topAnchor),
            mainStack.leftAnchor.constraint(equalTo: self.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: self.rightAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        self.rx.tap
            .subscribe { [weak self] _ in
                self?.alpha = 0.5
                UIView.animate(withDuration: 0.35) { [weak self] in
                    self?.alpha = 1.0
                }
            }
            .disposed(by: disposeBag)
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    let btn = ImageTextButton(
        iconImage: DSKitAsset.Icons.editPhoto.image,
        position: .postfix
    )
    btn.label.textString = "공고 수정"
    btn.tintColor = .black
    return btn
}


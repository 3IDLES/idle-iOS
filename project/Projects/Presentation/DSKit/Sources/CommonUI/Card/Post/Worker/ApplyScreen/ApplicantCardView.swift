//
//  ApplicantCardView.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//

import UIKit
import PresentationCore
import RxCocoa
import RxSwift
import Entity

public class ApplicantCardView: UIView {
    
    // View
    // Profile
    let profileImageContainer: UIImageView = {
        
        let view = UIImageView()
        view.backgroundColor = DSKitAsset.Colors.orange100.color
        view.layer.cornerRadius = 36
        view.clipsToBounds = true
        view.image = DSKitAsset.Icons.workerProfilePlaceholder.image
        view.contentMode = .scaleAspectFit

        return view
    }()
    let workerProfileImage: UIImageView = {
        
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 36
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    // Star
    public let starButton: IconWithColorStateButton = {
        let button = IconWithColorStateButton(
            representImage: DSKitAsset.Icons.subscribeStar.image,
            normalColor: DSKitAsset.Colors.gray200.color,
            accentColor: DSKitAsset.Colors.orange300.color
        )
        return button
    }()
    
    // Row1
    let workingTag: TagLabel = {
       let label = TagLabel(
        text: "",
        typography: .caption,
        textColor: DSKitAsset.Colors.orange500.color,
        backgroundColor: DSKitAsset.Colors.orange100.color
       )
        return label
    }()
    
    // Row2
    let nameLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle2)
        
        return label
    }()
    let infoLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    let expLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init(frame: .zero)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            starButton.widthAnchor.constraint(equalToConstant: 22),
            starButton.heightAnchor.constraint(equalTo: starButton.widthAnchor),
        ])
    }
    
    private func setObservable() {
        
    }
    
}

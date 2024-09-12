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
import Kingfisher
import Entity

public struct ApplicantCardRO {
    
    public let profileUrl: URL?
    public let isJobFinding: Bool
//    public let isStared: Bool
    public let name: String
    public let ageText: String
    public let genderText: String
    public let expText: String
    
    public init(
        profileUrl: URL?,
        isJobFinding: Bool,
//        isStared: Bool,
        name: String,
        ageText: String,
        genderText: String,
        expText: String
    ) {
        self.profileUrl = profileUrl
        self.isJobFinding = isJobFinding
//        self.isStared = isStared
        self.name = name
        self.ageText = ageText
        self.genderText = genderText
        self.expText = expText
    }
    
    public static let mock: ApplicantCardRO = .init(
        profileUrl: URL(string: "https://dummyimage.com/600x400/00ffbf/0011ff&text=worker+profile"),
        isJobFinding: false,
//        isStared: false,
        name: "홍길동",
        ageText: "51세",
        genderText: "여성",
        expText: "1년차"
    )
    
    public static func create(vo: PostApplicantVO) -> ApplicantCardRO {
        .init(
            profileUrl: vo.profileUrl,
            isJobFinding: vo.isJobFinding,
//            isStared: vo.isStared,
            name: vo.name,
            ageText: "\(vo.age)세",
            genderText: vo.gender.twoLetterKoreanWord,
            expText: vo.expYear == nil ? "신입" : "\(vo.expYear!)년차"
        )
    }
}

public protocol ApplicantCardViewModelable {
    
    // - Buttons
    var showProfileButtonClicked: PublishRelay<Void> { get }
    var employButtonClicked: PublishRelay<Void> { get }
    var staredThisWorker: PublishRelay<Bool> { get }
    
    // Output
    var renderObject: Driver<ApplicantCardRO>? { get }
}

public class ApplicantCard: UIView {
    
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
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    // Star
//    public let starButton: IconWithColorStateButton = {
//        let button = IconWithColorStateButton(
//            representImage: DSKitAsset.Icons.subscribeStar.image,
//            normalColor: DSKitAsset.Colors.gray200.color,
//            accentColor: DSKitAsset.Colors.orange300.color
//        )
//        return button
//    }()
    
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
    
    // Row3
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
    
    // 버튼들
    let showProfileButton: IdleSecondaryButton = {
        let button = IdleSecondaryButton(level: .medium)
        button.label.textString = "프로필 보기"
        return button
    }()
//    let employButton: IdlePrimaryButton = {
//        let button = IdlePrimaryButton(level: .medium)
//        button.label.textString = "채용하기"
//        return button
//    }()
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init(frame: .zero)
        setAppearance()
        setLayout()
        setObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        self.backgroundColor = .white
        self.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 12
    }
    
    private func setLayout() {
        
        self.layoutMargins = .init(top: 12, left: 16, bottom: 12, right: 16)
        
        profileImageContainer.addSubview(workerProfileImage)
        workerProfileImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            profileImageContainer.widthAnchor.constraint(equalToConstant: 72),
            profileImageContainer.heightAnchor.constraint(equalTo: profileImageContainer.widthAnchor),
            
            workerProfileImage.topAnchor.constraint(equalTo: profileImageContainer.topAnchor),
            workerProfileImage.leftAnchor.constraint(equalTo: profileImageContainer.leftAnchor),
            workerProfileImage.rightAnchor.constraint(equalTo: profileImageContainer.rightAnchor),
            workerProfileImage.bottomAnchor.constraint(equalTo: profileImageContainer.bottomAnchor),
        ])
        
        let nameTitleLabel: IdleLabel = .init(typography: .Body3)
        nameTitleLabel.textString = "요양보호사"
        
        let nameStack = HStack([
            nameLabel,
            nameTitleLabel,
        ], spacing: 2, alignment: .center)
        
        let divider = UIView()
        divider.backgroundColor = DSKitAsset.Colors.gray300.color
        let detailWorkerInfoStack = HStack([
            infoLabel,
            divider,
            expLabel,
        ], spacing: 8)
        
        NSLayoutConstraint.activate([
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.topAnchor.constraint(equalTo: detailWorkerInfoStack.topAnchor, constant: 3),
            divider.bottomAnchor.constraint(equalTo: detailWorkerInfoStack.bottomAnchor, constant: -3),
        ])
        
        let labelStack = VStack([
            workingTag,
            nameStack,
            detailWorkerInfoStack,
        ], spacing: 2, alignment: .leading)
        
        let workerInfoStack = HStack([
            profileImageContainer,
            labelStack,
            Spacer(),
//            starButton
        ], spacing: 16, alignment: .top)
        
//        NSLayoutConstraint.activate([
//            starButton.widthAnchor.constraint(equalToConstant: 22),
//            starButton.heightAnchor.constraint(equalTo: starButton.widthAnchor),
//        ])
        
        let buttonStack = HStack([
            showProfileButton, 
//            employButton
        ], spacing: 8, distribution: .fillEqually)
        
        let mainStack = VStack([
            workerInfoStack,
            buttonStack
        ], spacing: 12, alignment: .fill)
        
        [
            mainStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            mainStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        
    }
    
    public func bind(ro: ApplicantCardRO) {
        
        if let imageUrl = ro.profileUrl {
            workerProfileImage
                .setImage(url: imageUrl)
        }
        
        workingTag.textString = ro.isJobFinding ? "구직중" : "휴식중"
//        starButton.setState(ro.isStared ? .accent : .normal)
        nameLabel.textString = ro.name
        infoLabel.textString = "\(ro.ageText) \(ro.genderText)"
        expLabel.textString = "\(ro.expText)"
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    let cardView = ApplicantCard()
    cardView.bind(ro: .mock)
    return cardView
}

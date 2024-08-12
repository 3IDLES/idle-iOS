//
//  CenterEmployCard.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public struct CenterEmployCardRO {
    public let startDay: String
    public let endDay: String
    public let postTitle: String
    public let nameText: String
    public let careGradeText: String
    public let ageText: String
    public let genderText: String
    public let applicantCount: Int
    
    public init(startDay: String, endDay: String, postTitle: String, nameText: String, careGradeText: String, ageText: String, genderText: String, applicantCount: Int) {
        self.startDay = startDay
        self.endDay = endDay
        self.postTitle = postTitle
        self.nameText = nameText
        self.careGradeText = careGradeText
        self.ageText = ageText
        self.genderText = genderText
        self.applicantCount = applicantCount
    }
    
    static let mock: CenterEmployCardRO = .init(
        startDay: "2024. 07. 10",
        endDay: "2024. 07. 31",
        postTitle: "서울특별시 강남구 신사동",
        nameText: "홍길동",
        careGradeText: "1등급",
        ageText: "78세",
        genderText: "여성",
        applicantCount: 2
    )
}

public protocol CenterEmployCardViewModelable {
    
    // Output
    var renderObject: Driver<CenterEmployCardRO>? { get }
    
    // Input
    var postCardClicked: PublishRelay<Void> { get }
    
    // - Buttons
    var checkApplicantBtnClicked: PublishRelay<Void> { get }
    var editPostBtnClicked: PublishRelay<Void> { get }
    var terminatePostBtnClicked: PublishRelay<Void> { get }
}

public class CenterEmployCard: TappableUIView {
    
    // Init
    
    // View
    
    // Row1
    let durationLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray300.color
        return label
    }()
    
    // Row2
    let postTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle2)
        return label
    }()
    
    // Row3
    let nameLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    let informationLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    // Row4
    let checkApplicantsButton: IdlePrimaryCardButton = {
        let btn = IdlePrimaryCardButton(level: .medium)
        btn.label.textString = ""
        return btn
    }()
    
    // Row5
    let editPostButton: ImagePrefixButton = {
        let button = ImagePrefixButton(
            iconImage: DSKitAsset.Icons.postEdit.image
        )
        button.icon.tintColor = DSKitAsset.Colors.gray300.color
        button.label.textString = "공고 수정"
        button.label.attrTextColor = DSKitAsset.Colors.gray500.color
        
        return button
    }()
    let terminatePostButton: ImagePrefixButton = {
        let button = ImagePrefixButton(
            iconImage: DSKitAsset.Icons.postCheck.image
        )
        button.icon.tintColor = DSKitAsset.Colors.gray300.color
        button.label.textString = "채용 종료"
        button.label.attrTextColor = DSKitAsset.Colors.gray500.color
        
        return button
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
        self.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 12
    }
    
    private func setLayout() {
        
        self.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        // InfoLabel
        let divider = UIView()
        divider.backgroundColor = DSKitAsset.Colors.gray300.color
        let infoStack = HStack([
            nameLabel,
            divider,
            informationLabel,
        ], spacing: 8)
            
        NSLayoutConstraint.activate([
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.topAnchor.constraint(equalTo: infoStack.topAnchor, constant: 5),
            divider.bottomAnchor.constraint(equalTo: infoStack.bottomAnchor, constant: -5),
        ])
        
        let textStack = VStack([
            durationLabel,
            Spacer(height: 4),
            postTitleLabel,
            Spacer(height: 2),
            infoStack,
        ], alignment: .leading)
        
        let buttonStack = HStack([
            editPostButton,
            terminatePostButton,
        ], spacing: 4)
        
        let contentStack = VStack([
            HStack([textStack, Spacer()]),
            Spacer(height: 12),
            checkApplicantsButton,
            HStack([buttonStack, Spacer()])
        ], alignment: .fill)
        
        [
            contentStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            contentStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor),
            contentStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor),
            contentStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    private func setObservable() { }
    
    public func binc(ro: CenterEmployCardRO) {
        
        durationLabel.textString = "\(ro.startDay) ~ \(ro.endDay)"
        postTitleLabel.textString = ro.postTitle
        nameLabel.textString = ro.nameText
        informationLabel.textString = "\(ro.careGradeText) \(ro.ageText) \(ro.genderText)"
        checkApplicantsButton.label.textString = "지원자 \(ro.applicantCount)명 조회"
    }
}

fileprivate class TextVM: CenterEmployCardViewModelable {

    public let publishObect: PublishRelay<CenterEmployCardRO> = .init()
    
    var renderObject: RxCocoa.Driver<CenterEmployCardRO>?
    
    var postCardClicked: RxRelay.PublishRelay<Void> = .init()
    var checkApplicantBtnClicked: RxRelay.PublishRelay<Void> = .init()
    var editPostBtnClicked: RxRelay.PublishRelay<Void> = .init()
    var terminatePostBtnClicked: RxRelay.PublishRelay<Void> = .init()
    
    init() {
        
        renderObject = publishObect.asDriver(onErrorJustReturn: .mock)
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    let btn = CenterEmployCard()
    btn.binc(ro: .mock)
    
    return btn
}

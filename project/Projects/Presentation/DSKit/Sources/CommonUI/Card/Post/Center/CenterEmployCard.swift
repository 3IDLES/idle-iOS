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
    public let postState: PostState?
    
    public init(startDay: String, endDay: String, postTitle: String, nameText: String, careGradeText: String, ageText: String, genderText: String, postState: PostState? = nil) {
        self.startDay = startDay
        self.endDay = endDay
        self.postTitle = postTitle
        self.nameText = nameText
        self.careGradeText = careGradeText
        self.ageText = ageText
        self.genderText = genderText
        self.postState = postState
    }
    
    public static let mock: CenterEmployCardRO = .init(
        startDay: "2024. 07. 10",
        endDay: "2024. 07. 31",
        postTitle: "서울특별시 강남구 신사동",
        nameText: "홍길동",
        careGradeText: "1등급",
        ageText: "78세",
        genderText: "여성",
        postState: .closed
    )
    
    public static func create(_ vo: CenterEmployCardVO) -> CenterEmployCardRO {
        .init(
            startDay: vo.startDay,
            endDay: vo.endDay ?? "채용 시까지",
            postTitle: vo.postTitle,
            nameText: vo.name,
            careGradeText: "\(vo.careGrade.textForCellBtn)등급",
            ageText: "\(vo.age)세",
            genderText: vo.gender.twoLetterKoreanWord
        )
    }
    
    public static func create(vo: RecruitmentPostInfoForCenterVO) -> CenterEmployCardRO {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDay = dateFormatter.string(from: vo.createdAt)
        let endDay = vo.applyDeadline == nil ? "채용 시까지" : dateFormatter.string(from: vo.applyDeadline!)
         
        var splittedAddress = vo.roadNameAddress.split(separator: " ")
        
        if splittedAddress.count >= 3 {
            splittedAddress = Array(splittedAddress[0..<3])
        }
        let addressTitle = splittedAddress.joined(separator: " ")
        
        return .init(
            startDay: startDay,
            endDay: endDay,
            postTitle: addressTitle,
            nameText: vo.clientName,
            careGradeText: vo.careLevel.textForCellBtn,
            ageText: String(vo.age),
            genderText: vo.gender.twoLetterKoreanWord,
            postState: vo.state
        )
    }
}

public protocol CenterEmployCardViewModelable {
    
    // Output
    var renderObject: CenterEmployCardRO { get }
    var applicantCountText: Driver<String>? { get }
    
    // Input
    var cardClicked: PublishRelay<Void> { get }
    
    // - Buttons
    var checkApplicantBtnClicked: PublishRelay<Void> { get }
    var editPostBtnClicked: PublishRelay<Void> { get }
    var terminatePostBtnClicked: PublishRelay<Void> { get }
}

public class CenterEmployCard: TappableUIView {
        
    // View
    
    // Row1, 2, 3 View
    let centerEmployCardInfoView = CenterEmployCardInfoView()
    
    
    // Row4
    let checkApplicantsButton: IdlePrimaryCardButton = {
        let btn = IdlePrimaryCardButton(level: .medium)
        btn.label.textString = ""
        return btn
    }()
    
    // Row5
    let editPostButton: ImageTextButton = {
        let button = ImageTextButton(
            iconImage: DSKitAsset.Icons.postEdit.image,
            position: .prefix
        )
        button.icon.tintColor = DSKitAsset.Colors.gray300.color
        button.label.textString = "공고 수정"
        button.label.attrTextColor = DSKitAsset.Colors.gray500.color
        
        return button
    }()
    let terminatePostButton: ImageTextButton = {
        let button = ImageTextButton(
            iconImage: DSKitAsset.Icons.postCheck.image,
            position: .prefix
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
    
        let buttonStack = HStack([
            editPostButton,
            terminatePostButton,
        ], spacing: 4)
        
        let contentStack = VStack([
            HStack([centerEmployCardInfoView, Spacer()]),
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
    
    public func bind(ro: CenterEmployCardRO) {
        
        centerEmployCardInfoView.durationLabel.textString = "\(ro.startDay) ~ \(ro.endDay)"
        centerEmployCardInfoView.postTitleLabel.textString = ro.postTitle
        centerEmployCardInfoView.nameLabel.textString = ro.nameText
        centerEmployCardInfoView.informationLabel.textString = "\(ro.careGradeText) \(ro.ageText) \(ro.genderText)"
    }
}

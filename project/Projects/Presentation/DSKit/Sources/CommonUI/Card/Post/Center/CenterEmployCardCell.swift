//
//  CenterEmployCardCell.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

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

public class CenterEmployCardCell: UITableViewCell {
    
    var viewModel: CenterEmployCardViewModelable?
    
    public static let identifier = String(describing: CenterEmployCardCell.self)
    
    let cardView = CenterEmployCardInfoView()
    
    // Row4
    let checkApplicantsButton: IdlePrimaryCardButton = {
        let btn = IdlePrimaryCardButton(level: .medium)
        btn.label.textString = ""
        return btn
    }()
    
    // Row5
    lazy var buttonStack: VStack = {
        let stack = VStack([
            checkApplicantsButton,
            HStack([editPostButton, terminatePostButton, Spacer()], spacing: 4, distribution: .fill)
        ], spacing: 8, alignment: .fill)
        return stack
    }()
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
    
    private var disposables: [Disposable?]?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setAppearance()
        setLayout()
    }
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func prepareForReuse() {
        viewModel = nil
        
        disposables?.forEach { $0?.dispose() }
        disposables = nil
    }
    
    func setAppearance() { 
        contentView.backgroundColor = .clear
    }
    
    func setLayout() {
        
        let cellView = UIView()
        cellView.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        cellView.backgroundColor = DSColor.gray0.color
        cellView.layer.setGrayBorder()
        
        let contentStack = VStack([
            cardView,
            buttonStack
        ], spacing: 12, alignment: .fill)

        [
            contentStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cellView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: cellView.layoutMarginsGuide.topAnchor),
            contentStack.leftAnchor.constraint(equalTo: cellView.layoutMarginsGuide.leftAnchor),
            contentStack.rightAnchor.constraint(equalTo: cellView.layoutMarginsGuide.rightAnchor),
            contentStack.bottomAnchor.constraint(equalTo: cellView.layoutMarginsGuide.bottomAnchor),
        ])
        
        [
            cellView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            cellView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
    
    private func setObservable() { }
    
    public func bind(viewModel: CenterEmployCardViewModelable) {
        
        self.viewModel = viewModel
        
        // MARK: 카드 랜더링
        
        let ro = viewModel.renderObject
        cardView.durationLabel.textString = "\(ro.startDay) ~ \(ro.endDay)"
        cardView.postTitleLabel.textString = ro.postTitle
        cardView.nameLabel.textString = ro.nameText
        cardView.informationLabel.textString = "\(ro.careGradeText) \(ro.ageText) \(ro.genderText)"
        
        
        // MARK: 공고 상태에 따른 카드 버튼 숨김
        buttonStack.isHidden = ro.postState == .closed

        
        // MARK: 액션 바인딩
        let disposables: [Disposable?] = [
            // Output
            
            // 지원자수 텍스트
            viewModel
                .applicantCountText?
                .drive(onNext: { [weak self] text in
                    self?.checkApplicantsButton.label.textString = text
                }),
            
            // Input
            
            cardView.rx.tap
                .bind(to: viewModel.cardClicked),
            
            checkApplicantsButton
                .rx.tap
                .bind(to: viewModel.checkApplicantBtnClicked),
            
            editPostButton
                .rx.tap
                .bind(to: viewModel.editPostBtnClicked),
                
            terminatePostButton
                .rx.tap
                .bind(to: viewModel.terminatePostBtnClicked),
        ]
        
        self.disposables = disposables
    }
}

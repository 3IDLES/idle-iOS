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
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 8, right: 20))
    }
    
    func setAppearance() { }
    
    func setLayout() {
        
        self.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        let buttonStack = HStack([
            editPostButton,
            terminatePostButton,
        ], spacing: 4)
        
        let contentStack = VStack([
            HStack([cardView, Spacer()]),
            VStack([
                checkApplicantsButton,
                HStack([buttonStack, Spacer()])
            ], alignment: .fill)
        ], spacing: 12, alignment: .fill)
        
        [
            contentStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            contentStack.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            contentStack.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            contentStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
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
        checkApplicantsButton.isHidden = ro.postState == .closed
        editPostButton.isHidden = ro.postState == .closed
        terminatePostButton.isHidden = ro.postState == .closed
        
        
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

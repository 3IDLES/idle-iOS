//
//  WorkerEmployCard.swift
//  DSKit
//
//  Created by choijunios on 7/19/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public enum PostAppliedState {
    case applied
    case notApplied
}

public protocol WorkerEmployCardViewModelable {
    
    // Output
    var cellViewObject: WorkerNativeEmployCardVO { get }
    
    // Input
    var cardClicked: PublishRelay<Void> { get }
    var applyButtonClicked: PublishRelay<Void> { get }
    
    /// true일 경우 즐겨 찾기에 등록됩니다.
    var starButtonClicked: PublishRelay<Bool> { get }
}

public class WorkerEmployCardCell: UITableViewCell {
    
    public static let identifier = String(describing: WorkerEmployCardCell.self)
    
    
    var viewModel: WorkerEmployCardViewModelable?
    private var disposables: [Disposable?]?
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 8, right: 20))
    }
    
    // View
    let tappableArea: TappableUIView = .init()
    let cardView = WorkerEmployCard()
    let applyButton: IdlePrimaryCardButton = {
        let btn = IdlePrimaryCardButton(level: .large)
        btn.label.textString = "지원하기"
        return btn
    }()
    
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
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 12
        contentView.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
    }
    
    func setLayout() {
        
        let mainStack = VStack([cardView, applyButton], spacing: 8, alignment: .fill)
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        
        tappableArea.addSubview(mainStack)
        tappableArea.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        [
            tappableArea
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            applyButton.heightAnchor.constraint(equalToConstant: 44),
            
            mainStack.topAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.topAnchor),
            mainStack.leftAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.rightAnchor),
            mainStack.bottomAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.bottomAnchor),

            tappableArea.topAnchor.constraint(equalTo: contentView.topAnchor),
            tappableArea.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            tappableArea.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            tappableArea.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    public func bind(viewModel: WorkerEmployCardViewModelable) {
        
        self.viewModel = viewModel
        
        // Output
        let cardVO = viewModel.cellViewObject
        
        // 지원 여부
        if let appliedDate = cardVO.applyDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "지원완료 yyyy. MM. dd"
            let applyButtonLabelString = dateFormatter.string(from: appliedDate)
            applyButton.label.textString = applyButtonLabelString
            applyButton.setEnabled(false)
        }
        
        // 카드 컨텐츠 바인딩
        let cardRO = WorkerNativeEmployCardRO.create(vo: cardVO)
        cardView.bind(ro: cardRO)
        
        // input
        let disposables: [Disposable?] = [

            // Input
            tappableArea
                .rx.tap
                .bind(to: viewModel.cardClicked),
            
            applyButton
                .rx.tap
                .bind(to: viewModel.applyButtonClicked),
            
            cardView
                .starButton
                .eventPublisher
                .map { $0 == .accent }
                .bind(to: viewModel.starButtonClicked),
        ]
        
        self.disposables = disposables
    }
}

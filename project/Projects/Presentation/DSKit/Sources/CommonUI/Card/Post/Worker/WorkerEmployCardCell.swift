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

/// WorkerEmployCardCell에서 사용됩니다.
public struct ApplicationInfo {
    let isApplied: Bool
    let applicationDateText: String
}

public protocol WorkerEmployCardViewModelable {

    // Output
    var renderObject: Driver<WorkerEmployCardRO>? { get }
    var applicationInformation: Driver<ApplicationInfo>? { get }
    
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
    
    
    // View
    let tappableArea: TappableUIView = .init()
    let cardView = WorkerEmployCard()
    let applyButton: IdlePrimaryCardButton = {
        let btn = IdlePrimaryCardButton(level: .large)
        btn.label.textString = ""
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
        
        // input
        let disposables: [Disposable?] = [
            // Output
            viewModel
                .applicationInformation?
                .drive(onNext: { [weak self] info in
                    guard let self else { return }
                    if info.isApplied {
                        applyButton.setEnabled(false)
                        applyButton.label.textString = "지원완료 \(info.applicationDateText)"
                    } else {
                        applyButton.setEnabled(true)
                        applyButton.label.textString = "지원하기"
                    }
                }),
            viewModel
                .renderObject?
                .drive(onNext: { [cardView] ro in
                    cardView.bind(ro: ro)
                }),
            
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

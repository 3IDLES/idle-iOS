//
//  NotificationCell.swift
//  NotificationPageFeature
//
//  Created by choijunios on 9/28/24.
//

import UIKit
import Domain
import DSKit

import RxCocoa
import RxSwift

class NotificationCell: UITableViewCell {
    
    static let identifier: String = .init(describing: NotificationCell.self)
    
    var viewModel: NotificationCellViewModel?
    var disposables: [Disposable?] = []
    
    let profileImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.image = NotificationPageFeatureAsset.notificationNoImage.image
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let timeLabel: IdleLabel = {
        let label = IdleLabel(typography: .caption2)
        label.attrTextColor = DSColor.gray500.color
        label.textAlignment = .left
        return label
    }()
    
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle3)
        label.textAlignment = .left
        return label
    }()
    
    let subTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSColor.gray300.color
        label.textAlignment = .left
        return label
    }()
    
    private let tap: PublishSubject<Void> = .init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpUI()
        setUpGesture()
    }
    required init?(coder: NSCoder) { nil }
    
    private func setUpUI() {
        
        let labelStack = VStack([
            timeLabel,
            Spacer(height: 2),
            titleLabel,
            Spacer(height: 1),
            subTitleLabel
        ], alignment: .fill)
        
        let mainStack = HStack([
            profileImageView,
            labelStack,
        ], spacing: 16, alignment: .top)
        
        [
            mainStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(mainStack)
        }
        
        contentView.layoutMargins = .init(
            top: 12,
            left: 20,
            bottom: 12,
            right: 20
        )
        
        NSLayoutConstraint.activate([
            
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            
            mainStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            mainStack.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    private func setUpGesture() {
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        contentView.addGestureRecognizer(recognizer)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.viewModel = nil
        
        disposables.forEach { dis in
            dis?.dispose()
        }
        disposables = []
    }
    
    @objc
    private func onTap(recognizer: UITapGestureRecognizer) {
        tap.onNext(())
    }
    
    func bind(viewModel: NotificationCellViewModel) {
        
        self.viewModel = viewModel
        
        // Render
        let notificationVO = viewModel.notificationVO
        
        timeLabel.textString = viewModel.getTimeText()
        titleLabel.textString = notificationVO.title
        subTitleLabel.textString = notificationVO.body
        
        // Reactive
        disposables = [
            // Input
            tap.bind(to: viewModel.cellClicked),
            
            // Output
            viewModel
                .isRead?
                .drive(onNext: { [weak self] isRead in
                    self?.setState(isRead: isRead)
                }),
            
            viewModel
                .profileImage?
                .drive(onNext: { [weak self] image in
                    
                    guard let self else { return }
                    
                    UIView.transition(with: contentView, duration: 0.15, options: .transitionCrossDissolve) {
                        self.profileImageView.image = image
                    }
                })
        ]
    }
    
    private func setState(isRead: Bool) {
        
        contentView.backgroundColor = isRead ? DSColor.gray0.color : DSColor.orange050.color
    }
}

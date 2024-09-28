//
//  NotificationCell.swift
//  NotificationPageFeature
//
//  Created by choijunios on 9/28/24.
//

import UIKit
import Entity
import DSKit

import RxCocoa
import RxSwift


protocol NotificationCellViewModel {
    
    var id: String { get }
    var cellInfo: NotificationCellInfo { get }
    
    // Input
    var cellClicked: PublishSubject<Void> { get }
    
    // Output
    var isRead: Driver<Bool> { get }
}

class NotificationCell: UITableViewCell {
    
    static let identifier: String = .init(describing: NotificationCell.self)
    
    var viewModel: NotificationCellViewModel?
    var disposables: [Disposable] = []
    
    let profileImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 24
        return view
    }()
    
    let timeLabel: IdleLabel = {
        let label = IdleLabel(typography: .caption2)
        label.attrTextColor = DSColor.gray500.color
        label.textAlignment = .left
        return label
    }()
    
    let contentLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle3)
        label.textAlignment = .left
        return label
    }()
    
    let postInfoLabel: IdleLabel = {
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
            contentLabel,
            Spacer(height: 1),
            postInfoLabel
        ], alignment: .fill)
        
        let mainStack = HStack([
            profileImageView,
            labelStack,
        ], spacing: 16, alignment: .top)
        
        [
            mainStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addSubview(mainStack)
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
    }
    
    @objc
    private func onTap(recognizer: UITapGestureRecognizer) {
        tap.onNext(())
    }
    
    func bind(viewModel: NotificationCellViewModel) {
        
        self.viewModel = viewModel
        
        
        disposables = [
            // Input
            tap.bind(to: viewModel.cellClicked),
            
            // Output
            viewModel.isRead.drive(onNext: { [weak self] isRead in
                self?.setState(isRead: isRead)
            })
        ]
    }
    
    private func setState(isRead: Bool) {
        
        contentView.backgroundColor = isRead ? DSColor.gray0.color : DSColor.orange050.color
    }
}

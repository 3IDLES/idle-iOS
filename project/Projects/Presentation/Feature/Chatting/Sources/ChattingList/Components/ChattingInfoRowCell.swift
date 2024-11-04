//
//  ChattingInfoRowCell.swift
//  Chatting
//
//  Created by choijunios on 11/4/24.
//

import UIKit

import DSKit


import RxSwift

public final class ChattingInfoRowCell: UITableViewCell {
    
    // View
    let hostImage: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    let titleLabel: IdleLabel = {
        let label: IdleLabel = .init(typography: .Subtitle3)
        return label
    }()
    let latestChatDateLabel: IdleLabel = {
        let label: IdleLabel = .init(typography: .caption)
        label.attrTextColor = DSColor.gray500.color
        return label
    }()
    
    let latestChattingLabel: IdleLabel = {
        let label: IdleLabel = .init(typography: .caption)
        label.attrTextColor = DSColor.gray300.color
        return label
    }()
    let unreadChattingCountLabel: IdleLabel = {
        let label: IdleLabel = .init(typography: .caption)
        label.attrTextColor = DSColor.gray0.color
        label.layer.backgroundColor = DSColor.orange500.color.cgColor
        label.layer.cornerRadius = 11
        return label
    }()
    
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setLayout()
    }
    public required init?(coder: NSCoder) { nil }
    
    private func setLayout() {
        
        let titleAndDateStack: HStack = .init([
            titleLabel,
            Spacer(),
            latestChatDateLabel,
        ], alignment: .top)
        
        let latestChatAndUnreadLabelStack: HStack = .init([
            latestChattingLabel,
            unreadChattingCountLabel,
        ])
        unreadChattingCountLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        unreadChattingCountLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        let labelStack: VStack = .init([
            titleAndDateStack,
            latestChatAndUnreadLabelStack,
        ], alignment: .fill)
        
        let mainStack: HStack = .init([
            hostImage,
            labelStack
        ], spacing: 12, alignment: .center)
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            
            hostImage.heightAnchor.constraint(equalToConstant: 48),
            hostImage.widthAnchor.constraint(equalTo: hostImage.heightAnchor),
            
            unreadChattingCountLabel.heightAnchor.constraint(equalToConstant: 22),
            unreadChattingCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 22),
            
            mainStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mainStack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            mainStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
        ])
    }
}

@available(iOS 17, *)
#Preview(traits: .defaultLayout, body: {
    let view = ChattingInfoRowCell()
    
    view.hostImage.backgroundColor = .black
    view.titleLabel.textString = "세얼간이요양센터"
    view.latestChattingLabel.textString = "안녕하세요 문의드리고 싶어서 연락드렸어요"
    view.latestChatDateLabel.textString = "10월 29일"
    view.unreadChattingCountLabel.textString = "100"
    return view
})

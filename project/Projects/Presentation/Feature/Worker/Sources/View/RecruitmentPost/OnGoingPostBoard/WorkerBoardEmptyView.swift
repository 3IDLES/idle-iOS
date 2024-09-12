//
//  WorkerBoardEmptyView.swift
//  WorkerFeature
//
//  Created by choijunios on 9/12/24.
//

import UIKit
import DSKit

import RxSwift
import RxCocoa

class WorkerBoardEmptyView: UIView {
    
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "아직 해당 지역의 공고가 없어요."
        label.textAlignment = .center
        return label
    }()
    
    let descriptionLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSColor.gray300.color
        label.numberOfLines = 3
        label.textString = "나의 위치를 근처 다른 지역으로 바꿔\n새로운 공고를 탐색해보세요.\n나의 위치는 추후에 다시 변경할 수 있어요."
        label.textAlignment = .center
        return label
    }()
    
    let editProfile: IdleThirdinaryButton = {
        let button = IdleThirdinaryButton(level: .medium)
        button.label.textString = "내 프로필 수정"
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        
        setAppearance()
        setLayout()
    }
    required init?(coder: NSCoder) { nil }
    
    func setAppearance() {
        self.backgroundColor = .clear
    }
    
    func setLayout() {
        
        let mainStack = VStack([
            titleLabel,
            Spacer(height: 8),
            descriptionLabel,
            Spacer(height: 20),
            editProfile,
        ])
        
        self.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            editProfile.widthAnchor.constraint(equalToConstant: 165),
            
            mainStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
}

//
//  WorkerInfoCardView.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//

import UIKit
import PresentationCore
import Domain


import RxCocoa
import RxSwift

public class PostInfoCardView: TappableUIView {
    
    // View
    let contentView = CenterEmployCardInfoView()
    
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
        self.layoutMargins = .init(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )
        
        let mainStack = VStack([
            HStack([contentView, Spacer()])
        ],alignment: .fill)
        
        [
            mainStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            mainStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    private func setObservable() { }
    
    public func bind(vo: CenterEmployCardVO) {
        let ro = CenterEmployCardRO.create(vo)
        contentView.durationLabel.textString = "\(ro.startDay) ~ \(ro.endDay)"
        contentView.informationLabel.textString = "\(ro.careGradeText) \(ro.ageText) \(ro.genderText)"
        contentView.nameLabel.textString = ro.nameText
        contentView.postTitleLabel.textString = ro.postTitle
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    let view = PostInfoCardView()
    view.contentView.durationLabel.textString = "2024. 07. 10 ~ 2024. 07. 31"
    view.contentView.informationLabel.textString = "1등급 78세 여성"
    view.contentView.nameLabel.textString = "홍길동"
    view.contentView.postTitleLabel.textString = "서울특별시 강남구 신사동"
    
    return view
}

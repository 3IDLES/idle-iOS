//
//  IdleSmallAlertController.swift
//  DSKit
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public class IdleSmallAlertController: UIViewController {
    
    public struct ButtonInfo {
        let text: String
        let backgroundColor: UIColor
        let accentColor: UIColor
        
        public init(text: String, backgroundColor: UIColor, accentColor: UIColor) {
            self.text = text
            self.backgroundColor = backgroundColor
            self.accentColor = accentColor
        }
    }
    
    // Init values
    let titleText: String
    let button1Info: ButtonInfo
    let button2Info: ButtonInfo
    
    public init(titleText: String, button1Info: ButtonInfo, button2Info: ButtonInfo) {
        self.titleText = titleText
        self.button1Info = button1Info
        self.button2Info = button2Info
        
        super.init(nibName: nil, bundle: nil)
        
        setAppearance()
        setAutoLayout()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    // Not init
    private var viewModel: IdleAlertViewModelable?
    private let disposeBag = DisposeBag()
    
    // View
    private(set) lazy var titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle1)
        label.textString = titleText
        label.textAlignment = .center
        return label
    }()
    
    
    private(set) lazy var button1: TextButtonType1 = {
       let btn = TextButtonType1(
        labelText: button1Info.text,
        originBackground: button1Info.backgroundColor,
        accentBackgroundColor: button1Info.accentColor
       )
        btn.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        btn.layer.borderWidth = 1
        btn.label.typography = .Heading4
        return btn
    }()
    private(set) lazy var button2: TextButtonType1 = {
       let btn = TextButtonType1(
        labelText: button2Info.text,
        originBackground: button2Info.backgroundColor,
        accentBackgroundColor: button2Info.accentColor
       )
        btn.label.typography = .Heading4
        return btn
    }()
    
    private func setAppearance() {
        view.backgroundColor = DSKitAsset.Colors.gray500.color.withAlphaComponent(0.5)
        
        // TODO: 미정으로 변동가능합니다.
        view.layoutMargins = .init(top: 0, left: 24, bottom: 0, right: 24)
    }
    
    private func setAutoLayout() {
        
        
        // 버튼 스택
        let buttonStack = HStack(
            [
                button1,
                button2
            ],
            spacing: 8,
            alignment: .fill,
            distribution: .fillEqually
        )

        // 라벨 + 버튼 스택
        let alertContentsStack = VStack(
            [
                titleLabel,
                buttonStack
            ],
            spacing: 24,
            alignment: .fill
        )

        NSLayoutConstraint.activate([
            // 버튼 스택 높이 지정
            buttonStack.heightAnchor.constraint(equalToConstant: 52),
            
        ])
        
        // 전체 스택
        let alertContainer = UIView()
        alertContainer.backgroundColor = .white
        alertContainer.layer.cornerRadius = 12
        alertContainer.clipsToBounds = true
        
        alertContainer.layoutMargins = .init(top: 24, left: 12, bottom: 12, right: 12)
        
        [
            alertContentsStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            alertContainer.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            alertContentsStack.topAnchor.constraint(equalTo: alertContainer.layoutMarginsGuide.topAnchor),
            alertContentsStack.leadingAnchor.constraint(equalTo: alertContainer.layoutMarginsGuide.leadingAnchor),
            alertContentsStack.trailingAnchor.constraint(equalTo: alertContainer.layoutMarginsGuide.trailingAnchor),
            alertContentsStack.bottomAnchor.constraint(equalTo: alertContainer.layoutMarginsGuide.bottomAnchor),
        ])
        
        // 컨트롤러 뷰
        [
            alertContainer
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            alertContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertContainer.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            alertContainer.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    public func bind(viewModel vm: IdleAlertViewModelable) {
        // RC=1
        self.viewModel = vm
        
        button1
            .eventPublisher
            .map { _ in () }
            .bind(to: vm.button1Tapped)
            .disposed(by: disposeBag)
        
        button2
            .eventPublisher
            .map { _ in () }
            .bind(to: vm.button2Tapped)
            .disposed(by: disposeBag)
    }
}

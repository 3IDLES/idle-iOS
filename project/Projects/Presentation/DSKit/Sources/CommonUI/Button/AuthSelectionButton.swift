//
//  AuthSelectionButton.swift
//  DSKit
//
//  Created by choijunios on 8/26/24.
//

import UIKit
import RxSwift
import RxCocoa

public class AuthSelectionButton: TappableUIView {
    
    // Init
    private(set) var currentState: State
    
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle2)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let disposeBag = DisposeBag()
    
    public init(initialState: State, titleText: String, image: UIImage) {
        self.currentState = initialState
        self.titleLabel.textString = titleText
        self.imageView.image = image
        super.init()
        
        setAppearance()
        setLayout()
        setObservable()
        
        setState(initialState)
    }
    required init?(coder: NSCoder) { nil }
    
    private func setAppearance() {
        self.backgroundColor = DSColor.gray0.color
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
    }
    
    private func setLayout() {
        self.layoutMargins = .init(top: 28, left: 16, bottom: 28, right: 16)
        
        let contentStack = VStack([titleLabel, imageView], spacing: 16, alignment: .fill)
        
        [
            contentStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            contentStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor),
            contentStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor),
            contentStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        
        self.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                setState(currentState == .accent ? .normal : .accent)
            })
            .disposed(by: disposeBag)
    }
    
    public func setState(_ state: State) {
        
        let setting: StateSetting = state == .accent ? .accentDefault : .normalDefault
        self.layer.borderColor = setting.borderColor.cgColor
        self.backgroundColor = setting.backgroundColor
    }
}

public extension AuthSelectionButton {
    
    enum State {
        case normal, accent
    }
    
    struct StateSetting {
        
        let borderColor: UIColor
        let backgroundColor: UIColor
        
        static var normalDefault: StateSetting {
            StateSetting(
                borderColor: DSColor.gray100.color,
                backgroundColor: DSColor.gray0.color
            )
        }
        
        static var accentDefault: StateSetting {
            StateSetting(
                borderColor: DSColor.orange400.color,
                backgroundColor: DSColor.orange100.color
            )
        }
    }
}


@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    HStack([
        AuthSelectionButton(initialState: .normal, titleText: "센터 관리자로\n시작하기", image: DSIcon.centerLogo.image),
        AuthSelectionButton(initialState: .normal, titleText: "요양 보호사로\n시작하기", image: DSIcon.workerLogo.image),
    ], spacing: 8)
}

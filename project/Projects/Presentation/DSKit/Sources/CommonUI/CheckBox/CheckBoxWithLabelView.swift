//
//  CheckBoxWithLabelView.swift
//  DSKit
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import RxSwift
import RxCocoa

public class CheckBoxWithLabelView: HStack {
    
    public enum State {
        case idle
        case checked(text: String)
    }
    var currentState: State = .idle
    
    // Init
    let labelText: String
    
    // View
    let label: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        return label
    }()
    
    let checkIconView = DSIcon.checkBoxIcon.image.toView()
    private lazy var checkBox: TappableUIView = {
        let view = TappableUIView()
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
    
        view.addSubview(checkIconView)
        checkIconView.translatesAutoresizingMaskIntoConstraints = false
        checkIconView.tintColor = DSColor.gray0.color
        view.layoutMargins = .init(top: 6, left: 4, bottom: 5, right: 3)
        NSLayoutConstraint.activate([
            checkIconView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            checkIconView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            checkIconView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            checkIconView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
        
        // border설정
        view.layer.borderWidth = 1
        
        return view
    }()
    
    // Observable
    public lazy var opTap: PublishRelay<State> = .init()
    let disposeBag = DisposeBag()
    
    public init(labelText: String) {
        self.labelText = labelText
        self.label.textString = labelText
        super.init([], spacing: 12, alignment: .center)
        setAppearance()
        setLayout()
        setObservable()
        
        // 초기상태
        currentState = .idle
        toIdle()
    }
    public required init(coder: NSCoder) { fatalError() }
    
    func toIdle() {
        checkBox.layer.borderColor = DSColor.gray100.color.cgColor
        checkBox.backgroundColor = DSColor.gray0.color
        checkIconView.isHidden = true
    }
    
    func toChecked() {
        checkBox.layer.borderColor = DSColor.orange500.color.cgColor
        checkBox.backgroundColor = DSColor.orange500.color
        checkIconView.isHidden = false
    }
    
    func setAppearance() {
        
    }
    
    func setLayout() {
        
        [
            checkBox,
            label,
            Spacer()
        ].forEach {
            self.addArrangedSubview($0)
        }
        NSLayoutConstraint.activate([
            checkBox.widthAnchor.constraint(equalToConstant: 19),
            checkBox.heightAnchor.constraint(equalToConstant: 19),
        ])
    }
    
    func setObservable() {
        checkBox
            .rx.tap
            .observe(on: MainScheduler.instance)
            .compactMap { [weak self] _ -> State? in
                guard let self else { return nil }
                
                UIView.animate(withDuration: 0.2) {
                    switch self.currentState {
                    case .idle:
                        self.currentState = .checked(text: self.labelText)
                        self.toChecked()
                    case .checked:
                        self.currentState = .idle
                        self.toIdle()
                    }
                }
                return self.currentState
            }
            .bind(to: opTap)
            .disposed(by: disposeBag)
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    CheckBoxWithLabelView(labelText: "매칭매칭매칭매칭매칭매칭매칭")
}

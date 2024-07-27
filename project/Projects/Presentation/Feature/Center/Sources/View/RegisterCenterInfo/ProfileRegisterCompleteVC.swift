//
//  ProfileRegisterCompleteVC.swift
//  CenterFeature
//
//  Created by choijunios on 7/27/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public class ProfileRegisterCompleteVC: UIViewController {
    
    // Init
    weak var coordinator: ProfileRegisterCompleteCoordinator?
    
    // View
    let registerSuccessTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textString = "센터 회원으로 가입했어요."
        return label
    }()
    // 추후 이미지 추가 예정
    let registerSuccessImage: UIView = {
        let view = UIView()
        view.backgroundColor = .cyan
        return view
    }()
    
    let centerProfileButton: CenterProfileButton = {
       let profileBtn = CenterProfileButton(
            nameString: "센터명",
            locatonString: "위치"
       )
       return profileBtn
    }()
    
    // 하단 버튼
    let ctaButton: CTAButtonType1 = {
        let button = CTAButtonType1(labelText: "시작하기")
        return button
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(coordinator: ProfileRegisterCompleteCoordinator?) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    
    private func setAppearance() {
        view.backgroundColor = .white
        view.layoutMargins = .init(top: 0, left: 20, bottom: 16, right: 20)
    }
    
    private func setAutoLayout() {
        
        let titleImageSK = VStack(
            [
                registerSuccessTitle,
                registerSuccessImage,
            ],
            spacing: 20,
            alignment: .center
        )
        NSLayoutConstraint.activate([
            registerSuccessImage.widthAnchor.constraint(equalToConstant: 120),
            registerSuccessImage.heightAnchor.constraint(equalTo: registerSuccessImage.widthAnchor),
        ])
        
        let profileButtonSK = VStack(
            [
                {
                    let label = IdleLabel(typography: .Body3)
                    label.textString = "아래의 센터가 맞나요?"
                    label.textAlignment = .center
                    label.attrTextColor = DSKitAsset.Colors.gray300.color
                    return label
                }(),
                centerProfileButton
            ],
            spacing: 8,
            alignment: .fill
        )
        
        let mainSK = VStack(
            [
                titleImageSK,
                profileButtonSK
            ],
            spacing: 44,
            alignment: .fill
        )
        
        let mainBackground = UIView()
        mainBackground.addSubview(mainSK)
        mainSK.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainSK.centerYAnchor.constraint(equalTo: mainBackground.centerYAnchor),
            mainSK.leadingAnchor.constraint(equalTo: mainBackground.leadingAnchor),
            mainSK.trailingAnchor.constraint(equalTo: mainBackground.trailingAnchor),
        ])
        
        [
            mainBackground,
            ctaButton,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            mainBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainBackground.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            mainBackground.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            mainBackground.bottomAnchor.constraint(equalTo: ctaButton.topAnchor),
            
            ctaButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            ctaButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    private func setObservable() {
        
        ctaButton
            .eventPublisher
            .subscribe { [weak coordinator] _ in
                
                coordinator?.registerFinished()
            }
            .disposed(by: disposeBag)
    }
}

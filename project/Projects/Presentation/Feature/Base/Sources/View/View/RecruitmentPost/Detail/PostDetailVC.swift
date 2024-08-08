//
//  PostDetailVc.swift
//  BaseFeature
//
//  Created by choijunios on 8/7/24.
//

import UIKit
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public class PostDetailVC: BaseViewController {
    
    // Init
    
    // View
    let navigationBar: NavigationBarType1 = {
        let bar = NavigationBarType1(navigationTitle: "공고 정보")
        return bar
    }()
    
    let contentView = PostDetailContentView()
    
    // 하단 버튼
    let csButton: IdleSecondaryButton = {
        let btn = IdleSecondaryButton(level: .medium)
        btn.label.textString = "문의하기"
        return btn
    }()
    let applyButton: IdlePrimaryButton = {
        let btn = IdlePrimaryButton(level: .medium)
        btn.label.textString = "지원하기"
        return btn
    }()
    
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        setAppearance()
        setLayout()
        setObservable()
    }
    
    private func setAppearance() {
        view.backgroundColor = .white
    }
    
    private func setLayout() {
        
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        
        contentView.layoutMargins = .init(top: 24, left: 0, bottom: 16, right: 0)
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            contentView.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
            
            contentView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentView.leftAnchor.constraint(equalTo: contentGuide.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: contentGuide.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
        ])
        
        // Button
        let buttonStack = HStack([csButton, applyButton], spacing: 8, distribution: .fillEqually)
        
        
        // main view
        [
            navigationBar,
            scrollView,
            buttonStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 21),
            navigationBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 12),
            navigationBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -12),
            
            buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    private func setObservable() {
        
        // '문의하기'버튼 클릭시
        csButton.rx.tap
            .subscribe { [weak self] _ in
                let vc = SelectCSTypeVC()
                vc.modalPresentationStyle = .overFullScreen
                self?.present(vc, animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    public func bind() {
        
        // back button
        
        // Content view
        contentView.bind()
        
        // button
    }
}

// MARK: PostDetailContentView
public class PostDetailContentView: UIView {
    
    let cardView: WorkerEmployCard = .init()
    
    let workLocationView = WorkLocationView()
    let workConditionView = WorkConditionDisplayingView()
    let customerInfoView = CustomerInformationDisplayingView()
    let applicationDetailView = ApplicationDetailDisplayingView()
    let centerInfoCard = CenterInfoCardView()
    
    public init() {
        super.init(frame: .zero)
        
        setAppearance()
        setLayout()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    func setAppearance() {
        
        self.layoutMargins = .init(top: 24, left: 0, bottom: 16, right: 0)
    }
    
    func setLayout() {
        
        let titleViewData: [(title: String, view: UIView)] = [
            ("근무 장소", workLocationView),
            ("근무 조건", workConditionView),
            ("고객 정보", customerInfoView),
            ("추가 지원 정보", applicationDetailView),
            ("기관 정보", centerInfoCard),
        ]
        
        // 카드뷰 따로추가
        let cardPartView = UIView()
        cardPartView.backgroundColor = .white
        cardPartView.layoutMargins = .init(top: 0, left: 20, bottom: 24, right: 20)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardPartView.addSubview(cardView)
         
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cardPartView.layoutMarginsGuide.topAnchor),
            cardView.leftAnchor.constraint(equalTo: cardPartView.layoutMarginsGuide.leftAnchor),
            cardView.rightAnchor.constraint(equalTo: cardPartView.layoutMarginsGuide.rightAnchor),
            cardView.bottomAnchor.constraint(equalTo: cardPartView.layoutMarginsGuide.bottomAnchor),
        ])
        
        var viewList = [cardPartView]
        
        let titleViewList = titleViewData.map { (title, view) in
            
            let partView = UIView()
            partView.backgroundColor = .white
            partView.layoutMargins = .init(top: 24, left: 20, bottom: 24, right: 20)
            
            let titleLabel = IdleLabel(typography: .Subtitle1)
            titleLabel.textString = title
            
            [
                titleLabel,
                view
            ].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                partView.addSubview($0)
            }
            
            NSLayoutConstraint.activate([
                
                titleLabel.topAnchor.constraint(equalTo: partView.layoutMarginsGuide.topAnchor),
                titleLabel.leftAnchor.constraint(equalTo: partView.layoutMarginsGuide.leftAnchor),
                
                view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.43),
                view.leftAnchor.constraint(equalTo: partView.layoutMarginsGuide.leftAnchor),
                view.rightAnchor.constraint(equalTo: partView.layoutMarginsGuide.rightAnchor),
                view.bottomAnchor.constraint(equalTo: partView.layoutMarginsGuide.bottomAnchor),
            ])
            
            return partView
        }
        
        viewList.append(contentsOf: titleViewList)
        
        let contentViewStack = VStack(viewList, spacing: 8, alignment: .fill)
        contentViewStack.backgroundColor = DSKitAsset.Colors.gray050.color
        
        [
            contentViewStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            contentViewStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            contentViewStack.leftAnchor.constraint(equalTo: self.leftAnchor),
            contentViewStack.rightAnchor.constraint(equalTo: self.rightAnchor),
            contentViewStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        
        
    }
    
    public func bind() {
        
        cardView.bind(vo: .mock)
        workLocationView.bind()
        centerInfoCard.bind(nameText: "세얼간이 센터", locationText: "아남타워 7층")
    }
}

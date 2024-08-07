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
    
    let cardView: WorkerEmployCard = .init()
    
    let workConditionView = WorkConditionDisplayingView()
    let customerInfoView = CustomerInformationDisplayingView()
    let applicationDetailView = ApplicationDetailDisplayingView()
    
    
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
        
        let contentView = UIView()
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
        
        let titleViewData: [(title: String, view: UIView)] = [
            ("근무 장소", WorkLocationView()),
            ("근무 조건", workConditionView),
            ("고객 정보", customerInfoView),
            ("추가 지원 정보", applicationDetailView),
            ("기관 정보", UIView()),
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
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            contentViewStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            contentViewStack.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            contentViewStack.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            contentViewStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
        
        
        // main view
        [
            navigationBar,
            scrollView
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
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        
    }
    
    public func bind() {
        
        cardView.bind(vo: .mock)
    }
}


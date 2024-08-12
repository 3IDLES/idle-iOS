//
//  IdleTabControlBar.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//

import UIKit
import RxCocoa
import RxSwift

public protocol IdleTabItem {
    associatedtype ID: Equatable
    var id: ID { get }
    var tabLabelText: String { get }
}

fileprivate class IdleTabBarCell: TappableUIView {
    
    let label: IdleLabel = .init(typography: .Subtitle3)
    
    override init() {
    
        super.init()
        
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

public class IdleTabControlBar<Item: IdleTabItem>: UIView {
    
    let items: [Item]
    
    public let statePublisher: BehaviorRelay<Item>
    
    private var buttons: [IdleTabBarCell]!
    let movingBar: UIView = {
        let view = Spacer(height: 2)
        view.backgroundColor = DSKitAsset.Colors.gray900.color
        return view
    }()
    
    public private(set) var currentIndex: Int?
    
    public override var intrinsicContentSize: CGSize {
        .init(
            width: super.intrinsicContentSize.width,
            height: 48
        )
    }
    
    let disposeBag = DisposeBag()
    
    public init?(items: [Item], initialItem: Item) {
        
        if items.isEmpty { return nil }
        
        self.items = items
        self.statePublisher = .init(value: initialItem)
        super.init(frame: .zero)
        setLayout()
        selectItem(item: initialItem, animated: false)
        setObservable()
    }
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setLayout() {
        
        buttons = items.map { item in
            let btn = IdleTabBarCell()
            btn.label.textString = item.tabLabelText
            return btn
        }
        
        let buttonStack = HStack(buttons, alignment: .fill, distribution: .fillEqually)
        
        
        let barBackGroundView = Spacer(height: 1)
        barBackGroundView.backgroundColor = DSKitAsset.Colors.gray100.color
        
        [
            buttonStack,
            barBackGroundView,
            movingBar,
        ].enumerated().forEach { index, view in
            view.layer.zPosition = CGFloat(index)
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: self.topAnchor),
            buttonStack.leftAnchor.constraint(equalTo: self.leftAnchor),
            buttonStack.rightAnchor.constraint(equalTo: self.rightAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            barBackGroundView.leftAnchor.constraint(equalTo: self.leftAnchor),
            barBackGroundView.rightAnchor.constraint(equalTo: self.rightAnchor),
            barBackGroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            movingBar.leftAnchor.constraint(equalTo: self.leftAnchor),
            movingBar.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            movingBar.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0/CGFloat(items.count))
        ])
    }
    
    private func setObservable() {
        
        buttons
            .enumerated()
            .forEach { (index, tappableView) in
                tappableView
                    .rx.tap
                    .map { [weak self] _ in
                        self?.items[index]
                    }
                    .compactMap { $0 }
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] item in
                        self?.selectItem(item: item)
                        self?.statePublisher.accept(item)
                    })
                    .disposed(by: disposeBag)
            }
    }
    
    public func selectItem(item: Item, animated: Bool = true) {
        
        let moveToIndex = items.firstIndex(where: { $0.id == item.id })
        
        if currentIndex == moveToIndex { return }
        
        UIView.animate(withDuration: animated ? 0.2 : 0) { [weak self] in
            
            guard let self else { return }

            // 라벨색상변경
            buttons
                .enumerated()
                .forEach { [weak self] (index, view) in
                    
                    let isSelected = item.id == self?.items[index].id
                    view.label.attrTextColor = isSelected ? DSKitAsset.Colors.gray900.color : DSKitAsset.Colors.gray300.color
                }
            
            // 하단 바이동
            currentIndex = moveToIndex
            layoutSubviews()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // 레이아웃 요청 이후, 레이아웃 적용 이후
        movingBar.transform = .init(translationX: movingBar.bounds.width * CGFloat(currentIndex ?? 0), y: 0)
    }
}

fileprivate enum TestTab {
    case tab1
    case tab2
}


fileprivate struct TestItem: IdleTabItem {
    typealias ID = TestTab
    var tabLabelText: String
    var id: TestTab
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    let item1 = TestItem(
        tabLabelText: "진행 중인 공고",
        id: .tab1
    )
    let item2 = TestItem(
        tabLabelText: "이전 공고",
        id: .tab2
    )
    
    let tabBar = IdleTabControlBar(
        items: [item1, item2],
        initialItem: item1
    )!
    
    let vc = UIViewController()
    vc.view.addSubview(tabBar)
    tabBar.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
        tabBar.leftAnchor.constraint(equalTo: vc.view.leftAnchor),
        tabBar.rightAnchor.constraint(equalTo: vc.view.rightAnchor),
        tabBar.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
    ])
    
    return vc
}

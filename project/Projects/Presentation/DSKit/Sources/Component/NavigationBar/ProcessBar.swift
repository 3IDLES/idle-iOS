//
//  ProcessBar.swift
//  DSKit
//
//  Created by choijunios on 7/6/24.
//

import UIKit
import RxSwift
import RxCocoa

public class ProcessBar: UIView {
    
    private let processCount: Int
    private let startIndex: Int
    
    public let signal: BehaviorSubject<Int> = .init(value: 0)
    private let disposeBag = DisposeBag()
    
    private let movingBar: UIView = {
       
        let view = UIView()
        
        view.backgroundColor = DSKitAsset.Colors.orange500.color
        
        return view
    }()
    private var movingBarWidthConstraint: NSLayoutConstraint?
    
    init(
        processCount: Int,
        startIndex: Int
    ) {
        self.processCount = processCount
        self.startIndex = startIndex
        
        super.init(frame: .zero)
        
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public override var intrinsicContentSize: CGSize {
        .init(width: 0, height: 4)
    }
    
    func setAppearance() {
        
        self.backgroundColor = DSKitAsset.Colors.gray100.color
        self.layer.cornerRadius = self.intrinsicContentSize.height/2
        self.clipsToBounds = true
        
        signal.onNext(startIndex)
    }
    
    func setAutoLayout() {
        
        [
            movingBar
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            movingBar.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            movingBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            movingBar.heightAnchor.constraint(equalTo: self.heightAnchor),
        ])
    }

    func setObservable() {
        
        signal
            // DispatchQueue.main
            .observe(on: MainScheduler.instance)
            .filter({ [weak self] index in
                (0..<(self?.processCount ?? 0)).contains(index)
            })
            .subscribe(onNext: { [weak self] index in
                
                guard let self = self else { return }
                
                let multiplier: CGFloat = CGFloat(index+1) / CGFloat(processCount)
                
                // 기존 제약을 꺼준다.
                movingBarWidthConstraint?.isActive = false
                
                UIView.animate(withDuration: 0.2) { [weak self] in
                    
                    guard let self = self else { return }
                    
                    movingBarWidthConstraint = movingBar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: multiplier)
                    
                    // 새로운 제약을 실행한다.
                    movingBarWidthConstraint?.isActive = true
                    layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }
}

//
//  ProcessText.swift
//  DSKit
//
//  Created by choijunios on 7/6/24.
//

import UIKit
import RxSwift
import RxCocoa

public class ProcessText: UIStackView {
    
    // Init parameters
    public let processCount: Int
    public let startIndex: Int
    
    public let signal: BehaviorSubject<Int> = .init(value: 0)
    private let disposeBag = DisposeBag()
    
    // View
    private let currentProcessLabel: ResizableUILabel = {
            
        let label = ResizableUILabel()
        
        label.font = DSKitFontFamily.Pretendard.semiBold.font(size: 16)
        label.textColor = DSKitAsset.Colors.orange500.color
        label.textAlignment = .right
        
        return label
    }()
    private let processCountLabel: ResizableUILabel = {
            
        let label = ResizableUILabel()
        
        label.font = DSKitFontFamily.Pretendard.semiBold.font(size: 14)
        label.textColor = DSKitAsset.Colors.gray300.color
        
        return label
    }()
    
    public private(set) var currentIndex: Int
    
    init(
        processCount: Int,
        startIndex: Int
    ) {
        self.processCount = processCount
        self.startIndex = startIndex
        self.currentIndex = startIndex
        
        super.init(frame: .zero)
        
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    public required init(coder: NSCoder) { fatalError() }
    
    func setAppearance() {
        
        self.axis = . horizontal
        self.distribution = .fill
        self.spacing = 4
        self.alignment = .fill
        
        // ProcessLabel
        processCountLabel.text = "/ \(processCount)"
        
        signal.onNext(startIndex)
    }
    
    func setAutoLayout() {
        
        [
            currentProcessLabel,
            processCountLabel,
        ].forEach {
            self.addArrangedSubview($0)
        }
        
        currentProcessLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        processCountLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
            currentProcessLabel.widthAnchor.constraint(equalToConstant: 14),
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
                
                self?.currentProcessLabel.text = "\(index+1)"
                
            }).disposed(by: disposeBag)
    }
}

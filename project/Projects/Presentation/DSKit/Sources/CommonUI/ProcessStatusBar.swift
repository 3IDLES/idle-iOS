//
//  ProcessStatusBar.swift
//  DSKit
//
//  Created by choijunios on 7/6/24.
//

import UIKit
import RxSwift
import RxCocoa


public class ProcessStatusBar: UIStackView {
    
    public enum MoveTo: Int {
        case next = 1
        case prev = -1
    }
    
    // Init parameters
    public let processCount: Int
    public let startIndex: Int
    public private(set) var currentIndex: Int
    
    public let indexSignal: BehaviorSubject<Int> = .init(value: 0)
    public let moveToSignal: PublishSubject<MoveTo> = .init()
    
    private let disposeBag = DisposeBag()
    
    // View
    private lazy var processBar: ProcessBar = {
        
        let bar = ProcessBar(
            processCount: processCount,
            startIndex: startIndex
        )
        
        return bar
    }()
    private lazy var processText: ProcessText = {
        
        let text = ProcessText(
            processCount: processCount,
            startIndex: startIndex
        )
        
        return text
    }()
    
    public init(
        processCount: Int,
        startIndex: Int
    ) {
        self.processCount = processCount
        self.startIndex = startIndex
        self.currentIndex = startIndex
        
        super.init(frame: .zero)
        
        setApearance()
        setAutoLayout()
        setObservable()
    }
    
    public required init(coder: NSCoder) { fatalError() }
    
    func setApearance() {
        
        self.axis = .horizontal
        self.spacing = 12
        self.distribution = .fill
        self.alignment = .center
        
        indexSignal.onNext(startIndex)
    }
    
    func setAutoLayout() {
        
        let processBarBackground = UIView()
        
        processBarBackground.addSubview(processBar)
        processBar.translatesAutoresizingMaskIntoConstraints = false
        processBarBackground.layoutMargins = .init(top: 10.5, left: 0, bottom: 10.5, right: 0)
        NSLayoutConstraint.activate([
            processBar.topAnchor.constraint(equalTo: processBarBackground.layoutMarginsGuide.topAnchor),
            processBar.bottomAnchor.constraint(equalTo: processBarBackground.layoutMarginsGuide.bottomAnchor),
            processBar.leadingAnchor.constraint(equalTo: processBarBackground.layoutMarginsGuide.leadingAnchor),
            processBar.trailingAnchor.constraint(equalTo: processBarBackground.layoutMarginsGuide.trailingAnchor)
        ])
        
        [
            processBarBackground,
            processText,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addArrangedSubview($0)
        }
        
        processBarBackground.setContentHuggingPriority(.defaultLow, for: .horizontal)
        processText.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
            processText.heightAnchor.constraint(equalTo: processBarBackground.heightAnchor)
        ])
    }
    
    func setObservable() {
        
        // 유효한 인덱스인지 확인
        let validSignal = indexSignal
            .observe(on: MainScheduler.instance)
            .filter({ [weak self] index in
                (0..<(self?.processCount ?? 0)).contains(index)
            })
        
        // 유효한 인덱스에 한해서 이동
        validSignal
            .subscribe(onNext: { [weak self] validIndex in
                
                self?.changeProcess(validIndex)
            })
            .disposed(by: disposeBag)
        
        // 유효한 인덱스와 이동(다음, 이전) 신호
        moveToSignal
            .map({ [weak self] moveTo in
                (self?.currentIndex ?? 0) + moveTo.rawValue
            })
            .filter { [weak self] index in
                index >= 0 && index < (self?.processCount ?? 0)
            }
            .subscribe(onNext: { [weak self] validIndex in
                
                self?.changeProcess(validIndex)
            })
            .disposed(by: disposeBag)
    }
    
    func changeProcess(_ validIndex: Int) {
        
        currentIndex = validIndex
        
        self.processBar.signal.onNext(validIndex)
        self.processText.signal.onNext(validIndex)
    }
}



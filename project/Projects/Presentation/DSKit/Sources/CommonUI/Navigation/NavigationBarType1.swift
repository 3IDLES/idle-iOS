//
//  NavigationBarType1.swift
//  DSKit
//
//  Created by choijunios on 7/6/24.
//

import UIKit
import RxSwift
import RxCocoa

public class NavigationBarType1: UIStackView {
    
    // Observable
    public let eventPublisher: PublishRelay<Void> = .init()
    
    // Init parameters
    public let navigationTitle: String
    
    // View
    private let backButton: UIButton = {
        
        let btn = UIButton()
        
        let image = DSKitAsset.Icons.back.image
        
        let imageView = UIImageView(image: image)
        btn.setImage(image, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        
        return btn
    }()
    
    private lazy var titleText: ResizableUILabel = {
        
        let label = ResizableUILabel()
        
        label.textAlignment = .left
        label.text = navigationTitle
        label.font = DSKitFontFamily.Pretendard.semiBold.font(size: 20)
        
        return label
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(
        navigationTitle: String
    ) {
        self.navigationTitle = navigationTitle
        super.init(frame: .zero)
        
        setApearance()
        setAutoLayout()
        setObservable()
    }
    
    public required init(coder: NSCoder) { fatalError() }
    
    func setApearance() {
        
        self.axis = .horizontal
        self.spacing = 4
        self.distribution = .fill
        self.alignment = .center
    }
    
    func setAutoLayout() {
        
        [
            backButton,
            titleText,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addArrangedSubview($0)
        }
        
        titleText.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        backButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
        ])

    }
    
    func setObservable() {
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                
                self?.eventPublisher
                    .accept(())
            })
            .disposed(by: disposeBag)
    }
}

//
//  IdleTitleBar.swift
//  DSKit
//
//  Created by choijunios on 8/19/24.
//

import UIKit
import RxSwift
import RxCocoa

public class IdleTitleBar: UIView {
    
    // Init parameters
    
    // View
    public lazy var titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textAlignment = .left
        return label
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(
        titleText: String = "",
        innerViews: [UIView]
    ) {
        super.init(frame: .zero)
        
        self.titleLabel.textString = titleText
        
        setApearance()
        setAutoLayout(innerViews: innerViews)
    }
    
    public required init(coder: NSCoder) { fatalError() }
    
    func setApearance() {
        
    }
    
    private func setAutoLayout(innerViews: [UIView]) {
        
        self.layoutMargins = .init(
            top: 20.43,
            left: 20,
            bottom: 12,
            right: 20
        )
        
        let mainStack = HStack(
            [
                [
                    titleLabel,
                    Spacer(),
                ],
                innerViews
            ].flatMap { $0 },
            alignment: .center,
            distribution: .fill
        )
        
        [
            mainStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mainStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor),
            mainStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])

    }
}

//
//  IdleNavigationBar.swift
//  DSKit
//
//  Created by choijunios on 8/14/24.
//

import UIKit
import RxSwift
import RxCocoa

public class IdleNavigationBar: UIView {
    
    // Init parameters
    
    // View
    public let backButton: UIButton = {
        
        let btn = UIButton()
        
        let image = DSKitAsset.Icons.back.image
        
        let imageView = UIImageView(image: image)
        btn.setImage(image, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        
        return btn
    }()
    
    public lazy var titleLabel: IdleLabel = {
        
        let label = IdleLabel(typography: .Subtitle1)
        label.textAlignment = .left
        return label
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(
        titleText: String = "",
        innerViews: [UIView] = []
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
            left: 12,
            bottom: 12,
            right: 20
        )
        
        let mainStack = HStack(
            [
                [
                    backButton,
                    Spacer(width: 4),
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
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            mainStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor),
            mainStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])

    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    let innerView = Spacer(width: 50, height: 50)
    innerView.backgroundColor = .red
    let bar = IdleNavigationBar(titleText: "테스트", innerViews: [innerView])
    return bar
}

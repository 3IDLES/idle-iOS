//
//  WorkerMainTopView.swift
//  WorkerMainPageFeature
//
//  Created by choijunios on 10/15/24.
//

import UIKit
import DSKit


import RxSwift

// MARK: Top Container
class WorkerMainTopView: UIView {
    
    // Init parameters
    
    // View
    
    lazy var locationLabel: IdleLabel = {
        
        let label = IdleLabel(typography: .Heading1)
        label.textAlignment = .left
        return label
    }()
    
    let locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DSIcon.location.image
        imageView.tintColor = DSColor.gray700.color
        return imageView
    }()
    
    let notificationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DSIcon.bell.image
        imageView.tintColor = DSColor.gray200.color
        return imageView
    }()
    
    private let disposeBag = DisposeBag()
    
    init(
        titleText: String = "",
        innerViews: [UIView]
    ) {
        super.init(frame: .zero)
        
        self.locationLabel.textString = titleText
        
        setApearance()
        setAutoLayout(innerViews: innerViews)
    }
    
    required init(coder: NSCoder) { fatalError() }
    
    func setApearance() {
        
    }
    
    private func setAutoLayout(innerViews: [UIView]) {
        
        self.layoutMargins = .init(
            top: 20,
            left: 20,
            bottom: 7,
            right: 20
        )
        
        let mainStack = HStack(
            [
                [
                    locationImageView,
                    Spacer(width: 4),
                    locationLabel,
                    Spacer(),
                    notificationImageView
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
            locationImageView.widthAnchor.constraint(equalToConstant: 32),
            locationImageView.heightAnchor.constraint(equalTo: locationImageView.widthAnchor),
            
            mainStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor),
            mainStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])

    }
}

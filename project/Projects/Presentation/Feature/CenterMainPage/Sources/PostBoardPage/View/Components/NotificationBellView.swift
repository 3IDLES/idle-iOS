//
//  NotificationBellView.swift
//  CenterMainPageFeature
//
//  Created by choijunios on 10/22/24.
//

import UIKit

import DSKit

class NotificationBellView: UIView {
    
    let bellView: UIButton = {
        let button = UIButton()
        button.setImage(DSIcon.notiBell.image, for: .normal)
        button.imageView?.tintColor = DSColor.gray200.color
        return button
    }()
    
    let unreadPoint: UIView = {
        let view: UIView = .init()
        view.backgroundColor = DSColor.red200.color
        view.layer.cornerRadius = 3
        view.alpha = 0
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        
        setAutoLayout()
    }
    required init?(coder: NSCoder) { nil }
    
    private func setAutoLayout() {
        
        [
            bellView,
            unreadPoint,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
        
            bellView.widthAnchor.constraint(equalToConstant: 32),
            bellView.heightAnchor.constraint(equalTo: bellView.widthAnchor),
            
            bellView.leftAnchor.constraint(equalTo: self.leftAnchor),
            bellView.rightAnchor.constraint(equalTo: self.rightAnchor),
            bellView.topAnchor.constraint(equalTo: self.topAnchor),
            bellView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            unreadPoint.widthAnchor.constraint(equalToConstant: 6),
            unreadPoint.heightAnchor.constraint(equalTo: unreadPoint.widthAnchor),
            
            unreadPoint.topAnchor.constraint(equalTo: bellView.topAnchor, constant: 1),
            unreadPoint.rightAnchor.constraint(equalTo: bellView.rightAnchor),
        ])
    }
    
    func setUnreadState(_ showUnreadPoint: Bool) {
        UIView.animate(withDuration: 0.35) {
            self.unreadPoint.alpha = showUnreadPoint ? 1 : 0
        }
    }
}

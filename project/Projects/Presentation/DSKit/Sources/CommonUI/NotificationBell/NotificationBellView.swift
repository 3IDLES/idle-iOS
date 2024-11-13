//
//  NotificationBellView.swift
//  DSKit
//
//  Created by choijunios on 11/13/24.
//

import UIKit

public class NotificationBellView: UIView {
    
    public let button: UIButton = {
        let button = UIButton()
        button.setImage(DSIcon.notiBell.image, for: .normal)
        button.imageView?.tintColor = DSColor.gray200.color
        return button
    }()
    
    public let unreadPoint: UIView = {
        let view: UIView = .init()
        view.backgroundColor = DSColor.red200.color
        view.layer.cornerRadius = 3
        view.alpha = 0
        view.isUserInteractionEnabled = false
        return view
    }()
    
    public init() {
        super.init(frame: .zero)
        
        setAutoLayout()
    }
    required init?(coder: NSCoder) { nil }
    
    private func setAutoLayout() {
        
        [
            button,
            unreadPoint,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
        
            button.widthAnchor.constraint(equalToConstant: 32),
            button.heightAnchor.constraint(equalTo: button.widthAnchor),
            
            button.leftAnchor.constraint(equalTo: self.leftAnchor),
            button.rightAnchor.constraint(equalTo: self.rightAnchor),
            button.topAnchor.constraint(equalTo: self.topAnchor),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            unreadPoint.widthAnchor.constraint(equalToConstant: 6),
            unreadPoint.heightAnchor.constraint(equalTo: unreadPoint.widthAnchor),
            
            unreadPoint.topAnchor.constraint(equalTo: button.topAnchor, constant: 1),
            unreadPoint.rightAnchor.constraint(equalTo: button.rightAnchor),
        ])
    }
    
    public func setUnreadState(_ showUnreadPoint: Bool) {
        UIView.animate(withDuration: 0.35) {
            self.unreadPoint.alpha = showUnreadPoint ? 1 : 0
        }
    }
}

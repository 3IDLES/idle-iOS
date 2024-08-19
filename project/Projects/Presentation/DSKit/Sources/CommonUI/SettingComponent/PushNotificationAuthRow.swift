//
//  PushNotificationAuthRow.swift
//  DSKit
//
//  Created by choijunios on 8/19/24.
//

import UIKit
import RxSwift
import RxCocoa

public class PushNotificationAuthRow: UIView {
    
    let label: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.attrTextColor = DSColor.gray500.color
        label.textString = "알림 설정"
        return label
    }()
    
    public let `switch`: UISwitch = {
        let view = UISwitch()
        view.onTintColor = DSColor.orange500.color
        view.isOn = false
        return view
    }()
    
    public init() {
        super.init(frame: .zero)
        setApearance()
        setLayout()
        setObservable()
    }
    required init?(coder: NSCoder) { return nil }
    
    private func setApearance() {
        self.backgroundColor = DSColor.gray0.color
    }
    private func setLayout() {
        
        self.layoutMargins = .init(
            top: 12,
            left: 20,
            bottom: 12,
            right: 20
        )
        
        let mainStack = HStack([
            label,
            Spacer(),
            `switch`
        ], alignment: .center, distribution: .fill)
        
        [
            mainStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            mainStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
    }
    private func setObservable() {
   
    }
    
    public override func draw(_ rect: CGRect) {
        if `switch`.bounds.height > label.bounds.height {
            let per = label.bounds.height / `switch`.bounds.height
            `switch`.transform = `switch`.transform.scaledBy(x: per, y: per)
        }
    }

}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    PushNotificationAuthRow()
}

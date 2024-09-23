//
//  itemView.swift
//  DSKit
//
//  Created by choijunios on 8/15/24.
//

import UIKit
import RxSwift
import RxCocoa

/// 메인 화면의 탭바 아이템으로 사용됩니다.
public class IdleTabBarItem: TappableUIView {
    
    // Init
    public let index: Int
    
    // State components
    public enum State {
        case idle
        case accent
    }
    
    // idle
    let idleIcon: UIImage
    let accentIcon: UIImage
    
    // text color
    let accentTextColor: UIColor = DSColor.gray700.color
    let idleTextColor: UIColor = DSColor.gray300.color
    
    // View
    let label: IdleLabel = {
        let label = IdleLabel(typography: .caption)
        return label
    }()
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    public init(index: Int, labelText: String, idleImage: UIImage, accentImage: UIImage) {
        self.index = index
        self.label.textString = labelText
        self.idleIcon = idleImage
        self.accentIcon = accentImage
        
        super.init()
        
        setAppearance()
        setLayout()
    }
    public required init?(coder: NSCoder) { nil }
    
    private func setAppearance() {
        imageView.image = idleIcon
        label.attrTextColor = idleTextColor
    }
    
    private func setLayout() {
        let mainStack = VStack([imageView, label], spacing: 4, alignment: .center)
        
        self.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.topAnchor),
            mainStack.leftAnchor.constraint(equalTo: self.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: self.rightAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    /// 탭바 아이템의 상태를 변경합니다.
    public func setState(_ state: State, duration: CGFloat = 0.2) {
        UIView.animate(withDuration: duration) { [weak self] in
            if state == .accent {
                self?.setToAccent()
            } else {
                self?.setToIdle()
            }
        }
    }
    
    private func setToIdle() {
        imageView.image = idleIcon
        label.attrTextColor = idleTextColor
    }
    
    private func setToAccent() {
        imageView.image = accentIcon
        label.attrTextColor = accentTextColor
    }
}


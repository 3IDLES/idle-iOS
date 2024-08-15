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
    let idleIconColor: UIColor = DSColor.gray300.color
    
    
    // accent
    let accentIconColor: UIColor = DSColor.gray700.color
    
    // View
    let label: IdleLabel = {
        let label = IdleLabel(typography: .caption)
        label.attrTextColor = DSColor.gray700.color
        return label
    }()
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    public init(index: Int, labelText: String, image: UIImage) {
        self.index = index
        self.label.textString = labelText
        self.imageView.image = image
        
        super.init()
        
        setAppearance()
        setLayout()
    }
    public required init?(coder: NSCoder) { nil }
    
    private func setAppearance() {
        imageView.tintColor = idleIconColor
    }
    
    private func setLayout() {
        let mainStack = VStack([imageView, label], spacing: 4, alignment: .center)
        
        self.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 32),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
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
        imageView.tintColor = idleIconColor
    }
    
    private func setToAccent() {
        imageView.tintColor = accentIconColor
    }
}


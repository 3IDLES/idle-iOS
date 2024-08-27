//
//  CenterEmployCardInfoView.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//

import UIKit

public class CenterEmployCardInfoView: TappableUIView {
    // Row1
    let durationLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray300.color
        return label
    }()
    
    // Row2
    let postTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle2)
        return label
    }()
    
    // Row3
    let nameLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    let informationLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    override init() {
        super.init()
        setLayout()
    }
    
    public required init(coder: NSCoder) { fatalError() }
    
    func setLayout() {
        
        // InfoLabel
        let divider = UIView()
        divider.backgroundColor = DSKitAsset.Colors.gray300.color
        let infoStack = HStack([
            nameLabel,
            divider,
            informationLabel,
        ], spacing: 8)
            
        NSLayoutConstraint.activate([
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.topAnchor.constraint(equalTo: infoStack.topAnchor, constant: 5),
            divider.bottomAnchor.constraint(equalTo: infoStack.bottomAnchor, constant: -5),
        ])
        
        let viewList = [
            durationLabel,
            Spacer(height: 4),
            postTitleLabel,
            Spacer(height: 2),
            infoStack,
        ]
        
        let contentStack = VStack(viewList, alignment: .leading)
        
        [
            contentStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: self.topAnchor),
            contentStack.leftAnchor.constraint(equalTo: self.leftAnchor),
            contentStack.rightAnchor.constraint(equalTo: self.rightAnchor),
            contentStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}

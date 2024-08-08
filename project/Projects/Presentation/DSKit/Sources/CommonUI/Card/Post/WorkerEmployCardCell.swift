//
//  WorkerEmployCard.swift
//  DSKit
//
//  Created by choijunios on 7/19/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public class WorkerEmployCardCell: UITableViewCell {
    
    let tappableArea: TappableUIView = .init()
    
    let cardView = WorkerEmployCard()
    
    let applyButton: TextButtonType1 = {
       
        let btn = TextButtonType1(
            labelText: "지원하기"
        )
        return btn
    }()
    
    private var touchDispoable: Disposable?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setAppearance()
        setLayout()
    }
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func prepareForReuse() {
        touchDispoable?.dispose()
        touchDispoable = nil
    }
    
    func setAppearance() {
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 12
        contentView.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
    }
    
    func setLayout() {
        
        let mainStack = VStack([cardView, applyButton], spacing: 8, alignment: .fill)
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        
        tappableArea.addSubview(mainStack)
        tappableArea.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        [
            tappableArea
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            applyButton.heightAnchor.constraint(equalToConstant: 44),
            
            mainStack.topAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.topAnchor),
            mainStack.leftAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.rightAnchor),
            mainStack.bottomAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.bottomAnchor),

            tappableArea.topAnchor.constraint(equalTo: contentView.topAnchor),
            tappableArea.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            tappableArea.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            tappableArea.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    public func bind(vo: WorkerEmployCardVO) {
        
        // tap설정
        
        cardView.bind(vo: vo)
    }
}

//
//  CenterEmployCardCell.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public class CenterEmployCardCell: UITableViewCell {
    
    var viewModel: CenterEmployCardViewModelable?
    
    public static let identifier = String(describing: CenterEmployCardCell.self)
    
    let cardView = CenterEmployCard()
    
    private var disposables: [Disposable?]?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setAppearance()
        setLayout()
    }
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func prepareForReuse() {
        viewModel = nil
        
        disposables?.forEach { $0?.dispose() }
        disposables = nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 8, right: 20))
    }
    
    func setAppearance() { }
    
    func setLayout() {
        
        [
            cardView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            cardView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    public func bind(viewModel: CenterEmployCardViewModelable) {
        
        self.viewModel = viewModel
        
        let disposables: [Disposable?] = [
            // Output
            viewModel
                .renderObject?
                .drive(onNext: { [cardView] ro in
                    cardView.bind(ro: ro)
                }),
            
            // Input
            cardView.rx.tap
                .bind(to: viewModel.cardClicked),
            
            cardView.checkApplicantsButton
                .rx.tap
                .bind(to: viewModel.checkApplicantBtnClicked),
            
            cardView.editPostButton
                .rx.tap
                .bind(to: viewModel.editPostBtnClicked),
                
            cardView.terminatePostButton
                .rx.tap
                .bind(to: viewModel.terminatePostBtnClicked),
        ]
        
        self.disposables = disposables
    }
}

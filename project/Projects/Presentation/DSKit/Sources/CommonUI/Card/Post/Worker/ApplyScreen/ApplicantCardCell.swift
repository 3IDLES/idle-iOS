//
//  ApplicantCardCell.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//


import UIKit
import RxSwift
import RxCocoa
import Entity

public class ApplicantCardCell: UITableViewCell {
    
    public static let identifier = String(describing: ApplicantCardCell.self)
    
    var viewModel: ApplicantCardViewModelable?
    
    let cardView = ApplicantCard()
    
    private var disposables: [Disposable?]?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setAppearance()
        setLayout()
    }
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func prepareForReuse() {
        disposables?.forEach { $0?.dispose() }
        disposables = nil
    }
    
    func setAppearance() { }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0))
    }
    
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
    
    public func bind(viewModel: ApplicantCardViewModelable) {
        
        self.viewModel = viewModel
        
        let disposables: [Disposable?] = [
            // Output
            viewModel
                .renderObject?
                .drive(onNext: { [cardView] ro in
                    cardView.bind(ro: ro)
                }),
   
            // Input
//            cardView
//                .starButton.eventPublisher
//                .map { state in
//                    state == .accent
//                }
//                .bind(to: viewModel.staredThisWorker),
            
            cardView
                .showProfileButton.rx.tap
                .bind(to: viewModel.showProfileButtonClicked),
            
            cardView
                .employButton.rx.tap
                .bind(to: viewModel.employButtonClicked),
        ]
        
        self.disposables = disposables
    }
}


//
//  SingleImageButton.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa

public class SingleImageButton: TappableUIView {
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let disposeBag = DisposeBag()
    
    public override init() {
        
        super.init()
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: self.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        rx.tap
            .subscribe { [weak self] _ in
                self?.alpha = 0.5
                UIView.animate(withDuration: 0.35) { [weak self] in
                    self?.alpha = 1.0
                }
            }
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

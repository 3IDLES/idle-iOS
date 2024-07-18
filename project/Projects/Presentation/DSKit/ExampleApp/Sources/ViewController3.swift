//
//  ViewController3.swift
//  DSKitExampleApp
//
//  Created by choijunios on 7/17/24.
//

import UIKit
import DSKit
import RxSwift

class ViewController3: UIViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        view.layoutMargins = .init(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
        
        let field = MultiLineTextField(typography: .Body3, placeholderText: "Hello world")
        
        let label = IdleLabel(typography: .Body3)
        label.textString = "엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장엄청나게 긴 문장"
        label.numberOfLines = 0
        
        let centerImageEditButton: UIButton = {
            let btn = UIButton()
            btn.setImage(DSKitAsset.Icons.editPhoto.image, for: .normal)
            btn.isUserInteractionEnabled = true
            return btn
        }()
        [
            field,
            label,
            centerImageEditButton
        ]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            }
        
        NSLayoutConstraint.activate([
            field.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            field.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            field.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            label.topAnchor.constraint(equalTo: field.bottomAnchor, constant: 30),
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            centerImageEditButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30),
            centerImageEditButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
        ])
    }
}


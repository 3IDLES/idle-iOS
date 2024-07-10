//
//  CenterLoginViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import DSKit
import PresentationCore

class CenterLoginViewController: DisposableViewController {
    
    // View
    let idField: IdleOneLineInputField = {
        
        let field = IdleOneLineInputField(
            placeHolderText: "아이디를 입력해주세요.",
            isCompleteImageAvailable: false
        )
        
        return field
    }()
    let passwordField: IdleOneLineInputField = {
        
        let field = IdleOneLineInputField(
            placeHolderText: "비밀번호를 입력해주세요.",
            isCompleteImageAvailable: false
        )
        
        return field
    }()
    
    
    var coordinator: CenterLoginCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    
    
    private func setAppearance() {
        
        view.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    private func setAutoLayout() {
        
        
    }
    
    private func setObservable() {
        
        
    }
    
    
    func cleanUp() {
        
    }
}

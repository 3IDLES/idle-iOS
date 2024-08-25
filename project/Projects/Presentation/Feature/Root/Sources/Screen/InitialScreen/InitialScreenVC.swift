//
//  InitialScreenVC.swift
//  RootFeature
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public class InitialScreenVC: BaseViewController {
    
    var viewModel: InitialScreenVM?
    
    // Init
    
    // View
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.gray0.color
    }
    
    private func setLayout() {
        
    }
    
    private func setObservable() {
    }
    
    public func bind(viewModel: InitialScreenVM) {
        self.viewModel = viewModel
        
    }
}


//
//  SplashPageVC.swift
//  SplashFeature
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Domain
import DSKit

import RxCocoa
import RxSwift

public class SplashPageVC: BaseViewController {
    
    // Init
    
    // View
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setLayout()
        setObservable()
    }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.orange500.color
    }
    
    private func setLayout() { }
    
    private func setObservable() { }
}


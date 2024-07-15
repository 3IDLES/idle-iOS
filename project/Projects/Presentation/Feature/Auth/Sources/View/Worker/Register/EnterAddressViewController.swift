//
//  EnterAddressViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import DSKit
import Entity
import PresentationCore

public protocol EnterAddressInputable {
    var editingPostalCode: PublishRelay<String?> { get }
    var editingDetailAddress: PublishRelay<String?> { get }
}

public class EnterAddressViewController<T: ViewModelType>: DisposableViewController
where T.Input: EnterAddressInputable & CTAButtonEnableInputable {
    
    public var coordinator: CenterRegisterCoordinator?
    
    private let viewModel: T
    
    public init(coordinator: CenterRegisterCoordinator? = nil, viewModel: T) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public func cleanUp() {
        coordinator?.coordinatorDidFinish()
    }
}

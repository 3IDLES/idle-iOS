//
//  File.swift
//  WorkerFeature
//
//  Created by choijunios on 8/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity


public protocol WorkerProfileViewModelable {
    
    var coordinator: WorkerProfileCoordinator? { get }
    
    // Input
    var viewWillAppear: PublishRelay<Void> { get }
    var exitButtonClicked: PublishRelay<Void> { get }
    
    // Output
    var displayingImage: Driver<UIImage?>? { get }
    var profileRenderObject: Driver<WorkerProfileRenderObject>? { get }
}

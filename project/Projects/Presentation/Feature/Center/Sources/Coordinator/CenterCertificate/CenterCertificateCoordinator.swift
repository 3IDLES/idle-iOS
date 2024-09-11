//
//  CenterCertificateCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 9/11/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

public class CenterCertificateCoordinator: ChildCoordinator {
    
    enum Navigation {
        case requestProfileInfo
        case certificationOnGoing
        case certificateOnBoarding
    }
    
    public struct Dependency {
        let navigationController: UINavigationController
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    public let navigationController: UINavigationController
    
    
    public init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: RegisterRecruitmentCoordinator.self))")
    }
    
    public func start() {
        
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
        popViewController()
    }
}

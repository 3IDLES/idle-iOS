//
//  asd.swift
//  PresentationCore
//
//  Created by choijunios on 8/25/24.
//

import Foundation

public protocol RootCoorinatable: ParentCoordinator {
    func auth()
    func centerAuth()
    func workerMain()
    func centerMain()
    func popToRoot()
}

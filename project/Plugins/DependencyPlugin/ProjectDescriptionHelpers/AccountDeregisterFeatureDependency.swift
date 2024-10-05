//
//  AccountDeregisterFeatureDependency.swift
//  DependencyPlugin
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription

public extension ModuleDependency.Presentation {
    
    static let AccountDeregisterFeature: TargetDependency = .project(target: "AccountDeregisterFeature", path: .relativeToRoot("Projects/Presentation/Feature/AccountDeregister"))
}

//
//  RootFeatureDependency.swift
//  DependencyPlugin
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription

public extension ModuleDependency.Presentation {
    
    static let RootFeature: TargetDependency = .project(target: "RootFeature", path: .relativeToRoot("Projects/Presentation/Feature/Root"))
}

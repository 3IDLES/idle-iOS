//
//  CenterFeatureDependency.swift
//  DependencyPlugin
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription

public extension ModuleDependency.Presentation {
    
    static let CenterFeature: TargetDependency = .project(target: "CenterFeature", path: .relativeToRoot("Projects/Presentation/Feature/Center"))
}

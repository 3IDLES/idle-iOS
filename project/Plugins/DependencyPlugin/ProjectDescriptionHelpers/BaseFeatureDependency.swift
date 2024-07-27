//
//  BaseFeatureDependency.swift
//  DependencyPlugin
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription

public extension ModuleDependency.Presentation {
    
    static let BaseFeature: TargetDependency = .project(target: "BaseFeature", path: .relativeToRoot("Projects/Presentation/Feature/Base"))
}

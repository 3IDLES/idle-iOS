//
//  WorkerFeatureDependency.swift
//  DependencyPlugin
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription

public extension ModuleDependency.Presentation {
    
    static let WorkerFeature: TargetDependency = .project(target: "WorkerFeature", path: .relativeToRoot("Projects/Presentation/Feature/Worker"))
}

//
//  PostDetailForWorkerFeatureDependency.swift
//  DependencyPlugin
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription

public extension ModuleDependency.Presentation {
    
    static let PostDetailForWorkerFeature: TargetDependency = .project(target: "PostDetailForWorkerFeature", path: .relativeToRoot("Projects/Presentation/Feature/PostDetailForWorker"))
}

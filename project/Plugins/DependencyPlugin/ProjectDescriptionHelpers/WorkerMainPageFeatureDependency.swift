//
//  WorkerMainPageFeatureDependency.swift
//  DependencyPlugin
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription

public extension ModuleDependency.Presentation {
    
    static let WorkerMainPageFeature: TargetDependency = .project(target: "WorkerMainPageFeature", path: .relativeToRoot("Projects/Presentation/Feature/WorkerMainPage"))
}

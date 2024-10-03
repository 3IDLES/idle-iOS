//
//  CenterMainPageFeatureDependency.swift
//  DependencyPlugin
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription

public extension ModuleDependency.Presentation {
    
    static let CenterMainPageFeature: TargetDependency = .project(target: "CenterMainPageFeature", path: .relativeToRoot("Projects/Presentation/Feature/CenterMainPage"))
}

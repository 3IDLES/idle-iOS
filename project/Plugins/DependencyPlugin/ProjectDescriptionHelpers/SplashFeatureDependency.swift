//
//  SplashFeatureDependency.swift
//  DependencyPlugin
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription

public extension ModuleDependency.Presentation {
    
    static let SplashFeature: TargetDependency = .project(target: "SplashFeature", path: .relativeToRoot("Projects/Presentation/Feature/Splash"))
}

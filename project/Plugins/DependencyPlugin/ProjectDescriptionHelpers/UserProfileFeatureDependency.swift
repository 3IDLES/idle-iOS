//
//  UserProfileFeatureDependency.swift
//  DependencyPlugin
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription

public extension ModuleDependency.Presentation {
    
    static let UserProfileFeature: TargetDependency = .project(target: "UserProfileFeature", path: .relativeToRoot("Projects/Presentation/Feature/UserProfile"))
}

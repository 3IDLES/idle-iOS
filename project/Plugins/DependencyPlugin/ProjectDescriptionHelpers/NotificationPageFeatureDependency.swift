//
//  NotificationPageFeatureDependency.swift
//  DependencyPlugin
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription

public extension ModuleDependency.Presentation {
    
    static let NotificationPageFeature: TargetDependency = .project(target: "NotificationPageFeature", path: .relativeToRoot("Projects/Presentation/Feature/NotificationPage"))
}

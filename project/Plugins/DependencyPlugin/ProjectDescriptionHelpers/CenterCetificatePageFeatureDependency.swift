//
//  CenterCetificatePageFeatureDependency.swift
//  DependencyPlugin
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription

public extension ModuleDependency.Presentation {
    
    static let CenterCetificatePageFeature: TargetDependency = .project(target: "CenterCetificatePageFeature", path: .relativeToRoot("Projects/Presentation/Feature/CenterCetificatePage"))
}

//
//  ChattingFeatureDependency.swift
//  DependencyPlugin
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription

public extension ModuleDependency.Presentation {
    
    static let ChattingFeature: TargetDependency = .project(target: "ChattingFeature", path: .relativeToRoot("Projects/Presentation/Feature/Chatting"))
}

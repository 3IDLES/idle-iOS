//
//  Dependency.swift
//  ConfigurationPlugin
//
//  Created by 최준영 on 6/20/24.
//

import ProjectDescription
import Foundation

public typealias D = ModuleDependency

public enum ModuleDependency {
    
    public enum Domain {
        public static let ConcreteUseCase: TargetDependency = .project(target: "ConcreteUseCase", path: .relativeToRoot("Projects/Domain"))
        public static let UseCaseInterface: TargetDependency = .project(target: "UseCaseInterface", path: .relativeToRoot("Projects/Domain"))
        public static let RepositoryInterface: TargetDependency = .project(target: "RepositoryInterface", path: .relativeToRoot("Projects/Domain"))
        public static let Entity: TargetDependency = .project(target: "Entity", path: .relativeToRoot("Projects/Domain"))
    }
}


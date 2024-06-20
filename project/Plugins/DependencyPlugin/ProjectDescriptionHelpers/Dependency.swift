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
        public static let Concrete: TargetDependency = .project(target: "Concrete", path: .relativeToRoot("Projects/Domain"))
        public static let DomainInterface: TargetDependency = .project(target: "DomainInterface", path: .relativeToRoot("Projects/Domain"))
        public static let RepositoryInterface: TargetDependency = .project(target: "RepositoryInterface", path: .relativeToRoot("Projects/Domain"))
    }
}


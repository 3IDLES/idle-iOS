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
    
    public enum Data {
        public static let ConcreteRepository: TargetDependency = .project(target: "ConcreteRepository", path: .relativeToRoot("Projects/Data"))
        public static let NetworkConcrete: TargetDependency = .project(target: "ConcreteNetwork", path: .relativeToRoot("Projects/Data"))
        public static let NetworkInterface: TargetDependency = .project(target: "NetworkInterface", path: .relativeToRoot("Projects/Data"))
    }
    
    public enum Presentation {
        public static let DSKit: TargetDependency = .project(target: "DSKit", path: .relativeToRoot("Projects/Presentation/DSKit"))
        public static let PresentationCore: TargetDependency = .project(target: "PresentationCore", path: .relativeToRoot("Projects/Presentation/PresentationCore"))
    }
}

// External dependencies
public extension TargetDependency {
    
    static let rxswift: TargetDependency = .external(name: "RxSwift")
    static let rxCocoa: TargetDependency = .external(name: "RxCocoa")
}


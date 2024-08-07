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
        public static let NetworkDataSource: TargetDependency = .project(target: "NetworkDataSource", path: .relativeToRoot("Projects/Data"))
    }
    
    public enum Presentation {
        public static let DSKit: TargetDependency = .project(target: "DSKit", path: .relativeToRoot("Projects/Presentation/DSKit"))
        public static let PresentationCore: TargetDependency = .project(target: "PresentationCore", path: .relativeToRoot("Projects/Presentation/PresentationCore"))
    }
}

// External dependencies
public extension ModuleDependency {
    
    enum ThirdParty {
        public static let RxSwift: TargetDependency = .external(name: "RxSwift")
        public static let RxCocoa: TargetDependency = .external(name: "RxCocoa")
        public static let Swinject: TargetDependency = .external(name: "Swinject")
        public static let Alamofire: TargetDependency = .external(name: "Alamofire")
        public static let KeyChainAccess: TargetDependency = .external(name: "KeychainAccess")
        public static let Moya: TargetDependency = .external(name: "Moya")
        public static let RxMoya: TargetDependency = .external(name: "RxMoya")
        public static let FSCalendar: TargetDependency = .external(name: "FSCalendar")
        public static let NaverMapSDKForSPM: TargetDependency = .external(name: "Junios.NMapSDKForSPM")
    }
}


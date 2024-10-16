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
    
    public static let Domain: TargetDependency = .project(target: "Domain", path: .relativeToRoot("Projects/Domain"))
    
    public enum Data {
        public static let Repository: TargetDependency = .project(target: "Repository", path: .relativeToRoot("Projects/Data"))
        public static let DataSource: TargetDependency = .project(target: "DataSource", path: .relativeToRoot("Projects/Data"))
    }
    
    public enum Presentation {
        public static let DSKit: TargetDependency = .project(target: "DSKit", path: .relativeToRoot("Projects/Presentation/DSKit"))
        public static let PresentationCore: TargetDependency = .project(target: "PresentationCore", path: .relativeToRoot("Projects/Presentation/PresentationCore"))
    }
    
    public static let Core: TargetDependency = .project(target: "Core", path: .relativeToRoot("Projects/Core"))
    
    public static let Testing: TargetDependency = .project(target: "Testing", path: .relativeToRoot("Projects/Testing"))
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
        public static let Amplitude: TargetDependency = .external(name: "AmplitudeSwift")
        public static let SDWebImageWebPCoder: TargetDependency = .external(name: "SDWebImageWebPCoder")
        
        // FireBase
        public static let FirebaseRemoteConfig: TargetDependency = .external(name: "FirebaseRemoteConfig")
        public static let FirebaseCrashlytics: TargetDependency = .external(name: "FirebaseCrashlytics")
        public static let FirebaseAnalytics: TargetDependency = .external(name: "FirebaseAnalytics")
        public static let FirebaseMessaging: TargetDependency = .external(name: "FirebaseMessaging")
    }
}


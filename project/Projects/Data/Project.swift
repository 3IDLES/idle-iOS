//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 최준영 on 6/20/24.
//

import ProjectDescription
import ProjectDescriptionHelpers
import ConfigurationPlugin
import DependencyPlugin

let project = Project(
    name: "Data",
    settings: .settings(
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        
        /// RepositoryConcrete
        .target(
            name: "ConcreteRepository",
            destinations: DeploymentSettings.platforms,
            product: .staticLibrary,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["ConcreteRepository/**"],
            dependencies: [
                D.Domain,
                D.Data.DataSource,
                
                // ThirdParty
                D.ThirdParty.RxSwift,
                D.ThirdParty.FirebaseRemoteConfig,
                D.ThirdParty.SDWebImageWebPCoder,
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"]
            )
        ),
        
        /// ConcreteTests
        .target(
            name: "ConcretesTests",
            destinations: DeploymentSettings.platforms,
            product: .unitTests,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["ConcretesTests/**"],
            dependencies: [
                D.Data.ConcreteRepository,
                D.Data.DataSource,
            ],
            settings: .settings(
                configurations: IdleConfiguration.dataConfigurations
            )
        ),
        
        /// DataSource
        .target(
            name: "DataSource",
            destinations: DeploymentSettings.platforms,
            product: .staticLibrary,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: [
                "DataSource/**",
                SecretSource.networkDataSource,
            ],
            dependencies: [
                D.Domain,
                
                // ThirdParty
                D.ThirdParty.Alamofire,
                D.ThirdParty.RxSwift,
                D.ThirdParty.KeyChainAccess,
                D.ThirdParty.Moya,
                D.ThirdParty.RxMoya,
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"],
                configurations: IdleConfiguration.dataConfigurations
            )
        ),
    ],
    schemes: [
        Scheme.makeTestableSchemes(
            .target("ConcreteRepository"),
            testableTarget: .target("ConcretesTests"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName,
                IdleConfiguration.qaConfigName,
            ]
        )
    ].flatMap { $0 }
)

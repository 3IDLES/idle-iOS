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
            destinations: DeploymentSettings.platform,
            product: .staticLibrary,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["ConcreteRepository/**"],
            dependencies: [
                D.Domain.RepositoryInterface,
                D.Data.NetworkDataSource,
                
                // ThirdParty
                D.ThirdParty.RxSwift
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"]
            )
        ),
        
        /// ConcreteTests
        .target(
            name: "ConcretesTests",
            destinations: DeploymentSettings.platform,
            product: .unitTests,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["ConcretesTests/**"],
            dependencies: [
                D.Data.ConcreteRepository,
                D.Data.NetworkDataSource,
            ],
            settings: .settings(
                configurations: IdleConfiguration.dataConfigurations
            )
        ),
        
        /// NetworkDataSource
        .target(
            name: "NetworkDataSource",
            destinations: DeploymentSettings.platform,
            product: .staticLibrary,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: [
                "NetworkDataSource/**",
                SecretSource.networkDataSource,
            ],
            dependencies: [
                
                // ThirdParty
                D.ThirdParty.Alamofire,
                D.ThirdParty.RxSwift,
                D.ThirdParty.KeyChainAccess,
                D.ThirdParty.Moya,
                D.ThirdParty.RxMoya,
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"]
            )
        ),
    ],
    schemes: [
        Scheme.makeTestableSchemes(
            .target("ConcreteRepository"),
            testableTarget: .target("ConcretesTests"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        )
    ].flatMap { $0 }
)

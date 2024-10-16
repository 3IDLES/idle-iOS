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
            name: "Repository",
            destinations: DeploymentSettings.platforms,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Repository/**"],
            dependencies: [
                D.Domain,
                D.Data.DataSource,
                
                D.ThirdParty.SDWebImageWebPCoder,
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"],
                configurations: IdleConfiguration.dataConfigurations
            )
        ),
        
        /// DataSource
        .target(
            name: "DataSource",
            destinations: DeploymentSettings.platforms,
            product: .framework,
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
        
        /// ConcreteTests
        .target(
            name: "DataTests",
            destinations: DeploymentSettings.platforms,
            product: .unitTests,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["DataTests/**"],
            dependencies: [
                D.Data.Repository,
                D.Testing,
            ],
            settings: .settings(
                configurations: IdleConfiguration.dataConfigurations
            )
        ),
    ],
    schemes: [
        Scheme.makeTestableSchemes(
            .target("Repository"),
            testableTarget: .target("DataTests"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName,
                IdleConfiguration.qaConfigName,
            ]
        )
    ].flatMap { $0 }
)

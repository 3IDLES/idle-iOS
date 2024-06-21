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
                D.Data.NetworkInterface,
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
                D.Data.NetworkConcrete,
            ],
            settings: .settings(
                configurations: IdleConfiguration.dataConfigurations
            )
        ),
        
        /// NetworkConcrete
        .target(
            name: "ConcreteNetwork",
            destinations: DeploymentSettings.platform,
            product: .staticLibrary,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["ConcreteNetwork/**"],
            dependencies: [
                D.Data.NetworkInterface,
                // ThirdParty
                D.ThirdParty.Alamofire
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"]
            )
        ),
        
        /// NetworkInterface
        .target(
            name: "NetworkInterface",
            destinations: DeploymentSettings.platform,
            product: .staticLibrary,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["NetworkInterface/**"]
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

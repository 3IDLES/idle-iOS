//
//  Project.swift
//  Idle-iOSManifests
//
//  Created by 최준영 on 6/20/24.
//

import ProjectDescription
import ProjectDescriptionHelpers
import ConfigurationPlugin
import DependencyPlugin

let project = Project(
    name: "Domain",
    settings: .settings(
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        
        /// Concrete type
        .target(
            name: "Concrete",
            destinations: DeploymentSettings.platform,
            product: .staticLibrary,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Concrete/Sources/**"],
            dependencies: [
                D.Domain.DomainInterface,
                D.Domain.RepositoryInterface,
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"]
            )
        ),
        
        /// Concrete type Test
        .target(
            name: "ConcreteTests",
            destinations: DeploymentSettings.platform,
            product: .unitTests,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["ConcreteTests/**"],
            dependencies: [
                D.Domain.Concrete,
                D.Domain.RepositoryInterface,
            ],
            settings: .settings(
                configurations: IdleConfiguration.domainConfigurations
            )
        ),
        
        /// Domain interface
        .target(
            name: "DomainInterface",
            destinations: DeploymentSettings.platform,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["DomainInterface/Sources/**"],
            dependencies: [
                D.Domain.Entity,
            ],
            settings: .settings(
                configurations: IdleConfiguration.domainConfigurations
            )
        ),
        
        /// Repository interface
        .target(
            name: "RepositoryInterface",
            destinations: DeploymentSettings.platform,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["RepositoryInterface/Sources/**"],
            dependencies: [
                D.Domain.Entity,
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"],
                configurations: IdleConfiguration.domainConfigurations
            )
        ),
        
        /// Entity
        .target(
            name: "Entity",
            destinations: DeploymentSettings.platform,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Entity/**"],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"],
                configurations: IdleConfiguration.domainConfigurations
            )
        )
    ],
    schemes: [
        Scheme.makeTestableSchemes(
            .target("Concrete"),
            testableTarget: .target("ConcreteTests"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        ),
        Scheme.makeInterfaceSchemes(
            .target("DomainInterface"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        ),
        Scheme.makeInterfaceSchemes(
            .target("RepositoryInterface"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        ),
    ].flatMap({ $0 })
)

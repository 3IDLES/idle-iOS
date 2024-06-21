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
        
        /// UseCaseConcrete type
        .target(
            name: "ConcreteUseCase",
            destinations: DeploymentSettings.platform,
            product: .staticLibrary,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["ConcreteUseCase/**"],
            dependencies: [
                D.Domain.UseCaseInterface,
                D.Domain.RepositoryInterface,
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"]
            )
        ),
        
        /// Concrete type Test
        .target(
            name: "ConcreteUseCaseTests",
            destinations: DeploymentSettings.platform,
            product: .unitTests,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["ConcreteUseCaseTests/**"],
            dependencies: [
                D.Domain.ConcreteUseCase,
                D.Domain.RepositoryInterface,
            ],
            settings: .settings(
                configurations: IdleConfiguration.domainConfigurations
            )
        ),
        
        /// Domain interface
        .target(
            name: "UseCaseInterface",
            destinations: DeploymentSettings.platform,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["UseCaseInterface/**"],
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
            sources: ["RepositoryInterface/**"],
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
            .target("ConcreteUseCase"),
            testableTarget: .target("ConcreteUseCaseTests"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        ),
        Scheme.makeSchemes(
            .target("UseCaseInterface"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        ),
        Scheme.makeSchemes(
            .target("RepositoryInterface"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        ),
    ].flatMap({ $0 })
)

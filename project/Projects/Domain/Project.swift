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
            destinations: DeploymentSettings.platforms,
            product: .staticLibrary,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["ConcreteUseCase/**"],
            dependencies: [
                D.Domain.UseCaseInterface,
                D.Domain.RepositoryInterface,
                
                // ThirdParty
                D.ThirdParty.RxSwift,
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"]
            )
        ),
        
        /// Concrete type Test
        .target(
            name: "ConcreteUseCaseTests",
            destinations: DeploymentSettings.platforms,
            product: .unitTests,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["ConcreteUseCaseTests/**"],
            dependencies: [
                D.Domain.ConcreteUseCase,
                D.Domain.RepositoryInterface,
                
                // for test
                D.Data.ConcreteRepository,
                D.Data.DataSource
            ],
            settings: .settings(
                configurations: IdleConfiguration.domainConfigurations
            )
        ),
        
        /// Domain interface
        .target(
            name: "UseCaseInterface",
            destinations: DeploymentSettings.platforms,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["UseCaseInterface/**"],
            dependencies: [
                D.Domain.Entity,
                
                // ThirdParty
                D.ThirdParty.RxSwift,
            ],
            settings: .settings(
                configurations: IdleConfiguration.domainConfigurations
            )
        ),
        
        /// Repository interface
        .target(
            name: "RepositoryInterface",
            destinations: DeploymentSettings.platforms,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["RepositoryInterface/**"],
            dependencies: [
                D.Domain.Entity,
                
                // ThirdParty
                D.ThirdParty.RxSwift,
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"],
                configurations: IdleConfiguration.domainConfigurations
            )
        ),
        
        /// Entity
        .target(
            name: "Entity",
            destinations: DeploymentSettings.platforms,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Entity/**"],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"],
                configurations: IdleConfiguration.domainConfigurations
            )
        ),
        
        /// Logger interface
        .target(
            name: "LoggerInterface",
            destinations: DeploymentSettings.platforms,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["LoggerInterface/source/**"],
            dependencies: [
                D.Domain.Entity,
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"],
                configurations: IdleConfiguration.domainConfigurations
            )
        ),
    ],
    schemes: [
        Scheme.makeTestableSchemes(
            .target("ConcreteUseCase"),
            testableTarget: .target("ConcreteUseCaseTests"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName,
                IdleConfiguration.qaConfigName
            ]
        ),
        Scheme.makeSchemes(
            .target("UseCaseInterface"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName,
                IdleConfiguration.qaConfigName
            ]
        ),
        Scheme.makeSchemes(
            .target("RepositoryInterface"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName,
                IdleConfiguration.qaConfigName
            ]
        ),
    ].flatMap({ $0 })
)

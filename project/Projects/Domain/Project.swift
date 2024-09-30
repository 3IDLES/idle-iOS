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
            name: "Domain",
            destinations: DeploymentSettings.platforms,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Sources/**"],
            dependencies: [
                
                D.Core
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"],
                configurations: IdleConfiguration.domainConfigurations
            )
        ),
        
        /// Concrete type Test
        .target(
            name: "DomainTests",
            destinations: DeploymentSettings.platforms,
            product: .unitTests,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["DomainTests/**"],
            dependencies: [

                // for test
                D.Domain,
            ],
            settings: .settings(
                configurations: IdleConfiguration.domainConfigurations
            )
        ),
    ],
    schemes: [
        Scheme.makeTestableSchemes(
            .target("Domain"),
            testableTarget: .target("DomainTests"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName,
                IdleConfiguration.qaConfigName
            ]
        ),
    ].flatMap({ $0 })
)

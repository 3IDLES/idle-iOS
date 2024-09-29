//
//  Project.swift
//  Idle-iOSManifests
//
//  Created by 최준영 on 9/29/24.
//

import ProjectDescription
import ProjectDescriptionHelpers
import ConfigurationPlugin
import DependencyPlugin

let project = Project(
    name: "Core",
    settings: .settings(
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        
        /// UseCaseConcrete type
        .target(
            name: "Core",
            destinations: DeploymentSettings.platforms,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Sources/**"],
            dependencies: [
                // ThirdParty
                D.ThirdParty.RxSwift,
                D.ThirdParty.Swinject,
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"],
                configurations: IdleConfiguration.domainConfigurations
            )
        ),

    ]
)

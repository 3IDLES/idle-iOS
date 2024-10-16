//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 최준영 on 10/16/24.
//

import ProjectDescription
import ProjectDescriptionHelpers
import ConfigurationPlugin
import DependencyPlugin

let project = Project(
    name: "Testing",
    settings: .settings(
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        
        .target(
            name: "Testing",
            destinations: DeploymentSettings.platforms,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Sources/**"],
            dependencies: [
                
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"],
                configurations: IdleConfiguration.dataConfigurations
            )
        ),
    ]
)

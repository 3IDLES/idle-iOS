//
//  Project.swift
//  FeatureManifests
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription
import ProjectDescriptionHelpers
import ConfigurationPlugin
import DependencyPlugin

let proejct = Project(
    name: "DSKit",
    settings: .settings(
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        .target(
            name: "DSKit",
            destinations: DeploymentSettings.platform,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        )
    ]
)

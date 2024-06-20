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
    name: "PresentationCore",
    settings: .settings(
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        .target(
            name: "PresentationCore",
            destinations: DeploymentSettings.platform,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Sources/**"],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        )
    ]
)

//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by choijunyeong on 2024/10/30.
//

import ProjectDescription
import ConfigurationPlugin
import DependencyPlugin
import Foundation

let project = Project(
    name: "Logger",
    settings: .settings(
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        .target(
            name: "Logger",
            destinations: DeploymentSettings.platforms,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_iOS_version,
            sources: [
                "Sources/**",
                SecretSource.amplitudeConfig,
            ],
            resources: ["Resources/**",],
            dependencies: [
                // External
                D.ThirdParty.Amplitude,
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        ),
    ]
)

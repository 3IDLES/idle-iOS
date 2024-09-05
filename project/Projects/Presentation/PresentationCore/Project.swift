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
            destinations: DeploymentSettings.platforms,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Sources/**"],
            dependencies: [
                // ThirdParty
                D.ThirdParty.RxSwift,
                D.ThirdParty.RxCocoa,
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        )
    ]
)

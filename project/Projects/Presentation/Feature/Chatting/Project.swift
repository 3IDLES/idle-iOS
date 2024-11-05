//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by choijunios on 2024/11/04
//

import ProjectDescription
import ProjectDescriptionHelpers
import ConfigurationPlugin
import DependencyPlugin

let project = Project(
    name: "Chatting",
    settings: .settings(
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        
        .target(
            name: "ChattingFeatureInterface",
            destinations: DeploymentSettings.platforms,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_iOS_version,
            sources: ["Interface/**"],
            dependencies: [
                D.Presentation.BaseFeature,
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        ),
        
        /// FeatureConcrete
        .target(
            name: "ChattingFeature",
            destinations: DeploymentSettings.platforms,
            product: .staticFramework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_iOS_version,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                // Presentation
                D.Presentation.ChattingFeatureInterface,
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        ),
        
        /// FeatureConcrete ExampleApp
        .target(
            name: "Chatting_ExampleApp",
            destinations: DeploymentSettings.platforms,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_iOS_version,
            infoPlist: IdleInfoPlist.exampleAppDefault,
            sources: ["ExampleApp/Sources/**"],
            resources: ["ExampleApp/Resources/**"],
            dependencies: [
                .target(name: "ChattingFeature"),
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        ),
    ],
    schemes: [
        Scheme.makeSchemes(
            .target("ChattingFeature"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        ),
        Scheme.makeSchemes(
            .target("Chatting_ExampleApp"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        )
    ].flatMap { $0 }
)

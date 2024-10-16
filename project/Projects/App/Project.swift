//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by choijunyeong on 2024/06/19.
//

import ProjectDescription
import ConfigurationPlugin
import DependencyPlugin
import Foundation

let project = Project(
    name: "App",
    settings: .settings(
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        /// Application
        .target(
            name: "Idle-iOS",
            destinations: DeploymentSettings.platforms,
            product: .app,
            productName: DeploymentSettings.productName,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            infoPlist: IdleInfoPlist.mainApp,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: .file(path: .relativeToRoot("Entitlements/App/Idle-iOS.entitlements")),
            scripts: [
                .crashlyticsScript
            ],
            dependencies: [
                
                // Presentation
                D.Presentation.RootFeature,
            ],
            settings: .settings(
                configurations: IdleConfiguration.appConfigurations
            )
        ),
        
        /// UnitTests
        .target(
            name: "IdleAppTests",
            destinations: DeploymentSettings.platforms,
            product: .unitTests,
            bundleId: "com.idleApplication.test",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Tests/**"],
            dependencies: [.target(name: "Idle-iOS")]
        )
    ],
    schemes: [
        .scheme(
            name: "Idle-iOS_Debug",
            buildAction: .buildAction(
                targets: [
                    .target("Idle-iOS")
                ]
            ),
            testAction: .targets(
                [
                    .testableTarget(target: .target("IdleAppTests")) 
                ],
                configuration: IdleConfiguration.debugConfigName
            ),
            runAction: .runAction(configuration: IdleConfiguration.debugConfigName),
            archiveAction: .archiveAction(configuration: IdleConfiguration.debugConfigName)
        ),
        .scheme(
            name: "Idle-iOS_Release",
            buildAction: .buildAction(
                targets: [
                    .target("Idle-iOS")
                ]
            ),
            testAction: .targets(
                [
                    .testableTarget(target: .target("IdleAppTests"))
                ],
                configuration: IdleConfiguration.releaseConfigName
            ),
            runAction: .runAction(configuration: IdleConfiguration.releaseConfigName),
            archiveAction: .archiveAction(configuration: IdleConfiguration.releaseConfigName)
        ),
        .scheme(
            name: "Idle-iOS_QA",
            buildAction: .buildAction(
                targets: [
                    .target("Idle-iOS")
                ]
            ),
            testAction: .targets(
                [
                    .testableTarget(target: .target("IdleAppTests"))
                ],
                configuration: IdleConfiguration.qaConfigName
            ),
            runAction: .runAction(configuration: IdleConfiguration.qaConfigName),
            archiveAction: .archiveAction(configuration: IdleConfiguration.qaConfigName)
        )
    ]
)

//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by choijunyeong on 2024/06/19.
//

import ProjectDescription
import ConfigurationPlugin

let project = Project(
    name: "App",
    settings: .settings(
        configurations: IdleConfiguration.appConfigurations
    ),
    targets: [
        /// Application
        .target(
            name: "IdleApp",
            destinations: DeploymentSettings.platform,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: .iOS("13.0"),
            infoPlist: IdleInfoPlist.appDefault,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                
            ],
            settings: .settings(
                configurations: IdleConfiguration.appConfigurations
            )
        ),
        
        /// UnitTests
        .target(
            name: "IdleAppTests",
            destinations: DeploymentSettings.platform,
            product: .unitTests,
            bundleId: "com.idle-application.test",
            sources: ["Tests/**"],
            dependencies: [.target(name: "IdleApp")]
        )
    ],
    schemes: [
        .scheme(
            name: "IdleApp_Debug",
            buildAction: .buildAction(
                targets: [
                    .target("IdleApp")
                ]
            ),
            testAction: .targets(
                [
                    .testableTarget(target: .target("IdleAppTests")) 
                ],
                configuration: IdleConfiguration.appDebugConfigName
            ),
            runAction: .runAction(configuration: IdleConfiguration.appDebugConfigName),
            archiveAction: .archiveAction(configuration: IdleConfiguration.appDebugConfigName)
        ),
        .scheme(
            name: "IdleApp_Release",
            buildAction: .buildAction(
                targets: [
                    .target("IdleApp")
                ]
            ),
            testAction: .targets(
                [
                    .testableTarget(target: .target("IdleAppTests"))
                ],
                configuration: IdleConfiguration.appReleaseConfigName
            ),
            runAction: .runAction(configuration: IdleConfiguration.appReleaseConfigName),
            archiveAction: .archiveAction(configuration: IdleConfiguration.appReleaseConfigName)
        )
    ]
)

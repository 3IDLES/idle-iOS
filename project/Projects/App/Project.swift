//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by choijunyeong on 2024/06/19.
//

import ProjectDescription
import ConfigurationPlugin
import DependencyPlugin

let project = Project(
    name: "App",
    settings: .settings(
        base: [
            "CLANG_ENABLE_MODULE_VERIFIER": "YES",
            "ENABLE_USER_SCRIPT_SANDBOXING": "YES"
        ],
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        /// Application
        .target(
            name: "Idle-iOS",
            destinations: DeploymentSettings.platform,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            infoPlist: IdleInfoPlist.appDefault,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                // Domain
                D.Domain.ConcreteUseCase,
                D.Domain.RepositoryInterface,
                D.Domain.UseCaseInterface,
                
                // Data
                D.Data.ConcreteRepository,
                D.Data.NetworkConcrete,
                D.Data.NetworkInterface,
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
        )
    ]
)

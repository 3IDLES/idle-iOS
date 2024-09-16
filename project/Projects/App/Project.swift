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
            infoPlist: IdleInfoPlist.appDefault,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            scripts: [
                .crashlyticsScript
            ],
            dependencies: [
                
                // Presentation
                D.Presentation.RootFeature,
                
                // Domain
                D.Domain.ConcreteUseCase,
                
                // Data
                D.Data.ConcreteRepository,
                
                // Logger
                D.App.ConcreteLogger,
                
                // ThirdParty
                D.ThirdParty.Amplitude,
            ],
            settings: .settings(
                configurations: IdleConfiguration.appConfigurations
            )
        ),
        
        .target(
            name: "ConcreteLogger",
            destinations: DeploymentSettings.platforms,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["ConcreteLogger/source/**"],
            dependencies: [
                
                D.Domain.LoggerInterface,
                
                // ThirdParty
                D.ThirdParty.Amplitude,
                D.ThirdParty.RxSwift,
            ],
            settings: .settings(
                base: ["ENABLE_TESTABILITY": "YES"],
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
        )
    ]
)

//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by choijunios on 2024/07/25
//

import ProjectDescription
import ProjectDescriptionHelpers
import ConfigurationPlugin
import DependencyPlugin

let project = Project(
    name: "Root",
    settings: .settings(
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        
        /// FeatureConcrete
        .target(
            name: "RootFeature",
            destinations: DeploymentSettings.platforms,
            product: .staticFramework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: [
                "Sources/**",
                SecretSource.amplitudeConfig,
            ],
            resources: ["Resources/**"],
            dependencies: [

                // Presentation
                D.Presentation.SplashFeature,
                D.Presentation.AuthFeature,
                D.Presentation.CenterMainPageFeature,
                D.Presentation.WorkerMainPageFeature,
                D.Presentation.CenterCetificatePageFeature,
                D.Presentation.AccountDeregisterFeature,
                D.Presentation.PostDetailForWorkerFeature,
                D.Presentation.UserProfileFeature,
                D.Presentation.NotificationPageFeature,
                
                // ThirParty
                D.ThirdParty.Amplitude,
                D.ThirdParty.FirebaseMessaging,
                D.ThirdParty.FirebaseRemoteConfig,
                D.ThirdParty.FirebaseCrashlytics
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        ),
        
        /// FeatureConcrete ExampleApp
        .target(
            name: "Root_ExampleApp",
            destinations: DeploymentSettings.platforms,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            infoPlist: IdleInfoPlist.exampleAppDefault,
            sources: ["ExampleApp/Sources/**"],
            resources: ["ExampleApp/Resources/**"],
            dependencies: [
                .target(name: "RootFeature"),
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        ),
    ],
    schemes: [
        Scheme.makeSchemes(
            .target("RootFeature"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        ),
        Scheme.makeSchemes(
            .target("Root_ExampleApp"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        )
    ].flatMap { $0 }
)

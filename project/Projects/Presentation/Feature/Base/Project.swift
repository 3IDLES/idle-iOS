//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by choijunios on 2024/07/27
//

import ProjectDescription
import ProjectDescriptionHelpers
import ConfigurationPlugin
import DependencyPlugin

let project = Project(
    name: "Base",
    settings: .settings(
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        
        /// FeatureConcrete
        .target(
            name: "BaseFeature",
            destinations: DeploymentSettings.platforms,
            product: .staticFramework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                // Presentation
                D.Presentation.PresentationCore,
                D.Presentation.DSKit,

                // Domain
                D.Domain.UseCaseInterface,
                D.Domain.RepositoryInterface,
                
                // Data
                D.Data.ConcreteRepository,

                // ThirdParty
                D.ThirdParty.RxSwift,
                D.ThirdParty.RxCocoa,
                D.ThirdParty.NaverMapSDKForSPM,
                D.ThirdParty.FirebaseCrashlytics,
                D.ThirdParty.FirebaseAnalytics,
                D.ThirdParty.SDWebImageWebPCoder,
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        ),
        
        /// FeatureConcrete ExampleApp
        .target(
            name: "Base_ExampleApp",
            destinations: DeploymentSettings.platforms,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            infoPlist: IdleInfoPlist.exampleAppDefault,
            sources: ["ExampleApp/Sources/**"],
            resources: ["ExampleApp/Resources/**"],
            dependencies: [
                .target(name: "BaseFeature"),
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        ),
    ],
    schemes: [
        Scheme.makeSchemes(
            .target("BaseFeature"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        ),
        Scheme.makeSchemes(
            .target("Base_ExampleApp"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        )
    ].flatMap { $0 }
)

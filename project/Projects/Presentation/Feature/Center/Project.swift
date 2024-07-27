//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by choijunios on 2024/07/17
//

import ProjectDescription
import ProjectDescriptionHelpers
import ConfigurationPlugin
import DependencyPlugin

let project = Project(
    name: "Center",
    settings: .settings(
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        
        /// FeatureConcrete
        .target(
            name: "CenterFeature",
            destinations: DeploymentSettings.platform,
            product: .staticFramework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                // Presentation
                D.Presentation.BaseFeature,
                D.Presentation.PresentationCore,
                D.Presentation.DSKit,

                // Domain
                D.Domain.UseCaseInterface,
                D.Domain.RepositoryInterface,

                // ThirdParty
                D.ThirdParty.RxSwift,
                D.ThirdParty.RxCocoa,
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        ),
        
        /// FeatureConcrete ExampleApp
        .target(
            name: "Center_ExampleApp",
            destinations: DeploymentSettings.platform,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            infoPlist: IdleInfoPlist.exampleAppDefault,
            sources: ["ExampleApp/Sources/**"],
            resources: ["ExampleApp/Resources/**"],
            dependencies: [
                .target(name: "CenterFeature"),
                
                D.Domain.ConcreteUseCase,
                D.Data.ConcreteRepository,
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        ),
    ],
    schemes: [
        Scheme.makeSchemes(
            .target("CenterFeature"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        ),
        Scheme.makeSchemes(
            .target("Center_ExampleApp"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        )
    ].flatMap { $0 }
)

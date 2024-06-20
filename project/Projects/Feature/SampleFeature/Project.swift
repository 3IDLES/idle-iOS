//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 최준영 on 6/21/24.
//

import ProjectDescription
import ProjectDescriptionHelpers
import ConfigurationPlugin
import DependencyPlugin

let project = Project(
    name: "SampleFeature",
    settings: .settings(
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        
        /// FeatureConcrete
        .target(
            name: "SampleFeature",
            destinations: DeploymentSettings.platform,
            product: .staticFramework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                D.Presentation.PresentationCore,
                D.Presentation.DSKit,
                D.Domain.UseCaseInterface,
                D.Domain.RepositoryInterface,
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        ),
        
        /// FeatureConcrete ExampleApp
        .target(
            name: "SampleFeature_ExampleApp",
            destinations: DeploymentSettings.platform,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            infoPlist: IdleInfoPlist.exampleAppDefault,
            sources: ["ExampleApp/Sources/**"],
            resources: ["ExampleApp/Resources/**"],
            dependencies: [
                .target(name: "SampleFeature")
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        ),
    ],
    schemes: [
        Scheme.makeSchemes(
            .target("SampleFeature"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        ),
        Scheme.makeSchemes(
            .target("SampleFeature_ExampleApp"),
            configNames: [
                IdleConfiguration.debugConfigName,
                IdleConfiguration.releaseConfigName
            ]
        )
    ].flatMap { $0 }
)

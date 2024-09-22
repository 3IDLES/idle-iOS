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
    name: "DSKit",
    settings: .settings(
        configurations: IdleConfiguration.emptyConfigurations
    ),
    targets: [
        .target(
            name: "DSKit",
            destinations: DeploymentSettings.platforms,
            product: .framework,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            sources: ["Sources/**"],
            resources: ["Resources/**",],
            dependencies: [
                D.Domain.Entity,
                D.Presentation.PresentationCore,
                
                // ThirdParty
                D.ThirdParty.RxSwift,
                D.ThirdParty.RxCocoa,
                D.ThirdParty.FSCalendar,
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        ),
        
        // Component를 테스트하는 Example타겟
        .target(
            name: "DSKitExampleApp",
            destinations: DeploymentSettings.platforms,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: DeploymentSettings.deployment_version,
            infoPlist: IdleInfoPlist.exampleAppDefault,
            sources: ["ExampleApp/Sources/**"],
            resources: ["ExampleApp/Resources/**"],
            dependencies: [
                D.Presentation.DSKit,
            ],
            settings: .settings(
                configurations: IdleConfiguration.presentationConfigurations
            )
        ),
    ],
    resourceSynthesizers: .default
)

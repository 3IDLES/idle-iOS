//
//  Workspace.swift
//  ProjectDescriptionHelpers
//
//  Created by choijunyeong on 2024/06/19.
//

import ProjectDescription
import DependencyPlugin

let workspace = Workspace(
    name: "SWM-Idle",
    projects: [
        "Projects/**"
    ],
    schemes: [
        .scheme(
            name: "TestScheme",
            buildAction: .buildAction(targets: []),
            testAction: .targets(
                [
                    .testableTarget(
                        target: .project(
                            path: .relativeToRoot("Projects/Domain"),
                            target: "DomainTests"
                        )
                    ),
                    .testableTarget(
                        target: .project(
                            path: .relativeToRoot("Projects/Data"),
                            target: "DataTests"
                        )
                    )
                ],
                configuration: ConfigurationName.debug
            )
        )
    ]
)

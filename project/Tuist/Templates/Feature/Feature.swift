//
//  Feature.swift
//  ProjectDescriptionHelpers
//
//  Created by 최준영 on 6/21/24.
//

import Foundation
import ProjectDescription

private let projectName: Template.Attribute = .required("projectName")
private let author: Template.Attribute = .required("author")
private let currentDate: Template.Attribute = .required("currentDate")

let projectPath = "Projects/Presentation/\(projectName)"

let featureTemplate = Template(
    description: "A template for a new feature module",
    attributes: [
        projectName,
        author,
        currentDate
    ],
    items: [
        .directory(
            path: projectPath,
            sourcePath: .relativeToRoot("Scaffold/Feature/ExampleApp")
        ),
        .directory(
            path: projectPath,
            sourcePath: .relativeToRoot("Scaffold/Feature/Sources")
        ),
        .directory(
            path: projectPath,
            sourcePath: .relativeToRoot("Scaffold/Feature/Resources")
        ),
        .file(
            path: "\(projectPath)/Project.swift",
            templatePath: .relativeToRoot("Scaffold/Feature/Project.stencil")
        )
    ]
)

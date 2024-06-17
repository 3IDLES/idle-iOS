import ProjectDescription

let project = Project(
    name: "Project",
    targets: [
        .target(
            name: "Project",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Project",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                ]
            ),
            sources: ["Project/Sources/**"],
            resources: ["Project/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "ProjectTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.ProjectTests",
            infoPlist: .default,
            sources: ["Project/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Project")]
        ),
    ]
)

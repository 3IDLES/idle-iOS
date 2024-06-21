// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
//        productTypes: [
//            "RxSwift": .framework,
//        ]
    )
#endif

let package = Package(
    name: "Project",
    dependencies: [
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
        
        // RxSwift
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.1")
    ]
)

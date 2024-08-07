// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        productTypes: [
            "RxSwift": .framework,
            "RxCocoa": .framework,
        ],
        baseSettings: .settings(
            configurations: [
                .debug(name: "debug"),
                .release(name: "release")
            ]
        )
    )
#endif

let package = Package(
    name: "Project",
    dependencies: [
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
        // Alamofire
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.1"),
        // RxSwift
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.1"),
        // Swinject
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.1"),
        // KeyChainAccess
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        // Moya
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.3"),
        // FSCalendar
        .package(url: "https://github.com/WenchaoD/FSCalendar.git", from: "2.8.4"),
        // Naver map
        .package(url: "https://github.com/J0onYEong/NaverMapSDKForSPM.git", from: "1.0.0"),
    ]
)

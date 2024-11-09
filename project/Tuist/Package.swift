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
            .release(name: "release"),
                .release(name: "qa")
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
        
        // RxSwift
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.1"),
        
        
        // MARK: DI
        // Swinject
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.1"),
        
        
        // MARK: KeyChain
        // KeyChainAccess
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        
        
        // MARK: Networking
        // Alamofire
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.1"),
        // Moya
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.3"),
        
        
        // MARK: UI
        // FSCalendar
        .package(url: "https://github.com/WenchaoD/FSCalendar.git", from: "2.8.4"),
        // Naver map
        .package(url: "https://github.com/J0onYEong/NaverMapSDKForSPM.git", from: "1.0.0"),
        // WebpCoder
        .package(url: "https://github.com/SDWebImage/SDWebImageWebPCoder.git", from: "0.14.6"),
        
        
        // MARK: Product logging
        // Firebase
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.2.0"),
        // Amplitude
        .package(url: "https://github.com/amplitude/Amplitude-Swift", from: "1.9.2"),
    ]
)

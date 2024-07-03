//
//  BuildSettings.swift
//  EnvironmentPlugin
//
//  Created by 최준영 on 6/19/24.
//

import ProjectDescription

public enum IdleConfiguration {
    
    private enum Name {
        fileprivate static let debug: ConfigurationName = "debug"
        fileprivate static let release: ConfigurationName = "release"
    }
    
    private enum XcconfigFile {
        static let appDebug: Path = .relativeToRoot("Secrets/XcodeConfiguration/App/appDebug.xcconfig")
        static let appRelease: Path = .relativeToRoot("Secrets/XcodeConfiguration/App/appRelease.xcconfig")
        
        static let domainDebug: Path = .relativeToRoot("Secrets/XcodeConfiguration/Domain/domainDebug.xcconfig")
        static let domainRelease: Path = .relativeToRoot("Secrets/XcodeConfiguration/Domain/domainRelease.xcconfig")
        
        static let dataDebug: Path = .relativeToRoot("Secrets/XcodeConfiguration/Data/dataDebug.xcconfig")
        static let dataRelease: Path = .relativeToRoot("Secrets/XcodeConfiguration/Data/dataRelease.xcconfig")
        
        static let presentationDebug: Path = .relativeToRoot("Secrets/XcodeConfiguration/Presentation/presentationDebug.xcconfig")
        static let presentationRelease: Path = .relativeToRoot("Secrets/XcodeConfiguration/Presentation/presentationRelease.xcconfig")
    }
    
    public static let debugConfigName = Name.debug
    public static let releaseConfigName = Name.release
    
    private static let appDebug: Configuration = .debug(name: debugConfigName, xcconfig: XcconfigFile.appDebug)
    private static let appRelease: Configuration = .release(name: releaseConfigName, xcconfig: XcconfigFile.appRelease)
    
    private static let domainDebug: Configuration = .debug(name: debugConfigName, xcconfig: XcconfigFile.domainDebug)
    private static let domainRelease: Configuration = .release(name: releaseConfigName, xcconfig: XcconfigFile.domainRelease)
    
    private static let dataDebug: Configuration = .debug(name: debugConfigName, xcconfig: XcconfigFile.dataDebug)
    private static let dataRelease: Configuration = .release(name: releaseConfigName, xcconfig: XcconfigFile.dataRelease)
    
    private static let presentationDebug: Configuration = .debug(name: debugConfigName, xcconfig: XcconfigFile.presentationDebug)
    private static let presentationRelease: Configuration = .release(name: releaseConfigName, xcconfig: XcconfigFile.presentationRelease)
    
    public static let emptyConfigurations: [Configuration] = [
        .debug(name: debugConfigName),
        .release(name: releaseConfigName)
    ]
    
    public static let appConfigurations: [Configuration] = [appDebug, appRelease]
    public static let domainConfigurations: [Configuration] = [domainDebug, domainRelease]
    public static let dataConfigurations: [Configuration] = [dataDebug, dataRelease]
    public static let presentationConfigurations: [Configuration] = [presentationDebug, presentationRelease]
}

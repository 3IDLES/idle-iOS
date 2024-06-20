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
        static let appDebug: Path = .relativeToRoot("XcodeConfiguration/App/appDebug.xcconfig")
        static let appRelease: Path = .relativeToRoot("XcodeConfiguration/App/appRelease.xcconfig")
        
        static let domainDebug: Path = .relativeToRoot("XcodeConfiguration/Domain/domainDebug.xcconfig")
        static let domainRelease: Path = .relativeToRoot("XcodeConfiguration/Domain/domainRelease.xcconfig")
    }
    
    public static let debugConfigName = Name.debug
    public static let releaseConfigName = Name.release
    
    private static let appDebug: Configuration = .debug(name: debugConfigName, xcconfig: XcconfigFile.appDebug)
    private static let appRelease: Configuration = .release(name: releaseConfigName, xcconfig: XcconfigFile.appRelease)
    
    private static let domainDebug: Configuration = .debug(name: debugConfigName, xcconfig: XcconfigFile.domainDebug)
    private static let domainRelease: Configuration = .release(name: releaseConfigName, xcconfig: XcconfigFile.domainRelease)
    
    public static let emptyConfigurations: [Configuration] = [
        .debug(name: debugConfigName),
        .release(name: releaseConfigName)
    ]
    
    public static let appConfigurations: [Configuration] = [appDebug, appRelease]
    public static let domainConfigurations: [Configuration] = [domainDebug, domainRelease]
}

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
        static let appDebug: Path = .relativeToRoot("XcodeConfiguration/appDebug.xcconfig")
        static let appRelease: Path = .relativeToRoot("XcodeConfiguration/appRelease.xcconfig")
        static let domainDebug: Path = .relativeToRoot("XcodeConfiguration/Domain/domainDebug.xcconfig")
        static let domainRelease: Path = .relativeToRoot("XcodeConfiguration/Domain/domainRelease.xcconfig")
    }
    
    private static let appDebug: Configuration = .debug(name: Name.debug, xcconfig: XcconfigFile.appDebug)
    private static let appRelease: Configuration = .release(name: Name.release, xcconfig: XcconfigFile.appRelease)
    
    public static let appDebugConfigName = Name.debug
    public static let appReleaseConfigName = Name.release
    private static let domainDebug: Configuration = .debug(name: debugConfigName, xcconfig: XcconfigFile.domainDebug)
    private static let domainRelease: Configuration = .release(name: releaseConfigName, xcconfig: XcconfigFile.domainRelease)
    
    public static let appConfigurations: [Configuration] = [appDebug, appRelease]
    public static let domainConfigurations: [Configuration] = [domainDebug, domainRelease]
}

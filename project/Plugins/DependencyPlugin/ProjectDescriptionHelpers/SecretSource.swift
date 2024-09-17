//
//  SecretSource.swift
//  DependencyPlugin
//
//  Created by choijunios on 7/3/24.
//

import ProjectDescription

// MARK: SecretSource
public enum SecretSource {
    
    public static let networkDataSource: SourceFileGlob = .glob(.relativeToRoot("Secrets/SwiftCode/NetworkDataSource/**"))
    
    public static let amplitudeConfig: SourceFileGlob = .glob(.relativeToRoot("Secrets/SwiftCode/Amplitude/**"))
}

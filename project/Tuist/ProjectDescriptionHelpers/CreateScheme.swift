//
//  CreateScheme.swift
//  Config
//
//  Created by 최준영 on 6/20/24.
//

import ProjectDescription

public extension Scheme {
    
    static func makeInterfaceSchemes(_ targetReference: TargetReference, configNames: [ConfigurationName]) -> [Scheme] {
        
        return configNames.map { configName in
            
            .makeInterfaceScheme(
                targetReference,
                configName: configName
            )
        }
    }
    
    static func makeInterfaceScheme(_ targetReference: TargetReference, configName: ConfigurationName) -> Scheme {
        
        return .scheme(
            name: "\(targetReference.targetName)-\(configName.rawValue)",
            buildAction: .buildAction(targets: [targetReference]),
            runAction: .runAction(configuration: configName),
            archiveAction: .archiveAction(configuration: configName)
        )
    }
    
    static func makeTestableSchemes(_ targetReference: TargetReference, testableTarget: TargetReference, configNames: [ConfigurationName]) -> [Scheme] {
        
        return configNames.map { configName in
                .makeTestableScheme(
                    targetReference,
                    testableTarget: testableTarget,
                    configName: configName
                )
        }
    }
    
    static func makeTestableScheme(_ targetReference: TargetReference, testableTarget: TargetReference, configName: ConfigurationName) -> Scheme {
        
        return .scheme(
            name: "\(targetReference.targetName)_\(configName.rawValue)",
            buildAction: .buildAction(targets: [targetReference]),
            testAction: .targets(
                [.testableTarget(target: testableTarget)],
                configuration: configName
            ),
            runAction: .runAction(configuration: configName),
            archiveAction: .archiveAction(configuration: configName)
        )
    }
}

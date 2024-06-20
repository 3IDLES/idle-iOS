//
//  InfoPlist.swift
//  ConfigurationPlugin
//
//  Created by 최준영 on 6/19/24.
//

import ProjectDescription

public enum IdleInfoPlist {
    
    public static let appDefault: InfoPlist = .extendingDefault(with: [
        "UILaunchStoryboardName": "LaunchScreen.storyboard",
        "CFBundleDisplayName" : "$(BUNDLE_DISPLAY_NAME)",
        "UIApplicationSceneManifest": [
            "UIApplicationSupportsMultipleScenes": false,
            "UISceneConfigurations": [
                "UIWindowSceneSessionRoleApplication": [
                    [
                        "UISceneConfigurationName": "Default Configuration",
                        "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                    ]
                ]
            ]
        ]
    ])
    
    public static let exampleAppDefault: InfoPlist = .extendingDefault(with: [
        "UILaunchStoryboardName": "LaunchScreen.storyboard",
        "CFBundleDisplayName" : "$(BUNDLE_DISPLAY_NAME)",
        "UIApplicationSceneManifest": [
            "UIApplicationSupportsMultipleScenes": false,
            "UISceneConfigurations": [
                "UIWindowSceneSessionRoleApplication": [
                    [
                        "UISceneConfigurationName": "Default Configuration",
                        "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                    ]
                ]
            ]
        ]
    ])
}



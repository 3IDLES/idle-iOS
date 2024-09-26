//
//  InfoPlist.swift
//  ConfigurationPlugin
//
//  Created by 최준영 on 6/19/24.
//

import ProjectDescription

public enum IdleInfoPlist {
    
    public static let mainApp: InfoPlist = .extendingDefault(with: [
        
        "CFBundleDisplayName": "$(BUNDLE_DISPLAY_NAME)",
        
        "CFBundleShortVersionString" : "1.0.1",
        
        "NSAppTransportSecurity" : [
            "NSAllowsArbitraryLoads" : true
        ],
        
        "UILaunchStoryboardName": "LaunchScreen.storyboard",
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
        ],
        
        // 멀티 스크린 미지원
        "UIRequiresFullScreen": true,
        
        // 지원하는 화면 모드
        "UISupportedInterfaceOrientations" : [
            "UIInterfaceOrientationPortrait"
        ],
        
        // iPad 지원하는 화면 모드
        "UISupportedInterfaceOrientations~ipad" : [
            "UIInterfaceOrientationPortrait"
        ],
        
        "NMFClientId": "$(NAVER_API_CLIENT_ID)",

        // 네트워크 사용 메세지
        "NSLocalNetworkUsageDescription": "이 앱은 로컬 네트워크를 통해 서버에 연결하여 데이터를 주고받기 위해 로컬 네트워크 접근 권한이 필요합니다."
    ])
    
    public static let exampleAppDefault: InfoPlist = .extendingDefault(with: [
        "Privacy - Photo Library Usage Description" : "프로필 사진 설정을 위해 사진 라이브러리에 접근합니다.",
        "NSAppTransportSecurity" : [
            "NSAllowsArbitraryLoads" : true
        ],
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
        ],
        
        "NMFClientId": "$(NAVER_API_CLIENT_ID)"
    ])
}



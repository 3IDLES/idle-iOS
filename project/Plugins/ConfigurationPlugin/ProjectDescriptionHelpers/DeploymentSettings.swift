//
//  DeploymentSettings.swift
//  Packages
//
//  Created by 최준영 on 6/19/24.
//

import ProjectDescription

public enum DeploymentSettings {
    
    /// SceneDelegate를 지원하는 iOS 13이상 버전을 요구합니다.
    public static let productDisplayName = "케어밋"
    public static let deployment_version = DeploymentTargets.iOS("15.0")
    public static let platform = Destinations.iOS
    public static let workspace_name = "idle_workspace"
}

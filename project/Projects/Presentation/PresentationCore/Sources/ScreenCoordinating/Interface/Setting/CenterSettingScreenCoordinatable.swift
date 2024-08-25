//
//  asd.swift
//  PresentationCore
//
//  Created by choijunios on 8/25/24.
//

import Foundation

public protocol CenterSettingScreenCoordinatable: ParentCoordinator {
    /// 시설 관리자 계정을 지우는 작업을 시작합니다.
    func startRemoveCenterAccountFlow()
}

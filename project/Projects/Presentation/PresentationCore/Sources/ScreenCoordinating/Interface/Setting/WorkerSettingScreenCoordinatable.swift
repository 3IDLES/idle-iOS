//
//  WorkerSettingScreenCoordinatable.swift
//  PresentationCore
//
//  Created by choijunios on 8/25/24.
//

import Foundation

public protocol WorkerSettingScreenCoordinatable: ParentCoordinator {
    /// 요양보호사 계정을 지우는 작업을 시작합니다.
    func startRemoveWorkerAccountFlow()
}

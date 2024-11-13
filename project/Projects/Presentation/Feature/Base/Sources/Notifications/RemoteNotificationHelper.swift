//
//  RemoteNotificationHelper.swift
//  BaseFeature
//
//  Created by choijunios on 10/17/24.
//

import Foundation
import Domain


import RxSwift

public protocol RemoteNotificationHelper {
    
    var deeplinks: BehaviorSubject<DeeplinkBundle> { get }
    
    /// 인앱에서 발생한 Notification을 처리합니다.
    func handleNotificationInApp(detail: NotificationDestinationForInApp)
}

public enum DeepLinkPathComponent {
    
    // MARK: Center
    case centerMainPage
    case postApplicantPage
    case splashPage
    
    // MARK: Worker
    case workerMainPage
    case postDetailForWorkerPage
}

public enum PreDefinedDeeplinkPath: String {
    
    /// 센터관리자가 등록한 공고에 요양보호사가 지원하는 상황
    case postApplicant = "APPLICANT"
    
    case newJobPostingForWorker = "NEW_JOB_POSTING"
    
    public var outsideLinks: [DeepLinkPathComponent] {
        switch self {
        case .postApplicant:
            [.centerMainPage, .postApplicantPage]
        case .newJobPostingForWorker:
            [.workerMainPage, .postDetailForWorkerPage]
        }
    }
    
    public var insideLinks: [DeepLinkPathComponent] {
        switch self {
        case .postApplicant:
            [.postApplicantPage]
        case .newJobPostingForWorker:
            [.postDetailForWorkerPage]
        }
    }
}

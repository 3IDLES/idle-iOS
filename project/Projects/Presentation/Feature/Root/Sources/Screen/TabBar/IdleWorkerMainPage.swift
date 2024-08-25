//
//  IdleWorkerMainPage.swift
//  DSKit
//
//  Created by choijunios on 8/15/24.
//

import UIKit
import DSKit

public enum IdleWorkerMainPage: IdleMainPageItemable {
    
    public enum State {
        case idle
        case accent
    }
    
    case home
    case preferredPost
    case setting
    
    public init?(index: Int) {
        switch index {
        case 0: self = .home
        case 1: self = .preferredPost
        case 2: self = .setting
        default: return nil
        }
    }
        
    public var pageOrderNumber: Int {
        switch self {
        case .home:
            return 0
        case .preferredPost:
            return 1
        case .setting:
            return 2
        }
    }
    
    public var tabItemIcon: UIImage {
        switch self {
        case .home:
            return DSIcon.workerHome.image
        case .preferredPost:
            return DSIcon.workerPost.image
        case .setting:
            return DSIcon.workerSetting.image
        }
    }
    
    public var tabItemText: String {
        switch self {
        case .home:
            "홈"
        case .preferredPost:
            "공고"
        case .setting:
            "설정"
        }
    }
}

//
//  File.swift
//  WorkerMainPageFeature
//
//  Created by choijunios on 10/4/24.
//

import UIKit
import BaseFeature
import DSKit

enum WorkerMainPageTab {
    case postBoard
    case preferredPost
    case setting
}

extension WorkerMainPageTab: TabBarItem {
    
    enum State {
        case idle
        case accent
    }
    
    init?(index: Int) {
        switch index {
        case 0: self = .postBoard
        case 1: self = .preferredPost
        case 2: self = .setting
        default: return nil
        }
    }
        
    var pageOrderNumber: Int {
        switch self {
        case .postBoard:
            return 0
        case .preferredPost:
            return 1
        case .setting:
            return 2
        }
    }
    
    var tabItemIdleIcon: UIImage {
        switch self {
        case .postBoard:
            return DSIcon.dockHomeNormal.image
        case .preferredPost:
            return DSIcon.dockPostNormal.image
        case .setting:
            return DSIcon.dockSettingNormal.image
        }
    }
    
    var tabItemAccentIcon: UIImage {
        switch self {
        case .postBoard:
            return DSIcon.dockHomeAccent.image
        case .preferredPost:
            return DSIcon.dockPostAccent.image
        case .setting:
            return DSIcon.dockSettingAccent.image
        }
    }
    
    var tabItemText: String {
        switch self {
        case .postBoard:
            "홈"
        case .preferredPost:
            "공고"
        case .setting:
            "설정"
        }
    }
}

//
//  CenterMainPageTab.swift
//  CenterMainPageFeature
//
//  Created by choijunios on 10/3/24.
//

import UIKit
import BaseFeature
import DSKit

enum CenterMainPageTab {
    case postBoard
    case setting
}

extension CenterMainPageTab: TabBarItem {
    
    enum State {
        case idle
        case accent
    }
    
    init?(index: Int) {
        switch index {
        case 0: self = .postBoard
        case 1: self = .setting
        default: return nil
        }
    }
        
    var pageOrderNumber: Int {
        switch self {
        case .postBoard:
            return 0
        case .setting:
            return 1
        }
    }
    
    var tabItemIdleIcon: UIImage {
        switch self {
        case .postBoard:
            return DSIcon.dockHomeNormal.image
        case .setting:
            return DSIcon.dockSettingNormal.image
        }
    }
    
    var tabItemAccentIcon: UIImage {
        switch self {
        case .postBoard:
            return DSIcon.dockHomeAccent.image
        case .setting:
            return DSIcon.dockSettingAccent.image
            
        }
    }
    
    var tabItemText: String {
        switch self {
        case .postBoard:
            "공고"
        case .setting:
            "설정"
        }
    }
}

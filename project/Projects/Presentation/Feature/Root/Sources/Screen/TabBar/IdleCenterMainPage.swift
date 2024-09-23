//
//  IdleCenterMainPage.swift
//  RootFeature
//
//  Created by choijunios on 8/19/24.
//

import UIKit
import DSKit

public enum IdleCenterMainPage: IdleMainPageItemable {
    
    public enum State {
        case idle
        case accent
    }
    
    case home
    case setting
    
    public init?(index: Int) {
        switch index {
        case 0: self = .home
        case 1: self = .setting
        default: return nil
        }
    }
        
    public var pageOrderNumber: Int {
        switch self {
        case .home:
            return 0
        case .setting:
            return 1
        }
    }
    
    public var tabItemIdleIcon: UIImage {
        switch self {
        case .home:
            return DSIcon.dockHomeNormal.image
        case .setting:
            return DSIcon.dockSettingNormal.image
        }
    }
    
    public var tabItemAccentIcon: UIImage {
        switch self {
        case .home:
            return DSIcon.dockHomeAccent.image
        case .setting:
            return DSIcon.dockSettingAccent.image
            
        }
    }
    
    public var tabItemText: String {
        switch self {
        case .home:
            "공고"
        case .setting:
            "설정"
        }
    }
}

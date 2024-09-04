//
//  RecruitmentPostType.swift
//  Entity
//
//  Created by choijunios on 9/4/24.
//

import Foundation

public enum RecruitmentPostType {
    case native
    case workNet
    
    public var upscaleEngWord: String {
        switch self {
        case .native:
            "CAREMEET"
        case .workNet:
            "WORKNET"
        }
    }
}

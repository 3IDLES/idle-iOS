//
//  ForceUpdateInfo.swift
//  Entity
//
//  Created by choijunios on 9/13/24.
//

import Foundation

public struct ForceUpdateInfo: Decodable {
    public let minVersion: String
    public let marketUrl: String
    public let noticeMsg: String
}

//
//  CenterJoinStatusInfoVO.swift
//  Entity
//
//  Created by choijunios on 9/7/24.
//

import Foundation

public struct CenterJoinStatusInfoVO: Codable {
    public let id: String
    public let managerName: String
    public let phoneNumber: String
    public let centerManagerAccountStatus: CenterAccountStatus
}

public enum CenterAccountStatus: String, Codable {
    case new = "NEW"
    case pending = "PENDING"
    case approved = "APPROVED"
}

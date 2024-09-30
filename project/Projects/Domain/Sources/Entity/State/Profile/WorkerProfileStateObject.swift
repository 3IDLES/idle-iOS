//
//  WorkerProfileStateObject.swift
//  Entity
//
//  Created by choijunios on 8/10/24.
//

import Foundation

public struct WorkerProfileStateObject: Codable {
    public var experienceYear: Int?
    public var roadNameAddress: String?
    public var lotNumberAddress: String?
    public var introduce: String?
    public var speciality: String?
    public var isJobFinding: Bool?
    
    public init(experienceYear: Int? = nil, roadNameAddress: String? = nil, lotNumberAddress: String? = nil, introduce: String? = nil, speciality: String? = nil, isJobFinding: Bool? = nil) {
        self.experienceYear = experienceYear
        self.roadNameAddress = roadNameAddress
        self.lotNumberAddress = lotNumberAddress
        self.introduce = introduce
        self.speciality = speciality
        self.isJobFinding = isJobFinding
    }
    
    public static let `default`: WorkerProfileStateObject = .init()
}

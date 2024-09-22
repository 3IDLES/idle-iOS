//
//  WorknetRecruitmentPostDetailVO.swift
//  Entity
//
//  Created by choijunios on 9/6/24.
//

import Foundation

public struct WorknetRecruitmentPostDetailVO: Decodable {
    
    public let id: String
    public let title: String
    public let content: String
    public let clientAddress: String
    public let longitude: String?
    public let latitude: String?
    public let distance: Int
    public let createdAt: Date
    public let payInfo: String
    public let workingTime: String
    public let workingSchedule: String
    public let applyDeadline: Date
    public let recruitmentProcess: String
    public let applyMethod: String
    public let requiredDocumentation: String
    public let centerName: String
    public let centerAddress: String
    public let jobPostingUrl: String
    public let jobPostingType: RecruitmentPostType
    public let isFavorite: Bool
    
    public init(
        id: String,
        title: String,
        content: String,
        clientAddress: String,
        longitude: String?,
        latitude: String?,
        distance: Int,
        createdAt: Date,
        payInfo: String,
        workingTime: String,
        workingSchedule: String,
        applyDeadline: Date,
        recruitmentProcess: String,
        applyMethod: String,
        requiredDocumentation: String,
        centerName: String,
        centerAddress: String,
        jobPostingUrl: String,
        jobPostingType: RecruitmentPostType,
        isFavorite: Bool
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.clientAddress = clientAddress
        self.longitude = longitude
        self.latitude = latitude
        self.distance = distance
        self.createdAt = createdAt
        self.payInfo = payInfo
        self.workingTime = workingTime
        self.workingSchedule = workingSchedule
        self.applyDeadline = applyDeadline
        self.recruitmentProcess = recruitmentProcess
        self.applyMethod = applyMethod
        self.requiredDocumentation = requiredDocumentation
        self.centerName = centerName
        self.centerAddress = centerAddress
        self.jobPostingUrl = jobPostingUrl
        self.jobPostingType = jobPostingType
        self.isFavorite = isFavorite
    }
}

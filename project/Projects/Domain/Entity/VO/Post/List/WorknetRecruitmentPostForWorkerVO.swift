//
//  WorknetRecruitmentPostVO.swift
//  Entity
//
//  Created by choijunios on 9/6/24.
//

import Foundation

public struct WorknetRecruitmentPostVO: RecruitmentPostForWorkerRepresentable {
    
    public let postType: RecruitmentPostType
    
    public let id: String
    public let title: String
    public let distance: Int
    public let workingTime: String
    public let workingSchedule: String
    public let payInfo: String
    public let applyDeadline: Date
    public let isFavorite: Bool
    
    public init(
        id: String,
        title: String,
        distance: Int,
        workingTime: String,
        workingSchedule: String,
        payInfo: String,
        applyDeadline: Date,
        isFavorite: Bool,
        postType: RecruitmentPostType
    ) {
        self.id = id
        self.title = title
        self.distance = distance
        self.workingTime = workingTime
        self.workingSchedule = workingSchedule
        self.payInfo = payInfo
        self.applyDeadline = applyDeadline
        self.isFavorite = isFavorite
        self.postType = postType
    }
}

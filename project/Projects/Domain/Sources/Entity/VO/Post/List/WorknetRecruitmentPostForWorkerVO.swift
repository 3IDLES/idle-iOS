//
//  WorknetRecruitmentPostVO.swift
//  Entity
//
//  Created by choijunios on 9/6/24.
//

import Foundation

public struct WorknetRecruitmentPostVO: RecruitmentPostForWorkerRepresentable {
    
    // protocol required
    public var postType: RecruitmentPostType
    public var beFavoritedTime: Date?
    
    public let id: String
    public let title: String
    public let distance: Int
    public let workingTime: String
    public let workingSchedule: String
    public let payInfo: String
    public let applyDeadlineString: String
    public let isFavorite: Bool
    
    public init(
        id: String,
        title: String,
        distance: Int,
        workingTime: String,
        workingSchedule: String,
        payInfo: String,
        applyDeadlineString: String,
        isFavorite: Bool,
        postType: RecruitmentPostType,
        beFavoritedTime: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.distance = distance
        self.workingTime = workingTime
        self.workingSchedule = workingSchedule
        self.payInfo = payInfo
        self.applyDeadlineString = applyDeadlineString
        self.isFavorite = isFavorite
        self.postType = postType
        self.beFavoritedTime = beFavoritedTime
    }
}

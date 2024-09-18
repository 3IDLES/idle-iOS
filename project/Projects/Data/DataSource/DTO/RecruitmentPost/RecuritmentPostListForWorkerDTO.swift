//
//  RecuritmentPostListForWorkerDTO.swift
//  NetworkDataSource
//
//  Created by choijunios on 8/16/24.
//

import Foundation
import Entity

public protocol EntityRepresentable: Codable {
    associatedtype Entity
    func toEntity() -> Entity
}

public struct RecruitmentPostListForWorkerDTO<T: EntityRepresentable>: EntityRepresentable where T.Entity: RecruitmentPostForWorkerRepresentable {

    public let items: [T]
    public let next: String?
    public let total: Int
    
    public func toEntity() -> RecruitmentPostListForWorkerVO {
        
        return .init(
            posts: items.map { $0.toEntity() },
            nextPageId: next,
            fetchedPostCount: total
        )
    }
}

public struct FavoriteNativeRecruitmentPostListForWorkerDTO<T: EntityRepresentable>: EntityRepresentable where T.Entity: RecruitmentPostForWorkerRepresentable {
    
    public let favoriteJobPostings: [T]
    
    public func toEntity() -> [RecruitmentPostForWorkerRepresentable] {
        
        favoriteJobPostings.map { dto in
            dto.toEntity()
        }
    }
}

public struct FavoriteWorknetRecruitmentPostListForWorkerDTO<T: EntityRepresentable>: EntityRepresentable where T.Entity: RecruitmentPostForWorkerRepresentable {
    
    public let favoriteCrawlingJobPostings: [T]
    
    public func toEntity() -> [RecruitmentPostForWorkerRepresentable] {
        
        favoriteCrawlingJobPostings.map { dto in
            dto.toEntity()
        }
    }
}

// MARK: Worknet post의 카드 정보
public struct WorkNetRecruitmentPostForWorkerDTO: EntityRepresentable {
     
    public let id: String
    public let title: String
    public let distance: Int
    public let workingTime: String
    public let workingSchedule: String
    public let payInfo: String
    public let applyDeadline: String
    public let isFavorite: Bool
    public let jobPostingType: RecruitmentPostType
    public let createdAt: String?
    
    public func toEntity() -> WorknetRecruitmentPostVO {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let deadlineDate = dateFormatter.date(from: self.applyDeadline)!
        
        let iso8601Formatter = ISO8601DateFormatter()
        var createdDate: Date?
        if let createdAt {
            createdDate = iso8601Formatter.date(from: createdAt)
        }
        
        return .init(
            id: id,
            title: title,
            distance: distance,
            workingTime: workingTime,
            workingSchedule: workingSchedule,
            payInfo: payInfo,
            applyDeadline: deadlineDate,
            isFavorite: isFavorite,
            postType: jobPostingType,
            beFavoritedTime: createdDate
        )
    }
}

// MARK: Native Post의 카드 정보입니다.
public struct NativeRecruitmentPostForWorkerDTO: EntityRepresentable {
    
    public let isExperiencePreferred: Bool
    public let id: String
    public let weekdays: [String]
    public let startTime: String
    public let endTime: String
    public let payType: String
    public let payAmount: Int
    public let roadNameAddress: String
    public let lotNumberAddress: String
    public let gender: String
    public let age: Int
    public let careLevel: Int
    public let applyDeadlineType: String
    public let applyDeadline: String?
    public let distance: Int
    public let applyTime: String?
    public let isFavorite: Bool
    public let jobPostingType: RecruitmentPostType
    public let createdAt: String?
    
    public func toEntity() -> NativeRecruitmentPostForWorkerVO {
        
        let workDayList = weekdays.map({ dayText in
            WorkDay.toEntity(text: dayText)
        })
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let deadlineDate = self.applyDeadline != nil ? dateFormatter.date(from: self.applyDeadline!) : nil
        let applyDate = self.applyTime != nil ? dateFormatter.date(from: self.applyDeadline!) : nil
        
        let iso8601Formatter = ISO8601DateFormatter()
        var createdDate: Date?
        if let createdAt {
            createdDate = iso8601Formatter.date(from: createdAt)
        }
        
        return .init(
            postId: id,
            workDays: workDayList,
            startTime: startTime,
            endTime: endTime,
            roadNameAddress: roadNameAddress,
            lotNumberAddress: lotNumberAddress,
            gender: Gender.toEntity(text: gender),
            age: age,
            cardGrade: CareGrade(rawValue: careLevel-1)!,
            isExperiencePreferred: isExperiencePreferred,
            applyDeadlineType: ApplyDeadlineType.toEntity(text: applyDeadlineType),
            applyDeadlineDate: deadlineDate,
            payType: PaymentType.toEntity(text: payType),
            payAmount: String(payAmount),
            distanceFromWorkPlace: distance,
            applyTime: applyDate,
            isFavorite: isFavorite,
            postType: jobPostingType,
            beFavoritedTime: createdDate
        )
    }
}


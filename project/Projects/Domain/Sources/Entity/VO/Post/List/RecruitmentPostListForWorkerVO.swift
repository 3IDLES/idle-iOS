//
//  RecruitmentPostListForWorkerVO.swift
//  Entity
//
//  Created by choijunios on 9/6/24.
//

import Foundation

public struct RecruitmentPostListForWorkerVO {

    public let posts: [RecruitmentPostForWorkerRepresentable]
    public let nextPageId: String?
    public let fetchedPostCount: Int
    
    public init(posts: [RecruitmentPostForWorkerRepresentable], nextPageId: String?, fetchedPostCount: Int) {
        self.posts = posts
        self.nextPageId = nextPageId
        self.fetchedPostCount = fetchedPostCount
    }
}
public protocol RecruitmentPostForWorkerRepresentable {
    var postType: PostOriginType { get }
    var beFavoritedTime: Date? { get }
}

//
//  ChattingListItemVO.swift
//  Domain
//
//  Created by choijunios on 11/5/24.
//

import Foundation

public struct ChattingListItemVO {
    
    public let id: String
    public let counterPartName: String
    public let latestChat: String
    public let latestChatTime: Date
    
    public init(
        id: String,
        counterPartName: String,
        latestChat: String,
        latestChatTime: Date
    ) {
        self.id = id
        self.counterPartName = counterPartName
        self.latestChat = latestChat
        self.latestChatTime = latestChatTime
    }
}

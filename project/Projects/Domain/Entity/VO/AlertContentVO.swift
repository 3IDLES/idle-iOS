//
//  AlertContentVO.swift
//  Entity
//
//  Created by choijunios on 7/18/24.
//

import Foundation

public struct DefaultAlertContentVO {
    
    public let title: String
    public let message: String
    
    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }
    
    public static let `default` = DefaultAlertContentVO(
        title: "오류",
        message: "동작을 수행하지 못했습니다."
    )
}

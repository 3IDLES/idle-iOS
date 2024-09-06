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
    public let onDismiss: (() -> ())?
    
    public init(title: String, message: String, onDismiss: (() -> ())? = nil) {
        self.title = title
        self.message = message
        self.onDismiss = onDismiss
    }
    
    public static let `default` = DefaultAlertContentVO(
        title: "시스템 오류",
        message: "동작을 수행하지 못했습니다."
    )
}

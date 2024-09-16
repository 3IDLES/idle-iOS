//
//  AnonymousCompleteVCRenderObject.swift
//  PresentationCore
//
//  Created by choijunios on 9/16/24.
//

import Foundation

public struct AnonymousCompleteVCRenderObject {
    public let titleText: String
    public let descriptionText: String
    public let completeButtonText: String
    public let onComplete: (() -> ())?
    
    public init(
        titleText: String,
        descriptionText: String,
        completeButtonText: String,
        onComplete: (() -> Void)?
    ) {
        self.titleText = titleText
        self.descriptionText = descriptionText
        self.completeButtonText = completeButtonText
        self.onComplete = onComplete
    }
}

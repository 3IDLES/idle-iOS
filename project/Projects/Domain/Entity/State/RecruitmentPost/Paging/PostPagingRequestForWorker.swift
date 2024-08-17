//
//  PostPagingRequestForWorker.swift
//  Entity
//
//  Created by choijunios on 8/17/24.
//

import Foundation

public enum PostPagingRequestForWorker {
    case native(nextPageId: String?)
    case thirdParty(nextPageId: String?)
}

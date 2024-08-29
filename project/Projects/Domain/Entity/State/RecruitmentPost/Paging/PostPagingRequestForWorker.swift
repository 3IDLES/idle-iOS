//
//  PostPagingRequestForWorker.swift
//  Entity
//
//  Created by choijunios on 8/17/24.
//

import Foundation

public enum PostPagingRequestForWorker {
    public enum Source {
        case native
        case thirdParty
    }
    case initial
    case paging(source: Source, nextPageId: String?)
}

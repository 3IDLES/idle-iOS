//
//  ImageUploadInfo.swift
//  Entity
//
//  Created by choijunios on 7/20/24.
//

import Foundation

public struct ImageUploadInfo {
    public let data: Data
    public let ext: String
    
    public init(data: Data, ext: String) {
        self.data = data
        self.ext = ext
    }
}

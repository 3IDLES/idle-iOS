//
//  ImageDownLoadInfo.swift
//  Entity
//
//  Created by choijunios on 9/21/24.
//

import Foundation

public struct ImageDownLoadInfo: Codable {
    
    public let imageURL: URL
    public let imageFormat: ImageFormat
    
    public init(
        imageURL: URL,
        imageFormat: ImageFormat
    ) {
        self.imageURL = imageURL
        self.imageFormat = imageFormat
    }
}

public enum ImageFormat: String, Codable, Equatable {
    case jpg = "JPG"
    case jpeg = "JPEG"
    case png = "PNG"
    case gif = "GIF"
    case webp = "WEBP"
//    case svg = "SVG"
}

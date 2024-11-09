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
    
    public static func parseURL(string urlString: String) -> ImageDownLoadInfo? {
        
        guard let expString = urlString.split(separator: ".").last else {
            return nil
        }
        
        let imageFormat = expString.uppercased()
        
        guard let format = ImageFormat(rawValue: imageFormat), let url = URL(string: urlString) else {
            return nil
        }
        
        return .init(
            imageURL: url,
            imageFormat: format
        )
    }
}

public enum ImageFormat: String, Codable, Equatable {
    case jpeg = "JPEG"
    case png = "PNG"
    case gif = "GIF"
    case webp = "WEBP"
//    case svg = "SVG"
}

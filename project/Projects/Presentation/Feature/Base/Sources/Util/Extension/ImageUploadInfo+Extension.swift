//
//  asd.swift
//  BaseFeature
//
//  Created by choijunios on 9/21/24.
//

import Foundation
import Domain


import SDWebImageWebPCoder

public extension ImageUploadInfo {
    
    private static let coder = {
        let WebPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(WebPCoder)
        return SDImageCodersManager.shared
    }()
    
    static func create(image: UIImage) -> Self? {
        
        if let webpData = coder.encodedData(with: image, format: .webP) {
            return .init(
                data: webpData,
                ext: "WEBP"
            )
        }
        
        if let pngData = image.pngData() {
            return .init(data: pngData, ext: "PNG")
        }
        
        if let jpegData = image.jpegData(compressionQuality: 1) {
            return .init(data: jpegData, ext: "JPEG")
        }
        
        return nil
    }
}

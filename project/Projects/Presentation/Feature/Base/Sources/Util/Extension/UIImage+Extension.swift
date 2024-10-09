//
//  UIImage+Extension.swift
//  BaseFeature
//
//  Created by choijunios on 9/21/24.
//

import UIKit
import Domain


import SDWebImageWebPCoder

public extension UIImage {
    
    static func create(downloadInfo: ImageDownLoadInfo) -> UIImage? {
        
        if let data = try? Data(contentsOf: downloadInfo.imageURL) {
            
            if downloadInfo.imageFormat == .webp {
                
                // 넓이*3 * 높이*3 * 1byte
                let limitBytes = 320 * 250 * 9
                let image = SDImageWebPCoder.shared.decodedImage(with: data, options: [.decodeScaleDownLimitBytes: limitBytes])
                
                return image
            }
            return .init(data: data)
        }
        return nil
    }
}

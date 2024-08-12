//
//  UIImageView+KingFisher.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//

import UIKit
import Kingfisher

public extension UIImageView {
    
    /// KingFisher를 사용해 이미지를 적용합니다.
    /// option
    ///     - let pngSerializer = FormatIndicatedCacheSerializer.png
    func setImage(url: URL) {
        let pngSerializer = FormatIndicatedCacheSerializer.png
        self
            .kf.setImage(
                with: url,
                options: [.cacheSerializer(pngSerializer)]
            )
    }
}

//
//  IdleImageView.swift
//  DSKit
//
//  Created by choijunios on 7/17/24.
//

import UIKit

public extension UIImageView {
    
    static let backButton: UIImageView = {
        let view = UIImageView(image: DSKitAsset.Icons.back.image)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    static let locationMark: UIImageView = {
        let view = UIImageView(image: DSKitAsset.Icons.locationSmall.image)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    static let editPhotoImage: UIImageView = {
        let view = UIImageView(image: DSKitAsset.Icons.editPhoto.image)
        view.contentMode = .scaleAspectFit
        return view
    }()
}

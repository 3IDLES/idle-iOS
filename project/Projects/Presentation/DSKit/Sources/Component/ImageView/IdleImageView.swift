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

public extension UIImage {
    
    /// ScaleToAspectFit한 뷰를 만듭니다.
    func toView() -> UIImageView {
        let view = UIImageView()
        view.image = self
        view.contentMode = .scaleAspectFit
        return view
    }
    
    /// SingleImageButton을 만듭니다.
    func toButton(tintColor: UIColor) -> SingleImageButton {
        self.withRenderingMode(.alwaysTemplate)
        let btn = SingleImageButton()
        btn.tintColor = tintColor
        btn.imageView.image = self
        return btn
    }
}

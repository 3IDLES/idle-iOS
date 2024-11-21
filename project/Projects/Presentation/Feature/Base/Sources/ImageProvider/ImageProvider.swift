//
//  ImageProvider.swift
//  Base
//
//  Created by choijunios on 11/21/24.
//

import UIKit

import Domain

import RxSwift
import SimpleImageProvider

public protocol ImageProvider {
    
    /// 이미지 데이터를 획득합니다.
    func getImage(url: String, size: CGSize?) -> Single<UIImage>
}

public class DefaultImageProvider: ImageProvider {
    
    enum ImageProviderError: Error {
        case cantProvideImage
    }
    
    public init() { }
    
    public func getImage(url: String, size: CGSize?) -> Single<UIImage> {
        
        Single<UIImage>.create { single in
            
            let task = Task { [single] in
                
                if let image = await SimpleImageProvider.shared
                    .requestImage(url: url, size: size) {
                    
                    single(.success(image))
                    
                } else {
                    
                    single(.failure(ImageProviderError.cantProvideImage))
                }
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
        
    }
}

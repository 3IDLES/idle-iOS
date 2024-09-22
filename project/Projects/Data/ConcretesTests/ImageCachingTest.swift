//
//  ImageCachingTest.swift
//  ConcretesTests
//
//  Created by choijunios on 9/22/24.
//

import Foundation
import XCTest
@testable import ConcreteRepository
import Entity

import RxSwift

class ImageCachingTest: XCTestCase {
    
    let cacheRepo = DefaultCacheRepository()
    let disposeBag = DisposeBag()
    
    func testCaching() {
        
        let imageInfo = ImageDownLoadInfo(
            imageURL: URL(string: "https://fastly.picsum.photos/id/237/200/300.jpg?hmac=TmmQSbShHz9CdQm0NkEjx1Dyh_Y984R9LpNrpvH2D_U")!,
            imageFormat: .jpeg
        )
        
        let exp = XCTestExpectation(description: "caching")
        cacheRepo
            .getImage(imageInfo: imageInfo)
            .map { image in
                print("--첫번째 이미지--")
            }
            .flatMap { [cacheRepo]_ in
                cacheRepo
                    .getImage(imageInfo: imageInfo)
            }
            .map { image in
                print("--메모리 캐싱 체크--")
            }
            .map { [cacheRepo]_ in
                cacheRepo
                    .checkDiskCache(info: imageInfo)
            }
            .subscribe(onSuccess: { image in
                
                print("--디스크 체크--")
                
                if let image {
                    exp.fulfill()
                } else {
                    XCTFail()
                }
                
            })
            .disposed(by: disposeBag)
        
        wait(for: [exp], timeout: 5.0)
    }
}

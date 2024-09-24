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
    
    var cacheRepository: DefaultCacheRepository!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        self.cacheRepository = .init()
        self.disposeBag = .init()
    }
    
    func test_diskcache_oveflows_50images() {
        
        class ImageFetchedCounter {
            var count: Int
            
            init(count: Int) {
                self.count = count
            }
        }
        
        // 디스크 캐싱 내역 삭제
        guard cacheRepository.clearImageCacheDirectory() else {
            XCTFail("디스크 캐싱내역 삭제 실패")
            return
        }
        
        let counter = ImageFetchedCounter(count: 0)
        
        // 이미지 50개를 테스트
        let observables = (0..<60).map { index in
            
            let url = URL(string: "https://dummyimage.com/300x\(300+index)/000/fff")!
            let imageInfo = ImageDownLoadInfo(
                imageURL: url,
                imageFormat: .png
            )
                
            return cacheRepository
                .getImage(imageInfo: imageInfo)
                .asObservable()
        }
        
        let cacheExpectation = XCTestExpectation(description: "cacheExpectation")
        
        Observable
            .merge(observables)
            .subscribe(onNext: { [counter] _ in
                
                counter.count += 1
                print("이미지 획득 성공 \(counter.count)")
                
                if counter.count == 60 {
                    
                    cacheExpectation.fulfill()
                }
            })
            .disposed(by: disposeBag)
            
        
        wait(for: [cacheExpectation], timeout: 10.0)
    }
}

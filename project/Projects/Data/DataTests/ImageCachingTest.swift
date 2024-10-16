//
//  ImageCachingTest.swift
//  ConcretesTests
//
//  Created by choijunios on 9/22/24.
//

import Foundation
import XCTest
import Core
import Domain

@testable import Repository
@testable import Testing

import RxSwift

class ImageCachingTest: XCTestCase {
    
    var disposeBag: DisposeBag = .init()
    
    static override func setUp() {
        DependencyInjector.shared.assemble(MockAssemblies)
    }
    
    func test_diskcache_oveflows_50images() {
        
        class ImageFetchedCounter {
            var count: Int
            
            init(count: Int) {
                self.count = count
            }
        }
        
        return;
        
        let cacheRepository = DefaultCacheRepository(maxFileCount: 5, removeFileCountForOveflow: 1)
        
        // 디스크 캐싱 내역 삭제
        cacheRepository.clearImageCacheDirectory()
        
        let counter = ImageFetchedCounter(count: 0)
        
        // 이미지 50개를 테스트
        let observables = (0..<10).map { index in
            
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
                
                if counter.count == 10 {
                    
                    cacheExpectation.fulfill()
                }
            })
            .disposed(by: disposeBag)
            
        
        wait(for: [cacheExpectation], timeout: 20.0)
    }
}

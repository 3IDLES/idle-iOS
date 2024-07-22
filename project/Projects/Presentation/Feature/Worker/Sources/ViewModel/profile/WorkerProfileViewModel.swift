//
//  WorkerProfileViewModel.swift
//  WorkerFeature
//
//  Created by choijunios on 7/22/24.
//

import UIKit
import PresentationCore
import RxSwift
import RxCocoa
import DSKit
import Entity

public class WorkerProfileViewModel: WorkerProfileViewModelable {
    
    public var input = Input()
    public var output: Output?
    
    public init() {
        
        let fetchedProfileVOResult = input
            .readyToFetch
            .flatMap { [unowned self] _ in
                fetchProfileVO()
            }
            .share()
        
        let fetchedProfileVOSuccess = fetchedProfileVOResult
            .compactMap { $0.value }
          
        let imageDriver = fetchedProfileVOSuccess
            .compactMap { vo in
                vo.profileImageURL
            }
            .flatMap { [unowned self] url in
                fetchImageFrom(url: url)
            }
            .asDriver(onErrorJustReturn: nil)
            
        self.output = .init(
            profileVO: fetchedProfileVOSuccess.asDriver(onErrorJustReturn: .mock),
            displayingImage: imageDriver
        )
    }
    
    private func fetchProfileVO() -> Single<Result<WorkerProfileVO, Error>> {
        return .just(.success(.mock))
    }
    
    private func fetchImageFrom(url: URL) -> Single<UIImage?> {
        
        Single.create { single in
            
            let task = Task.detached {
                guard
                    let data = try? Data(contentsOf: url),
                    let image = UIImage(data: data)
                else {
                    return single(.success(nil))
                }
                
                single(.success(image))
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}


public extension WorkerProfileViewModel {
    
    class Input: WorkerProfileInputable {
        public var readyToFetch: PublishRelay<Void> = .init()
    }
    
    class Output: WorkerProfileOutputable {
        public var profileVO: Driver<WorkerProfileVO>
        public var displayingImage: Driver<UIImage?>
        
        init(profileVO: Driver<WorkerProfileVO>, displayingImage: Driver<UIImage?>) {
            self.profileVO = profileVO
            self.displayingImage = displayingImage
        }
    }
}

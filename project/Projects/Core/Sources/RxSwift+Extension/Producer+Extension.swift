//
//  Single+Extension.swift
//  Core
//
//  Created by choijunios on 10/1/24.
//

import Foundation


import RxSwift

public extension ObservableType {
    
    func unretained<T: AnyObject>(_ object: T) -> Observable<(T, Element)> {
        
        self
            .compactMap { [weak object] output -> (T, Element)? in
            
                guard let object else { return nil }
            
                return (object, output)
            }
            .asObservable()
    }
}

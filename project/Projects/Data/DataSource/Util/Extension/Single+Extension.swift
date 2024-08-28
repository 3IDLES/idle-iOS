//
//  Single+Extension.swift
//  ConcreteRepository
//
//  Created by choijunios on 8/28/24.
//

import RxSwift
import Moya

public extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    func mapToVoid() -> Single<Void> {
        flatMap { _ in .just(()) }
    }
}

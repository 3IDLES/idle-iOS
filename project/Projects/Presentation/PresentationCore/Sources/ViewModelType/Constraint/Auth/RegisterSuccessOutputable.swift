//
//  RegisterSuccessOutputable.swift
//  PresentationCore
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import RxCocoa

public protocol RegisterSuccessOutputable {
    var registerValidation: PublishRelay<Bool?> { get }
}

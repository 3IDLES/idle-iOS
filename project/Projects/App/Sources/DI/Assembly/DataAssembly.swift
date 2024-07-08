//
//  DataAssembly.swift
//  Idle-iOS
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import RepositoryInterface
import ConcreteRepository
import Swinject

public struct DataAssembly: Assembly {
    public func assemble(container: Container) {
        
        // MARK: 센터 회원가입 레포지토리
        container.register(CenterRegisterRepository.self) { _ in
            return DefaultCenterRegisterRepository()
        }
    }
}

//
//  AuthRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 7/10/24.
//

import RxSwift
import Entity

public protocol AuthRepository: RepositoryBase {
    
    func requestRegisterCenterAccount(managerName: String, phoneNumber: String, businessNumber: String, id: String, password: String) -> Single<BoolResult>
    func requestCenterLogin(id: String, password: String) -> Single<BoolResult>
}

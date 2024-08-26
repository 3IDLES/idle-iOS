//
//  UserInfoLocalRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 8/26/24.
//

import Foundation
import Entity

public protocol UserInfoLocalRepository {
    
    /// 로그인했던 유저정보를 가져옵니다.
    func getUserType() -> UserType?
    
    /// 로그인한 유저정보를 업데이트 합니다.
    func updateUserType(_ type: UserType)
    
    /// 로그인중인 요양보호사 유저의 프로필을 로컬에서 빠르게 가져옵니다.
    func getCurrentWorkerData() -> WorkerProfileVO?
    
    /// 로컬에 저장될 유저정보를 업데이트합니다.
    func updateCurrentWorkerData(vo: WorkerProfileVO)
    
    /// 로그인중인 센터관리자 유저의 프로필을 로컬에서 빠르게 가져옵니다.
    func getCurrentCenterData() -> CenterProfileVO?
}

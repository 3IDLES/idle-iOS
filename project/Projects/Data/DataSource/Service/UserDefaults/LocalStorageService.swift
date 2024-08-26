//
//  LocalStorageService.swift
//  DataSoruce
//
//  Created by choijunios on 8/26/24.
//

import Foundation

/// LocalStorageService를 사용하여 로컬에 데이터를 저장힙니다.
public protocol LocalStorageService {
    associatedtype T: Hashable
    func fetchData<Value>(key: T) -> Value?
    func saveData<Value>(key: T, value: Value)
}

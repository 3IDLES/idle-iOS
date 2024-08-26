//
//  LocalStorageService.swift
//  DataSoruce
//
//  Created by choijunios on 8/26/24.
//

import Foundation

/// LocalStorageService를 사용하여 로컬에 데이터를 저장힙니다.
public protocol LocalStorageService {
    func fetchData<Value>(key: String) -> Value?
    func saveData<Value>(key: String, value: Value)
    func remove(key: String)
}

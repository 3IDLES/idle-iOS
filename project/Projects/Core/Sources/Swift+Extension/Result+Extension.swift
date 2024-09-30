//
//  Result+Extension.swift
//  Core
//
//  Created by choijunios on 9/29/24.
//

import Foundation

public extension Result {
    var value: Success? {
        guard case let .success(value) = self else {
            return nil
        }
        return value
    }

    var error: Failure? {
        guard case let .failure(error) = self else {
            return nil
        }
        return error
    }
}

//
//  CenterAuthState.swift
//  Entity
//
//  Created by choijunios on 8/29/24.
//

import Foundation

public enum CenterAuthState: String {
    /// #1. 인증 요청이 되지 않은 상태입니다.
    case notRequested
    /// #2. 프로필이 입력되지 않은 상태입니다.
    case noProfile
    /// #3. 인증이 완료된 단계입니다.
    case authFinished
}

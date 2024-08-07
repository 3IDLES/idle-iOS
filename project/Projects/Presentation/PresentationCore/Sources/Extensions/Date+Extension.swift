//
//  Date+Extension.swift
//  PresentationCore
//
//  Created by choijunios on 8/7/24.
//

import Foundation

public extension Date {
    /// 2024년 04월 01일 형태로 변경합니다.
    func convertDateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: self)
    }
}

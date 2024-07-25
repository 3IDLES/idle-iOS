//
//  BusinessInfoVO.swift
//  Entity
//
//  Created by choijunios on 7/9/24.
//

import Foundation

public class BusinessInfoVO {
    
    public let name: String
    public let keyValue: [String: String]
    
    public init(name: String, keyValue: [String: String] = [:]) {
        self.name = name
        self.keyValue = keyValue
    }
    
    public static let mock: BusinessInfoVO = .init(
        name: "센터 정보",
        keyValue: [
            "이름": "홍길동",
            "전화번호": "010-1234-5678",
            "주소": "서울시 강남구 역삼동",
            "운영시간": "09:00 ~ 18:00",
            "휴무일": "매주 일요일",
            "센터 소개": "안녕하세요. 홍길동 센터입니다."
        ]
    )
    
    public static let onError: BusinessInfoVO = .init(
        name: "오류가 발생했습니다.",
        keyValue: [
            "이름": "오류가 발생했습니다.",
            "전화번호": "오류가 발생했습니다.",
            "주소": "오류가 발생했습니다.",
            "운영시간": "오류가 발생했습니다.",
            "휴무일": "오류가 발생했습니다.",
            "센터 소개": "오류가 발생했습니다.",
        ]
    )
}

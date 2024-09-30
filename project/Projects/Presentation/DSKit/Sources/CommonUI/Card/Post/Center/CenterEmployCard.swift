//
//  CenterEmployCard.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//

import UIKit
import Domain


import RxSwift
import RxCocoa

public struct CenterEmployCardRO {
    public let startDay: String
    public let endDay: String
    public let postTitle: String
    public let nameText: String
    public let careGradeText: String
    public let ageText: String
    public let genderText: String
    public let postState: PostState?
    
    public init(startDay: String, endDay: String, postTitle: String, nameText: String, careGradeText: String, ageText: String, genderText: String, postState: PostState? = nil) {
        self.startDay = startDay
        self.endDay = endDay
        self.postTitle = postTitle
        self.nameText = nameText
        self.careGradeText = careGradeText
        self.ageText = ageText
        self.genderText = genderText
        self.postState = postState
    }
    
    public static let mock: CenterEmployCardRO = .init(
        startDay: "2024. 07. 10",
        endDay: "2024. 07. 31",
        postTitle: "서울특별시 강남구 신사동",
        nameText: "홍길동",
        careGradeText: "1등급",
        ageText: "78세",
        genderText: "여성",
        postState: .closed
    )
    
    public static func create(_ vo: CenterEmployCardVO) -> CenterEmployCardRO {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDayText = dateFormatter.string(from: vo.startDay)
        let endDayText = vo.endDay == nil ? "채용 시까지" : dateFormatter.string(from: vo.endDay!)
        
        var splittedAddress = vo.roadNameAddress.split(separator: " ")
        
        if splittedAddress.count >= 3 {
            splittedAddress = Array(splittedAddress[0..<3])
        }
        let addressTitle = splittedAddress.joined(separator: " ")
        
        return .init(
            startDay: startDayText,
            endDay: endDayText,
            postTitle: addressTitle,
            nameText: vo.name,
            careGradeText: "\(vo.careGrade.textForCellBtn)등급",
            ageText: "\(vo.age)세",
            genderText: vo.gender.twoLetterKoreanWord
        )
    }
    
    public static func create(vo: RecruitmentPostInfoForCenterVO) -> CenterEmployCardRO {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDay = dateFormatter.string(from: vo.createdAt)
        let endDay = vo.applyDeadline == nil ? "채용 시까지" : dateFormatter.string(from: vo.applyDeadline!)
         
        var splittedAddress = vo.roadNameAddress.split(separator: " ")
        
        if splittedAddress.count >= 3 {
            splittedAddress = Array(splittedAddress[0..<3])
        }
        let addressTitle = splittedAddress.joined(separator: " ")
        
        return .init(
            startDay: startDay,
            endDay: endDay,
            postTitle: addressTitle,
            nameText: vo.clientName,
            careGradeText: "\(vo.careLevel.textForCellBtn)등급",
            ageText: "\(vo.age)세",
            genderText: vo.gender.twoLetterKoreanWord,
            postState: vo.state
        )
    }
}

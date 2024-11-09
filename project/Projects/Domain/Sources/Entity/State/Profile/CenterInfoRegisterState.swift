//
//  CenterProfileRegisterState.swift
//  Entity
//
//  Created by choijunios on 7/27/24.
//

import Foundation

public class CenterProfileRegisterState {
    
    // 모든 값들 required
    public var centerName: String = ""
    public var officeNumber: String = ""
    public var roadNameAddress: String = ""
    public var lotNumberAddress: String = ""
    public var detailedAddress: String = ""
    public var introduce: String = ""
    
    // 추후 이미지를 옵셔널로 바꿀수도 있음
    public var imageInfo: ImageUploadInfo? = nil
    
    public init() { }
}

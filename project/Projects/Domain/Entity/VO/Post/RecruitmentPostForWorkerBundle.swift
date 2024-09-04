//
//  RecruitmentPostForWorkerBundle.swift
//  Entity
//
//  Created by choijunios on 8/15/24.
//

import Foundation
 
/// 위도경도 좌표를 담고 있습니다.
public struct LocationInformation {
    public let longitude: Double
    public let latitude: Double
    
    public init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

public class RecruitmentPostForWorkerBundle {
    
    public struct CenterInfo {
        public let centerId: String
        public let centerName: String
        public let centerRoadAddress: String
        
        public init(centerId: String, centerName: String, centerRoadAddress: String) {
            self.centerId = centerId
            self.centerName = centerName
            self.centerRoadAddress = centerRoadAddress
        }
    }
    
    public let isFavorite: Bool?
    public let applyDate: Date?
    public let workTimeAndPay: WorkTimeAndPayStateObject
    public let customerRequirement: CustomerRequirementStateObject
    public let customerInformation: CustomerInformationStateObject
    public let applicationDetail: ApplicationDetailStateObject
    public let addressInfo: AddressInputStateObject
    
    /// 센터정보
    public let centerInfo: CenterInfo
    
    /// 근무지 위치정보
    public let distanceToWorkPlace: Int
    public let jobLocation: LocationInformation
    
    
    public init(
        isFavorite: Bool? = false,
        applyDate: Date? = nil,
        workTimeAndPay: WorkTimeAndPayStateObject,
        customerRequirement: CustomerRequirementStateObject,
        customerInformation: CustomerInformationStateObject,
        applicationDetail: ApplicationDetailStateObject,
        addressInfo: AddressInputStateObject,
        centerInfo: CenterInfo,
        jobLocation: LocationInformation,
        distanceToWorkPlace: Int
    ) {
        self.isFavorite = isFavorite
        self.applyDate = applyDate
        self.workTimeAndPay = workTimeAndPay
        self.customerRequirement = customerRequirement
        self.customerInformation = customerInformation
        self.applicationDetail = applicationDetail
        self.addressInfo = addressInfo
        self.centerInfo = centerInfo
        self.jobLocation = jobLocation
        self.distanceToWorkPlace = distanceToWorkPlace
    }
}

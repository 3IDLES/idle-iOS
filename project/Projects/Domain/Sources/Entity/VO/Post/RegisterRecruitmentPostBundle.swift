//
//  RegisterRecruitmentPostBundle.swift
//  Entity
//
//  Created by choijunios on 8/9/24.
//

import Foundation

public struct RegisterRecruitmentPostBundle {
    public let workTimeAndPay: WorkTimeAndPayStateObject
    public let customerRequirement: CustomerRequirementStateObject
    public let customerInformation: CustomerInformationStateObject
    public let applicationDetail: ApplicationDetailStateObject
    public let addressInfo: AddressInputStateObject
    
    public init(workTimeAndPay: WorkTimeAndPayStateObject, customerRequirement: CustomerRequirementStateObject, customerInformation: CustomerInformationStateObject, applicationDetail: ApplicationDetailStateObject, addressInfo: AddressInputStateObject) {
        self.workTimeAndPay = workTimeAndPay
        self.customerRequirement = customerRequirement
        self.customerInformation = customerInformation
        self.applicationDetail = applicationDetail
        self.addressInfo = addressInfo
    }
}

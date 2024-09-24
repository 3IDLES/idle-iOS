//
//  SettingAdditionalInfoType.swift
//  Entity
//
//  Created by choijunios on 9/15/24.
//

import Foundation

public enum SettingAdditionalInfoType {
    
    case frequentQuestion
    case contact
    case termsandPolicies
    case privacyPolicy
    
    public func getWebUrl() -> URL {
        var urlString: String!
        switch self {
        case .frequentQuestion:
            urlString = "https://grove-maraca-55d.notion.site/8579186ee8ca4dbb8dc55e3b8b744d11?pvs=4"
        case .contact:
            urlString = "http://pf.kakao.com/_VPcIn/chat"
        case .termsandPolicies:
            urlString = "https://grove-maraca-55d.notion.site/2e4d597aff1f406e9164cdb6f9195de0?pvs=4"
        case .privacyPolicy:
            urlString = "https://grove-maraca-55d.notion.site/ad4f62dff5304d63a162f1269639afca?pvs=4"
        }
        
        return URL(string: urlString)!
    }
}

//
//  ProfileImageUploadInfoDTO.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/20/24.
//

import Foundation

public struct ProfileImageUploadInfoDTO: Decodable {
    
    public let imageId: String
    public let imageFileExtension: String
    public let uploadUrl: String
}

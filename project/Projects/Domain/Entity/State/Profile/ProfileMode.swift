//
//  ProfileMode.swift
//  Entity
//
//  Created by choijunios on 7/29/24.
//

import Foundation

public enum ProfileMode: Equatable {
    case myProfile
    case otherProfile(id: String)
}

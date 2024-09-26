//
//  RemoteNotification.swift
//  PresentationCore
//
//  Created by choijunios on 9/26/24.
//

import Foundation

public extension Notification.Name {
    
    static let requestTransportTokenToServer: Self = .init("requestTransportTokenToServer")
    static let requestDeleteTokenFromServer: Self = .init("requestDeleteTokenFromServer")
}

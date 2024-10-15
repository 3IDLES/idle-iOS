//
//  DeepLinkBundle.swift
//  RootFeature
//
//  Created by choijunios on 10/15/24.
//

import Foundation
import BaseFeature


public struct DeeplinkBundle {
    public let deeplinks: [DeeplinkExecutable]
    public let userInfo: [AnyHashable: Any]?
}

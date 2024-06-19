//
//  Config.swift
//  Packages
//
//  Created by 최준영 on 6/19/24.
//

import Foundation
import ProjectDescription

let config = Config(
    plugins: [
        .local(path: .relativeToRoot("Plugins/ConfigurationPlugin")),
    ]
)

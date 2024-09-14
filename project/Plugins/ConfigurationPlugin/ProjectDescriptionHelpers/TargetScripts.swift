//
//  TargetScripts.swift
//  ConfigurationPlugin
//
//  Created by choijunios on 9/14/24.
//

import Foundation
import ProjectDescription

// MARK: Firebase crashlytics

public extension TargetScript {
    
    static let crashlyticsScript: TargetScript = .post(
        script: """
          ROOT_DIR=\(ProcessInfo.processInfo.environment["TUIST_ROOT_DIR"] ?? "")
          "${ROOT_DIR}/Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run"
          """,
        name: "Firebase Crashlytics",
        inputPaths: [
          "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}",
          "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist",
          "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist",
          "$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)",
        ],
        basedOnDependencyAnalysis: false
      )
}

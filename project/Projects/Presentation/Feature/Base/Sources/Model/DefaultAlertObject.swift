//
//  DefaultAlertObject.swift
//  BaseFeature
//
//  Created by choijunios on 10/2/24.
//

import Foundation

public struct DefaultAlertObject {
    
    public struct Action {
        let titleName: String
        let action: (() -> ())?
        
        public init(titleName: String, action: (() -> Void)?) {
            self.titleName = titleName
            self.action = action
        }
    }
    
    public var title: String = ""
    public var description: String = ""
    public var actions: [Action] = []
    
    public init() { }
    
    public mutating func setTitle(_ text: String) -> Self {
        self.title = text
        return self
    }
    
    public mutating func setDescription(_ text: String) -> Self {
        self.description = text
        return self
    }
    
    public mutating func addAction(_ action: Action) -> Self {
        actions.append(action)
        return self
    }
}

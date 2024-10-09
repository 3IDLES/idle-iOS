//
//  DeeplinkParser.swift
//  RootFeature
//
//  Created by choijunios on 10/9/24.
//

import Foundation
import BaseFeature

enum DeeplinkParserError: Error {
    case rootNotFound
    case childNotFound
}

class DeeplinkParser {
    
    func makeDeeplinkList(components: [String]) throws -> [DeeplinkExecutable] {
        
        var deeplinks: [DeeplinkExecutable] = []
        
        for component in components {
            
            if deeplinks.isEmpty {
                let root = try findRoot(name: component)
                deeplinks.append(root)
                continue
            }
            
            guard let parent = deeplinks.last, let child = parent.findChild(name: component) else {
                throw DeeplinkParserError.childNotFound
            }
            
            deeplinks.append(child)
        }
        
        return deeplinks
    }
    
    private func findRoot(name: String) throws -> DeeplinkExecutable {
        switch name {
        case "CenterMainPage":
            return CenterMainPageDeeplink()
        default:
            throw DeeplinkParserError.rootNotFound
        }
    }
}



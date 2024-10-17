//
//  DeeplinkParser.swift
//  RootFeature
//
//  Created by choijunios on 10/9/24.
//

import Foundation
import BaseFeature

enum DeeplinkParserError: LocalizedError {
    case startPointNotFound
    case rootNotFound
    case childNotFound
    
    var errorDescription: String? {
        switch self {
        case .startPointNotFound:
            "딥링크 시작지점을 찾을 수 없음"
        case .rootNotFound:
            "답링크 루트를 찾을 수 없음"
        case .childNotFound:
            "자식 딥링크를 찾을 수 없음"
        }
    }
}

class DeeplinkParser {
    
    func makeDeeplinkList(components: [DeepLinkPathComponent], startFromRoot: Bool = true) throws -> [DeeplinkExecutable] {
        
        var deeplinks: [DeeplinkExecutable] = []
        
        for component in components {
            
            if deeplinks.isEmpty {
                
                var start: DeeplinkExecutable!
                
                if startFromRoot {
                    start = try findRoot(component: component)
                } else {
                    start = try findStartPoint(component: component)
                }
                
                deeplinks.append(start)
                continue
            }
            
            guard let parent = deeplinks.last, let child = parent.findChild(component: component) else {
                throw DeeplinkParserError.childNotFound
            }
            
            deeplinks.append(child)
        }
        
        return deeplinks
    }
    
    private func findRoot(component: DeepLinkPathComponent) throws -> DeeplinkExecutable {
        switch component {
        case .centerMainPage:
            return CenterMainPageDeeplink()
        default:
            throw DeeplinkParserError.rootNotFound
        }
    }
    
    private func findStartPoint(component: DeepLinkPathComponent) throws -> DeeplinkExecutable {
        switch component {
        case .centerMainPage:
            return CenterMainPageDeeplink()
        case .postApplicantPage:
            return PostApplicantDeeplink()
        default:
            throw DeeplinkParserError.startPointNotFound
        }
    }
}



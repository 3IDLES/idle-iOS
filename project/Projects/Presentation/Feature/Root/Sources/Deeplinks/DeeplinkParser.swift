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
    
    /// [딥링크 동작]
    /// 먼저 딥링크를 처리할 수 있는 루트와 스타팅 포인트를 탐색합니다. 스타팅포인트는 옵셔널 입니다.
    /// 스타팅 포인트를 따로둔 이유는 알림 인앱처리시 루트가 코디네이터에 대한 처리가 필요없기 때문입니다.
    func makeDeeplinkList(components: [DeepLinkPathComponent], startFromRoot: Bool = true) throws -> [DeeplinkExecutable] {
        
        var deeplinks: [DeeplinkExecutable] = []
        
        for component in components {
            
            if deeplinks.isEmpty {
                
                // 딥링크의 경로의 첫번째 시작지점을 선정합니다.
                
                var start: DeeplinkExecutable!
                
                if startFromRoot {
                    start = try findRoot(component: component)
                } else {
                    start = try findFirstStartPointAboveApp(component: component)
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
    
    /// 딥링크의 루트를 의미합니다.
    private func findRoot(component: DeepLinkPathComponent) throws -> DeeplinkExecutable {
        switch component {
        case .centerMainPage:
            return CenterMainPageDeeplink()
        case .workerMainPage:
            return WorkerMainPageDeepLink()
        default:
            throw DeeplinkParserError.rootNotFound
        }
    }
    
    /// 루트는 아니지만 스타팅 포인트가 될 수 있는 지점을 의미합니다.
    private func findFirstStartPointAboveApp(component: DeepLinkPathComponent) throws -> DeeplinkExecutable {
        switch component {
        case .postApplicantPage:
            
            return PostApplicantDeeplink()
            
        case .postDetailForWorkerPage:
            
            return PostDetailForWorkerDeepLink()
            
        default:
            throw DeeplinkParserError.startPointNotFound
        }
    }
}



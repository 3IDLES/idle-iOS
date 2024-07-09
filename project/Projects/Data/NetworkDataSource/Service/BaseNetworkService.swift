//
//  BaseNetworkService.swift
//  ConcreteRepository
//
//  Created by choijunios on 6/28/24.
//

import Foundation
import RxSwift
import Alamofire
import Moya
import RxMoya

public class BaseNetworkService<TagetAPI: BaseAPI> {
    
    private let keyValueStore: KeyValueStore
    
    init(keyValueStore: KeyValueStore = KeyChainList.shared) {
        self.keyValueStore = keyValueStore
    }
    
    private lazy var provider = self.defaultProvider
        
    private lazy var defaultProvider: MoyaProvider<TagetAPI> = {
        
        let provider = MoyaProvider<TagetAPI>(session: sessionWithToken)
        
        return provider
    }()
    
    lazy var sessionWithToken: Session = {
        
        let configuration = URLSessionConfiguration.default
        
        // 단일 요청이 완료되는데 걸리는 최대 시간, 초과시 타임아웃
        configuration.timeoutIntervalForRequest = 10
        
        // 하나의 리소스를 로드하는데 걸리는 시간, 재시도를 포함한다 초과시 타임아웃
        configuration.timeoutIntervalForResource = 10
        
        // Cache policy: 로컬캐시를 무시하고 항상 새로운 데이터를 가져온다.
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let tokenIntercepter = Interceptor.interceptor(
            adapter: tokenAdpater,
            retrier: tokenRetrier
        )
        
        return Session(
            configuration: configuration,
            interceptor: tokenIntercepter
        )
    }()
    
    
    // MARK: Alamofire Interceptor
    lazy var tokenAdpater = Adapter { [weak self] request, session, completion in
        
        var adaptedRequest = request
        
        if let token = self?.keyValueStore.getAuthToken() {
            
            let bearerToken = "Bearer \(token.accessToken)"
            
            adaptedRequest.setValue(bearerToken, forHTTPHeaderField: "Authorization")
        }
          
        completion(.success(adaptedRequest))
    }
    
    lazy var tokenRetrier = Retrier { [weak self] request, session, error, completion in
        
        if let httpResponse = request.response {
            
            if httpResponse.statusCode == 401 {
                
                // TODO: 토큰 재발급후 요청 재시도
            }
        }
            
        completion(.doNotRetry)
    }
    
}

// MARK: DataRequest
public extension BaseNetworkService {
    
    func requestDecodable<T: Decodable>(api: TagetAPI) -> Single<T> {
        
        self.provider.rx.request(api)
            .map(T.self)
    }
    
    func request(api: TagetAPI) -> Single<Response> {
        
        self.provider.rx.request(api)
    }
    
    // MARK: Request with Progress
    struct ProgressResponse<T: Decodable> {
        
        let progress: Double
        let data: T?
    }
    
    func requestDecodableWithProgress<T: Decodable>(api: TagetAPI) -> Single<ProgressResponse<T>> {
        
        Single<ProgressResponse<T>>.create { single in
            
            self.provider.rx
                .requestWithProgress(api)
                .subscribe(onNext: { response in
                    
                    if let result = response.response {
                        
                        do {
                            
                            let decoded = try result.map(T.self)
                            
                            let item = ProgressResponse<T>(
                                progress: response.progress,
                                data: decoded
                            )
                            
                            single(.success(item))
                            
                        } catch {
                            
                            single(.failure(error))
                        }
                    }
                })
        }
    }
}

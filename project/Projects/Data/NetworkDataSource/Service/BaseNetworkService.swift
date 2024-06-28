//
//  BaseNetworkService.swift
//  ConcreteRepository
//
//  Created by choijunios on 6/28/24.
//

import Foundation
import RxSwift
import Alamofire

class BaseNetworkService<T: BaseAPI> {
    
    let keyValueStore: KeyValueStore
    
    init(keyValueStore: KeyValueStore = KeyChainList.shared) {
        self.keyValueStore = keyValueStore
    }
    
    lazy var tokenSession: Session = {
        
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = 10
        
        let tokenIntercepter = Interceptor.interceptor(
            adapter: tokenAdpater,
            retrier: tokenRetrier
        )
        
        let serverTrustPolicies: [String: ServerTrustEvaluating] = [
            "667c2cf33c30891b865ba28e.mockapi.io": DisabledTrustEvaluator()
        ]

        let serverTrustManager = ServerTrustManager(evaluators: serverTrustPolicies)
        
        let tokenSession = Session(
            configuration: configuration,
            interceptor: tokenIntercepter,
            serverTrustManager: serverTrustManager
        )
        
        return tokenSession
    }()
    
    lazy var tokenAdpater = Adapter { [weak self] request, session, completion in
        
        guard let token = self?.keyValueStore.getAuthToken() else {
            
            // TODO: 에러처리 규칙 정해지면 수정예정
            precondition(false, "Token not found")
        }
        
        var adaptedRequest = request
        
        let bearerToken = "Bearer \(token.accessToken)"
        
        adaptedRequest.setValue(bearerToken, forHTTPHeaderField: ReqeustConponents.Header.authorization.key)
          
        completion(.success(adaptedRequest))
    }
    
    lazy var tokenRetrier = Retrier { [weak self] request, session, error, completion in
        
        if let httpResponse = request.response {
            
            if httpResponse.statusCode == 401 {
                
                // TODO: 토큰 재발급후 요청 재시도
            
            }
        }
        
        completion(.doNotRetryWithError(error))
    }
    
}

extension BaseNetworkService {
    
    func request<R: Decodable>(api: T) -> Single<R> {
        
        return Single<R>.create { [weak self] single in
            
            let urlRequest = URLRequest(url: api.baseUrl)
            
            print(urlRequest.url!.absoluteString)
            
            let requestSession = api.headers.keys.contains("Authorization") ? self?.tokenSession : AF
            
            let dataRequest = requestSession?
                .request(urlRequest)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: R.self) { response in
                    switch response.result {
                    case .success(let decoded):
                        single(.success(decoded))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            
            return Disposables.create {
                dataRequest?.cancel()
            }
        }
    }
}

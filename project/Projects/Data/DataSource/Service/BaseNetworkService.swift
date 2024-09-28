//
//  BaseNetworkService.swift
//  ConcreteRepository
//
//  Created by choijunios on 6/28/24.
//

import Foundation
import Domain


import RxSwift
import Alamofire
import Moya
import RxMoya

public class BaseNetworkService<TagetAPI: BaseAPI> {
    
    public let keyValueStore: KeyValueStore
    
    init(keyValueStore: KeyValueStore = KeyChainList.shared) {
        self.keyValueStore = keyValueStore
    }
        
    private lazy var providerWithToken: MoyaProvider<TagetAPI> = {
        
        let provider = MoyaProvider<TagetAPI>(session: sessionWithToken)
        
        return provider
    }()
    
    private lazy var providerWithoutToken: MoyaProvider<TagetAPI> = {
        
        let provider = MoyaProvider<TagetAPI>(session: sessionWithoutToken)
        
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
    
    private let tokenSession: Session = {
       
        let configuration = URLSessionConfiguration.default
        
        // 단일 요청이 완료되는데 걸리는 최대 시간, 초과시 타임아웃
        configuration.timeoutIntervalForRequest = 10
        
        // 하나의 리소스를 로드하는데 걸리는 시간, 재시도를 포함한다 초과시 타임아웃
        configuration.timeoutIntervalForResource = 10
        
        // Cache policy: 로컬캐시를 무시하고 항상 새로운 데이터를 가져온다.
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let session = Session(configuration: configuration)
        
        return session
    }()
    
    lazy var tokenRetrier = Retrier { [weak self] request, session, error, completion in
        
        if let httpResponse = request.response {
            
            if httpResponse.statusCode == 401, request.retryCount < 1 {
                
                guard let self else {
                    return completion(.doNotRetry)
                }
                
                guard let refreshToken = self.keyValueStore.getAuthToken()?.refreshToken else {
                    completion(.doNotRetry)
                    return
                }
                
                let configuration = URLSessionConfiguration.default
                configuration.timeoutIntervalForRequest = 10
                configuration.timeoutIntervalForResource = 10
                configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
                
                let provider = MoyaProvider<AuthAPI>(session: Session(configuration: configuration))
                
                provider.rx
                    .request(.reissueToken(refreshToken: refreshToken))
                    .catch({ error in
                        // 토큰 리프래쉬 실패 -> 재로그인 필요
                        completion(.doNotRetryWithError(error))
                        return .error(error)
                    })
                    .subscribe { [weak self] response in
                        
                        guard let self else { fatalError() }
                        
                        if let token = try? response.map(TokenDTO.self),
                           let accessToken = token.accessToken,
                            let refreshToken = token.refreshToken
                        {
                            
                            do {
                                try self.keyValueStore.saveAuthToken(
                                    accessToken: accessToken,
                                    refreshToken: refreshToken
                                )
                                // 맵핑및 저장에 성공한 경우 Retry
                                completion(.retry)
                            } catch {
                                completion(.doNotRetryWithError(error))
                            }
                            
                        } else {
                            completion(.doNotRetry)
                        }
                    }
                    .disposed(by: self.disposeBag)
                    
            } else {
                completion(.doNotRetryWithError(error))
            }
        }
    }
    
    /// Token을 요구하지 않는 요청이 사용한다.
    let sessionWithoutToken: Session = {
       
        let configuration = URLSessionConfiguration.default
        
        // 단일 요청이 완료되는데 걸리는 최대 시간, 초과시 타임아웃
        configuration.timeoutIntervalForRequest = 20
        
        // 하나의 리소스를 로드하는데 걸리는 시간, 재시도를 포함한다 초과시 타임아웃
        configuration.timeoutIntervalForResource = 20
        
        // Cache policy: 로컬캐시를 무시하고 항상 새로운 데이터를 가져온다.
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        return Session(configuration: configuration)
    }()

    let disposeBag = DisposeBag()
}

// MARK: DataRequest
public extension BaseNetworkService {
    
    enum RequestType {
        case plain
        case withToken
    }
    
    private func _request(api: TagetAPI, provider: MoyaProvider<TagetAPI>) -> Single<Response> {
        
        provider.rx
            .request(api)
            .catch { error in
                
                let moyaError = error as! MoyaError
                
                // 재시도 실패 or 근본적인 에러(Ex 타임아웃, 네트워크 끊어짐)
                if case let .underlying(error, response) = moyaError {
                    
                    // 리타리어 실패
                    if let afError = error.asAFError {
                        
                        if case .requestRetryFailed = afError, let response {
                            
                            return .error(
                                HTTPResponseException(response: response)
                            )
                        }
                    }
                    
                    // 근본적인 문제
                    if let urlError = error as? URLError {
                        
                        var underlyingError: UnderLyingError!
                        
                        switch urlError.code {
                        case .notConnectedToInternet:
                            underlyingError = .internetNotConnected
                        case .networkConnectionLost:
                            underlyingError = .networkConnectionLost
                        case .timedOut:
                            underlyingError = .timeout
                        default:
                            underlyingError = .unHandledError
                        }
                        
                        return .error(underlyingError)
                    }
                }
                
                // HTTP통신 에러
                if case let .statusCode(response) = moyaError {
                    return .error(
                        HTTPResponseException(response: response)
                    )
                }
                
                // 엣지 케이스
                return .error(error)
            }
    }
    
    func request(api: TagetAPI, with: RequestType) -> Single<Response> {
        
        _request(
            api: api,
            provider: with == .plain ? self.providerWithoutToken : self.providerWithToken
        )
    }
    
    func requestDecodable<T: Decodable>(api: TagetAPI, with: RequestType) -> Single<T> {
        
        request(api: api, with: with)
            .map(T.self)
    }

//    // MARK: Request with Progress
//    struct ProgressResponse<T: Decodable> {
//        
//        let progress: Double
//        let data: T?
//    }
//    
//    func requestDecodableWithProgress<T: Decodable>(api: TagetAPI) -> Single<ProgressResponse<T>> {
//        
//        Single<ProgressResponse<T>>.create { single in
//            
//            self.provider.rx
//                .requestWithProgress(api)
//                .subscribe(onNext: { response in
//                    
//                    if let result = response.response {
//                        
//                        do {
//                            
//                            let decoded = try result.map(T.self)
//                            
//                            let item = ProgressResponse<T>(
//                                progress: response.progress,
//                                data: decoded
//                            )
//                            
//                            single(.success(item))
//                            
//                        } catch {
//                            
//                            single(.failure(error))
//                        }
//                    }
//                })
//        }
//    }
}

// MARK: HTTPResponseException+Extension
extension HTTPResponseException {
    init(response: Response) {
        
        let status: HttpResponseStatus = .create(code: response.statusCode)
        var rawCode: String? = nil
        var timeStamp: String? = nil
        
        if let decodedError = try? JSONDecoder().decode(ErrorDTO.self, from: response.data) {
            if let code = decodedError.code { rawCode = code }
            if let time = decodedError.timestamp { timeStamp = time }
        }
        self.init(
            status: status,
            rawCode: rawCode,
            timeStamp: timeStamp
        )
    }
}

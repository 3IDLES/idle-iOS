//
//  CacheRepository.swift
//  ConcreteRepository
//
//  Created by choijunios on 9/21/24.
//

import Foundation
import Entity
import UIKit
import UniformTypeIdentifiers

import SDWebImageWebPCoder
import RxSwift

public class CachedImageObject {
    
    let downloadInfo: ImageDownLoadInfo
    let data: Data
    
    public init(downloadInfo: ImageDownLoadInfo, data: Data) {
        self.downloadInfo = downloadInfo
        self.data = data
    }
}

public protocol CacheRepository {
    
    /// 이미지 데이터를 획득합니다.
    func getImage(imageInfo: ImageDownLoadInfo) -> Single<UIImage>
}

struct ImageCacheInfo: Codable {
    let url: String
    let format: ImageFormat
    let date: Date
    
    func updateDate() -> Self {
        .init(
            url: url,
            format: format,
            date: .now
        )
    }
}

public class DefaultCacheRepository: CacheRepository {
    
    /// UserDefaults에 사여용되는 키
    enum Key {
        static let cacheInfoDict = "cacheInfoDictionary"
    }
    
    /// 이미지를 메모리에서 캐싱하는 NSCache입니다.
    private let imageMemoryCache: NSCache<NSString, UIImage> = .init()
    
    /// 캐시정보를 저장하는 딕셔너리입니다. 키: url , 값: (disk path, time)
    private var cacheInfoDict: [String: ImageCacheInfo] {
        if let dict = UserDefaults.standard.dictionary(forKey: Key.cacheInfoDict) {
            
            return dict.mapValues { value in
                let data = value as! Data
                let decoded = try! jsonDecoder.decode(ImageCacheInfo.self, from: data)
                return decoded
            }
        }
        let newDict: [String: Data] = [:]
        UserDefaults.standard.set(newDict, forKey: Key.cacheInfoDict)
        return [:]
    }
    
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()
    
    public init() {
        // 이미지 인메모리 캐시 설정
        imageMemoryCache.countLimit = 30
        imageMemoryCache.totalCostLimit = 20
    }
    
    public func getImage(imageInfo: ImageDownLoadInfo) -> Single<UIImage> {
        
        Single<UIImage>.create { [weak self] observer in
            
            let urlString = imageInfo.imageURL.absoluteString
            let cacheInfoKey = urlString
            let memoryKey = NSString(string: urlString)
            
            // MARK: 메모리 캐싱정보 체크
            if let image = self?.imageMemoryCache.object(forKey: memoryKey) {
                
                #if DEBUG
                print("key: \(cacheInfoKey) memory cache hit")
                #endif
                
                // 접근시간 업데이트
                self?.updateLastReadTime(cacheInfoKey: cacheInfoKey)
                
                observer(.success(image))
                
            } else {
                
                // MARK: 디스크 캐싱정보 체크
                if let image = self?.checkDiskCache(info: imageInfo) {
                    
                    #if DEBUG
                    print("key: \(cacheInfoKey) disk cache hit")
                    #endif
                    
                    // 접근시간 업데이트
                    self?.updateLastReadTime(cacheInfoKey: cacheInfoKey)
                    
                    observer(.success(image))
                    
                } else {
                    
                    // 디스크정보 없음, 이미지 다운로드 실행
                    do {
                        let contents = try Data(contentsOf: imageInfo.imageURL)
                        
                        // 디스크에 파일 생성
                        self?.createImageFile(imageURL: imageInfo.imageURL, contents: contents)
                        
                        // UIImage생성
                        if let image = self?.createImage(data: contents, format: imageInfo.imageFormat) {
                            
                            // 캐싱정보 지정
                            let cacheInfo = ImageCacheInfo(
                                url: imageInfo.imageURL.absoluteString,
                                format: imageInfo.imageFormat,
                                date: .now
                            )
                            
                            if var dict = self?.cacheInfoDict {
                                dict[cacheInfoKey] = cacheInfo
                                self?.setCacheInfoDict(dict: dict)
                            }
                            
                            // 메모리 캐시에 올리기
                            self?.imageMemoryCache.setObject(image, forKey: memoryKey)
                            
                            observer(.success(image))
                        }
                    } catch {
                        #if DEBUG
                        print("이미지 다운로드 싪패")
                        #endif
                    }
                }
            }
            
            return Disposables.create { }
        }
    }
}

// MARK: Cache info
extension DefaultCacheRepository {
    
    var getCurrentTime: String {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.string(from: .now)
    }
    
    /// 마지막으로 캐시를 읽은 시각 업데이트
    func updateLastReadTime(cacheInfoKey: String) {
        if let cacheInfo = cacheInfoDict[cacheInfoKey] {
            let updated = cacheInfo.updateDate()
            updateCacheInfoDict(key: cacheInfoKey, update: updated)
            
            #if DEBUG
            print("key: \(cacheInfoKey) Hit time updated")
            #endif
        }
    }
    
    /// 업데이트된 캐시정보를 저장합니다.
    func updateCacheInfoDict(key: String, update: ImageCacheInfo) {
        var dict = cacheInfoDict
        dict[key] = update
        setCacheInfoDict(dict: dict)
    }
    
    func setCacheInfoDict(dict: [String: ImageCacheInfo]) {
        let encoded = dict.mapValues { info in
            try! jsonEncoder.encode(info)
        }
        UserDefaults.standard.set(encoded, forKey: Key.cacheInfoDict)
    }
}

// MARK: Checking disk
extension DefaultCacheRepository {
    
    /// image경로를 획득합니다.
    func createImagePath(url: String) -> URL? {
        
        guard let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            #if DEBUG
            print("\(url) 이미지 경로 생성 실패")
            #endif
            return nil
        }
        
        let imageDirectory = path.appendingPathComponent("Image")
        try? FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
        
        let imageFileName = url
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        
        let imageURL = imageDirectory
            .appendingPathComponent(imageFileName)
        return imageURL
    }
    
    /// 디스크 캐시를 확인합니다.
    func checkDiskCache(info: ImageDownLoadInfo) -> UIImage? {
        
        guard let imagePath = createImagePath(url: info.imageURL.absoluteString) else {
            return nil
        }
        
        if FileManager.default.fileExists(atPath: imagePath.path) {
            
            // 이미지 파일이 존재
            
            #if DEBUG
            print("\(info.imageURL) : 파일이 존재함, 디스크 히트")
            #endif
            
            // 접근시간 업데이트
            updateLastReadTime(cacheInfoKey: info.imageURL.absoluteString)
            
            if let data = FileManager.default.contents(atPath: imagePath.path) {
                
                return createImage(data: data, format: info.imageFormat)
            }
            
            #if DEBUG
            print("\(info.imageURL) : 파일이 존재하지만 데이터를 불러오지 못함")
            #endif
            
            return nil
            
        } else {
            
            // 파일이 존재하지 않는 경우
            #if DEBUG
            print("디스크에 파일이 존재하지 않음")
            #endif
            
            return nil
        }
    }
    
    func createImageFile(imageURL: URL, contents: Data) {
        
        guard let imagePath = createImagePath(url: imageURL.absoluteString) else {
            return
        }
        
        let imageDirectoryPath = imagePath.deletingLastPathComponent()
        
        if let numOfFiles = try? FileManager.default.contentsOfDirectory(atPath: imageDirectoryPath.path).count {
            
            // 최대 파일수를 초과한 경우 삭제(LRU), 하위 10개 파일 삭제
            if numOfFiles >= 50 {
                
                var dict = cacheInfoDict
                let sortedInfo = dict.sorted { (lhs, rhs) in
                    lhs.value.date < rhs.value.date
                }
                
                // 이미지 파일 삭제
                sortedInfo[0..<10].forEach { (key, value) in
                    dict.removeValue(forKey: key)
                    if let path = createImagePath(url: value.url) {
                        do {
                            try FileManager.default.removeItem(at: path)
                        } catch {
                            #if DEBUG
                            print("\(imageURL) 이미지 삭제 실패")
                            #endif
                        }
                    }
                }
                
                // 이미지 캐싱정보 저장 (10개 삭제)
                setCacheInfoDict(dict: dict)
            }
        }
        
        // 이미지 파일 생성
        let fileCreationResult = FileManager.default.createFile(atPath: imagePath.path, contents: contents)
        
        #if DEBUG
        print("디스크에 이미지 생성 \(fileCreationResult ? "성공" : "실패")")
        #endif
    }
    
    func createImage(data: Data, format: ImageFormat) -> UIImage? {
        var image: UIImage?
        if format == .webp {
            image = SDImageWebPCoder.shared.decodedImage(with: data)
        } else {
            image = UIImage(data: data)
        }
        
        if let image {
            
            return image
        }
        return nil
        #if DEBUG
        print("이미지 다운로드 싪패")
        #endif
    }
}
